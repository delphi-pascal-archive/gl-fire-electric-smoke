unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OpenGL, ExtCtrls,NewtonImport,NewtonImport_JointLibrary,
  StdCtrls;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TVector3f = record
   X,Y,Z : Single;
  end;
 TMatrix4f = array[0..3, 0..3] of Single;

 TNewtonBox = class
   NewtonBody : PNewtonBody;  // Pointer to the rigid body created by newton
   Matrix     : TMatrix4f;    // Used to retrieve the matrix from newton
   Size       : TVector3f;    // Stored for rendering the correct size
   constructor Create(pSize, pPosition : TVector3f; pMass : Single);
   procedure Render;
  end;

var
  Form1: TForm1;
 DC:HDC;
 hrc:HGLRC;
  Rotation      : Single;
 NewtonWorld   : PNewtonWorld;
 NewtonBox     : array of TNewtonBox;
 TimeLastFrame : Cardinal;
const
 IdentityMatrix : TMatrix4f = ((1, 0, 0, 0), (0, 1, 0, 0), (0, 0, 1, 0), (0, 0, 0, 1));
implementation

{$R *.dfm}

function V3(pX, pY, pZ : Single) : TVector3f;
begin
Result.x := pX;
Result.y := pY;
Result.z := pZ;
end;

procedure ForceAndTorqueCallback(const Body : PNewtonBody; TimeStep : Float; ThreadIndex : int); cdecl;
var
 Mass    : Single;
 Inertia : TVector3f;
 Force   : TVector3f;
begin
NewtonBodyGetMassMatrix(Body, @Mass, @Inertia.x, @Inertia.y, @Inertia.z);
Force := V3(0, -9.8 * Mass, 0);
NewtonBodyAddForce(Body, @Force.x);
end;

procedure TNewtonBox.Render;
begin
// Get current matrix
NewtonBodyGetMatrix(NewtonBody, @Matrix[0,0]);
// Matrices from newton are luckily byte-compatible with matrices from newton,
// which means that we can directly pass them to the GL
glPushMatrix;
 glMultMatrixf(@Matrix[0,0]);
 // Scale to correct size
 glScalef(Size.x/2, Size.y/2, Size.z/2);
 // Render the box using quads
 glBegin(GL_QUADS);
  glNormal3f(0, 0, 1);
   glVertex3f( -1, -1,  1);
   glVertex3f(  1, -1,  1);
   glVertex3f(  1,  1,  1);
   glVertex3f( -1,  1,  1);
  glNormal3f(0, 0, -1);
   glVertex3f( -1, -1, -1);
   glVertex3f( -1,  1, -1);
   glVertex3f(  1,  1, -1);
   glVertex3f(  1, -1, -1);
  glNormal3f(0, 1, 0);
   glVertex3f( -1,  1, -1);
   glVertex3f( -1,  1,  1);
   glVertex3f(  1,  1,  1);
   glVertex3f(  1,  1, -1);
  glNormal3f(0, -1, 0);
   glVertex3f( -1, -1, -1);
   glVertex3f(  1, -1, -1);
   glVertex3f(  1, -1,  1);
   glVertex3f( -1, -1,  1);
  glNormal3f(1, 0, 0);
   glVertex3f(  1, -1, -1);
   glVertex3f(  1,  1, -1);
   glVertex3f(  1,  1,  1);
   glVertex3f(  1, -1,  1);
  glNormal3f(-1, 0, 0);
   glVertex3f( -1, -1, -1);
   glVertex3f( -1, -1,  1);
   glVertex3f( -1,  1,  1);
   glVertex3f( -1,  1, -1);
 glEnd;
glPopMatrix;
end;

constructor TNewtonBox.Create(pSize, pPosition : TVector3f; pMass : Single);
var
 Inertia   : TVector3f;
 Collision : PNewtonCollision;
 TmpMatrix : TMatrix4f;
begin
Size := pSize;
// Create a box collision
Collision  := NewtonCreateBox(NewtonWorld, pSize.x, pSize.y, pSize.z, 0, nil);
// Create the rigid body
NewtonBody := NewtonCreateBody(NewtonWorld, Collision, @IdentityMatrix[0,0]);
// Remove the collider, we don't need it anymore
NewtonReleaseCollision(NewtonWorld, Collision);
// Now we calculate the moment of intertia for this box. Note that a correct
// moment of inertia is CRUCIAL for the CORRECT PHYSICAL BEHAVIOUR of a body,
// so we use an special equation for calculating it
Inertia.x := pMass * (pSize.y * pSize.y + pSize.z * pSize.z) / 12;
Inertia.y := pMass * (pSize.x * pSize.x + pSize.z * pSize.z) / 12;
Inertia.z := pMass * (pSize.x * pSize.x + pSize.y * pSize.y) / 12;
// Set the bodies mass and moment of inertia
NewtonBodySetMassMatrix(NewtonBody, pMass, Inertia.x, Inertia.y, Inertia.z);
// Now set the position of the body's matrix
NewtonBodyGetMatrix(NewtonBody, @Matrix[0,0]);
Matrix[3,0] := pPosition.x;
Matrix[3,1] := pPosition.y;
Matrix[3,2] := pPosition.z;
NewtonBodySetMatrix(NewtonBody, @Matrix[0,0]);
// Finally set the callback in which the forces on this body will be applied
NewtonBodySetForceAndTorqueCallBack(NewtonBody,ForceAndTorqueCallBack);
end;

procedure InitNewton;
var
 TmpV : TVector3f;
 i    : Integer;
begin
Randomize;
NewtonWorld := NewtonCreate(nil, nil);
// Create a static floor first
SetLength(NewtonBox, 1);
NewtonBox[0] := TNewtonBox.Create(V3(10,0.5,10), V3(0,-2,0), 0);
// Now create some randomly positioned boxes at different heights
for i := 0 to 9 do
 begin
 SetLength(NewtonBox, Length(NewtonBox)+1);
 NewtonBox[High(NewtonBox)] := TNewtonBox.Create(V3(1,1,1), V3(0,3+i*1.1,0), 10);
 // Give the body some random spin (aka "omega")
 TmpV := V3(Random(5), Random(5), Random(5));
 NewtonBodySetOmega(NewtonBox[High(NewtonBox)].NewtonBody, @TmpV.x);
 end;
end;

procedure SetDCPixelFormat (hdc : HDC);
var 
pfd : TPixelFormatDescriptor; 
nPixelFormat : Integer; 
begin 
FillChar (pfd, SizeOf (pfd), 0); 
pfd.dwFlags :=PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
nPixelFormat :=ChoosePixelFormat (hdc, @pfd);
SetPixelFormat(hdc, nPixelFormat, @pfd);
end; 

procedure TForm1.FormCreate(Sender: TObject);
begin
DC := GetDC (Handle);
SetDCPixelFormat(DC); 
hrc := wglCreateContext(DC); 
wglMakeCurrent(DC, hrc);
glenable(GL_DEPTH_TEST);
glenable(GL_LIGHTING);
glenable(GL_LIGHT0);
glEnable(GL_NORMALIZE);
glClearColor (0.0, 0.0, 0.75, 1.0);
glmatrixmode(GL_PROJECTION);
glloadidentity;
gluperspective(30,clientwidth/clientheight,0.001,10000);
glmatrixmode(GL_MODELVIEW);
glloadidentity;
glulookat(1,1,1,0,0,0,0,0,1);
InitNewton;
//timer1.Enabled:=true;
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
i:integer;
begin
wglMakeCurrent(0, 0);
wglDeleteContext(hrc); 
ReleaseDC (Handle, DC);
DeleteDC (DC);
if Length(NewtonBox) > 0 then
 for i := 0 to High(NewtonBox) do
  NewtonBox[i].Free;
NewtonDestroy (NewtonWorld);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
i:integer;
begin
glclear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
glmatrixmode(GL_MODELVIEW);
glloadidentity;
glTranslatef(0, 0, -15);
glRotatef(15, 1, 0, 0);
glRotatef(45, 0, 1, 0);
//glulookat(10,10,10,0,0,0,0,0,1);
if Length(NewtonBox) > 0 then
 for i := 0 to High(NewtonBox) do
  NewtonBox[i].Render;
SwapBuffers(DC);
 NewtonUpdate(NewtonWorld, 1);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
application.Terminate;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
C:cardinal;
i:integer;
begin
c:=0;
while true do
begin
inc(c);
if c=100 then
application.ProcessMessages;
glclear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
glmatrixmode(GL_MODELVIEW);
glloadidentity;
glTranslatef(0, 0, -15);
glRotatef(15, 1, 0, 0);
glRotatef(45, 0, 1, 0);
//glulookat(10,10,10,0,0,0,0,0,1);
if Length(NewtonBox) > 0 then
 for i := 0 to High(NewtonBox) do
  NewtonBox[i].Render;
SwapBuffers(DC);
 NewtonUpdate(NewtonWorld, 1);
end;
end;

end.
 