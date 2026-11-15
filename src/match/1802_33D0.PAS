{ src: SAM1RE 1802:33D0 (../SAM menus: the sam1.apo logo with sound $15, then a key or about 5 s on the
  W6852 tick counter). Only R of the four locals is used. }
{ from: 33C7 }
{ to: 3477 }
{ interface }
{ keep: ShowLogo; }
procedure ShowLogo;
var
  V1, V2, R, V4: Integer;
begin
  FadeOut(0);
  R := Genus000F(2);
  R := Genus0047(1);
  R := SetStride($28);
  CamX := 0;
  CamY := 0;
  W6862 := 0;
  PageY := 0;
  R := ShowPicture('sam1.apo', 1, 0, 0);
  FadeIn($14);
  PlaySound($15);
  MemW[0:$41C] := MemW[0:$41A];
  Ticks := 0;
  repeat
  until KeyPressed or (Ticks > $2D0);
  Ticks := 0;
  FadeOut(0);
end;
