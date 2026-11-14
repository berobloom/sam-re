{ src: SAM1RE 1802:005F (palette registers 0..7 -> 0..7, 8..15 -> $10..$17, Delay(D) after each) }
{ interface }
{ keep: FadeIn(0); }
procedure FadeIn(D: Integer);
begin
  SetPalReg(0, 0);
  Delay(D);
  SetPalReg(1, 1);
  Delay(D);
  SetPalReg(2, 2);
  Delay(D);
  SetPalReg(3, 3);
  Delay(D);
  SetPalReg(4, 4);
  Delay(D);
  SetPalReg(5, 5);
  Delay(D);
  SetPalReg(6, 6);
  Delay(D);
  SetPalReg(7, 7);
  Delay(D);
  SetPalReg(8, $10);
  Delay(D);
  SetPalReg(9, $11);
  Delay(D);
  SetPalReg(10, $12);
  Delay(D);
  SetPalReg(11, $13);
  Delay(D);
  SetPalReg(12, $14);
  Delay(D);
  SetPalReg(13, $15);
  Delay(D);
  SetPalReg(14, $16);
  Delay(D);
  SetPalReg(15, $17);
  Delay(D);
end;
