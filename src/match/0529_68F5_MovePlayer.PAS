{ src: GUESS 0529:68F5 (moves the player by the held directions: right/left (RightHeld/LeftHeld) WalkSpeed pixels after
  Ramp, down/up (DownHeld/UpHeld) 4 pixels, each only when CanMove allows it; the camera follows, clamped to
  0..$140 and 0..$B8; W06/W08 keep the old position) }
{ interface }
{$F+}
procedure MovePlayer;
begin
  Slots[1].PrevX := Slots[1].X;
  Slots[1].PrevY := Slots[1].Y;
  if RightHeld <> 0 then
  begin
    Ramp;
    if CanMove(WalkSpeed, 0) then
    begin
      if (CamX < $140) and (CamX + $AA < Slots[1].X) then
      begin
        Inc(CamX, WalkSpeed);
        if CamX > $140 then
          CamX := $140;
      end;
      Inc(Slots[1].X, WalkSpeed);
    end;
  end;
  if LeftHeld <> 0 then
  begin
    Ramp;
    if CanMove(-WalkSpeed, 0) then
    begin
      if (CamX > 0) and (CamX + $96 > Slots[1].X) then
      begin
        Dec(CamX, WalkSpeed);
        if CamX < 0 then
          CamX := 0;
      end;
      Dec(Slots[1].X, WalkSpeed);
    end;
  end;
  if DownHeld <> 0 then
    if CanMove(0, 4) then
    begin
      if (CamY < $B8) and (CamY + $50 < Slots[1].Y) then
        Inc(CamY, 4);
      Inc(Slots[1].Y, 4);
    end;
  if UpHeld <> 0 then
    if CanMove(0, -4) then
    begin
      if (CamY > 0) and (CamY + $50 > Slots[1].Y) then
      begin
        Dec(CamY, 4);
        if CamY < 0 then
          CamY := 0;
      end;
      Dec(Slots[1].Y, 4);
    end;
end;
{$F-}
