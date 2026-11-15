unit U25E6;
{$S-,D+,L+}
interface
{ 25E6 data, DS:21FC..2205 }
var
  VideoSeg: Word; { @21FC }
  SnowWait: Boolean; { @21FE; FastWrite waits for retrace per character (25E6:04CC): DetectAdapter = 1, CGA }
  L2200: LongInt; { @2200 }
  BiosMode: Integer; { @2204; BIOS mode at the adapter detect (SAM1RE code-map.md 4:054f) }
procedure Window(X1, Y1, X2, Y2, Fg, Bg, Frame: Integer);
procedure WriteCenter(Row, Fg, Bg: Integer; S: String);
procedure WriteVert(X, Y, Fg, Bg: Integer; S: String);
procedure OBJ25E6;
implementation
{$L OBJ25E6.OBJ}
{$F+} function MakeAttr(Fg, Bg: Byte): Byte; forward; {$F-}
{$F+} function Replicate(N: Byte; Ch: Char): String; forward; {$F-}
{$F+} procedure ClearArea(X1, Y1, X2, Y2, Fg, Bg: Integer); forward; {$F-}
{$F+} procedure Box(X1, Y1, X2, Y2, Fg, Bg, Frame: Integer); forward; {$F-}
{$F+} procedure InitVideo; forward; {$F-}
procedure OBJ25E6; external;
{$F+} procedure FastWrite(Col, Row, Attr: Byte; S: String); external; {$F-}
{$F+} function DetectAdapter: Byte; external; {$F-}
{$F+} function GetVideoMode: Byte; external; {$F-}
{ src: GUESS 25E6:0000 (text attribute from foreground and background) }
{ keep: - }
{$F+}
function MakeAttr(Fg, Bg: Byte): Byte;
begin
  MakeAttr := (Bg shl 4) or Fg;
end;
{$F-}
{ src: GUESS 25E6:0045 (N copies of Ch; N outside 1..80 counts as 1; the set constant is its literal) }
{ from: 0025 }
{ keep: - }
{$F+}
function Replicate(N: Byte; Ch: Char): String;
var
  Buf: String;
begin
  if not (N in [1..80]) then
    N := 1;
  FillChar(Buf, N + 1, Ch);
  Buf[0] := Chr(N);
  Replicate := Buf;
end;
{$F-}
{ src: GUESS 25E6:0097 (fills rows Y1..Y2, columns X1..X2 (at most 80) with blanks in Fg/Bg) }
{ keep: - }
{$F+}
procedure ClearArea(X1, Y1, X2, Y2, Fg, Bg: Integer);
var
  I: Integer;
  Attr: Byte;
begin
  if X2 > 80 then
    X2 := 80;
  Attr := MakeAttr(Fg, Bg);
  for I := Y1 to Y2 do
    FastWrite(X1, I, Attr, Replicate(X2 - X1 + 1, ' '));
end;
{$F-}
{ src: GUESS 25E6:0101 (a frame. Frame 0 blank, 1 single, 2 double, 3 double sides,
  4 double top; else every part is Chr(Frame)) }
{ keep: - }
{$F+}
procedure Box(X1, Y1, X2, Y2, Fg, Bg, Frame: Integer);
var
  I: Integer;
  TL, TR, BL, BR, H, V: Char;
  Attr: Byte;
begin
  case Frame of
    0: begin
         TL := ' ';
         TR := ' ';
         BL := ' ';
         BR := ' ';
         H := ' ';
         V := ' ';
       end;
    1: begin
         TL := #$DA;
         TR := #$BF;
         BL := #$C0;
         BR := #$D9;
         H := #$C4;
         V := #$B3;
       end;
    2: begin
         TL := #$C9;
         TR := #$BB;
         BL := #$C8;
         BR := #$BC;
         H := #$CD;
         V := #$BA;
       end;
    3: begin
         TL := #$D6;
         TR := #$B7;
         BL := #$D3;
         BR := #$BD;
         H := #$C4;
         V := #$BA;
       end;
    4: begin
         TL := #$D5;
         TR := #$B8;
         BL := #$D4;
         BR := #$BE;
         H := #$CD;
         V := #$B3;
       end;
  else
    begin
      TL := Chr(Frame);
      TR := Chr(Frame);
      BL := Chr(Frame);
      BR := Chr(Frame);
      H := Chr(Frame);
      V := Chr(Frame);
    end;
  end;
  Attr := MakeAttr(Fg, Bg);
  FastWrite(X1, Y1, Attr, TL);
  FastWrite(X1 + 1, Y1, Attr, Replicate(X2 - X1 - 1, H));
  FastWrite(X2, Y1, Attr, TR);
  for I := Y1 + 1 to Y2 - 1 do
  begin
    FastWrite(X1, I, Attr, V);
    FastWrite(X2, I, Attr, V);
  end;
  FastWrite(X1, Y2, Attr, BL);
  FastWrite(X1 + 1, Y2, Attr, Replicate(X2 - X1 - 1, H));
  FastWrite(X2, Y2, Attr, BR);
end;
{$F-}
{ src: GUESS 25E6:0309 (a framed window: Box, then its inside cleared) }
{ interface }
{ keep: Window(1, 1, 2, 2, 0, 0, 0); }
procedure Window(X1, Y1, X2, Y2, Fg, Bg, Frame: Integer);
begin
  Box(X1, Y1, X2, Y2, Fg, Bg, Frame);
  ClearArea(X1 + 1, Y1 + 1, X2 - 1, Y2 - 1, Fg, Bg);
end;
{ src: GUESS 25E6:0349 (S centred on an 80-column row) }
{ interface }
{ keep: WriteCenter(1, 0, 0, ''); }
procedure WriteCenter(Row, Fg, Bg: Integer; S: String);
begin
  FastWrite(40 - Length(S) div 2, Row, MakeAttr(Fg, Bg), S);
end;
{ src: GUESS 25E6:0399 (S downwards from column X, row Y, cut at row 26; T is assigned and never read) }
{ interface }
{ keep: WriteVert(1, 1, 0, 0, ''); }
procedure WriteVert(X, Y, Fg, Bg: Integer; S: String);
var
  I: Integer;
  T: String;
begin
  if Length(S) > 26 - Y then
    Delete(S, 27 - Y, 80);
  for I := 1 to Length(S) do
  begin
    T := S[I];
    FastWrite(X, Y - 1 + I, MakeAttr(Fg, Bg), S[I]);
  end;
end;
{ src: GUESS 25E6:045E (video segment from the BIOS mode: B000h for mode 7, else B800h) }
{ keep: - }
{$F+}
procedure InitVideo;
begin
  if GetVideoMode = 7 then
    VideoSeg := $B000
  else
    VideoSeg := $B800;
  SnowWait := DetectAdapter = 1;
end;
{$F-}
begin
{ src: 25E6:048C, the unit init }
{ init }
  InitVideo;
  L2200 := 200;
end.
