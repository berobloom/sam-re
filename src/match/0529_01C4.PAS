{ src: GUESS 0529:01C4 (a hit on the player when X, Y overlaps slot 1 (10 x 16): unless HitLock or GOD mode, a
  life goes (HitRecover a short guard, sound 7), or with the last life sound $16 and the death arc starts) }
{$F+}
procedure HitPlayer(X, Y: Integer);
begin
  if (((Slots[1].X >= X) and (X + 9 >= Slots[1].X)) or ((Slots[1].X + 9 >= X) and (Slots[1].X <= X)))
    and (((Slots[1].Y >= Y) and (Y + 15 >= Slots[1].Y)) or ((Slots[1].Y + 15 >= Y) and (Slots[1].Y <= Y)))
    and (HitLock = 0) and (Invulnerable = 0) then
    if Lives > 1 then
    begin
      if HitRecover = 0 then
      begin
        HitRecover := 1;
        HitTimer := 30;
        Dec(Lives);
        StatusCamX := -1;
        Slots[1].MaskFrames := 5;
        PlaySound(7);
      end;
    end
    else if HitRecover = 0 then
    begin
      PlaySound($16);
      HitLock := 1;
      ArcLen := $23;
    end;
end;
{$F-}
