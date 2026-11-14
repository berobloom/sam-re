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
  State.W22 := W69CA;
  State.W24 := W69CC;
  State.B26 := B69D3;
  State.W27 := W69D0;
  State.B29 := B69D2;
  State.B2A := B69D6;
  State.W2B := W69D4;
  State.W2D := W69D8;
  State.W2F := W69DC;
  State.MapSite := MapSite;
  for I := 1 to 20 do
    State.SiteDone[I] := SiteDone[I];
  State.B47 := B6A02;
end;
