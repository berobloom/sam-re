{ src: SAM1RE 0D9C:3A91 (../SAM level-load.md, objects.md: the actor spawner of row char S at cell X, Y (levels
  > 1): each actor char clears its cell to tile 2 and takes the next slot W6854, drawn on both pages, with
  its kind (W14), facing (W16, often Random) and timers) }
{ from: 3A59 }
{ keep: - }
{$F+}
procedure SpawnActor(X, Y: Integer; S: String; FO: Boolean);
begin
  if S = #174 then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[14]^.Tile[13], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[14]^.Tile[13], X shl 4, (Y shl 4) + $1A0);
    DrawTileB(Gfx[14]^.Tile[9], (X + 1) shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[14]^.Tile[9], (X + 1) shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $353;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    if Random(2) > 0 then
      Slots[W6854].W16 := 1
    else
      Slots[W6854].W16 := -1;
    Slots[W6854].W18 := 0;
    if Slots[W6854].W16 = 1 then
      Slots[W6854].W0A := 1
    else
      Slots[W6854].W0A := $29;
    Slots[W6854].W1A := 2;
    Slots[W6854].W0C := 0;
    Slots[W6854].W0E := 0;
    Slots[W6854].W10 := 3;
    Slots[W6854].W1C := $2A;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = '8' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[16]^.Tile[1], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[16]^.Tile[1], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $15F;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    if Random(2) > 0 then
      Slots[W6854].W16 := 1
    else
      Slots[W6854].W16 := -1;
    Slots[W6854].W18 := 0;
    if Slots[W6854].W16 = 1 then
      Slots[W6854].W0A := 1
    else
      Slots[W6854].W0A := $15;
    Slots[W6854].W1A := 1;
    Slots[W6854].W0C := 0;
    Slots[W6854].W0E := 0;
    Slots[W6854].W1C := 1;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = '9' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[16]^.Tile[9], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[16]^.Tile[9], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $167;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    if Random(2) > 0 then
      Slots[W6854].W16 := 1
    else
      Slots[W6854].W16 := -1;
    Slots[W6854].W18 := 0;
    if Slots[W6854].W16 = 1 then
      Slots[W6854].W0A := 1
    else
      Slots[W6854].W0A := $15;
    Slots[W6854].W1A := 1;
    Slots[W6854].W0C := 0;
    Slots[W6854].W1C := 2;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = '0' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[16]^.Tile[17], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[16]^.Tile[17], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $16F;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    if Random(2) > 0 then
      Slots[W6854].W16 := 1
    else
      Slots[W6854].W16 := -1;
    Slots[W6854].W18 := 0;
    if Slots[W6854].W16 = 1 then
      Slots[W6854].W0A := 1
    else
      Slots[W6854].W0A := $15;
    Slots[W6854].W1A := 2;
    Slots[W6854].W0C := 0;
    Slots[W6854].W1C := 3;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = 'g' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[16]^.Tile[25], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[16]^.Tile[25], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $177;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    if Random(2) > 0 then
      Slots[W6854].W16 := 1
    else
      Slots[W6854].W16 := -1;
    Slots[W6854].W18 := 0;
    if Slots[W6854].W16 = 1 then
      Slots[W6854].W0A := 1
    else
      Slots[W6854].W0A := $15;
    Slots[W6854].W1A := 2;
    Slots[W6854].W0C := Random($32) + $32;
    Slots[W6854].W0E := 0;
    Slots[W6854].W1C := 4;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = 'G' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[16]^.Tile[33], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[16]^.Tile[33], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $17F;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    if Random(2) > 0 then
      Slots[W6854].W16 := 1
    else
      Slots[W6854].W16 := -1;
    Slots[W6854].W18 := 0;
    if Slots[W6854].W16 = 1 then
      Slots[W6854].W0A := 1
    else
      Slots[W6854].W0A := $15;
    Slots[W6854].W1A := 2;
    Slots[W6854].W0C := Random($14) + $1E;
    Slots[W6854].W0E := 0;
    Slots[W6854].W1C := 5;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = 'V' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[12]^.Tile[1], X shl 4, ((Y shl 4) + $10) - $10);
    DrawTileB(Gfx[12]^.Tile[1], X shl 4, ((Y shl 4) + $1A0) - $10);
    DrawTileB(Gfx[12]^.Tile[5], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[12]^.Tile[5], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $321;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    if Random(2) > 0 then
      Slots[W6854].W16 := 1
    else
      Slots[W6854].W16 := -1;
    Slots[W6854].W18 := 0;
    if Slots[W6854].W16 = 1 then
      Slots[W6854].W0A := 1
    else
      Slots[W6854].W0A := $29;
    Slots[W6854].W1A := 2;
    Slots[W6854].W0C := Random($14) + $1E;
    Slots[W6854].W0E := 0;
    Slots[W6854].W10 := 3;
    Slots[W6854].W1C := $1E;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = 'X' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[12]^.Tile[17], X shl 4, ((Y shl 4) + $10) - $10);
    DrawTileB(Gfx[12]^.Tile[17], X shl 4, ((Y shl 4) + $1A0) - $10);
    DrawTileB(Gfx[12]^.Tile[21], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[12]^.Tile[21], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $331;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    if Random(2) > 0 then
      Slots[W6854].W16 := 1
    else
      Slots[W6854].W16 := -1;
    Slots[W6854].W18 := 0;
    if Slots[W6854].W16 = 1 then
      Slots[W6854].W0A := $3D
    else
      Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 2;
    Slots[W6854].W0C := $3C;
    Slots[W6854].W0E := 0;
    Slots[W6854].W10 := 3;
    Slots[W6854].W12 := Random($14) + $3C;
    Slots[W6854].W1C := $1F;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = '#' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[10]^.Tile[1], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[10]^.Tile[1], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $97;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    Slots[W6854].W16 := 1;
    Slots[W6854].W18 := 0;
    Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 0;
    Slots[W6854].W0C := 3;
    Slots[W6854].W1C := $20;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = 'c' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[12]^.Tile[41], X shl 4, ((Y shl 4) + $10) - $10);
    DrawTileB(Gfx[12]^.Tile[41], X shl 4, ((Y shl 4) + $1A0) - $10);
    DrawTileB(Gfx[12]^.Tile[41], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[12]^.Tile[41], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $345;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    if Random(2) > 0 then
      Slots[W6854].W16 := 1
    else
      Slots[W6854].W16 := -1;
    Slots[W6854].W18 := 0;
    if Slots[W6854].W16 = 1 then
      Slots[W6854].W0A := 1
    else
      Slots[W6854].W0A := $15;
    Slots[W6854].W1A := 2;
    Slots[W6854].W0C := Random($14) + $1E;
    Slots[W6854].W0E := 0;
    Slots[W6854].W10 := 3;
    Slots[W6854].W1C := $21;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = 'e' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[2]^.Tile[17], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[2]^.Tile[17], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $75;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    if Random(2) > 0 then
      Slots[W6854].W16 := 1
    else
      Slots[W6854].W16 := -1;
    Slots[W6854].W18 := 0;
    if Slots[W6854].W16 = 1 then
      Slots[W6854].W0A := 1
    else
      Slots[W6854].W0A := $15;
    Slots[W6854].W1A := 2;
    Slots[W6854].W0C := 0;
    Slots[W6854].W0E := 0;
    Slots[W6854].W10 := 3;
    Slots[W6854].W1C := $22;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = 'u' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[2]^.Tile[9], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[2]^.Tile[9], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $6D;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    Slots[W6854].W16 := 1;
    Slots[W6854].W18 := 0;
    Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 0;
    Slots[W6854].W0C := 0;
    Slots[W6854].W0E := 0;
    Slots[W6854].W10 := 3;
    Slots[W6854].W1C := $23;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = 'v' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[2]^.Tile[13], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[2]^.Tile[13], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $71;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    Slots[W6854].W16 := 1;
    Slots[W6854].W18 := 0;
    Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 0;
    Slots[W6854].W0C := 0;
    Slots[W6854].W0E := $A;
    Slots[W6854].W10 := $A;
    Slots[W6854].W1C := $24;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = 'n' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[2]^.Tile[33], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[2]^.Tile[33], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $85;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    if Random(2) > 0 then
      Slots[W6854].W16 := 1
    else
      Slots[W6854].W16 := -1;
    Slots[W6854].W18 := 0;
    Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 2;
    Slots[W6854].W0C := Random($14) + $1E;
    Slots[W6854].W0E := 0;
    Slots[W6854].W10 := 3;
    Slots[W6854].W12 := Random($32) + $64;
    Slots[W6854].W1C := $26;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = '$' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[2]^.Tile[1], X shl 4, ((Y shl 4) + $10) - $10);
    DrawTileB(Gfx[2]^.Tile[1], X shl 4, ((Y shl 4) + $1A0) - $10);
    DrawTileB(Gfx[2]^.Tile[5], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[2]^.Tile[5], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $65;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    if Random(2) > 0 then
      Slots[W6854].W16 := 1
    else
      Slots[W6854].W16 := -1;
    Slots[W6854].W18 := 0;
    if Slots[W6854].W16 = 1 then
      Slots[W6854].W0A := $C9
    else
      Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 2;
    Slots[W6854].W0C := $3C;
    Slots[W6854].W0E := 0;
    Slots[W6854].W10 := 3;
    Slots[W6854].W12 := Random($14) + $3C;
    Slots[W6854].W1C := $27;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = '[' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $1B3;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    Slots[W6854].W16 := 0;
    Slots[W6854].W18 := 0;
    Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 0;
    Slots[W6854].W0C := 0;
    Slots[W6854].W0E := 0;
    Slots[W6854].W10 := 0;
    Slots[W6854].W12 := 0;
    Slots[W6854].W1C := $29;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = #127 then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[6]^.Tile[9], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[6]^.Tile[9], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $261;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    if Random(2) > 0 then
      Slots[W6854].W16 := 1
    else
      Slots[W6854].W16 := -1;
    Slots[W6854].W18 := 0;
    Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 2;
    Slots[W6854].W0C := 2;
    Slots[W6854].W0E := $B;
    Slots[W6854].W1C := 6;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = 'R' then
  begin
    SetCell(X, Y, 2, $1D0, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[5]^.Tile[14], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[5]^.Tile[14], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $1D0;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    Slots[W6854].W16 := 1;
    Slots[W6854].W18 := 0;
    Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 0;
    Slots[W6854].W0C := Random($14) + $37;
    Slots[W6854].W0E := 0;
    Slots[W6854].W1C := $A;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = 'Q' then
  begin
    SetCell(X, Y, 2, $1D1, 0, 0, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[5]^.Tile[15], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[5]^.Tile[15], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $1D1;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    Slots[W6854].W16 := 1;
    Slots[W6854].W18 := 0;
    Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 0;
    Slots[W6854].W0C := Random($14) + $37;
    Slots[W6854].W0E := 0;
    Slots[W6854].W1C := $B;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = '<' then
  begin
    SetCell(X, Y, 2, 0, $1E7, 1, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[5]^.Tile[37], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[5]^.Tile[37], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $1E7;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    Slots[W6854].W16 := 1;
    Slots[W6854].W18 := 0;
    Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 0;
    Slots[W6854].W0C := Random($14) + $37;
    Slots[W6854].W0E := 0;
    Slots[W6854].W1C := $C;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = '=' then
  begin
    SetCell(X, Y, 2, 0, $1EB, 1, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[5]^.Tile[41], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[5]^.Tile[41], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $1EB;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    Slots[W6854].W16 := 1;
    Slots[W6854].W18 := 0;
    Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 0;
    Slots[W6854].W0C := Random($14) + $37;
    Slots[W6854].W0E := 0;
    Slots[W6854].W1C := $D;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = ';' then
  begin
    SetCell(X, Y - 2, 2, 0, $1AC, 1, 0, False);
    SetCell(X, Y - 1, 2, 0, 0, 0, 0, FO);
    SetCell(X, Y, 2, 0, $1AB, 1, 0, False);
    Inc(W6854);
    DrawTileB(Gfx[4]^.Tile[28], X shl 4, ((Y - 2) shl 4) + $10);
    DrawTileB(Gfx[4]^.Tile[28], X shl 4, ((Y - 2) shl 4) + $1A0);
    DrawTileB(Gfx[4]^.Tile[27], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[4]^.Tile[27], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $1B3;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := (Y - 1) shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := (Y - 1) shl 4;
    Slots[W6854].W16 := 1;
    Slots[W6854].W18 := 0;
    Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 0;
    Slots[W6854].W0C := $1E;
    Slots[W6854].W0E := Random($1E);
    Slots[W6854].W1C := $F;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = '>' then
  begin
    SetCell(X - 2, Y, 2, 0, $1B1, 1, 0, FO);
    SetCell(X - 1, Y, 2, 0, 0, 0, 0, FO);
    SetCell(X, Y, 2, 0, $1B2, 1, 0, FO);
    Inc(W6854);
    DrawTileB(Gfx[4]^.Tile[33], (X - 2) shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[4]^.Tile[33], (X - 2) shl 4, (Y shl 4) + $1A0);
    DrawTileB(Gfx[4]^.Tile[34], X shl 4, (Y shl 4) + $10);
    DrawTileB(Gfx[4]^.Tile[34], X shl 4, (Y shl 4) + $1A0);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $1B3;
    Slots[W6854].X := (X - 1) shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := (X - 1) shl 4;
    Slots[W6854].W08 := Y shl 4;
    Slots[W6854].W16 := 1;
    Slots[W6854].W18 := 0;
    Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 0;
    Slots[W6854].W0C := $1E;
    Slots[W6854].W0E := Random($1E);
    Slots[W6854].W1C := $10;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = '?' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $1B3;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    Slots[W6854].W16 := 1;
    Slots[W6854].W18 := 0;
    Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 0;
    Slots[W6854].W0C := $1E;
    Slots[W6854].W0E := Random($1E);
    Slots[W6854].W1C := $11;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = 'A' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $1B3;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    Slots[W6854].W16 := 1;
    Slots[W6854].W18 := 0;
    Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 0;
    Slots[W6854].W0C := $1E;
    Slots[W6854].W0E := Random($1E);
    Slots[W6854].W1C := $12;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = '@' then
  begin
    SetCell(X, Y, 2, 0, $12E, 0, 0, FO);
    Inc(W6854);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $131;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := (Y - 1) shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := (Y - 1) shl 4;
    Slots[W6854].W16 := 0;
    Slots[W6854].W18 := 0;
    Slots[W6854].W0A := Random($12) + 1;
    Slots[W6854].W1A := 0;
    Slots[W6854].W0C := 0;
    Slots[W6854].W0E := 5;
    Slots[W6854].W1C := $2B;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = #212 then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $135;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    Slots[W6854].W16 := 0;
    Slots[W6854].W18 := 0;
    Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 0;
    Slots[W6854].W0C := 0;
    Slots[W6854].W0E := 2;
    Slots[W6854].W1C := $2C;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
  if S = 'x' then
  begin
    SetCell(X, Y, 2, 0, 0, 0, 0, FO);
    Inc(W6854);
    Slots[W6854].W00 := 0;
    Slots[W6854].W14 := $103;
    Slots[W6854].X := X shl 4;
    Slots[W6854].Y := Y shl 4;
    Slots[W6854].W06 := X shl 4;
    Slots[W6854].W08 := Y shl 4;
    Slots[W6854].W16 := 0;
    Slots[W6854].W18 := 0;
    Slots[W6854].W0A := 1;
    Slots[W6854].W1A := 0;
    Slots[W6854].W0C := 0;
    Slots[W6854].W0E := 2;
    Slots[W6854].W1C := $2C;
    Slots[W6854].Free := 0;
    Slots[W6854].B1F := 0;
  end;
end;
{$F-}
