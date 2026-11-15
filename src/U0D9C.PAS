unit U0D9C;
{$S-,D+,L+}
interface
uses Crt, U29C3, U2891, U287F, U286F, GENUS, U25E6, U1802;
{ 0D9C data, DS:02BC..21FC; names: SAM1RE (../SAM level-load.md: base DS:01EC, 200 bytes a column, 8 a cell) }
type
  TRow = array[1..42] of Char;     { one record of SAM103.GFX: a map row, 40 chars used, encrypted }
  TCell = record                   { SAM1RE level-load.md }
    Back, Mid, Front: Integer;     { tile values }
    Solid, FlagB: Byte;            { +6 flagA (solid), +7 flagB }
  end;
var
  Map: array[1..40, 1..25] of TCell; { @02BC; column-major: Map[X, Y], 40x24 visible plus row 25 }
procedure S0D9C_3A59;
procedure DrawBack(X, Y: Integer);
procedure DrawFront(X, Y: Integer);
implementation
{$F+} procedure DrawSheet(X, Y: Integer); forward; {$F-}
{$F+} procedure SetCell(X, Y, Back, Mid, Front: Integer; Solid, FlagB: Byte; FrontOnly: Boolean); forward; {$F-}
{$F+} procedure WorldCell(X, Y: Integer; S: String); forward; {$F-}
{$F+} procedure ParseRow(Y: Integer; var Row: TRow); forward; {$F-}
{$F+} procedure LoadLevel(N: Integer); forward; {$F-}
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
        DrawTile(Gfx[1]^.Tile[Map[CX + 1, CY + 1].Front], CX shl 1, (CY shl 4) + W6866);
      $B3:
        if W6866 = $10 then
          DrawTile(Gfx[10]^.Tile[29], CX shl 1, (CY shl 4) + W6866)
        else
          DrawTile(Gfx[10]^.Tile[30], CX shl 1, (CY shl 4) + W6866);
      $64..$96:
        DrawTile(Gfx[2]^.Tile[Map[CX + 1, CY + 1].Front - $64], CX shl 1, (CY shl 4) + W6866);
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
      $265:
        if W6866 = $10 then
          DrawTile(Gfx[6]^.Tile[13], CX shl 1, (CY shl 4) + W6866)
        else
          DrawTile(Gfx[6]^.Tile[17], CX shl 1, (CY shl 4) + W6866);
      $259..$25A:
        DrawTile(Gfx[6]^.Tile[Map[CX + 1, CY + 1].Front - $258], CX shl 1, (CY shl 4) + W6866);
      $25B:
        if W6866 = $1A0 then
          DrawTile(Gfx[6]^.Tile[Map[CX + 1, CY + 1].Front - $258], CX shl 1, (CY shl 4) + W6866);
      $25C..$26F:
        DrawTile(Gfx[6]^.Tile[Map[CX + 1, CY + 1].Front - $258], CX shl 1, (CY shl 4) + W6866);
      $270:
        if W6866 = $1A0 then
          DrawTile(Gfx[6]^.Tile[Map[CX + 1, CY + 1].Front - $258], CX shl 1, (CY shl 4) + W6866)
        else
          DrawTile(Gfx[6]^.Tile[Map[CX + 1, CY + 1].Front - $246], CX shl 1, (CY shl 4) + W6866);
      $271..$28A:
        DrawTile(Gfx[6]^.Tile[Map[CX + 1, CY + 1].Front - $258], CX shl 1, (CY shl 4) + W6866);
      $28B..$2BC:
        DrawTile(Gfx[7]^.Tile[Map[CX + 1, CY + 1].Front - $28A], CX shl 1, (CY shl 4) + W6866);
      $2BD..$2EE:
        DrawTile(Gfx[8]^.Tile[Map[CX + 1, CY + 1].Front - $2BC], CX shl 1, (CY shl 4) + W6866);
      $2EF..$320:
        DrawTile(Gfx[9]^.Tile[Map[CX + 1, CY + 1].Front - $2EE], CX shl 1, (CY shl 4) + W6866);
    end;
end;
{ src: SAM1RE 0D9C:2C6E (../SAM level-load.md: SetCell, the cell X, Y (0-based) of Map gets its five fields
  and is repainted on both pages ($10 and $1A0, W6866); FrontOnly sets the front tile only. No bounds test) }
{ to: 2E20 }
{ keep: SetCell(0, 0, 0, 0, 0, 0, 0, False); }
{$F+}
procedure SetCell(X, Y, Back, Mid, Front: Integer; Solid, FlagB: Byte; FrontOnly: Boolean);
begin
  if FrontOnly then
  begin
    Map[X + 1, Y + 1].Front := Front;
    W6866 := $10;
    DrawFront(X shl 4, Y shl 4);
    W6866 := $1A0;
    DrawFront(X shl 4, Y shl 4);
    W6866 := $10;
  end
  else
  begin
    Map[X + 1, Y + 1].Back := Back;
    Map[X + 1, Y + 1].Mid := Mid;
    Map[X + 1, Y + 1].Front := Front;
    Map[X + 1, Y + 1].Solid := Solid;
    Map[X + 1, Y + 1].FlagB := FlagB;
    W6866 := $10;
    if Y = $18 then
      DrawSheet(X shl 4, Y shl 4)
    else
      DrawBack(X shl 4, Y shl 4);
    DrawFront(X shl 4, Y shl 4);
    W6866 := $1A0;
    if Y = $18 then
      DrawSheet(X shl 4, Y shl 4)
    else
      DrawBack(X shl 4, Y shl 4);
    DrawFront(X shl 4, Y shl 4);
    W6866 := $10;
  end;
end;
{$F-}
{ src: SAM1RE 0D9C:2E88 (../SAM level-load.md: the world-map cell of row char S at cell X, Y. B6868 := exactly
  15 of the 16 site counters done; on the world map (Level 1) each char gives its SetCell; the site markers
  M N O P show done or undone by SiteDone[W685A + 2], and 'l' by B6868) }
{ from: 2E20 }
{ to: 3A59 }
{ keep: WorldCell(0, 0, NameInput); }
{$F+}
procedure WorldCell(X, Y: Integer; S: String);
var
  I, N: Integer;
  FO: Boolean;
begin
  B6868 := 0;
  FO := False;
  N := 0;
  for I := 2 to $11 do
    if SiteDone[I] = 1 then
      Inc(N);
  if N = 15 then
    B6868 := 1;
  if Level = 1 then
  begin
    if S = 'A' then
      SetCell(X, Y, $1F5, 0, 0, 0, 0, FO);
    if S = 'B' then
      SetCell(X, Y, $1F6, 0, 0, 1, 0, FO);
    if S = 'C' then
      SetCell(X, Y, $1F7, 0, 0, 1, 0, FO);
    if S = 'D' then
      SetCell(X, Y, $1F8, 0, 0, 1, 0, FO);
    if S = 'E' then
      SetCell(X, Y, $1F9, 0, 0, 1, 0, FO);
    if S = 'F' then
      SetCell(X, Y, $1FA, 0, 0, 1, 0, FO);
    if S = 'G' then
      SetCell(X, Y, $1FB, 0, 0, 1, 0, FO);
    if S = 'H' then
      SetCell(X, Y, W6840, 0, 0, 0, 0, FO);
    if S = 'I' then
      SetCell(X, Y, W6840, 0, 0, 0, 0, FO);
    if S = 'J' then
      SetCell(X, Y, $295, 0, 0, 0, 0, FO);
    if S = 'K' then
      SetCell(X, Y, W6840, 0, 0, 0, 0, FO);
    if S = 'L' then
      SetCell(X, Y, W6840, 0, 0, 0, 0, FO);
    if S = 'M' then
      if SiteDone[W685A + 2] <> 0 then
        SetCell(X, Y, W685A + 2, 0, $205, 0, 0, FO)
      else
        SetCell(X, Y, W685A + 2, 0, $201, 0, 0, FO);
    if S = 'N' then
    begin
      if SiteDone[W685A + 2] <> 0 then
        SetCell(X, Y, W685A + 2, 0, $206, 0, 0, FO)
      else
        SetCell(X, Y, W685A + 2, 0, $202, 0, 0, FO);
      Inc(W685A);
    end;
    if S = 'O' then
    begin
      if SiteDone[W685A + 2] <> 0 then
        SetCell(X, Y, W685A + 2, 0, $207, 0, 0, FO)
      else
        SetCell(X, Y, W685A + 2, 0, $203, 0, 0, FO);
      Inc(W685A);
    end;
    if S = 'P' then
    begin
      if SiteDone[W685A + 2] <> 0 then
        SetCell(X, Y, W685A + 2, 0, $208, 0, 0, FO)
      else
        SetCell(X, Y, W685A + 2, 0, $204, 0, 0, FO);
      Inc(W685A);
    end;
    if S = 'Q' then
      SetCell(X, Y, $205, 0, 0, 0, 0, FO);
    if S = 'R' then
      SetCell(X, Y, $206, 0, 0, 0, 0, FO);
    if S = 'S' then
      SetCell(X, Y, $207, 0, 0, 0, 0, FO);
    if S = 'T' then
      SetCell(X, Y, $208, 0, 0, 0, 0, FO);
    if S = 'U' then
      SetCell(X, Y, $209, 0, 0, 1, 0, FO);
    if S = 'V' then
      SetCell(X, Y, $20A, 0, 0, 0, 0, FO);
    if S = 'W' then
      SetCell(X, Y, $20B, 0, 0, 0, 0, FO);
    if S = 'X' then
      SetCell(X, Y, $20C, 0, 0, 0, 0, FO);
    if S = '0' then
      SetCell(X, Y, $20D, 0, 0, 0, 0, FO);
    if S = 'Z' then
      SetCell(X, Y, $20E, 0, 0, 0, 0, FO);
    if S = 'a' then
      SetCell(X, Y, $20F, 0, 0, 1, 0, FO);
    if S = 'b' then
      SetCell(X, Y, $210, 0, 0, 0, 0, FO);
    if S = 'c' then
      SetCell(X, Y, $211, 0, 0, 0, 0, FO);
    if S = 'd' then
      SetCell(X, Y, $212, 0, 0, 0, 0, FO);
    if S = 'e' then
      SetCell(X, Y, $213, 0, 0, 0, 0, FO);
    if S = 'f' then
      SetCell(X, Y, $214, 0, 0, 1, 0, FO);
    if S = 'g' then
      SetCell(X, Y, $215, 0, 0, 1, 0, FO);
    if S = 'h' then
      SetCell(X, Y, $216, 0, 0, 0, 0, FO);
    if S = 'i' then
      SetCell(X, Y, $217, 0, 0, 0, 0, FO);
    if S = 'j' then
      SetCell(X, Y, $218, 0, 0, 0, 0, FO);
    if S = 'k' then
      SetCell(X, Y, $219, 0, 0, 0, 0, FO);
    if S = 'l' then
      if B6868 = 0 then
        SetCell(X, Y, $1FC, 0, 0, 1, 0, FO)
      else
        SetCell(X, Y, W6840, 0, 0, 0, 0, FO);
    if S = 'm' then
      SetCell(X, Y, W6840, 0, $299, 0, 0, FO);
    if S = 'n' then
      SetCell(X, Y, W6840, 0, $29A, 0, 0, FO);
    if S = 'o' then
      SetCell(X, Y, W6840, $29F, 0, 0, 1, FO);
    if S = 'p' then
      SetCell(X, Y, W6840, $2A0, 0, 0, 1, FO);
    if S = 'q' then
      SetCell(X, Y, W6840, $2A1, 0, 0, 1, FO);
    if S = 'r' then
      SetCell(X, Y, W6840, $2A2, 0, 0, 1, FO);
    if S = 's' then
      SetCell(X, Y, $2AB, 0, 0, 0, 0, FO);
    if S = 't' then
      SetCell(X, Y, W6840, 0, $2AC, 0, 0, FO);
    if S = 'u' then
      SetCell(X, Y, W6840, 0, $2AD, 0, 0, FO);
    if S = 'v' then
      SetCell(X, Y, W6840, 0, $2AE, 0, 0, FO);
    if S = 'x' then
      SetCell(X, Y, W6840, 0, $2B0, 0, 0, FO);
    if S = 'y' then
      SetCell(X, Y, W6840, 0, $2B1, 0, 0, FO);
    if S = 'z' then
      SetCell(X, Y, $2B2, 0, 0, 0, 0, FO);
    if S = 'w' then
      SetCell(X, Y, W6840, 0, $2AF, 0, 0, FO);
    if S = 'w' then
    begin
      SetCell(X, Y - 1, 2, 0, $B3, 1, 0, FO);
      SetCell(X, Y, 2, 0, $B7, 0, 0, FO);
    end;
  end;
end;
{$F-}
procedure S0D9C_3A59;
begin
DrawSheet(0, 0);;
SetCell(0, 0, 0, 0, 0, 0, 0, False);;
WorldCell(0, 0, NameInput);;
LoadLevel(0);;
Inline(>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
$00)
end;
{$F+}
procedure ParseRow(Y: Integer; var Row: TRow);
begin
Inline(>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/$00)
end;
{$F-}
{ src: SAM1RE 0D9C:A1AE (../SAM level-load.md: the level loader. Resets slots 2..25 and the ten shots, then
  reads SAM103.GFX, 42-byte encrypted records: the world map (N = 1) is the first 25, level N (2..17) the
  25 after (N-1)*48. The first record's three chars are the number W6840, the next is row 24 (the sheet
  row), then rows 0..23 ('*' rows repeat the row). Then the page sweep, FadeIn(20) and sound $D) }
{ from: A1A3 }
{ keep: LoadLevel(0); }
{$I-}
{$F+}
procedure LoadLevel(N: Integer);
var
  I: Integer;
  F: file of TRow;
  Row: TRow;
  S: String[40];
begin
  W6854 := 1;
  CopyPage;
  W6858 := -1;
  for I := 2 to 25 do
  begin
    Slots[I].W00 := 0;
    Slots[I].W14 := 9;
    Slots[I].X := -41;
    Slots[I].Y := 0;
    Slots[I].W06 := -41;
    Slots[I].W08 := 0;
    Slots[I].W16 := 1;
    Slots[I].W18 := 0;
    Slots[I].W0A := 1;
    Slots[I].W1A := 1;
    Slots[I].W0C := 0;
    Slots[I].W0E := 0;
    Slots[I].W10 := 0;
    Slots[I].W12 := 0;
    Slots[I].W1C := 1;
    Slots[I].Free := 1;
    Slots[I].B1F := 1;
  end;
  for I := 1 to 10 do
  begin
    Shots[I].W14 := 7;
    Shots[I].X := -41;
    Shots[I].Y := 0;
    Shots[I].W06 := -41;
    Shots[I].W08 := 0;
    Shots[I].W16 := 1;
    Shots[I].W18 := 0;
    Shots[I].W0A := 1;
    Shots[I].W1A := 8;
    Shots[I].W0C := 0;
    Shots[I].W1C := 1;
    Shots[I].Free := 1;
    Shots[I].B1F := 0;
  end;
  Bullets[N] := 0;
  if IOResult <> 0 then
    ;
  case N of
    1:
      begin
        W685A := 0;
        Assign(F, 'SAM103.GFX');
        Reset(F);
        Read(F, Row);
        Decrypt(Row, 40);
        S := Row[1] + Row[2] + Row[3];
        Val(S, W6840, I);
        Read(F, Row);
        Decrypt(Row, 40);
        ParseRow($18, Row);
        for I := 0 to $17 do
        begin
          Read(F, Row);
          Decrypt(Row, 40);
          if Row[1] = '*' then
            Dec(I);
          ParseRow(I, Row);
        end;
        Close(F);
      end;
    2..17:
      begin
        Assign(F, 'SAM103.GFX');
        Reset(F);
        for I := 1 to (N - 1) * $30 do
          Read(F, Row);
        Read(F, Row);
        Decrypt(Row, 40);
        S := Row[1] + Row[2] + Row[3];
        Val(S, W6840, I);
        Read(F, Row);
        Decrypt(Row, 40);
        ParseRow($18, Row);
        for I := 0 to $17 do
        begin
          Read(F, Row);
          Decrypt(Row, 40);
          if Row[1] = '*' then
            Dec(I);
          ParseRow(I, Row);
        end;
        Close(F);
      end;
  end;
  SetColor(0);
  ClearRows(0, $50, 0, 8);
  FadeIn($14);
  PlaySound($D);
end;
{$F-}
{$I+}
begin
{ init }
{ src: EXE 0D9C:A658: the unit has no initialization statements; TP emits an empty frame }
end.
