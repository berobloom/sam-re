{ src: GUESS 25E6:0309 (a framed window: Box, then its inside cleared) }
{ interface }
{ keep: Window(1, 1, 2, 2, 0, 0, 0); }
procedure Window(X1, Y1, X2, Y2, Fg, Bg, Frame: Integer);
begin
  Box(X1, Y1, X2, Y2, Fg, Bg, Frame);
  ClearArea(X1 + 1, Y1 + 1, X2 - 1, Y2 - 1, Fg, Bg);
end;
