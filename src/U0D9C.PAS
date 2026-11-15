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
procedure DrawBack(X, Y: Integer);
procedure DrawFront(X, Y: Integer);
procedure LoadLevel(N: Integer);
implementation
{$F+} procedure DrawSheet(X, Y: Integer); forward; {$F-}
{$F+} procedure SetCell(X, Y, Back, Mid, Front: Integer; Solid, FlagB: Byte; FrontOnly: Boolean); forward; {$F-}
{$F+} procedure WorldCell(X, Y: Integer; S: String); forward; {$F-}
{$F+} procedure SpawnActor(X, Y: Integer; S: String; FO: Boolean); forward; {$F-}
{$F+} procedure ParseRow(Y: Integer; Row: TRow); forward; {$F-}
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
{ keep: - }
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
{ keep: - }
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
{ keep: - }
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
{ src: SAM1RE 0D9C:68A9 (../SAM level-load.md: the row parser. Row Y of the map from Row's 40 chars: a row
  that starts with '*' keeps its cells (FO), else they are cleared first. For each column: a space is the
  background tile 2; on levels > 1 the char chain sets cells (SetCell) and spawns actors inline (slot
  W6854) or through SpawnActor; then WorldCell, and 'Y' is the player's start: slot 1 there (on the world
  map at the stored State position), the camera centred on it and clamped) }
{ from: 66F9 }
{ keep: - }
{$F+}
procedure ParseRow(Y: Integer; Row: TRow);
var
  I: Integer;
  S: String;
  SI, SY: Integer;
  FO: Boolean;
begin
  if Row[1] <> '*' then
  begin
    FO := False;
    for I := 1 to 40 do
    begin
      Map[I, Y + 1].Back := 0;
      Map[I, Y + 1].Mid := 0;
      Map[I, Y + 1].Front := 0;
      Map[I, Y + 1].Solid := 0;
      Map[I, Y + 1].FlagB := 0;
    end;
  end
  else
    FO := True;
  for I := 0 to $27 do
  begin
    MemW[0:$41C] := MemW[0:$41A];
    S := Row[I + 1];
    if (S = ' ') and not FO then
      SetCell(I, Y, 2, 0, 0, 0, 0, FO);
    if Level > 1 then
    begin
      if S = '1' then
        SetCell(I, Y, 1, 0, 0, 1, 0, FO);
      if S = '2' then
        SetCell(I, Y, 3, 0, 0, 1, 0, FO);
      if S = '3' then
        SetCell(I, Y, 4, 0, 0, 1, 0, FO);
      if S = '5' then
        SetCell(I, Y, 5, 0, 0, 0, 0, FO);
      if S = '6' then
        SetCell(I, Y, 6, 0, 0, 0, 0, FO);
      if S = '7' then
        SetCell(I, Y, 7, 0, 0, 0, 0, FO);
      if S = #30 then
        SetCell(I, Y, 8, 0, 0, 0, 0, FO);
      if S = 'w' then
      begin
        SetCell(I, Y - 1, 2, 0, $B3, 1, 0, FO);
        SetCell(I, Y, 2, 0, $B7, 0, 0, FO);
      end;
      if S = #1 then
        SetCell(I, Y, 2, 0, $26B, 0, 0, FO);
      if S = #2 then
        SetCell(I, Y, 2, $A1, 0, 0, 0, FO);
      if S = #3 then
        SetCell(I, Y, 2, $A2, 0, 0, 0, FO);
      if S = #4 then
        SetCell(I, Y, 2, $9B, 0, 0, 0, FO);
      if S = #6 then
        SetCell(I, Y, 2, $9E, 0, 0, 0, FO);
      if S = #5 then
      begin
        SetCell(I - 1, Y, $9C, 0, 0, 0, 1, FO);
        SetCell(I, Y, $9D, 0, 0, 0, 1, FO);
      end;
      if S = #7 then
        SetCell(I, Y, 2, $AE, 0, 0, 0, FO);
      if S = #8 then
      begin
        SetCell(I - 1, Y, 2, $B5, 0, 0, 1, FO);
        SetCell(I, Y, 2, $B6, 0, 0, 1, FO);
      end;
      if S = #12 then
      begin
        SetCell(I - 1, Y, 2, $B9, 0, 0, 1, FO);
        SetCell(I, Y, 2, $BA, 0, 0, 1, FO);
      end;
      if S = #11 then
        SetCell(I, Y, 2, $B2, 0, 0, 1, FO);
      if S = #14 then
        SetCell(I, Y, 2, $2DD, 0, 0, 0, FO);
      if S = #15 then
        SetCell(I, Y, 2, $2DE, 0, 0, 0, FO);
      if S = #16 then
        SetCell(I, Y, 2, $2DF, 0, 0, 0, FO);
      if S = #17 then
        SetCell(I, Y, 2, $2E1, 0, 0, 0, FO);
      if S = #18 then
        SetCell(I, Y, 2, $2E5, 0, 0, 0, FO);
      if S = #19 then
        SetCell(I, Y, 2, $2E7, 0, 0, 0, FO);
      if S = #20 then
      begin
        SetCell(I, Y - 1, 2, $2E9, 0, 0, 0, FO);
        SetCell(I, Y, 2, $2ED, 0, 0, 0, FO);
      end;
      if S = #21 then
        SetCell(I, Y, 2, $2EA, 0, 0, 0, FO);
      if S = #22 then
        SetCell(I, Y, 2, $2EE, 0, 0, 0, FO);
      if S = #23 then
        SetCell(I, Y, 2, $2A5, 0, 0, 0, FO);
      if S = #24 then
        SetCell(I, Y, 2, $2A6, 0, 0, 0, FO);
      if S = #25 then
      begin
        SetCell(I, Y - 1, 2, $FB, 0, 0, 1, FO);
        SetCell(I, Y, 2, $FF, 0, 0, 0, FO);
      end;
      if S = #27 then
      begin
        SetCell(I - 1, Y - 1, 2, $FC, 0, 0, 1, FO);
        SetCell(I, Y - 1, 2, $FD, 0, 0, 1, FO);
        SetCell(I - 1, Y, 2, $100, 0, 0, 0, FO);
        SetCell(I, Y, 2, $101, 0, 0, 0, FO);
      end;
      if S = #28 then
      begin
        SetCell(I, Y - 1, 2, $FE, 0, 0, 1, FO);
        SetCell(I, Y, 2, $102, 0, 0, 0, FO);
      end;
      if S = '^' then
        SetCell(I, Y, 2, 0, $13A, 0, 0, FO);
      if S = 'K' then
        SetCell(I, Y, 2, 0, $25E, 0, 0, FO);
      if S = 'I' then
        SetCell(I, Y, W6840, 0, 0, 0, 1, FO);
      if S = #211 then
        SetCell(I, Y, W6840, 0, -1, 0, 0, FO);
      if S = 'r' then
        SetCell(I, Y, 2, 0, $25F, 0, 0, FO);
      if S = 's' then
        SetCell(I, Y, 2, 0, $12D, 0, 0, FO);
      if S = 'N' then
        SetCell(I, Y, 2, 0, $139, 0, 0, FO);
      if S = 'T' then
        SetCell(I, Y, 2, 0, $13C, 0, 0, FO);
      if S = 'W' then
        SetCell(I, Y, 2, 0, $26A, 0, 0, FO);
      if S = '\' then
        SetCell(I, Y, 2, 0, $26C, 0, 0, FO);
      if S = ']' then
        SetCell(I, Y, 2, 0, $275, 0, 0, FO);
      if S = 'd' then
        SetCell(I, Y, 2, 0, $276, 0, 0, FO);
      if S = 'f' then
        SetCell(I, Y, 2, 0, $277, 0, 0, FO);
      if S = 'h' then
        SetCell(I, Y, 2, 0, $278, 0, 0, FO);
      if S = ':' then
        SetCell(I, Y, 2, 0, $1D2, 0, 0, FO);
      if S = 'H' then
        SetCell(I, Y, 2, 0, $1D4, 0, 0, FO);
      if S = 'M' then
        SetCell(I, Y, 2, 0, $270, 0, 0, FO);
      if S = 'P' then
        SetCell(I, Y, 2, 0, $130, 0, 0, FO);
      if S = 'p' then
      begin
        SetCell(I - 1, Y, 2, $9F, 0, 0, 0, FO);
        SetCell(I, Y, 2, $A0, 0, 0, 0, FO);
      end;
      if S = #139 then
      begin
        SetCell(I - 1, Y, W6840, $A3, 0, 1, 0, FO);
        SetCell(I, Y, W6840, $A4, 0, 1, 0, FO);
      end;
      if S = #154 then
      begin
        SetCell(I - 1, Y, W6840, $A6, 0, 1, 0, FO);
        SetCell(I, Y, W6840, $A5, 0, 1, 0, FO);
      end;
      if S = #31 then
        SetCell(I, Y, W6840, $A6, 0, 1, 0, FO);
      if S = #168 then
        SetCell(I, Y, 2, 0, $AF, 0, 0, FO);
      if S = #169 then
        SetCell(I, Y, 2, 0, $B0, 0, 0, FO);
      if S = #170 then
        SetCell(I, Y, 2, 0, $B1, 0, 0, FO);
      if S = #171 then
      begin
        SetCell(I, Y - 1, $C2, 0, 0, 0, 1, FO);
        SetCell(I, Y, $C6, 0, 0, 0, 0, FO);
      end;
      if S = #172 then
        SetCell(I, Y, 2, $C5, 0, 0, 0, FO);
      if S = #173 then
        SetCell(I, Y, $C1, 0, 0, 0, 1, FO);
      if S = #133 then
      begin
        SetCell(I - 3, Y, 2, 0, $DD, 0, 0, FO);
        SetCell(I - 2, Y, 2, 0, $DE, 0, 1, FO);
        SetCell(I - 1, Y, 2, 0, $DF, 0, 0, FO);
        SetCell(I, Y, 2, 0, $E0, 0, 0, FO);
      end;
      if S = #134 then
      begin
        SetCell(I - 2, Y, 2, 0, $E5, 0, 0, FO);
        SetCell(I - 1, Y, 2, 0, $E6, 0, 1, FO);
        SetCell(I, Y, 2, 0, $E7, 0, 0, FO);
      end;
      if S = '+' then
        SetCell(I, Y, 2, 0, $1A5, 0, 0, FO);
      if S = ',' then
        SetCell(I, Y, 2, 0, $1A6, 1, 0, FO);
      if S = '-' then
        SetCell(I, Y, 2, 0, $1A7, 0, 0, FO);
      if S = '.' then
        SetCell(I, Y, 2, 0, $1A8, 1, 0, FO);
      if S = '/' then
        SetCell(I, Y, 2, 0, $1A9, 0, 0, FO);
      if S = '4' then
        SetCell(I, Y, 2, 0, $1AA, 1, 0, FO);
      if S = 'o' then
        SetCell(I, Y, W6840, $1A1, 0, 1, 0, FO);
      if S = 'i' then
        SetCell(I, Y, $1B9, 0, 0, 0, 0, FO);
      if S = 'j' then
        SetCell(I, Y, W6840, $1BA, 0, 0, 1, FO);
      if S = 'k' then
        SetCell(I, Y, W6840, $1BB, 0, 1, 0, FO);
      if S = 'l' then
        SetCell(I, Y, W6840, $1BC, 0, 0, 1, FO);
      if S = #149 then
        SetCell(I, Y, 2, $1C1, 0, 0, 0, FO);
      if S = '|' then
        SetCell(I, Y, 2, $1A3, 0, 0, 0, FO);
      if S = '~' then
        SetCell(I, Y, 2, $1A4, 0, 0, 0, FO);
      if S = 'm' then
      begin
        SetCell(I, Y, 2, 0, 0, 0, 0, FO);
        Inc(W6854);
        DrawTileB(Gfx[4]^.Tile[45], I shl 4, (Y shl 4) + $10);
        DrawTileB(Gfx[4]^.Tile[45], I shl 4, (Y shl 4) + $1A0);
        Slots[W6854].W00 := 0;
        Slots[W6854].W14 := $1BD;
        Slots[W6854].X := I shl 4;
        Slots[W6854].Y := Y shl 4;
        Slots[W6854].W06 := I shl 4;
        Slots[W6854].W08 := Y shl 4;
        if Random(2) > 0 then
          Slots[W6854].W16 := 1
        else
          Slots[W6854].W16 := -1;
        Slots[W6854].W18 := 0;
        Slots[W6854].W0A := 1;
        Slots[W6854].W1A := 1;
        Slots[W6854].W0C := 0;
        Slots[W6854].W0E := 0;
        Slots[W6854].W1C := $14;
        Slots[W6854].Free := 0;
        Slots[W6854].B1F := 0;
      end;
      if S = 'a' then
        SetCell(I, Y, $1F4, 0, 0, 1, 0, FO);
      if S = '`' then
        SetCell(I, Y, 2, 0, $1F3, 0, 0, FO);
      if S = '_' then
      begin
        SetCell(I, Y, 2, 0, 0, 0, 0, FO);
        Inc(W6854);
        DrawTileB(Gfx[5]^.Tile[45], I shl 4, (Y shl 4) + $10);
        DrawTileB(Gfx[5]^.Tile[45], I shl 4, (Y shl 4) + $1A0);
        Slots[W6854].W00 := 0;
        Slots[W6854].X := I shl 4;
        Slots[W6854].Y := Y shl 4;
        Slots[W6854].W06 := I shl 4;
        Slots[W6854].W08 := Y shl 4;
        if Random(2) > 0 then
          Slots[W6854].W16 := 1
        else
          Slots[W6854].W16 := -1;
        if Slots[W6854].W16 = 1 then
          Slots[W6854].W14 := $1F1
        else
          Slots[W6854].W14 := $1EF;
        Slots[W6854].W18 := 0;
        Slots[W6854].W0A := 1;
        Slots[W6854].W1A := 1;
        Slots[W6854].W0C := 0;
        Slots[W6854].W0E := 0;
        Slots[W6854].W1C := $15;
        Slots[W6854].Free := 0;
        Slots[W6854].B1F := 0;
      end;
      if S = 'D' then
        SetCell(I, Y, 2, 0, $265, 0, 0, FO);
      if S = 'E' then
        SetCell(I, Y, W6840, 0, $266, 0, 1, FO);
      if S = 'O' then
        SetCell(I, Y, 2, 0, $267, 0, 0, FO);
      if S = 'U' then
        SetCell(I, Y, 2, 0, $268, 0, 0, FO);
      if S = #128 then
        SetCell(I, Y, 2, 0, $259, 0, 0, FO);
      if S = #129 then
        SetCell(I, Y, 2, 0, $25A, 0, 0, FO);
      if S = #130 then
        SetCell(I, Y, 2, 0, $25B, 0, 0, FO);
      if S = #131 then
        SetCell(I, Y, 2, 0, $25C, 0, 0, FO);
      if S = #132 then
        SetCell(I, Y, 2, 0, $25D, 0, 0, FO);
      if S = #140 then
        SetCell(I, Y, 2, 0, $26D, 0, 0, FO);
      if S = #141 then
        SetCell(I, Y, 2, 0, $26E, 0, 0, FO);
      if S = #142 then
        SetCell(I, Y, 2, 0, $26F, 0, 0, FO);
      if S = '%' then
      begin
        SetCell(I - 1, Y, 2, 0, $1C4, 0, 0, FO);
        SetCell(I, Y, 2, 0, $1C5, 0, 0, FO);
      end;
      if S = '&' then
      begin
        SetCell(I - 1, Y - 1, $1C7, 0, 0, 1, 0, FO);
        SetCell(I, Y - 1, $1C8, 0, 0, 1, 0, FO);
        SetCell(I - 1, Y, $1CB, 0, 0, 1, 0, FO);
        SetCell(I, Y, $1CC, 0, 0, 1, 0, FO);
      end;
      if S = '(' then
      begin
        SetCell(I - 1, Y - 1, $1C9, 0, 0, 1, 0, FO);
        SetCell(I, Y - 1, $1CA, 0, 0, 1, 0, FO);
        SetCell(I - 1, Y, $1CD, 0, 0, 1, 0, FO);
        SetCell(I, Y, $1CE, 0, 0, 1, 0, FO);
      end;
      if S = ')' then
        SetCell(I, Y, 2, 0, $1CF, 0, 0, FO);
      if S = '*' then
        if I > 0 then
          SetCell(I, Y, 2, 0, $1D3, 0, 0, FO);
      if S = 'q' then
      begin
        SetCell(I, Y - 1, 2, 0, $279, 1, 0, FO);
        SetCell(I, Y, 2, 0, $27D, 1, 0, FO);
      end;
      if S = 't' then
        SetCell(I, Y, 2, 0, $27B, 0, 0, FO);
      SpawnActor(I, Y, S, FO);
      if S = #175 then
        SetCell(I, Y, $15D, 0, 0, 0, 0, FO);
      if S = #143 then
        SetCell(I, Y, W6840, $28B, 0, 1, 0, FO);
      if S = #144 then
        SetCell(I, Y, $28C, 0, 0, 1, 0, FO);
      if S = #145 then
        SetCell(I, Y, W6840, $28D, 0, 1, 0, FO);
      if S = #146 then
        SetCell(I, Y, W6840, $28E, 0, 0, 1, FO);
      if S = #147 then
        SetCell(I, Y, $28F, 0, 0, 1, 0, FO);
      if S = #148 then
        SetCell(I, Y, $290, 0, 0, 1, 0, FO);
      if S = #150 then
        SetCell(I, Y, 2, 0, $292, 0, 0, FO);
      if S = #151 then
        SetCell(I, Y, 2, 0, $293, 0, 0, FO);
      if S = #152 then
        SetCell(I, Y, 2, 0, $294, 0, 0, FO);
      if S = #153 then
        SetCell(I, Y, $295, 0, 0, 0, 0, FO);
      if S = #155 then
        SetCell(I, Y, 2, 0, $297, 0, 0, FO);
      if S = #156 then
        SetCell(I, Y, 2, 0, $298, 0, 0, FO);
      if S = #157 then
        SetCell(I, Y, 2, $299, 0, 0, 0, FO);
      if S = #158 then
        SetCell(I, Y, 2, $29A, 0, 0, 0, FO);
      if S = #163 then
        SetCell(I, Y, W6840, $29F, 0, 0, 1, FO);
      if S = #164 then
        SetCell(I, Y, W6840, $2A0, 0, 0, 1, FO);
      if S = #165 then
        SetCell(I, Y, W6840, $2A1, 0, 0, 1, FO);
      if S = #166 then
        SetCell(I, Y, W6840, $2A2, 0, 0, 1, FO);
      if S = #176 then
        SetCell(I, Y, 2, 0, $2AC, 0, 0, FO);
      if S = #177 then
        SetCell(I, Y, 2, 0, $2AD, 0, 0, FO);
      if S = #178 then
        SetCell(I, Y, 2, 0, $2AE, 0, 0, FO);
      if S = #179 then
        SetCell(I, Y, 2, 0, $2AF, 0, 0, FO);
      if S = #180 then
        SetCell(I, Y, 2, 0, $2B0, 0, 0, FO);
      if S = #181 then
        SetCell(I, Y, 2, 0, $2B1, 0, 0, FO);
      if S = #183 then
        SetCell(I, Y, 2, 0, $2B3, 0, 0, FO);
      if S = #184 then
        SetCell(I, Y, 2, 0, $2B4, 0, 0, FO);
      if S = #185 then
        SetCell(I, Y, 2, 0, $2B5, 0, 0, FO);
      if S = #186 then
      begin
        SetCell(I - 1, Y, $2B2, 0, 0, 0, 1, FO);
        SetCell(I, Y, $2B6, 0, 0, 0, 1, FO);
      end;
      if S = #187 then
        SetCell(I, Y, $2B7, 0, 0, 0, 0, FO);
      if S = #188 then
        SetCell(I, Y, $2BA, 0, 0, 0, 0, FO);
      if S = #189 then
        SetCell(I, Y, $2B8, 0, 0, 0, 0, FO);
      if S = #190 then
        SetCell(I, Y, $2B9, 0, 0, 0, 0, FO);
      if S = #191 then
      begin
        SetCell(I - 1, Y, $2A7, 0, 0, 0, 1, FO);
        SetCell(I, Y, $2A8, 0, 0, 0, 1, FO);
      end;
      if S = 'y' then
      begin
        SetCell(I - 1, Y, $13E, 0, 0, 0, 1, FO);
        SetCell(I, Y, $13F, 0, 0, 0, 1, FO);
      end;
      if S = 'z' then
        SetCell(I, Y, 2, $13D, 0, 0, 0, FO);
      if S = #135 then
      begin
        SetCell(I - 1, Y, $143, 0, 0, 0, 1, FO);
        SetCell(I, Y, $144, 0, 0, 0, 1, FO);
      end;
      if S = #182 then
        SetCell(I, Y, 2, $2A9, 0, 0, 0, FO);
      if S = #192 then
      begin
        SetCell(I - 1, Y, $2BB, 0, 0, 0, 1, FO);
        SetCell(I, Y, $2BC, 0, 0, 0, 1, FO);
      end;
      if S = #136 then
        SetCell(I, Y, 2, $159, 0, 0, 0, FO);
      if S = #137 then
        SetCell(I, Y, 2, $15A, 0, 0, 0, FO);
      if S = #138 then
        SetCell(I, Y, 2, $15B, 0, 0, 0, FO);
      if S = #162 then
        SetCell(I, Y, 2, $15C, 0, 0, 1, FO);
      if S = #193 then
        SetCell(I, Y, $2BD, 0, 0, 1, 0, FO);
      if S = #194 then
        SetCell(I, Y, $2BE, 0, 0, 1, 0, FO);
      if S = #195 then
        SetCell(I, Y, $2BF, 0, 0, 1, 0, FO);
      if S = #196 then
        SetCell(I, Y, $2C0, 0, 0, 1, 0, FO);
      if S = #197 then
        SetCell(I, Y, $2C1, 0, 0, 1, 0, FO);
      if S = #198 then
        SetCell(I, Y, $2C2, 0, 0, 1, 0, FO);
      if S = #199 then
        SetCell(I, Y, $2C3, 0, 0, 1, 0, FO);
      if S = #200 then
        SetCell(I, Y, $2C4, 0, 0, 1, 0, FO);
      if S = #201 then
        SetCell(I, Y, $2C5, 0, 0, 1, 0, FO);
      if S = #202 then
        SetCell(I, Y, 2, 0, $2C6, 0, 0, FO);
      if S = #203 then
        SetCell(I, Y, W6840, 0, $2C7, 0, 1, FO);
      if S = #204 then
        SetCell(I, Y, W6840, 0, $2C8, 0, 1, FO);
      if S = #205 then
        SetCell(I, Y, W6840, 0, $2C9, 0, 1, FO);
      if S = #206 then
        SetCell(I, Y, 2, 0, $2CA, 0, 0, FO);
      if S = #207 then
        SetCell(I, Y, 2, 0, $2CB, 0, 0, FO);
      if S = #208 then
        SetCell(I, Y, 2, 0, $2CC, 0, 0, FO);
      if S = #209 then
      begin
        SetCell(I, Y, 2, 0, 0, 0, 0, FO);
        Inc(W6854);
        DrawTileB(Gfx[16]^.Tile[1], I shl 4, (Y shl 4) + $10);
        DrawTileB(Gfx[16]^.Tile[1], I shl 4, (Y shl 4) + $1A0);
        Slots[W6854].W00 := 0;
        Slots[W6854].W14 := $2CD;
        Slots[W6854].X := I shl 4;
        Slots[W6854].Y := Y shl 4;
        Slots[W6854].W06 := I shl 4;
        Slots[W6854].W08 := Y shl 4;
        Slots[W6854].W16 := 1;
        Slots[W6854].W18 := 0;
        Slots[W6854].W0A := 1;
        Slots[W6854].W1A := 0;
        Slots[W6854].W0C := 0;
        Slots[W6854].W0E := 0;
        Slots[W6854].W1C := $1A;
        Slots[W6854].Free := 0;
        Slots[W6854].B1F := 0;
      end;
      if S = #210 then
      begin
        SetCell(I - 1, Y - 1, $BF, 0, 0, 0, 1, FO);
        SetCell(I, Y - 1, $C0, 0, 0, 0, 1, FO);
        SetCell(I - 1, Y, $C3, 0, 0, 0, 0, FO);
        SetCell(I, Y, $C4, 0, 0, 0, 0, FO);
      end;
      if S = #213 then
        SetCell(I, Y, W6840, $2D1, 0, 0, 1, FO);
      if S = #214 then
        SetCell(I, Y, W6840, $2D2, 0, 0, 1, FO);
      if S = #215 then
        SetCell(I, Y, W6840, $2D3, 0, 0, 1, FO);
      if S = #217 then
        SetCell(I, Y, 2, $2D5, 0, 0, 0, FO);
      if S = #218 then
        SetCell(I, Y, W6840, $2D6, 0, 0, 1, FO);
      if S = #219 then
        SetCell(I, Y, W6840, $2D7, 0, 0, 1, FO);
      if S = #220 then
        SetCell(I, Y, W6840, $2D8, 0, 0, 1, FO);
      if S = #221 then
        SetCell(I, Y, 2, $2D9, 0, 0, 0, FO);
      if S = #222 then
        SetCell(I, Y, W6840, $2DA, 0, 0, 1, FO);
      if S = #223 then
        SetCell(I, Y, $C9, 0, 0, 0, 1, FO);
      if S = #224 then
        SetCell(I, Y, $CA, 0, 0, 0, 1, FO);
      if S = #225 then
        SetCell(I, Y, $CB, 0, 0, 0, 1, FO);
      if S = #226 then
        SetCell(I, Y, $CD, 0, 0, 0, 0, FO);
      if S = #227 then
        SetCell(I, Y, $CE, 0, 0, 0, 0, FO);
      if S = #228 then
        SetCell(I, Y, $CF, 0, 0, 0, 0, FO);
      if S = '!' then
        SetCell(I, Y, $2EF, 0, 0, 0, 0, FO);
      if S = 'B' then
        SetCell(I, Y, W6840, $2F1, 0, 0, 1, FO);
      if S = 'C' then
        SetCell(I, Y, $2F3, 0, 0, 1, 0, FO);
      if S = 'F' then
        SetCell(I, Y, W6840, $2F4, 0, 1, 0, FO);
      if S = 'J' then
        SetCell(I, Y, W6840, $2F5, 0, 1, 0, FO);
      if S = #229 then
        SetCell(I, Y, $2F6, 0, 0, 1, 0, FO);
      if S = #230 then
        SetCell(I, Y, 2, 0, $2F7, 0, 0, FO);
      if S = #231 then
        SetCell(I, Y, 2, 0, $2F8, 0, 0, FO);
      if S = #232 then
        SetCell(I, Y, 2, 0, $2F9, 0, 0, FO);
      if S = #233 then
        SetCell(I, Y, 2, 0, $2FA, 0, 0, FO);
      if S = #234 then
        SetCell(I, Y, 2, 0, $2FB, 0, 0, FO);
      if S = #235 then
        SetCell(I, Y, 2, 0, $2FC, 0, 0, FO);
      if S = #236 then
        SetCell(I, Y, 2, 0, $2FD, 0, 0, FO);
      if S = #237 then
      begin
        SetCell(I - 1, Y, $C7, 0, 0, 0, 1, FO);
        SetCell(I, Y, $C8, 0, 0, 0, 1, FO);
      end;
      if S = #216 then
      begin
        SetCell(I - 1, Y, $10C, 0, 0, 0, 1, FO);
        SetCell(I, Y, $10D, 0, 0, 0, 1, FO);
      end;
      if S = #238 then
      begin
        SetCell(I - 2, Y, 2, $108, 0, 0, 1, FO);
        SetCell(I - 1, Y, 2, $109, 0, 0, 1, FO);
        SetCell(I, Y, 2, $10A, 0, 0, 1, FO);
      end;
      if S = #239 then
      begin
        SetCell(I, Y - 1, 2, $107, 0, 0, 1, FO);
        SetCell(I, Y, 2, $10B, 0, 0, 0, FO);
      end;
      if S = #241 then
        SetCell(I, Y, $307, 0, 0, 1, 0, FO);
      if S = #242 then
        SetCell(I, Y, $308, 0, 0, 1, 0, FO);
      if S = #243 then
        SetCell(I, Y, $309, 0, 0, 1, 0, FO);
      if S = #244 then
        SetCell(I, Y, $30A, 0, 0, 1, 0, FO);
      if S = #245 then
        SetCell(I, Y, $30B, 0, 0, 1, 0, FO);
      if S = #246 then
        SetCell(I, Y, $30C, 0, 0, 1, 0, FO);
      if S = #247 then
        SetCell(I, Y, $30D, 0, 0, 1, 0, FO);
      if S = #248 then
        SetCell(I, Y, $30E, 0, 0, 1, 0, FO);
      if S = #249 then
        SetCell(I, Y, $30F, 0, 0, 1, 0, FO);
      if S = #250 then
        SetCell(I, Y, $310, 0, 0, 1, 0, FO);
      if S = #251 then
        SetCell(I, Y, $311, 0, 0, 1, 0, FO);
      if S = #252 then
        SetCell(I, Y, $312, 0, 0, 1, 0, FO);
      if S = #253 then
        SetCell(I, Y, W6840, $313, 0, 1, 0, FO);
      if S = #254 then
        SetCell(I, Y, $314, 0, 0, 1, 0, FO);
      if S = 'L' then
        SetCell(I, Y, W6840, $315, 0, 1, 0, FO);
      if S = #159 then
        SetCell(I, Y, W6840, $317, 0, 1, 0, FO);
      if S = #160 then
        SetCell(I, Y, $318, 0, 0, 1, 0, FO);
      if S = #161 then
        SetCell(I, Y, W6840, $319, 0, 1, 0, FO);
      if S = 'S' then
        SetCell(I, Y, 2, 0, $316, 0, 0, FO);
      if S = 'Z' then
      begin
        SetCell(I - 1, Y - 1, 2, $31B, 0, 0, 1, FO);
        SetCell(I, Y - 1, 2, $31C, 0, 0, 1, FO);
        SetCell(I - 1, Y, 2, $31F, 0, 0, 0, FO);
        SetCell(I, Y, 2, $320, 0, 0, 0, FO);
      end;
      if S = #167 then
      begin
        SetCell(I, Y, 2, 0, 0, 0, 0, FO);
        Inc(W6854);
        DrawTileB(Gfx[7]^.Tile[25], I shl 4, (Y shl 4) + $10);
        DrawTileB(Gfx[7]^.Tile[25], I shl 4, (Y shl 4) + $1A0);
        Slots[W6854].W00 := 0;
        Slots[W6854].W14 := $2A3;
        Slots[W6854].X := I shl 4;
        Slots[W6854].Y := Y shl 4;
        Slots[W6854].W06 := I shl 4;
        Slots[W6854].W08 := Y shl 4;
        Slots[W6854].W16 := 1;
        Slots[W6854].W18 := 0;
        Slots[W6854].W0A := 1;
        Slots[W6854].W1A := 0;
        Slots[W6854].W0C := 0;
        Slots[W6854].W0E := 0;
        Slots[W6854].W1C := $1B;
        Slots[W6854].Free := 0;
        Slots[W6854].B1F := 0;
      end;
      if S = 'b' then
      begin
        SetCell(I, Y, 2, 0, 0, 0, 0, FO);
        Inc(W6854);
        DrawTileB(Gfx[7]^.Tile[26], I shl 4, (Y shl 4) + $10);
        DrawTileB(Gfx[7]^.Tile[26], I shl 4, (Y shl 4) + $1A0);
        Slots[W6854].W00 := 0;
        Slots[W6854].W14 := $2A4;
        Slots[W6854].X := I shl 4;
        Slots[W6854].Y := Y shl 4;
        Slots[W6854].W06 := I shl 4;
        Slots[W6854].W08 := Y shl 4;
        if Random(2) > 0 then
          Slots[W6854].W16 := 1
        else
          Slots[W6854].W16 := -1;
        Slots[W6854].W18 := 0;
        Slots[W6854].W0A := 1;
        Slots[W6854].W1A := 2;
        Slots[W6854].W0C := 0;
        Slots[W6854].W0E := 0;
        Slots[W6854].W1C := $1C;
        Slots[W6854].Free := 0;
        Slots[W6854].B1F := 0;
      end;
    end;
    WorldCell(I, Y, S);
    if S = 'Y' then
    begin
      SetCell(I, Y, 2, 0, 0, 0, 0, FO);
      SI := I;
      SY := Y;
      if (State.X <> 0) and (Level = 1) then
      begin
        I := State.X shr 4;
        Y := State.Y shr 4;
      end;
      DrawTileB(Gfx[3]^.Tile[1], I shl 4, (Y shl 4) + $10);
      DrawTileB(Gfx[3]^.Tile[1], I shl 4, (Y shl 4) + $1A0);
      Slots[1].W00 := 0;
      Slots[1].W14 := 9;
      Slots[1].X := I shl 4;
      Slots[1].Y := Y shl 4;
      Slots[1].W06 := I shl 4;
      Slots[1].W08 := Y shl 4;
      Slots[1].W16 := 1;
      Slots[1].W18 := 0;
      Slots[1].W0A := 1;
      Slots[1].W1A := 2;
      Slots[1].W0C := 0;
      Slots[1].W1C := $63;
      Slots[1].Free := 0;
      Slots[1].B1F := 0;
      CamX := (I shl 4) - $A0;
      if CamX < 0 then
        CamX := 0;
      if CamX > $140 then
        CamX := $140;
      CamY := (Y shl 4) - $64;
      if CamY < 0 then
        CamY := 0;
      if CamY > $B8 then
        CamY := $B8;
      if W70EC = 0 then
        SetViewStart(CamX, CamY + $10)
      else
        SetViewStartAlt(CamX, CamY + $10);
      I := SI;
      Y := SY;
    end;
  end;
end;
{$F-}
{ src: SAM1RE 0D9C:A1AE (../SAM level-load.md: the level loader. Resets slots 2..25 and the ten shots, then
  reads SAM103.GFX, 42-byte encrypted records: the world map (N = 1) is the first 25, level N (2..17) the
  25 after (N-1)*48. The first record's three chars are the number W6840, the next is row 24 (the sheet
  row), then rows 0..23 ('*' rows repeat the row). Then the page sweep, FadeIn(20) and sound $D) }
{ from: A1A3 }
{ interface }
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
