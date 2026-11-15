{ src: GUESS 0529:6A0E (the player's jump step: falls unless jumping or B6EE8; a jump starts on the jump key
  (B6EF3) or the joystick's jump button, when the two cells above the head are clear: pose, sound 1;
  JumpUpTop then climbs to 10 through JumpUp, the camera following up to 0, a blocked step ends it) }
{ to: 6B8E }
{ interface }
{ keep: Jump; }
{$F+}
procedure Jump;
begin
  if (Jumping = 0) and (B6EE8 = 0) then
    Fall;
  if (KeysOff = 0) and (Jumping = 0) and (Falling = 0) and ((JumpHeld <> 0) or (JumpButton and JoyOn))
    and (Map[(Slots[1].X + 3) shr 4 + 1, (Slots[1].Y - 3) shr 4 + 1].Solid = 0)
    and (Map[(Slots[1].X + 12) shr 4 + 1, (Slots[1].Y - 3) shr 4 + 1].Solid = 0) then
  begin
    if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) or (Slots[1].Sprite = $D) then
      Slots[1].Sprite := $D
    else
      Slots[1].Sprite := $E;
    PlaySound(1);
    Jumping := 1;
    B6EE8 := 0;
    JumpUpTop := 0;
  end;
  if Jumping <> 0 then
  begin
    Inc(JumpUpTop);
    if JumpUpTop = 10 then
    begin
      Jumping := 0;
      JumpUpTop := 9;
    end;
    if JumpUpTop < 17 then
      if CanMove(0, -JumpUp[JumpUpTop]) then
      begin
        if (CamY > 0) and (CamY + $50 > Slots[1].Y) then
        begin
          Dec(CamY, JumpUp[JumpUpTop]);
          if CamY < 0 then
            CamY := 0;
        end;
        Dec(Slots[1].Y, JumpUp[JumpUpTop]);
      end
      else
      begin
        JumpUpTop := 9;
        Jumping := 0;
      end;
  end;
end;
{$F-}
