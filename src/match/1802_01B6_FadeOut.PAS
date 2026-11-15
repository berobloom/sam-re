{ src: SAM1RE 1802:01B6 (palette registers 0..15 to black, Delay(D) before each) }
{ interface }
procedure FadeOut(D: Integer);
var
  I: Integer;
begin
  for I := 0 to 15 do
  begin
    Delay(D);
    SetPalReg(I, 0);
  end;
end;
