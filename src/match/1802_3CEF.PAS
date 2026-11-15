{ src: SAM1RE 1802:3CEF (../SAM physics.md: restores the game state from the store DS:6D3E) }
{ to: 3DA2 }
{ interface }
procedure RestoreState;
var
  I: Integer;
begin
  Slots[1].X := State.X;
  Slots[1].Y := State.Y;
  Score := State.Score;
  W69C4 := State.W08;
  Ammo := State.Ammo;
  Gun := State.Gun;
  for I := 1 to 20 do
    Bullets[I] := State.Bullets[I];
  SpeedBonus := State.W22;
  SpeedTimer := State.W24;
  Confused := State.B26;
  ConfuseTimer := State.W27;
  UnconfuseMsg := State.B29;
  SlowWalk := State.B2A;
  SlowTimer := State.W2B;
  W69D8 := State.W2D;
  W69DC := State.W2F;
  MapSite := State.MapSite;
  for I := 1 to 20 do
    SiteDone[I] := State.SiteDone[I];
  AmmoCheat := State.B47;
end;
