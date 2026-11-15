{ src: SAM1RE 1802:3C3C (../SAM physics.md: saves the game state into the store DS:6D3E) }
{ interface }
{ keep: SaveState; }
procedure SaveState;
var
  I: Integer;
begin
  State.X := Slots[1].X;
  State.Y := Slots[1].Y;
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
  State.B47 := AmmoCheat;
end;
