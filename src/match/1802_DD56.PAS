{ src: SAM1RE 1802:DD56 (../SAM: the ending: SAM1.END, 30 x 50 ms with the keyboard buffer flushed, the
  ordering pages, a key, the high-score check, then back to the title) }
{ from: DD4D }
{ interface }
{ keep: ShowEnding; }
procedure ShowEnding;
var
  I, R: Integer;
begin
  SetGraphMode(0);
  R := Genus000F(2);
  R := Genus0047(1);
  R := SetStride($28);
  CamX := 0;
  CamY := 0;
  W6862 := 0;
  PageY := 0;
  R := ShowPicture('SAM1.END', 1, 0, 0);
  FadeIn(0);
  for I := 1 to 30 do
  begin
    Delay(50);
    MemW[0:$41C] := MemW[0:$41A];
  end;
  OrderInfo;
  MemW[0:$41C] := MemW[0:$41A];
  repeat
  until KeyPressed;
  MemW[0:$41C] := MemW[0:$41A];
  CheckHighScore;
  B6EED := 1;
  B6D8C := 0;
  B6EEC := 0;
end;
