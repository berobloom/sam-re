{ src: GUESS 0529:68F5 (moves the player by the held directions: right/left (B6EF1/B6EF0) W6846 pixels after
  Ramp, down/up (B6EEA/B6EE9) 4 pixels, each only when CanMove allows it; the camera follows, clamped to
  0..$140 and 0..$B8; W06/W08 keep the old position) }
{ keep: MovePlayer; }
{$F+}
procedure MovePlayer;
begin
  Slots[1].W06 := Slots[1].X;
  Slots[1].W08 := Slots[1].Y;
  if B6EF1 <> 0 then
  begin
    Ramp;
    if CanMove(W6846, 0) then
    begin
      if (CamX < $140) and (CamX + $AA < Slots[1].X) then
      begin
        Inc(CamX, W6846);
        if CamX > $140 then
          CamX := $140;
      end;
      Inc(Slots[1].X, W6846);
    end;
  end;
  if B6EF0 <> 0 then
  begin
    Ramp;
    if CanMove(-W6846, 0) then
    begin
      if (CamX > 0) and (CamX + $96 > Slots[1].X) then
      begin
        Dec(CamX, W6846);
        if CamX < 0 then
          CamX := 0;
      end;
      Dec(Slots[1].X, W6846);
    end;
  end;
  if B6EEA <> 0 then
    if CanMove(0, 4) then
    begin
      if (CamY < $B8) and (CamY + $50 < Slots[1].Y) then
        Inc(CamY, 4);
      Inc(Slots[1].Y, 4);
    end;
  if B6EE9 <> 0 then
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
