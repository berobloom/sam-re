{ src: GUESS 0529:65D9 (may the player move by DX, DY? the cells under the corners of slot 1's 16x16 box,
  inset 3 pixels left and right, must all be clear (Solid = 0); when blocked and Level > 1, W6844 := 0) }
{ keep: if CanMove(0, 0) then; }
{$F+}
function CanMove(DX, DY: Integer): Boolean;
var
  X1, Y1, X2, Y2: Integer;
begin
  X1 := (Slots[1].X + DX + 3) shr 4 + 1;
  X2 := (Slots[1].X + DX + 12) shr 4 + 1;
  Y1 := (Slots[1].Y + DY) shr 4 + 1;
  Y2 := (Slots[1].Y + DY + 15) shr 4 + 1;
  if (Map[X1, Y1].Solid <> 0) or (Map[X2, Y1].Solid <> 0) or (Map[X1, Y2].Solid <> 0)
    or (Map[X2, Y2].Solid <> 0) then
  begin
    CanMove := False;
    if Level > 1 then
      W6844 := 0;
  end
  else
    CanMove := True;
end;
{$F-}
