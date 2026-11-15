{ src: GUESS 0529:66B3 (the player falls one step: JumpUpTop counts up to 19 and picks the step from JumpUp;
  a solid cell under the feet, or past step 10 a FlagB ledge, lands him on the 16-pixel row; the camera
  follows down to $B8; then the falling or standing pose by facing) }
{$F+}
procedure Fall;
begin
  Inc(JumpUpTop);
  if JumpUpTop > 19 then
    JumpUpTop := 19;
  Falling := 1;
  Inc(Slots[1].Y, JumpUp[JumpUpTop]);
  if (Map[(Slots[1].X + 3) shr 4 + 1, Slots[1].Y shr 4 + 2].Solid <> 0)
    or (Map[(Slots[1].X + 12) shr 4 + 1, Slots[1].Y shr 4 + 2].Solid <> 0) then
  begin
    Inc(Landings);
    Slots[1].Y := Slots[1].Y and $FFF0;
    Falling := 0;
  end;
  if JumpUpTop > 10 then
    if (Map[(Slots[1].X + 3) shr 4 + 1, (Slots[1].Y + 16) shr 4 + 1].FlagB <> 0)
      or (Map[(Slots[1].X + 12) shr 4 + 1, (Slots[1].Y + 16) shr 4 + 1].FlagB <> 0) then
      if Slots[1].Y < 5 then
      begin
        Inc(Landings);
        Slots[1].Y := Slots[1].Y and $FFF0;
        Falling := 0;
      end
      else if (Map[(Slots[1].X + 3) shr 4 + 1, (Slots[1].Y + 7) shr 4 + 1].FlagB = 0)
        and (Map[(Slots[1].X + 12) shr 4 + 1, (Slots[1].Y + 7) shr 4 + 1].FlagB = 0) then
      begin
        Inc(Landings);
        Slots[1].Y := Slots[1].Y and $FFF0;
        Falling := 0;
      end;
  if CamY + $78 < Slots[1].Y then
    if JumpUp[JumpUpTop] + CamY < $B8 then
      Inc(CamY, JumpUp[JumpUpTop])
    else
      CamY := $B8;
  if Falling <> 0 then
  begin
    if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) or (Slots[1].Sprite = $D) then
      Slots[1].Sprite := $D
    else
      Slots[1].Sprite := $E;
  end
  else if Slots[1].Sprite = $D then
  begin
    if RightHeld <> 0 then
      Slots[1].Sprite := 1
    else
      Slots[1].Sprite := 9;
  end
  else if Slots[1].Sprite = $E then
  begin
    if LeftHeld <> 0 then
      Slots[1].Sprite := 5
    else
      Slots[1].Sprite := $A;
  end;
end;
{$F-}
