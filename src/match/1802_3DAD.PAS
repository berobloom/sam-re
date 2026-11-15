{ src: GUESS 1802:3DAD (like SaveState, with the position rounded to 16 (+8, and $FFF0), then the
  store written to SAM1-<N>.SAV; called from the menus in this unit) }
{ from: 3DA2 }
{ to: 3EF5 }
{ interface }
{ keep: SaveGame(1); }
{$I-}
procedure SaveGame(N: Integer);
var
  F: file of TState;
  I: Integer;
  S: String;
begin
  State.X := (Slots[1].X + 8) and $FFF0;
  State.Y := (Slots[1].Y + 8) and $FFF0;
  State.Score := Score;
  State.W08 := W69C4;
  State.Ammo := Ammo;
  State.Gun := Gun;
  for I := 1 to 20 do
    State.Bullets[I] := Bullets[I];
  State.W22 := SpeedBonus;
  State.W24 := SpeedTimer;
  State.B26 := Confused;
  State.W27 := ConfuseTimer;
  State.B29 := UnconfuseMsg;
  State.B2A := SlowWalk;
  State.W2B := SlowTimer;
  State.W2D := W69D8;
  State.W2F := W69DC;
  State.MapSite := MapSite;
  for I := 1 to 20 do
    State.SiteDone[I] := SiteDone[I];
  State.B47 := B6A02;
  Str(N:1, S);
  Assign(F, 'SAM1-' + S + '.SAV');
  Rewrite(F);
  Write(F, State);
  Close(F);
end;
{$I+}
