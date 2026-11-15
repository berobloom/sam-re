{ src: SAM1RE 0D9C:3A91 (../SAM level-load.md, objects.md: the actor spawner of row char S at cell X, Y (levels
  > 1): each actor char clears its cell to tile 2 and takes the next slot SlotCount, drawn on both pages, with
  its kind (W14), facing (W16, often Random) and timers) }
{ from: 3A59 }
{$F+}
procedure SpawnActor(X, Y: Integer; S: String; FO: Boolean);
begin
  if S = #174 then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[14]^.Tile[13], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[14]^.Tile[13], X shl 4, (Y shl 4) + $1A0);
    DrawTileB(Gfx[14]^.Tile[9], (X + 1) shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[14]^.Tile[9], (X + 1) shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $353;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    if Random(2) > 0 then
      Slots[SlotCount].DirX := 1
    else
      Slots[SlotCount].DirX := -1;
    Slots[SlotCount].DirY := 0;
    if Slots[SlotCount].DirX = 1 then
      Slots[SlotCount].Anim := 1
    else
      Slots[SlotCount].Anim := $29;
    Slots[SlotCount].Speed := 2;
    Slots[SlotCount].W0C := 0;
    Slots[SlotCount].W0E := 0;
    Slots[SlotCount].W10 := 3;
    Slots[SlotCount].Kind := $2A;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = '8' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[16]^.Tile[1], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[16]^.Tile[1], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $15F;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    if Random(2) > 0 then
      Slots[SlotCount].DirX := 1
    else
      Slots[SlotCount].DirX := -1;
    Slots[SlotCount].DirY := 0;
    if Slots[SlotCount].DirX = 1 then
      Slots[SlotCount].Anim := 1
    else
      Slots[SlotCount].Anim := $15;
    Slots[SlotCount].Speed := 1;
    Slots[SlotCount].W0C := 0;
    Slots[SlotCount].W0E := 0;
    Slots[SlotCount].Kind := 1;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = '9' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[16]^.Tile[9], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[16]^.Tile[9], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $167;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    if Random(2) > 0 then
      Slots[SlotCount].DirX := 1
    else
      Slots[SlotCount].DirX := -1;
    Slots[SlotCount].DirY := 0;
    if Slots[SlotCount].DirX = 1 then
      Slots[SlotCount].Anim := 1
    else
      Slots[SlotCount].Anim := $15;
    Slots[SlotCount].Speed := 1;
    Slots[SlotCount].W0C := 0;
    Slots[SlotCount].Kind := 2;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = '0' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[16]^.Tile[17], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[16]^.Tile[17], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $16F;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    if Random(2) > 0 then
      Slots[SlotCount].DirX := 1
    else
      Slots[SlotCount].DirX := -1;
    Slots[SlotCount].DirY := 0;
    if Slots[SlotCount].DirX = 1 then
      Slots[SlotCount].Anim := 1
    else
      Slots[SlotCount].Anim := $15;
    Slots[SlotCount].Speed := 2;
    Slots[SlotCount].W0C := 0;
    Slots[SlotCount].Kind := 3;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = 'g' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[16]^.Tile[25], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[16]^.Tile[25], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $177;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    if Random(2) > 0 then
      Slots[SlotCount].DirX := 1
    else
      Slots[SlotCount].DirX := -1;
    Slots[SlotCount].DirY := 0;
    if Slots[SlotCount].DirX = 1 then
      Slots[SlotCount].Anim := 1
    else
      Slots[SlotCount].Anim := $15;
    Slots[SlotCount].Speed := 2;
    Slots[SlotCount].W0C := Random($32) + $32;
    Slots[SlotCount].W0E := 0;
    Slots[SlotCount].Kind := 4;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = 'G' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[16]^.Tile[33], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[16]^.Tile[33], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $17F;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    if Random(2) > 0 then
      Slots[SlotCount].DirX := 1
    else
      Slots[SlotCount].DirX := -1;
    Slots[SlotCount].DirY := 0;
    if Slots[SlotCount].DirX = 1 then
      Slots[SlotCount].Anim := 1
    else
      Slots[SlotCount].Anim := $15;
    Slots[SlotCount].Speed := 2;
    Slots[SlotCount].W0C := Random($14) + $1E;
    Slots[SlotCount].W0E := 0;
    Slots[SlotCount].Kind := 5;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = 'V' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[12]^.Tile[1], X shl 4, ((Y shl 4) + $10) - $10);
    DrawTileB(Gfx[12]^.Tile[1], X shl 4, ((Y shl 4) + $1A0) - $10);
    DrawTileB(Gfx[12]^.Tile[5], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[12]^.Tile[5], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $321;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    if Random(2) > 0 then
      Slots[SlotCount].DirX := 1
    else
      Slots[SlotCount].DirX := -1;
    Slots[SlotCount].DirY := 0;
    if Slots[SlotCount].DirX = 1 then
      Slots[SlotCount].Anim := 1
    else
      Slots[SlotCount].Anim := $29;
    Slots[SlotCount].Speed := 2;
    Slots[SlotCount].W0C := Random($14) + $1E;
    Slots[SlotCount].W0E := 0;
    Slots[SlotCount].W10 := 3;
    Slots[SlotCount].Kind := $1E;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = 'X' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[12]^.Tile[17], X shl 4, ((Y shl 4) + $10) - $10);
    DrawTileB(Gfx[12]^.Tile[17], X shl 4, ((Y shl 4) + $1A0) - $10);
    DrawTileB(Gfx[12]^.Tile[21], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[12]^.Tile[21], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $331;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    if Random(2) > 0 then
      Slots[SlotCount].DirX := 1
    else
      Slots[SlotCount].DirX := -1;
    Slots[SlotCount].DirY := 0;
    if Slots[SlotCount].DirX = 1 then
      Slots[SlotCount].Anim := $3D
    else
      Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 2;
    Slots[SlotCount].W0C := $3C;
    Slots[SlotCount].W0E := 0;
    Slots[SlotCount].W10 := 3;
    Slots[SlotCount].W12 := Random($14) + $3C;
    Slots[SlotCount].Kind := $1F;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = '#' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[10]^.Tile[1], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[10]^.Tile[1], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $97;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    Slots[SlotCount].DirX := 1;
    Slots[SlotCount].DirY := 0;
    Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 0;
    Slots[SlotCount].W0C := 3;
    Slots[SlotCount].Kind := $20;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = 'c' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[12]^.Tile[41], X shl 4, ((Y shl 4) + $10) - $10);
    DrawTileB(Gfx[12]^.Tile[41], X shl 4, ((Y shl 4) + $1A0) - $10);
    DrawTileB(Gfx[12]^.Tile[41], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[12]^.Tile[41], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $345;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    if Random(2) > 0 then
      Slots[SlotCount].DirX := 1
    else
      Slots[SlotCount].DirX := -1;
    Slots[SlotCount].DirY := 0;
    if Slots[SlotCount].DirX = 1 then
      Slots[SlotCount].Anim := 1
    else
      Slots[SlotCount].Anim := $15;
    Slots[SlotCount].Speed := 2;
    Slots[SlotCount].W0C := Random($14) + $1E;
    Slots[SlotCount].W0E := 0;
    Slots[SlotCount].W10 := 3;
    Slots[SlotCount].Kind := $21;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = 'e' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[2]^.Tile[17], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[2]^.Tile[17], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $75;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    if Random(2) > 0 then
      Slots[SlotCount].DirX := 1
    else
      Slots[SlotCount].DirX := -1;
    Slots[SlotCount].DirY := 0;
    if Slots[SlotCount].DirX = 1 then
      Slots[SlotCount].Anim := 1
    else
      Slots[SlotCount].Anim := $15;
    Slots[SlotCount].Speed := 2;
    Slots[SlotCount].W0C := 0;
    Slots[SlotCount].W0E := 0;
    Slots[SlotCount].W10 := 3;
    Slots[SlotCount].Kind := $22;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = 'u' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[2]^.Tile[9], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[2]^.Tile[9], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $6D;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    Slots[SlotCount].DirX := 1;
    Slots[SlotCount].DirY := 0;
    Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 0;
    Slots[SlotCount].W0C := 0;
    Slots[SlotCount].W0E := 0;
    Slots[SlotCount].W10 := 3;
    Slots[SlotCount].Kind := $23;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = 'v' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[2]^.Tile[13], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[2]^.Tile[13], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $71;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    Slots[SlotCount].DirX := 1;
    Slots[SlotCount].DirY := 0;
    Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 0;
    Slots[SlotCount].W0C := 0;
    Slots[SlotCount].W0E := $A;
    Slots[SlotCount].W10 := $A;
    Slots[SlotCount].Kind := $24;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = 'n' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[2]^.Tile[33], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[2]^.Tile[33], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $85;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    if Random(2) > 0 then
      Slots[SlotCount].DirX := 1
    else
      Slots[SlotCount].DirX := -1;
    Slots[SlotCount].DirY := 0;
    Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 2;
    Slots[SlotCount].W0C := Random($14) + $1E;
    Slots[SlotCount].W0E := 0;
    Slots[SlotCount].W10 := 3;
    Slots[SlotCount].W12 := Random($32) + $64;
    Slots[SlotCount].Kind := $26;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = '$' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[2]^.Tile[1], X shl 4, ((Y shl 4) + $10) - $10);
    DrawTileB(Gfx[2]^.Tile[1], X shl 4, ((Y shl 4) + $1A0) - $10);
    DrawTileB(Gfx[2]^.Tile[5], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[2]^.Tile[5], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $65;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    if Random(2) > 0 then
      Slots[SlotCount].DirX := 1
    else
      Slots[SlotCount].DirX := -1;
    Slots[SlotCount].DirY := 0;
    if Slots[SlotCount].DirX = 1 then
      Slots[SlotCount].Anim := $C9
    else
      Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 2;
    Slots[SlotCount].W0C := $3C;
    Slots[SlotCount].W0E := 0;
    Slots[SlotCount].W10 := 3;
    Slots[SlotCount].W12 := Random($14) + $3C;
    Slots[SlotCount].Kind := $27;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = '[' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $1B3;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    Slots[SlotCount].DirX := 0;
    Slots[SlotCount].DirY := 0;
    Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 0;
    Slots[SlotCount].W0C := 0;
    Slots[SlotCount].W0E := 0;
    Slots[SlotCount].W10 := 0;
    Slots[SlotCount].W12 := 0;
    Slots[SlotCount].Kind := $29;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = #127 then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[6]^.Tile[9], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[6]^.Tile[9], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $261;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    if Random(2) > 0 then
      Slots[SlotCount].DirX := 1
    else
      Slots[SlotCount].DirX := -1;
    Slots[SlotCount].DirY := 0;
    Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 2;
    Slots[SlotCount].W0C := 2;
    Slots[SlotCount].W0E := $B;
    Slots[SlotCount].Kind := 6;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = 'R' then
  begin
    SetCell(X, Y, 2, $1D0, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[5]^.Tile[14], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[5]^.Tile[14], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $1D0;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    Slots[SlotCount].DirX := 1;
    Slots[SlotCount].DirY := 0;
    Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 0;
    Slots[SlotCount].W0C := Random($14) + $37;
    Slots[SlotCount].W0E := 0;
    Slots[SlotCount].Kind := $A;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = 'Q' then
  begin
    SetCell(X, Y, 2, $1D1, 0, 0, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[5]^.Tile[15], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[5]^.Tile[15], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $1D1;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    Slots[SlotCount].DirX := 1;
    Slots[SlotCount].DirY := 0;
    Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 0;
    Slots[SlotCount].W0C := Random($14) + $37;
    Slots[SlotCount].W0E := 0;
    Slots[SlotCount].Kind := $B;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = '<' then
  begin
    SetCell(X, Y, 2, 0, $1E7, 1, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[5]^.Tile[37], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[5]^.Tile[37], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $1E7;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    Slots[SlotCount].DirX := 1;
    Slots[SlotCount].DirY := 0;
    Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 0;
    Slots[SlotCount].W0C := Random($14) + $37;
    Slots[SlotCount].W0E := 0;
    Slots[SlotCount].Kind := $C;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = '=' then
  begin
    SetCell(X, Y, 2, 0, $1EB, 1, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[5]^.Tile[41], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[5]^.Tile[41], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $1EB;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    Slots[SlotCount].DirX := 1;
    Slots[SlotCount].DirY := 0;
    Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 0;
    Slots[SlotCount].W0C := Random($14) + $37;
    Slots[SlotCount].W0E := 0;
    Slots[SlotCount].Kind := $D;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = ';' then
  begin
    SetCell(X, Y - 2, 2, 0, $1AC, 1, 0, False);
    SetCell(X, Y - 1, 2, 0, 0, 0, 0, FO);
    SetCell(X, Y, 2, 0, $1AB, 1, 0, False);
    Inc(SlotCount);
    DrawTileB(Gfx[4]^.Tile[28], X shl 4, ((Y - 2) shl 4) + $10);
    DrawTileB(Gfx[4]^.Tile[28], X shl 4, ((Y - 2) shl 4) + $1A0);
    DrawTileB(Gfx[4]^.Tile[27], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[4]^.Tile[27], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $1B3;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := (Y - 1) shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := (Y - 1) shl 4;
    Slots[SlotCount].DirX := 1;
    Slots[SlotCount].DirY := 0;
    Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 0;
    Slots[SlotCount].W0C := $1E;
    Slots[SlotCount].W0E := Random($1E);
    Slots[SlotCount].Kind := $F;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = '>' then
  begin
    SetCell(X - 2, Y, 2, 0, $1B1, 1, 0, FO);
    SetCell(X - 1, Y, 2, 0, 0, 0, 0, FO);
    SetCell(X, Y, 2, 0, $1B2, 1, 0, FO);
    Inc(SlotCount);
    DrawTileB(Gfx[4]^.Tile[33], (X - 2) shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[4]^.Tile[33], (X - 2) shl 4, (Y shl 4) + $1A0);
    DrawTileB(Gfx[4]^.Tile[34], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[4]^.Tile[34], X shl 4, (Y shl 4) + $1A0);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $1B3;
    Slots[SlotCount].X := (X - 1) shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := (X - 1) shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    Slots[SlotCount].DirX := 1;
    Slots[SlotCount].DirY := 0;
    Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 0;
    Slots[SlotCount].W0C := $1E;
    Slots[SlotCount].W0E := Random($1E);
    Slots[SlotCount].Kind := $10;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = '?' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $1B3;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    Slots[SlotCount].DirX := 1;
    Slots[SlotCount].DirY := 0;
    Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 0;
    Slots[SlotCount].W0C := $1E;
    Slots[SlotCount].W0E := Random($1E);
    Slots[SlotCount].Kind := $11;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = 'A' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $1B3;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    Slots[SlotCount].DirX := 1;
    Slots[SlotCount].DirY := 0;
    Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 0;
    Slots[SlotCount].W0C := $1E;
    Slots[SlotCount].W0E := Random($1E);
    Slots[SlotCount].Kind := $12;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = '@' then
  begin
    SetCell(X, Y, 2, 0, $12E, 0, 0, FO);
    Inc(SlotCount);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $131;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := (Y - 1) shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := (Y - 1) shl 4;
    Slots[SlotCount].DirX := 0;
    Slots[SlotCount].DirY := 0;
    Slots[SlotCount].Anim := Random($12) + 1;
    Slots[SlotCount].Speed := 0;
    Slots[SlotCount].W0C := 0;
    Slots[SlotCount].W0E := 5;
    Slots[SlotCount].Kind := $2B;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = #212 then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $135;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    Slots[SlotCount].DirX := 0;
    Slots[SlotCount].DirY := 0;
    Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 0;
    Slots[SlotCount].W0C := 0;
    Slots[SlotCount].W0E := 2;
    Slots[SlotCount].Kind := $2C;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
  if S = 'x' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(SlotCount);
    Slots[SlotCount].MaskFrames := 0;
    Slots[SlotCount].Sprite := $103;
    Slots[SlotCount].X := X shl 4;
    Slots[SlotCount].Y := Y shl 4;
    Slots[SlotCount].PrevX := X shl 4;
    Slots[SlotCount].PrevY := Y shl 4;
    Slots[SlotCount].DirX := 0;
    Slots[SlotCount].DirY := 0;
    Slots[SlotCount].Anim := 1;
    Slots[SlotCount].Speed := 0;
    Slots[SlotCount].W0C := 0;
    Slots[SlotCount].W0E := 2;
    Slots[SlotCount].Kind := $2C;
    Slots[SlotCount].Free := 0;
    Slots[SlotCount].Remove := 0;
  end;
end;
{$F-}
