{ src: GUESS 0529:01C4 (a hit on the player when X, Y overlaps slot 1 (10 x 16): unless B6A1B or GOD mode, a
  life goes (B6A67 a short guard, sound 7), or with the last life sound $16 and the death arc starts) }
{ keep: HitPlayer(0, 0); }
{$F+}
procedure HitPlayer(X, Y: Integer);
begin
  if (((Slots[1].X >= X) and (X + 9 >= Slots[1].X)) or ((Slots[1].X + 9 >= X) and (Slots[1].X <= X)))
    and (((Slots[1].Y >= Y) and (Y + 15 >= Slots[1].Y)) or ((Slots[1].Y + 15 >= Y) and (Slots[1].Y <= Y)))
    and (B6A1B = 0) and (B6A19 = 0) then
    if Lives > 1 then
    begin
      if B6A67 = 0 then
      begin
        B6A67 := 1;
        B6A68 := 30;
        Dec(Lives);
        W6858 := -1;
        Slots[1].W00 := 5;
        PlaySound(7);
      end;
    end
    else if B6A67 = 0 then
    begin
      PlaySound($16);
      B6A1B := 1;
      ArcLen := $23;
    end;
end;
{$F-}
