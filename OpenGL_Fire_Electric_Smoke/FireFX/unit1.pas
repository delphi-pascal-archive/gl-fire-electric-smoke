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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  DC:HDC;
  hrc:HGLRC;

  GenTimer:real=0;
  GTmrCount:single=0;

  pnow:byte=0;

  Fire:array[1..100]of record
  x,y:glfloat;
  dx,dy:glfloat;
  life:word;
  state:word;
  end;
implementation

{$R *.dfm}

const
Cols:array[1..4,1..4]of glfloat=((1,1,0,1),(1,0,0,0),(0.1,0.1,0.1,1),(0,0,0,0));

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

glclearcolor(0,0,0,1);
gtmrcount:=5;

GLEnable(GL_BLEND);
glBlendFunc(GL_SRC_ALPHA, GL_one) ;
end;

function znak(VAR X):ShortInt;
begin
if GLDouble(X)<0 then result:=-1
 else
if GLDouble(X)>0 then result:=1
 else
result:=0;
end;

procedure Glow(CR,CG,CB,CA,RR,RG,RB,RA,Size:GLFloat);
begin
glscalef(size+1,size+1,size+1);
glbegin(GL_TRIANGLE_FAN);
glcolor4f(cr,cg,cb,ca);
glvertex2f(0,0);
glcolor4f(rr,rg,rb,ra);
glvertex2f(0,1);
glvertex2f(-0.866025403,0.5);
glvertex2f(-0.866025403,-0.5);
glvertex2f(0,-1);
glvertex2f(0.866025403,-0.5);
glvertex2f(0.866025403,0.5);
glvertex2f(0,1);
glend;
end;

function DecBound(Dec,Min,Max:single):Single;
begin
if(dec>min)and(dec<max)then result:=dec;
if(dec<min)then result:=min;
if(dec>max)then result:=max;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
m,n,i:integer;
c:GLFloat;
begin
gentimer:=gentimer+1;
if gentimer>=gtmrcount then
if pnow<100 then
inc(pnow);
glclear(GL_COLOR_BUFFER_BIT);
glloadidentity;
glscalef(0.03,0.03,0.03);
for n:=1 to pnow do
begin
if(fire[n].life=0)or(fire[n].state>=fire[n].life)then
 with fire[n] do
 begin
  x:=0;
  y:=-32;
  dx:=random*0.5-0.25;
  dy:=0.55+random*0.3;
  life:=30+random(20);
  state:=0;
 end;
inc(fire[n].state);
fire[n].dy:=fire[n].dy*1.003;

fire[n].x:=fire[n].x+fire[n].dx;
fire[n].y:=fire[n].y+fire[n].dy;

glpopmatrix;
glpushmatrix;
gltranslatef(fire[n].x,fire[n].y,0);


{gllinewidth(1);
//stripes
glcolor3f(1,0.85,0.75);
glbegin(GL_LINES);
glvertex2f(0,0);
glvertex2f(-fire[n].dx,-fire[n].dy);
glend;}
//c:=(1-1/(fire[n].life/fire[n].state)*0.5);
if fire[n].life/fire[n].state<2 then
 i:=3 else i:=1;
glow(cols[i,1],cols[i,2],cols[i,3],cols[i,4],cols[i+1,1],cols[i+1,2],cols[i+1,3],cols[i+1,4],i*2);
//glow(c,c,1/(fire[n].life/fire[n].state)*0.5,c,c*2,0,0,0);
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

end.
 