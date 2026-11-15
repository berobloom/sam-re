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
          CopySheet(PX, PY + W6866, Map[MX, MY].Back - 1);
      9..$32:
          DrawTileO(Gfx[1]^.Tile[Map[MX, MY].Back], PX, PY + W6866);
      $65:
          CopySheet(PX, PY + W6866, 4);
      $64, $66..$96:
          DrawTileO(Gfx[2]^.Tile[Map[MX, MY].Back - $64], PX, PY + W6866);
      $B3:
          if W6866 = $10 then
            DrawTileO(Gfx[10]^.Tile[29], PX, PY + W6866)
          else
            DrawTileO(Gfx[10]^.Tile[30], PX, PY + W6866);
      $97..$C8:
          DrawTileO(Gfx[10]^.Tile[Map[MX, MY].Back - $96], PX, PY + W6866);
      $C9..$FA:
          DrawTileO(Gfx[11]^.Tile[Map[MX, MY].Back - $C8], PX, PY + W6866);
      $FB..$12C:
          DrawTileO(Gfx[15]^.Tile[Map[MX, MY].Back - $FA], PX, PY + W6866);
      $12D..$15E:
          DrawTileO(Gfx[13]^.Tile[Map[MX, MY].Back - $12C], PX, PY + W6866);
      $15F..$190:
          DrawTileO(Gfx[16]^.Tile[Map[MX, MY].Back - $15E], PX, PY + W6866);
      $191..$1C2:
          DrawTileO(Gfx[4]^.Tile[Map[MX, MY].Back - $190], PX, PY + W6866);
      $1F3:
          if W6866 = $10 then
            DrawTileO(Gfx[5]^.Tile[49], PX, PY + W6866)
          else
            DrawTileO(Gfx[5]^.Tile[1], PX, PY + W6866);
      $1C3..$1F4:
          DrawTileO(Gfx[5]^.Tile[Map[MX, MY].Back - $1C2], PX, PY + W6866);
      $217:
          if W6866 = $10 then
            DrawTileO(Gfx[1]^.Tile[21], PX, PY + W6866)
          else
            DrawTileO(Gfx[1]^.Tile[35], PX, PY + W6866);
      $1F5..$226:
          DrawTileO(Gfx[1]^.Tile[Map[MX, MY].Back - $1F4], PX, PY + W6866);
      $265:
          if W6866 = $10 then
            DrawTileO(Gfx[6]^.Tile[13], CX shl 1, (CY shl 4) + W6866)
          else
            DrawTileO(Gfx[6]^.Tile[17], CX shl 1, (CY shl 4) + W6866);
      $259..$28A:
          DrawTileO(Gfx[6]^.Tile[Map[MX, MY].Back - $258], PX, PY + W6866);
      $28B..$2BC:
          DrawTileO(Gfx[7]^.Tile[Map[MX, MY].Back - $28A], PX, PY + W6866);
      $2BD..$2EE:
          DrawTileO(Gfx[8]^.Tile[Map[MX, MY].Back - $2BC], PX, PY + W6866);
      $2EF..$320:
          DrawTileO(Gfx[9]^.Tile[Map[MX, MY].Back - $2EE], PX, PY + W6866);
    end;
    case Map[MX, MY].Mid of
      0:
          ;
      1..$32:
          DrawTile(Gfx[1]^.Tile[Map[MX, MY].Mid], PX, PY + W6866);
      $64..$96:
          DrawTile(Gfx[2]^.Tile[Map[MX, MY].Mid - $64], PX, PY + W6866);
      $B3:
          if W6866 = $10 then
            DrawTile(Gfx[10]^.Tile[29], PX, PY + W6866)
          else
            DrawTile(Gfx[10]^.Tile[30], PX, PY + W6866);
      $97..$C8:
          DrawTile(Gfx[10]^.Tile[Map[MX, MY].Mid - $96], PX, PY + W6866);
      $C9..$FA:
          DrawTile(Gfx[11]^.Tile[Map[MX, MY].Mid - $C8], PX, PY + W6866);
      $FB..$12C:
          DrawTile(Gfx[15]^.Tile[Map[MX, MY].Mid - $FA], PX, PY + W6866);
      $12D..$15E:
          DrawTile(Gfx[13]^.Tile[Map[MX, MY].Mid - $12C], PX, PY + W6866);
      $15F..$190:
          DrawTile(Gfx[16]^.Tile[Map[MX, MY].Mid - $15E], PX, PY + W6866);
      $191..$1C2:
          DrawTile(Gfx[4]^.Tile[Map[MX, MY].Mid - $190], PX, PY + W6866);
      $1F3:
          if W6866 = $10 then
            DrawTile(Gfx[5]^.Tile[49], PX, PY + W6866)
          else
            DrawTile(Gfx[5]^.Tile[1], PX, PY + W6866);
      $1C3..$1F4:
          DrawTile(Gfx[5]^.Tile[Map[MX, MY].Mid - $1C2], PX, PY + W6866);
      $1F5..$226:
          DrawTile(Gfx[1]^.Tile[Map[MX, MY].Mid - $1F4], PX, PY + W6866);
      $265:
          if W6866 = $10 then
            DrawTile(Gfx[6]^.Tile[13], CX shl 1, (CY shl 4) + W6866)
          else
            DrawTile(Gfx[6]^.Tile[17], CX shl 1, (CY shl 4) + W6866);
      $259..$28A:
          DrawTile(Gfx[6]^.Tile[Map[MX, MY].Mid - $258], PX, PY + W6866);
      $28B..$2BC:
          DrawTile(Gfx[7]^.Tile[Map[MX, MY].Mid - $28A], PX, PY + W6866);
      $2BD..$2EE:
          DrawTile(Gfx[8]^.Tile[Map[MX, MY].Mid - $2BC], PX, PY + W6866);
      $2EF..$320:
          DrawTile(Gfx[9]^.Tile[Map[MX, MY].Mid - $2EE], PX, PY + W6866);
    end;
    case Map[MX, MY].Front of
      0:
          ;
      1..$32:
          DrawTile(Gfx[1]^.Tile[Map[MX, MY].Front], PX, PY + W6866);
      $64..$96:
          DrawTile(Gfx[2]^.Tile[Map[MX, MY].Front - $64], PX, PY + W6866);
      $B3:
          if W6866 = $10 then
            DrawTile(Gfx[10]^.Tile[29], PX, PY + W6866)
          else
            DrawTile(Gfx[10]^.Tile[30], PX, PY + W6866);
      $97..$C8:
          DrawTile(Gfx[10]^.Tile[Map[MX, MY].Front - $96], PX, PY + W6866);
      $C9..$FA:
          DrawTile(Gfx[11]^.Tile[Map[MX, MY].Front - $C8], PX, PY + W6866);
      $FB..$12C:
          DrawTile(Gfx[15]^.Tile[Map[MX, MY].Front - $FA], PX, PY + W6866);
      $12D..$15E:
          DrawTile(Gfx[13]^.Tile[Map[MX, MY].Front - $12C], PX, PY + W6866);
      $15F..$190:
          DrawTile(Gfx[16]^.Tile[Map[MX, MY].Front - $15E], PX, PY + W6866);
      $191..$1C2:
          DrawTile(Gfx[4]^.Tile[Map[MX, MY].Front - $190], PX, PY + W6866);
      $1F3:
          if W6866 = $10 then
            DrawTile(Gfx[5]^.Tile[49], PX, PY + W6866)
          else
            DrawTile(Gfx[5]^.Tile[1], PX, PY + W6866);
      $1C3..$1F4:
          DrawTile(Gfx[5]^.Tile[Map[MX, MY].Front - $1C2], PX, PY + W6866);
      $1F5..$226:
          DrawTile(Gfx[1]^.Tile[Map[MX, MY].Front - $1F4], PX, PY + W6866);
      $265:
          if W6866 = $10 then
            DrawTile(Gfx[6]^.Tile[13], CX shl 1, (CY shl 4) + W6866)
          else
            DrawTile(Gfx[6]^.Tile[17], CX shl 1, (CY shl 4) + W6866);
      $259..$25A:
          DrawTile(Gfx[6]^.Tile[Map[MX, MY].Front - $258], PX, PY + W6866);
      $25B:
          if W6866 = $1A0 then
            DrawTile(Gfx[6]^.Tile[Map[MX, MY].Front - $258], PX, PY + W6866);
      $25C..$26F:
          DrawTile(Gfx[6]^.Tile[Map[MX, MY].Front - $258], PX, PY + W6866);
      $270:
          if W6866 = $1A0 then
            DrawTile(Gfx[6]^.Tile[Map[MX, MY].Front - $258], PX, PY + W6866)
          else
            DrawTile(Gfx[6]^.Tile[Map[MX, MY].Front - $246], PX, PY + W6866);
      $271..$28A:
          DrawTile(Gfx[6]^.Tile[Map[MX, MY].Front - $258], PX, PY + W6866);
      $28B..$2BC:
          DrawTile(Gfx[7]^.Tile[Map[MX, MY].Front - $28A], PX, PY + W6866);
      $2BD..$2EE:
          DrawTile(Gfx[8]^.Tile[Map[MX, MY].Front - $2BC], PX, PY + W6866);
      $2EF..$320:
          DrawTile(Gfx[9]^.Tile[Map[MX, MY].Front - $2EE], PX, PY + W6866);
    end;
  end;
end;
