{ src: GUESS 0529:0000 (slot N within the view (320 x 184 from CamX, CamY) widened by Margin on each side) }
{ interface }
{ keep: if OnScreen(0, 1) then; }
function OnScreen(Margin, N: Integer): Boolean;
begin
  if Slots[N].X < CamX - Margin then
    OnScreen := False
  else if Slots[N].X > CamX + $140 + Margin then
    OnScreen := False
  else if Slots[N].Y < CamY - Margin then
    OnScreen := False
  else if Slots[N].Y > CamY + $B8 + Margin then
    OnScreen := False
  else
    OnScreen := True;
end;
