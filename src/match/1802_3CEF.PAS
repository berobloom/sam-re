{ src: SAM1RE 1802:3CEF (../SAM physics.md: restores the game state from the store DS:6D3E) }
{ to: 3DA2 }
{ interface }
{ keep: RestoreState; }
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
  W69CA := State.W22;
  W69CC := State.W24;
  B69D3 := State.B26;
  W69D0 := State.W27;
  B69D2 := State.B29;
  B69D6 := State.B2A;
  W69D4 := State.W2B;
  W69D8 := State.W2D;
  W69DC := State.W2F;
  MapSite := State.MapSite;
  for I := 1 to 20 do
    SiteDone[I] := State.SiteDone[I];
  B6A02 := State.B47;
end;
