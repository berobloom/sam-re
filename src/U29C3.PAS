unit U29C3;
{$S-,D+,L+}
interface
{ 29C3 data, DS:7114..71B7 }
var
  V7114: array[0..$51] of Byte; { @7114 }
  Copyright: String[80]; { @7166 }
procedure OBJ29C3;
procedure SetGraphMode(Sel: Integer);
function SetStride(N: Integer): Integer;
procedure SetViewStart(X, Y: Integer);
procedure SetViewStartAlt(X, Y: Integer);
procedure SetPalReg(Reg, Color: Integer);
procedure DrawTile(var Src; X, Y: Integer);
procedure DrawCellM(var Src; X, Y: Integer);
procedure SetColor(C: Integer);
procedure ClearRows(Base, Count, Row, Rows: Integer);
procedure GetImage(var Buf; X1, Y1, X2, Y2: Integer);
procedure PutImage(var Buf; X, Y: Integer);
procedure DrawCellX(var Src; X, Y: Integer);
procedure DrawCell(var Src; X, Y: Integer);
procedure Proc2ECF(A, B, C, D: Integer);
procedure CopyPage;
implementation
{$L OBJ29C3.OBJ}
procedure OBJ29C3; external;
procedure SetGraphMode; external;
{$F+} procedure SetBiosMode(Mode: Integer); external; {$F-}
function SetStride; external;
procedure SetViewStart; external;
procedure SetViewStartAlt; external;
procedure SetPalReg; external;
procedure DrawTile; external;
procedure DrawCellM; external;
procedure SetColor; external;
procedure ClearRows; external;
procedure GetImage; external;
procedure PutImage; external;
procedure DrawCellX; external;
{$F+} procedure GetRomFonts; external; {$F-}
{$F+} procedure Proc2981(X: Integer); external; {$F-}
procedure DrawCell; external;
procedure Proc2ECF; external;
procedure CopyPage; external;
begin
{ src: 29C3:0070, the unit init (SAM1RE: sets the video mode; copies the notice to DS:7166) }
{ from: 0000 }
{ init }
  SetGraphMode(1);
  GetRomFonts;
  Proc2981(0);
  SetBiosMode($10);
  SetColor($F);
  Copyright := 'Copyright 1991 Peder Jungck';
  Copyright := '1019 W Lovers Lane         ';
  Copyright := 'Arlington, Texas  76013    ';
  Copyright := '(817) 795-8903             ';
end.
