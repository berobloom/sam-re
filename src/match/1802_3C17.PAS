{ src: GUESS 1802:3C17 (palette registers 0..15 to black at once) }
{ interface }
{ keep: Blackout; }
procedure Blackout;
var
  I: Integer;
begin
  for I := 0 to 15 do
    SetPalReg(I, 0);
end;
