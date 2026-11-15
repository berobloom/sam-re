{ src: SAM1RE 1802:3F10 (../SAM menus.md: loads SAM1-<N>.SAV into the state store and restores from it, as
  RestoreState does; Reset runs twice; a missing file shows 'File Not Found!' and returns False) }
{ from: 3EF5 }
{ to: 409B }
{ interface }
{ keep: if LoadGame(0) then; }
{$I-}
{$F+}
function LoadGame(N: Integer): Boolean;
var
  F: file of TState;
  I: Integer;
  S: String;
  Ok: Boolean;
begin
  Str(N:1, S);
  Assign(F, 'SAM1-' + S + '.SAV');
  Reset(F);
  Ok := IOResult = 0;
  Reset(F);
  Ok := IOResult = 0;
  if Ok then
  begin
    Read(F, State);
    Close(F);
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
    B6A02 := State.B47;
    LoadGame := True;
  end
  else
  begin
    ShowMessage('File Not Found!');
    LoadGame := False;
  end;
end;
{$F-}
{$I+}
