{ src: SAM1RE 0D9C:1185 (../SAM level-load.md: the row-24 sheet cell repaint at pixel X, Y, load time only:
  the sheet's Back values 2, 5, 6, 7 stand for the level's own tiles W6840..W6840+3 and 8 for $29B while
  it draws (mapped back after), Back without mask, Mid and Front with mask, the banks as DrawFront's. No
  bounds test) }
{ keep: DrawSheet(0, 0); }
{$F+}
procedure DrawSheet(X, Y: Integer);
var
  CX, CY: Integer;
begin
  CX := X shr 4;
  CY := Y shr 4;
  if Map[CX + 1, CY + 1].Back = 2 then
    Map[CX + 1, CY + 1].Back := W6840;
  if Map[CX + 1, CY + 1].Back = 5 then
    Map[CX + 1, CY + 1].Back := W6840 + 1;
  if Map[CX + 1, CY + 1].Back = 6 then
    Map[CX + 1, CY + 1].Back := W6840 + 2;
  if Map[CX + 1, CY + 1].Back = 7 then
    Map[CX + 1, CY + 1].Back := W6840 + 3;
  if Map[CX + 1, CY + 1].Back = 8 then
    Map[CX + 1, CY + 1].Back := $29B;
  case Map[CX + 1, CY + 1].Back of
    1..$32:
        DrawTileO(Gfx[1]^.Tile[Map[CX + 1, CY + 1].Back], CX shl 1, (CY shl 4) + W6866);
    $64..$96:
        DrawTileO(Gfx[2]^.Tile[Map[CX + 1, CY + 1].Back - $64], CX shl 1, (CY shl 4) + W6866);
    $B3:
        if W6866 = $10 then
          DrawTileO(Gfx[10]^.Tile[29], CX shl 1, (CY shl 4) + W6866)
        else
          DrawTileO(Gfx[10]^.Tile[30], CX shl 1, (CY shl 4) + W6866);
    $97..$C8:
        DrawTileO(Gfx[10]^.Tile[Map[CX + 1, CY + 1].Back - $96], CX shl 1, (CY shl 4) + W6866);
    $C9..$FA:
        DrawTileO(Gfx[11]^.Tile[Map[CX + 1, CY + 1].Back - $C8], CX shl 1, (CY shl 4) + W6866);
    $FB..$12C:
        DrawTileO(Gfx[15]^.Tile[Map[CX + 1, CY + 1].Back - $FA], CX shl 1, (CY shl 4) + W6866);
    $12D..$15E:
        DrawTileO(Gfx[13]^.Tile[Map[CX + 1, CY + 1].Back - $12C], CX shl 1, (CY shl 4) + W6866);
    $15F..$190:
        DrawTileO(Gfx[16]^.Tile[Map[CX + 1, CY + 1].Back - $15E], CX shl 1, (CY shl 4) + W6866);
    $191..$1C2:
        DrawTileO(Gfx[4]^.Tile[Map[CX + 1, CY + 1].Back - $190], CX shl 1, (CY shl 4) + W6866);
    $1F3:
        if W6866 = $10 then
          DrawTileO(Gfx[5]^.Tile[49], CX shl 1, (CY shl 4) + W6866)
        else
          DrawTileO(Gfx[5]^.Tile[1], CX shl 1, (CY shl 4) + W6866);
    $1C3..$1F4:
        DrawTileO(Gfx[5]^.Tile[Map[CX + 1, CY + 1].Back - $1C2], CX shl 1, (CY shl 4) + W6866);
    $1F5..$226:
        DrawTileO(Gfx[1]^.Tile[Map[CX + 1, CY + 1].Back - $1F4], CX shl 1, (CY shl 4) + W6866);
    $265:
        if W6866 = $10 then
          DrawTileO(Gfx[6]^.Tile[13], CX shl 1, (CY shl 4) + W6866)
        else
          DrawTileO(Gfx[6]^.Tile[17], CX shl 1, (CY shl 4) + W6866);
    $259..$28A:
        DrawTileO(Gfx[6]^.Tile[Map[CX + 1, CY + 1].Back - $258], CX shl 1, (CY shl 4) + W6866);
    $28B..$2BC:
        DrawTileO(Gfx[7]^.Tile[Map[CX + 1, CY + 1].Back - $28A], CX shl 1, (CY shl 4) + W6866);
    $2BD..$2EE:
        DrawTileO(Gfx[8]^.Tile[Map[CX + 1, CY + 1].Back - $2BC], CX shl 1, (CY shl 4) + W6866);
    $2EF..$320:
        DrawTileO(Gfx[9]^.Tile[Map[CX + 1, CY + 1].Back - $2EE], CX shl 1, (CY shl 4) + W6866);
  end;
  if Map[CX + 1, CY + 1].Back = W6840 then
    Map[CX + 1, CY + 1].Back := 2;
  if W6840 + 1 = Map[CX + 1, CY + 1].Back then
    Map[CX + 1, CY + 1].Back := 5;
  if W6840 + 2 = Map[CX + 1, CY + 1].Back then
    Map[CX + 1, CY + 1].Back := 6;
  if W6840 + 3 = Map[CX + 1, CY + 1].Back then
    Map[CX + 1, CY + 1].Back := 7;
  if Map[CX + 1, CY + 1].Back = $29B then
    Map[CX + 1, CY + 1].Back := 8;
  case Map[CX + 1, CY + 1].Mid of
    0:
        ;
    1..$32:
        DrawTile(Gfx[1]^.Tile[Map[CX + 1, CY + 1].Mid], CX shl 1, (CY shl 4) + W6866);
    $64..$96:
        DrawTile(Gfx[2]^.Tile[Map[CX + 1, CY + 1].Mid - $64], CX shl 1, (CY shl 4) + W6866);
    $B3:
        if W6866 = $10 then
          DrawTile(Gfx[10]^.Tile[29], CX shl 1, (CY shl 4) + W6866)
        else
          DrawTile(Gfx[10]^.Tile[30], CX shl 1, (CY shl 4) + W6866);
    $97..$C8:
        DrawTile(Gfx[10]^.Tile[Map[CX + 1, CY + 1].Mid - $96], CX shl 1, (CY shl 4) + W6866);
    $C9..$FA:
        DrawTile(Gfx[11]^.Tile[Map[CX + 1, CY + 1].Mid - $C8], CX shl 1, (CY shl 4) + W6866);
    $FB..$12C:
        DrawTile(Gfx[15]^.Tile[Map[CX + 1, CY + 1].Mid - $FA], CX shl 1, (CY shl 4) + W6866);
    $12D..$15E:
        DrawTile(Gfx[13]^.Tile[Map[CX + 1, CY + 1].Mid - $12C], CX shl 1, (CY shl 4) + W6866);
    $15F..$190:
        DrawTile(Gfx[16]^.Tile[Map[CX + 1, CY + 1].Mid - $15E], CX shl 1, (CY shl 4) + W6866);
    $191..$1C2:
        DrawTile(Gfx[4]^.Tile[Map[CX + 1, CY + 1].Mid - $190], CX shl 1, (CY shl 4) + W6866);
    $1F3:
        if W6866 = $10 then
          DrawTile(Gfx[5]^.Tile[49], CX shl 1, (CY shl 4) + W6866)
        else
          DrawTile(Gfx[5]^.Tile[1], CX shl 1, (CY shl 4) + W6866);
    $1C3..$1F4:
        DrawTile(Gfx[5]^.Tile[Map[CX + 1, CY + 1].Mid - $1C2], CX shl 1, (CY shl 4) + W6866);
    $1F5..$226:
        DrawTile(Gfx[1]^.Tile[Map[CX + 1, CY + 1].Mid - $1F4], CX shl 1, (CY shl 4) + W6866);
    $265:
        if W6866 = $10 then
          DrawTile(Gfx[6]^.Tile[13], CX shl 1, (CY shl 4) + W6866)
        else
          DrawTile(Gfx[6]^.Tile[17], CX shl 1, (CY shl 4) + W6866);
    $259..$28A:
        DrawTile(Gfx[6]^.Tile[Map[CX + 1, CY + 1].Mid - $258], CX shl 1, (CY shl 4) + W6866);
    $28B..$2BC:
        DrawTile(Gfx[7]^.Tile[Map[CX + 1, CY + 1].Mid - $28A], CX shl 1, (CY shl 4) + W6866);
    $2BD..$2EE:
        DrawTile(Gfx[8]^.Tile[Map[CX + 1, CY + 1].Mid - $2BC], CX shl 1, (CY shl 4) + W6866);
    $2EF..$320:
        DrawTile(Gfx[9]^.Tile[Map[CX + 1, CY + 1].Mid - $2EE], CX shl 1, (CY shl 4) + W6866);
  end;
  case Map[CX + 1, CY + 1].Front of
    0:
        ;
    1..$32:
        DrawTile(Gfx[1]^.Tile[Map[CX + 1, CY + 1].Front], CX shl 1, (CY shl 4) + W6866);
    $64..$96:
        DrawTile(Gfx[2]^.Tile[Map[CX + 1, CY + 1].Front - $64], CX shl 1, (CY shl 4) + W6866);
    $B3:
        if W6866 = $10 then
          DrawTile(Gfx[10]^.Tile[29], CX shl 1, (CY shl 4) + W6866)
        else
          DrawTile(Gfx[10]^.Tile[30], CX shl 1, (CY shl 4) + W6866);
    $97..$C8:
        DrawTile(Gfx[10]^.Tile[Map[CX + 1, CY + 1].Front - $96], CX shl 1, (CY shl 4) + W6866);
    $C9..$FA:
        DrawTile(Gfx[11]^.Tile[Map[CX + 1, CY + 1].Front - $C8], CX shl 1, (CY shl 4) + W6866);
    $FB..$12C:
        DrawTile(Gfx[15]^.Tile[Map[CX + 1, CY + 1].Front - $FA], CX shl 1, (CY shl 4) + W6866);
    $12D..$15E:
        DrawTile(Gfx[13]^.Tile[Map[CX + 1, CY + 1].Front - $12C], CX shl 1, (CY shl 4) + W6866);
    $15F..$190:
        DrawTile(Gfx[16]^.Tile[Map[CX + 1, CY + 1].Front - $15E], CX shl 1, (CY shl 4) + W6866);
    $191..$1C2:
        DrawTile(Gfx[4]^.Tile[Map[CX + 1, CY + 1].Front - $190], CX shl 1, (CY shl 4) + W6866);
    $1F3:
        if W6866 = $10 then
          DrawTile(Gfx[5]^.Tile[49], CX shl 1, (CY shl 4) + W6866)
        else
          DrawTile(Gfx[5]^.Tile[1], CX shl 1, (CY shl 4) + W6866);
    $1C3..$1F4:
        DrawTile(Gfx[5]^.Tile[Map[CX + 1, CY + 1].Front - $1C2], CX shl 1, (CY shl 4) + W6866);
    $1F5..$226:
        DrawTile(Gfx[1]^.Tile[Map[CX + 1, CY + 1].Front - $1F4], CX shl 1, (CY shl 4) + W6866);
    $265:
        if W6866 = $10 then
          DrawTile(Gfx[6]^.Tile[13], CX shl 1, (CY shl 4) + W6866)
        else
          DrawTile(Gfx[6]^.Tile[17], CX shl 1, (CY shl 4) + W6866);
    $259..$28A:
        DrawTile(Gfx[6]^.Tile[Map[CX + 1, CY + 1].Front - $258], CX shl 1, (CY shl 4) + W6866);
    $28B..$2BC:
        DrawTile(Gfx[7]^.Tile[Map[CX + 1, CY + 1].Front - $28A], CX shl 1, (CY shl 4) + W6866);
    $2BD..$2EE:
        DrawTile(Gfx[8]^.Tile[Map[CX + 1, CY + 1].Front - $2BC], CX shl 1, (CY shl 4) + W6866);
    $2EF..$320:
        DrawTile(Gfx[9]^.Tile[Map[CX + 1, CY + 1].Front - $2EE], CX shl 1, (CY shl 4) + W6866);
  end;
end;
{$F-}
