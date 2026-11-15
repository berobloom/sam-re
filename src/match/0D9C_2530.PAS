{ src: SAM1RE 0D9C:2530 (../SAM objects.md: the front cell repaint at pixel X, Y: the cell's Front tile from
  its bank (1..$32 bank 1, then 50 a bank: $64.. 2, $97.. 10, $C9.. 11, $FB.. 15, $12D.. 13, $15F.. 16,
  $191.. 4, $1C3.. 5, $259.. 6, $28B.. 7, $2BD.. 8, $2EF.. 9) on the page W6866; $B3, $1F3, $265, $25B and
  $270 differ by page (two-frame animation). Columns 0..$27 only, no upper row bound) }
{ interface }
{ keep: DrawFront(0, 0); }
procedure DrawFront(X, Y: Integer);
var
  CX, CY: Integer;
begin
  CX := X shr 4;
  CY := Y shr 4;
  if (CX >= 0) and (CX <= $27) and (CY >= 0) then
    case Map[CX + 1, CY + 1].Front of
      0:
        ;
      1..$32:
        DrawTile(Gfx[1]^.Tile[Map[CX + 1, CY + 1].Front], CX shl 1, (CY shl 4) + PageY);
      $B3:
        if PageY = $10 then
          DrawTile(Gfx[10]^.Tile[29], CX shl 1, (CY shl 4) + PageY)
        else
          DrawTile(Gfx[10]^.Tile[30], CX shl 1, (CY shl 4) + PageY);
      $64..$96:
        DrawTile(Gfx[2]^.Tile[Map[CX + 1, CY + 1].Front - $64], CX shl 1, (CY shl 4) + PageY);
      $97..$C8:
        DrawTile(Gfx[10]^.Tile[Map[CX + 1, CY + 1].Front - $96], CX shl 1, (CY shl 4) + PageY);
      $C9..$FA:
        DrawTile(Gfx[11]^.Tile[Map[CX + 1, CY + 1].Front - $C8], CX shl 1, (CY shl 4) + PageY);
      $FB..$12C:
        DrawTile(Gfx[15]^.Tile[Map[CX + 1, CY + 1].Front - $FA], CX shl 1, (CY shl 4) + PageY);
      $12D..$15E:
        DrawTile(Gfx[13]^.Tile[Map[CX + 1, CY + 1].Front - $12C], CX shl 1, (CY shl 4) + PageY);
      $15F..$190:
        DrawTile(Gfx[16]^.Tile[Map[CX + 1, CY + 1].Front - $15E], CX shl 1, (CY shl 4) + PageY);
      $191..$1C2:
        DrawTile(Gfx[4]^.Tile[Map[CX + 1, CY + 1].Front - $190], CX shl 1, (CY shl 4) + PageY);
      $1F3:
        if PageY = $10 then
          DrawTile(Gfx[5]^.Tile[49], CX shl 1, (CY shl 4) + PageY)
        else
          DrawTile(Gfx[5]^.Tile[1], CX shl 1, (CY shl 4) + PageY);
      $1C3..$1F4:
        DrawTile(Gfx[5]^.Tile[Map[CX + 1, CY + 1].Front - $1C2], CX shl 1, (CY shl 4) + PageY);
      $265:
        if PageY = $10 then
          DrawTile(Gfx[6]^.Tile[13], CX shl 1, (CY shl 4) + PageY)
        else
          DrawTile(Gfx[6]^.Tile[17], CX shl 1, (CY shl 4) + PageY);
      $259..$25A:
        DrawTile(Gfx[6]^.Tile[Map[CX + 1, CY + 1].Front - $258], CX shl 1, (CY shl 4) + PageY);
      $25B:
        if PageY = $1A0 then
          DrawTile(Gfx[6]^.Tile[Map[CX + 1, CY + 1].Front - $258], CX shl 1, (CY shl 4) + PageY);
      $25C..$26F:
        DrawTile(Gfx[6]^.Tile[Map[CX + 1, CY + 1].Front - $258], CX shl 1, (CY shl 4) + PageY);
      $270:
        if PageY = $1A0 then
          DrawTile(Gfx[6]^.Tile[Map[CX + 1, CY + 1].Front - $258], CX shl 1, (CY shl 4) + PageY)
        else
          DrawTile(Gfx[6]^.Tile[Map[CX + 1, CY + 1].Front - $246], CX shl 1, (CY shl 4) + PageY);
      $271..$28A:
        DrawTile(Gfx[6]^.Tile[Map[CX + 1, CY + 1].Front - $258], CX shl 1, (CY shl 4) + PageY);
      $28B..$2BC:
        DrawTile(Gfx[7]^.Tile[Map[CX + 1, CY + 1].Front - $28A], CX shl 1, (CY shl 4) + PageY);
      $2BD..$2EE:
        DrawTile(Gfx[8]^.Tile[Map[CX + 1, CY + 1].Front - $2BC], CX shl 1, (CY shl 4) + PageY);
      $2EF..$320:
        DrawTile(Gfx[9]^.Tile[Map[CX + 1, CY + 1].Front - $2EE], CX shl 1, (CY shl 4) + PageY);
    end;
end;
