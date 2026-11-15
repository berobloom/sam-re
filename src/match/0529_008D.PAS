{ src: GUESS 0529:008D (OnScreen for the second slot table, Shots) }
{ interface }
{ keep: if ShotOnScreen(0, 1) then; }
function ShotOnScreen(Margin, N: Integer): Boolean;
begin
  if Shots[N].X < CamX - Margin then
    ShotOnScreen := False
  else if Shots[N].X > CamX + $140 + Margin then
    ShotOnScreen := False
  else if Shots[N].Y < CamY - Margin then
    ShotOnScreen := False
  else if Shots[N].Y > CamY + $B8 + Margin then
    ShotOnScreen := False
  else
    ShotOnScreen := True;
end;
