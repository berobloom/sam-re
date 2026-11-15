{ src: SAM1RE 1802:3489 (../SAM menus: the title: sam1.crd and sam1.ttl, the view scrolls down and up between
  them; W684A set (by the key handler) opens the menu; ends on B, R or Q with sound 12) }
{ from: 3477 }
{ to: 3694 }
{ interface }
{ keep: TitleLoop; }
procedure TitleLoop;
var
  Dir, Y, R: Integer;
  Key: Char;
begin
  FadeOut(0);
  R := Genus000F(2);
  R := Genus0047(1);
  R := SetStride($28);
  CamX := 0;
  CamY := 0;
  W6862 := 0;
  PageY := 0;
  R := ShowPicture('sam1.crd', 1, 0, 0);
  Proc2ECF(0, 0, 0, 200);
  R := ShowPicture('sam1.ttl', 1, 0, 0);
  FadeIn($14);
  Dir := 1;
  Y := 0;
  W684A := 0;
  Key := ' ';
  W6852 := 0;
  repeat
    if W684A > 0 then
    begin
      Key := MainMenu;
      W684A := 0;
    end
    else
      W684A := 0;
  until (W6852 > $90) or (Key <> ' ');
  if (Key <> 'B') and (Key <> 'R') and (Key <> 'Q') then
  repeat
    if (Key <> 'B') and (Key <> 'R') and (Key <> 'Q') then
      Key := ' ';
    if Dir = 1 then
    begin
      if W70EC = 0 then
        SetViewStart(0, Y)
      else
        SetViewStartAlt(0, Y);
      W6862 := Y;
    end
    else
    begin
      if W70EC = 0 then
        SetViewStart(0, 200 - Y)
      else
        SetViewStartAlt(0, 200 - Y);
      W6862 := 200 - Y;
    end;
    Inc(Y);
    if Y > 200 then
    begin
      Y := 0;
      Dir := -Dir;
      W6852 := 0;
      repeat
        if W684A > 0 then
        begin
          Key := MainMenu;
          W684A := 0;
          W6852 := 0;
        end;
      until (W6852 > $1B0) or (Key <> ' ');
    end;
    B6EE9 := 0;
    B6EEA := 0;
    B6EF0 := 0;
    B6EF1 := 0;
    B6EEB := 0;
    MemW[0:$41C] := MemW[0:$41A];
    if W684A <> 0 then
    begin
      Key := MainMenu;
      W6852 := 0;
      W684A := 0;
    end;
  until (Key = 'B') or (Key = 'R') or (Key = 'Q');
  PlaySound(12);
  FadeOut(0);
end;
