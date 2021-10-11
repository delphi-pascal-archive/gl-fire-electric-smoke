unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OpenGL, ExtCtrls;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  DC:HDC;
  hrc:HGLRC;

  ELECT:array[1..100,1..2]of GLFloat;
  px1,px2,py1,py2:GLFLoat;
  st:GLDOUBLE;
implementation

{$R *.dfm}

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
var
m,n:integer;
DST:GLFloat;
begin
randomize;
dc:=getdc(handle);
setdcpixelformat(dc);
hrc:=wglcreatecontext(dc);
wglmakecurrent(dc,hrc);
px1:=-9.999; py1:=0;
px2:=0.9; py1:=0;
DST:=0.2;
for n:=1 to 100 do
 begin
  Elect[n,1]:=px1+(n*dst);
  elect[n,2]:=0;
 end;
st:=0.1;
GLEnable(GL_BLEND);
glBlendFunc(GL_SRC_ALPHA, GL_ONE) ;
end;

function znak(VAR X):ShortInt;
begin
if GLDouble(X)<0 then result:=-1
 else
if GLDouble(X)>0 then result:=1
 else
result:=0;
end;

procedure Glow;
const
coef=pi/180*(360/6);
size=2.5;
begin
glscalef(size,size,size);
glbegin(GL_TRIANGLE_FAN);
//glcolor4f(1,1,1,0.8415);
glcolor4f(0.7,0.7,0.7,0.18);
glvertex2f(0,0);
glcolor4f(0,0,1,0.0);
glvertex2f(0,1);
glvertex2f(-0.866025403,0.5);
glvertex2f(-0.866025403,-0.5);
glvertex2f(0,-1);
glvertex2f(0.866025403,-0.5);
glvertex2f(0.866025403,0.5);
glvertex2f(0,1);
glend;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
m,n:integer;
c:GLFloat;
priority:single;
begin
glclear(GL_COLOR_BUFFER_BIT);
glloadidentity;
glscalef(0.1,0.1,0.1);
for n:=2 to 99 do
 begin
  if N<50 then
   priority:=0.01
    else
   priority:=-0.01;
  ELECT[n,2]:=elect[n-1,2]+(random-0.5)*0.5+priority;
 end;

gllinewidth(clientwidth*clientheight*0.000015);
glcolor3f(0.1,0.1,0.1);
glbegin(GL_LINE_STRIP);
for n:=1 to 100 do
 glvertex2f(ELECT[n,1],ELECT[n,2]);
glend;

glpushmatrix;
for n:=1 to 100 do
 begin
  glpopmatrix;
  glpushmatrix;
  gltranslatef(elect[n,1],elect[n,2],0);
  glow;
 end;
swapbuffers(dc);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
wglmakecurrent(0,0);
wgldeletecontext(hrc);
releasedc(handle,dc);
deletedc(dc);
end;

procedure TForm1.FormResize(Sender: TObject);
begin
glviewport(0,0,clientwidth,clientheight);
end;

end.
 