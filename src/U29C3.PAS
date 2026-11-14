unit U29C3;
{$S-,D+,L+}
interface
{ 29C3 data, DS:7114..71B7 }
var
  V7114: array[0..$51] of Byte; { @7114 }
  Copyright: String[80]; { @7166 }
procedure OBJ29C3;
procedure SetViewStart(X, Y: Integer);
procedure SetViewStartAlt(X, Y: Integer);
procedure SetPalReg(Reg, Color: Integer);
procedure SetColor(C: Integer);
procedure ClearRows(Base, Count, Row, Rows: Integer);
procedure CopyPage;
implementation
{$L OBJ29C3.OBJ}
procedure OBJ29C3; external;
{$F+} procedure SetGraphMode(Sel: Integer); external; {$F-}
{$F+} procedure SetBiosMode(Mode: Integer); external; {$F-}
procedure SetViewStart; external;
procedure SetViewStartAlt; external;
procedure SetPalReg; external;
procedure SetColor; external;
procedure ClearRows; external;
{$F+} procedure GetRomFonts; external; {$F-}
{$F+} procedure Proc2981(X: Integer); external; {$F-}
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
