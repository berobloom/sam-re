{ src: SAM1RE 0D9C:0000 (../SAM objects.md, level-load.md: the back cell repaint at pixel X, Y: the cell's
  Back (1..8 a pattern of the row-24 sheet, else a tile drawn without mask), then its Mid and Front tiles
  with mask, on the page W6866; the banks as DrawFront's. Columns 0..$27 only, no upper row bound) }
{ interface }
{ keep: DrawBack(0, 0); }
procedure DrawBack(X, Y: Integer);
var
  CX, CY, MX, MY, PX, PY: Integer;
begin
  CX := X shr 4;
  CY := Y shr 4;
  if (CX >= 0) and (CX <= $27) and (CY >= 0) then
  begin
    MX := X shr 4 + 1;
    MY := Y shr 4 + 1;
    PX := CX shl 1;
    PY := CY shl 4;
    case Map[MX, MY].Back of
      0:
          ;
      1..8:
          CopySheet(PX, PY + PageY, Map[MX, MY].Back - 1);
      9..$32:
          DrawTileO(Gfx[1]^.Tile[Map[MX, MY].Back], PX, PY + PageY);
      $65:
          CopySheet(PX, PY + PageY, 4);
      $64, $66..$96:
          DrawTileO(Gfx[2]^.Tile[Map[MX, MY].Back - $64], PX, PY + PageY);
      $B3:
          if PageY = $10 then
            DrawTileO(Gfx[10]^.Tile[29], PX, PY + PageY)
          else
            DrawTileO(Gfx[10]^.Tile[30], PX, PY + PageY);
      $97..$C8:
          DrawTileO(Gfx[10]^.Tile[Map[MX, MY].Back - $96], PX, PY + PageY);
      $C9..$FA:
          DrawTileO(Gfx[11]^.Tile[Map[MX, MY].Back - $C8], PX, PY + PageY);
      $FB..$12C:
          DrawTileO(Gfx[15]^.Tile[Map[MX, MY].Back - $FA], PX, PY + PageY);
      $12D..$15E:
          DrawTileO(Gfx[13]^.Tile[Map[MX, MY].Back - $12C], PX, PY + PageY);
      $15F..$190:
          DrawTileO(Gfx[16]^.Tile[Map[MX, MY].Back - $15E], PX, PY + PageY);
      $191..$1C2:
          DrawTileO(Gfx[4]^.Tile[Map[MX, MY].Back - $190], PX, PY + PageY);
      $1F3:
          if PageY = $10 then
            DrawTileO(Gfx[5]^.Tile[49], PX, PY + PageY)
          else
            DrawTileO(Gfx[5]^.Tile[1], PX, PY + PageY);
      $1C3..$1F4:
          DrawTileO(Gfx[5]^.Tile[Map[MX, MY].Back - $1C2], PX, PY + PageY);
      $217:
          if PageY = $10 then
            DrawTileO(Gfx[1]^.Tile[21], PX, PY + PageY)
          else
            DrawTileO(Gfx[1]^.Tile[35], PX, PY + PageY);
      $1F5..$226:
          DrawTileO(Gfx[1]^.Tile[Map[MX, MY].Back - $1F4], PX, PY + PageY);
      $265:
          if PageY = $10 then
            DrawTileO(Gfx[6]^.Tile[13], CX shl 1, (CY shl 4) + PageY)
          else
            DrawTileO(Gfx[6]^.Tile[17], CX shl 1, (CY shl 4) + PageY);
      $259..$28A:
          DrawTileO(Gfx[6]^.Tile[Map[MX, MY].Back - $258], PX, PY + PageY);
      $28B..$2BC:
          DrawTileO(Gfx[7]^.Tile[Map[MX, MY].Back - $28A], PX, PY + PageY);
      $2BD..$2EE:
          DrawTileO(Gfx[8]^.Tile[Map[MX, MY].Back - $2BC], PX, PY + PageY);
      $2EF..$320:
          DrawTileO(Gfx[9]^.Tile[Map[MX, MY].Back - $2EE], PX, PY + PageY);
    end;
    case Map[MX, MY].Mid of
      0:
          ;
      1..$32:
          DrawTile(Gfx[1]^.Tile[Map[MX, MY].Mid], PX, PY + PageY);
      $64..$96:
          DrawTile(Gfx[2]^.Tile[Map[MX, MY].Mid - $64], PX, PY + PageY);
      $B3:
          if PageY = $10 then
            DrawTile(Gfx[10]^.Tile[29], PX, PY + PageY)
          else
            DrawTile(Gfx[10]^.Tile[30], PX, PY + PageY);
      $97..$C8:
          DrawTile(Gfx[10]^.Tile[Map[MX, MY].Mid - $96], PX, PY + PageY);
      $C9..$FA:
          DrawTile(Gfx[11]^.Tile[Map[MX, MY].Mid - $C8], PX, PY + PageY);
      $FB..$12C:
          DrawTile(Gfx[15]^.Tile[Map[MX, MY].Mid - $FA], PX, PY + PageY);
      $12D..$15E:
          DrawTile(Gfx[13]^.Tile[Map[MX, MY].Mid - $12C], PX, PY + PageY);
      $15F..$190:
          DrawTile(Gfx[16]^.Tile[Map[MX, MY].Mid - $15E], PX, PY + PageY);
      $191..$1C2:
          DrawTile(Gfx[4]^.Tile[Map[MX, MY].Mid - $190], PX, PY + PageY);
      $1F3:
          if PageY = $10 then
            DrawTile(Gfx[5]^.Tile[49], PX, PY + PageY)
          else
            DrawTile(Gfx[5]^.Tile[1], PX, PY + PageY);
      $1C3..$1F4:
          DrawTile(Gfx[5]^.Tile[Map[MX, MY].Mid - $1C2], PX, PY + PageY);
      $1F5..$226:
          DrawTile(Gfx[1]^.Tile[Map[MX, MY].Mid - $1F4], PX, PY + PageY);
      $265:
          if PageY = $10 then
            DrawTile(Gfx[6]^.Tile[13], CX shl 1, (CY shl 4) + PageY)
          else
            DrawTile(Gfx[6]^.Tile[17], CX shl 1, (CY shl 4) + PageY);
      $259..$28A:
          DrawTile(Gfx[6]^.Tile[Map[MX, MY].Mid - $258], PX, PY + PageY);
      $28B..$2BC:
          DrawTile(Gfx[7]^.Tile[Map[MX, MY].Mid - $28A], PX, PY + PageY);
      $2BD..$2EE:
          DrawTile(Gfx[8]^.Tile[Map[MX, MY].Mid - $2BC], PX, PY + PageY);
      $2EF..$320:
          DrawTile(Gfx[9]^.Tile[Map[MX, MY].Mid - $2EE], PX, PY + PageY);
    end;
    case Map[MX, MY].Front of
      0:
          ;
      1..$32:
          DrawTile(Gfx[1]^.Tile[Map[MX, MY].Front], PX, PY + PageY);
      $64..$96:
          DrawTile(Gfx[2]^.Tile[Map[MX, MY].Front - $64], PX, PY + PageY);
      $B3:
          if PageY = $10 then
            DrawTile(Gfx[10]^.Tile[29], PX, PY + PageY)
          else
            DrawTile(Gfx[10]^.Tile[30], PX, PY + PageY);
      $97..$C8:
          DrawTile(Gfx[10]^.Tile[Map[MX, MY].Front - $96], PX, PY + PageY);
      $C9..$FA:
          DrawTile(Gfx[11]^.Tile[Map[MX, MY].Front - $C8], PX, PY + PageY);
      $FB..$12C:
          DrawTile(Gfx[15]^.Tile[Map[MX, MY].Front - $FA], PX, PY + PageY);
      $12D..$15E:
          DrawTile(Gfx[13]^.Tile[Map[MX, MY].Front - $12C], PX, PY + PageY);
      $15F..$190:
          DrawTile(Gfx[16]^.Tile[Map[MX, MY].Front - $15E], PX, PY + PageY);
      $191..$1C2:
          DrawTile(Gfx[4]^.Tile[Map[MX, MY].Front - $190], PX, PY + PageY);
      $1F3:
          if PageY = $10 then
            DrawTile(Gfx[5]^.Tile[49], PX, PY + PageY)
          else
            DrawTile(Gfx[5]^.Tile[1], PX, PY + PageY);
      $1C3..$1F4:
          DrawTile(Gfx[5]^.Tile[Map[MX, MY].Front - $1C2], PX, PY + PageY);
      $1F5..$226:
          DrawTile(Gfx[1]^.Tile[Map[MX, MY].Front - $1F4], PX, PY + PageY);
      $265:
          if PageY = $10 then
            DrawTile(Gfx[6]^.Tile[13], CX shl 1, (CY shl 4) + PageY)
          else
            DrawTile(Gfx[6]^.Tile[17], CX shl 1, (CY shl 4) + PageY);
      $259..$25A:
          DrawTile(Gfx[6]^.Tile[Map[MX, MY].Front - $258], PX, PY + PageY);
      $25B:
          if PageY = $1A0 then
            DrawTile(Gfx[6]^.Tile[Map[MX, MY].Front - $258], PX, PY + PageY);
      $25C..$26F:
          DrawTile(Gfx[6]^.Tile[Map[MX, MY].Front - $258], PX, PY + PageY);
      $270:
          if PageY = $1A0 then
            DrawTile(Gfx[6]^.Tile[Map[MX, MY].Front - $258], PX, PY + PageY)
          else
            DrawTile(Gfx[6]^.Tile[Map[MX, MY].Front - $246], PX, PY + PageY);
      $271..$28A:
          DrawTile(Gfx[6]^.Tile[Map[MX, MY].Front - $258], PX, PY + PageY);
      $28B..$2BC:
          DrawTile(Gfx[7]^.Tile[Map[MX, MY].Front - $28A], PX, PY + PageY);
      $2BD..$2EE:
          DrawTile(Gfx[8]^.Tile[Map[MX, MY].Front - $2BC], PX, PY + PageY);
      $2EF..$320:
          DrawTile(Gfx[9]^.Tile[Map[MX, MY].Front - $2EE], PX, PY + PageY);
    end;
  end;
end;
