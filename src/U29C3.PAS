unit U29C3;
{$S-,D+,L+}
interface
{ 29C3 data, DS:7114..71B7 }
var
  V7114: array[0..$51] of Byte; { @7114 }
  Copyright: String[80]; { @7166 }
procedure OBJ29C3;
procedure SetGraphMode(Sel: Integer);
procedure SetBiosMode(Mode: Integer);
function SetStride(N: Integer): Integer;
procedure SetViewStart(X, Y: Integer);
procedure SetViewStartAlt(X, Y: Integer);
procedure SetSplit(Line: Integer);
procedure SetSplitVGA(Line: Integer);
procedure SetBorder(Color: Integer);
procedure SetPalReg(Reg, Color: Integer);
procedure DrawTile(var Src; X, Y: Integer);
procedure DrawCellM(var Src; X, Y: Integer);
procedure SetColor(C: Integer);
procedure ClearRows(Base, Count, Row, Rows: Integer);
procedure GetImage(var Buf; X1, Y1, X2, Y2: Integer);
procedure PutImage(var Buf; X, Y: Integer);
procedure DrawTileB(var Src; X, Y: Integer);
procedure DrawCellX(var Src; X, Y: Integer);
procedure DrawSprite(var Src; X, Y: Integer);
procedure DrawTileO(var Src; X, Y: Integer);
procedure DrawCell(var Src; X, Y: Integer);
procedure CopySheet(X, Y, Slot: Integer);
procedure CopyScreen(SrcX, SrcY, DstX, DstY: Integer);
procedure CopyPage;
implementation
{$L OBJ29C3.OBJ}
procedure OBJ29C3; external;
procedure SetGraphMode; external;
procedure SetBiosMode; external;
function SetStride; external;
procedure SetViewStart; external;
procedure SetViewStartAlt; external;
procedure SetSplit; external;
procedure SetSplitVGA; external;
procedure SetBorder; external;
procedure SetPalReg; external;
procedure DrawTile; external;
procedure DrawCellM; external;
procedure SetColor; external;
procedure ClearRows; external;
procedure GetImage; external;
procedure PutImage; external;
procedure DrawTileB; external;
procedure DrawCellX; external;
procedure DrawSprite; external;
{$F+} procedure GetRomFonts; external; {$F-}
{$F+} procedure SelectFont(Small: Integer); external; {$F-}
procedure DrawTileO; external;
procedure DrawCell; external;
procedure CopySheet; external;
procedure CopyScreen; external;
procedure CopyPage; external;
begin
{ src: 29C3:0070, the unit init (SAM1RE: sets the video mode; copies the notice to DS:7166) }
{ from: 0000 }
{ init }
  SetGraphMode(1);
  GetRomFonts;
  SelectFont(0);
  SetBiosMode($10);
  SetColor($F);
  Copyright := 'Copyright 1991 Peder Jungck';
  Copyright := '1019 W Lovers Lane         ';
  Copyright := 'Arlington, Texas  76013    ';
  Copyright := '(817) 795-8903             ';
end.
