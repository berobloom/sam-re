{ src: GUESS 25E6:0097 (fills rows Y1..Y2, columns X1..X2 (at most 80) with blanks in Fg/Bg) }
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
