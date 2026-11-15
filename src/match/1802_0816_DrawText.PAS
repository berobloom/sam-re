{ src: SAM1RE 1802:0816 (../SAM menus.md: the window font: each character of S is looked up in the table T;
  1..$48 are cells of SAM102.GFX record 2, $49..$75 of record 3, $76.. game tiles of SAM101.GFX; '^' is
  skipped (the caret). The table's own characters are CP437 bytes) }
{ from: 0764 }
{$F+}
procedure DrawText(X, Y: Integer; S: String);
var
  I, P: Integer;
  T: String;
begin
  T := '~~~~~~~~~~~~~~~~~~|||||||||||||| !"#$%& ()*+,-./0123456789:;<=>?'
    + '@ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    + #127#128#129#130#131#132#133#134#135#136#137#138#139#140#141#142#143
    + #144#145#146#147#148#149#150#151#152#153#154#155#156#157#158#159#160
    + #161#162#163#164#165#166#167#168#169#170#171#172#173#174#175#176#177
    + #178#179#180#181#182#183#184;
  for I := 1 to Length(S) do
  begin
    P := Pos(Copy(S, I, 1), T);
    if Copy(S, I, 1) <> '^' then
      if (P >= $5D) and (P < $76) then
        DrawCellM(GfxSmall[3]^.Cell[P - $5D + $15], X + I - 1, (Y shl 3) + ScanPage)
      else if P <= $48 then
        case P of
          $20..$48: DrawCellM(GfxSmall[2]^.Cell[P - $20 + $0A], X + I - 1, (Y shl 3) + ScanPage);
        end
      else if P >= $76 then
        case P of
          $76: DrawTile(Gfx[14]^.Tile[1], X + I - 1, (Y shl 3) + ScanPage);
          $77: DrawTile(Gfx[14]^.Tile[7], X + I - 1, (Y shl 3) + ScanPage);
          $78: DrawTile(Gfx[1]^.Tile[15], X + I - 1, (Y shl 3) + ScanPage);
          $79: DrawTile(Gfx[1]^.Tile[16], X + I - 1, (Y shl 3) + ScanPage);
          $7A: DrawTile(Gfx[1]^.Tile[13], X + I - 1, (Y shl 3) + ScanPage);
          $7B: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
          $7C: DrawTile(Gfx[2]^.Tile[4], X + I - 1, (Y shl 3) + ScanPage);
          $7D: DrawTile(Gfx[2]^.Tile[8], X + I - 1, (Y shl 3) + ScanPage);
          $7E: DrawTile(Gfx[2]^.Tile[34], X + I - 1, (Y shl 3) + ScanPage);
          $7F: DrawTile(Gfx[2]^.Tile[21], X + I - 1, (Y shl 3) + ScanPage);
          $80: DrawTile(Gfx[4]^.Tile[21], X + I - 1, (Y shl 3) + ScanPage);
          $81: DrawTile(Gfx[4]^.Tile[23], X + I - 1, (Y shl 3) + ScanPage);
          $82: DrawTile(Gfx[4]^.Tile[25], X + I - 1, (Y shl 3) + ScanPage);
          $83: DrawTile(Gfx[4]^.Tile[22], X + I - 1, (Y shl 3) + ScanPage);
          $84: DrawTile(Gfx[4]^.Tile[24], X + I - 1, (Y shl 3) + ScanPage);
          $85: DrawTile(Gfx[4]^.Tile[26], X + I - 1, (Y shl 3) + ScanPage);
          $86: DrawTile(Gfx[4]^.Tile[47], X + I - 1, (Y shl 3) + ScanPage);
          $87: DrawTile(Gfx[6]^.Tile[4], X + I - 1, (Y shl 3) + ScanPage);
          $88: DrawTile(Gfx[6]^.Tile[5], X + I - 1, (Y shl 3) + ScanPage);
          $89: DrawTile(Gfx[6]^.Tile[33], X + I - 1, (Y shl 3) + ScanPage);
          $8A: DrawTile(Gfx[6]^.Tile[37], X + I - 1, (Y shl 3) + ScanPage);
          $8B: DrawTile(Gfx[6]^.Tile[19], X + I - 1, (Y shl 3) + ScanPage);
          $8C: DrawTile(Gfx[6]^.Tile[18], X + I - 1, (Y shl 3) + ScanPage);
          $8D: DrawTile(Gfx[6]^.Tile[20], X + I - 1, (Y shl 3) + ScanPage);
          $8E: DrawTile(Gfx[6]^.Tile[29], X + I - 1, (Y shl 3) + ScanPage);
          $8F: DrawTile(Gfx[6]^.Tile[30], X + I - 1, (Y shl 3) + ScanPage);
          $90: DrawTile(Gfx[6]^.Tile[31], X + I - 1, (Y shl 3) + ScanPage);
          $91: DrawTile(Gfx[6]^.Tile[32], X + I - 1, (Y shl 3) + ScanPage);
          $92: DrawTile(Gfx[6]^.Tile[35], X + I - 1, (Y shl 3) + ScanPage);
          $93: DrawTile(Gfx[7]^.Tile[25], X + I - 1, (Y shl 3) + ScanPage);
          $94: DrawTile(Gfx[13]^.Tile[1], X + I - 1, (Y shl 3) + ScanPage);
          $95: DrawTile(Gfx[13]^.Tile[4], X + I - 1, (Y shl 3) + ScanPage);
          $96: DrawTile(Gfx[13]^.Tile[13], X + I - 1, (Y shl 3) + ScanPage);
          $97: DrawTile(Gfx[13]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
          $98: DrawTile(Gfx[13]^.Tile[16], X + I - 1, (Y shl 3) + ScanPage);
          $99: DrawTile(Gfx[12]^.Tile[1], X + I - 1, (Y shl 3) + ScanPage);
          $9A: DrawTile(Gfx[12]^.Tile[5], X + I - 1, (Y shl 3) + ScanPage);
          $9B: DrawTile(Gfx[12]^.Tile[32], X + I - 1, (Y shl 3) + ScanPage);
          $9C: DrawTile(Gfx[12]^.Tile[36], X + I - 1, (Y shl 3) + ScanPage);
          $9D: DrawTile(Gfx[12]^.Tile[37], X + I - 1, (Y shl 3) + ScanPage);
          $9E: DrawTile(Gfx[3]^.Tile[2], X + I - 1, (Y shl 3) + ScanPage);
          $9F: DrawTile(Gfx[3]^.Tile[1], X + I - 1, (Y shl 3) + ScanPage);
          $A0: DrawTile(Gfx[16]^.Tile[1], X + I - 1, (Y shl 3) + ScanPage);
          $A1: DrawTile(Gfx[16]^.Tile[9], X + I - 1, (Y shl 3) + ScanPage);
          $A2: DrawTile(Gfx[16]^.Tile[18], X + I - 1, (Y shl 3) + ScanPage);
          $A3: DrawTile(Gfx[16]^.Tile[25], X + I - 1, (Y shl 3) + ScanPage);
          $A4: DrawTile(Gfx[16]^.Tile[36], X + I - 1, (Y shl 3) + ScanPage);
          $A5: DrawTile(Gfx[10]^.Tile[2], X + I - 1, (Y shl 3) + ScanPage);
          $A6: DrawTile(Gfx[10]^.Tile[30], X + I - 1, (Y shl 3) + ScanPage);
          $A7: DrawTile(Gfx[10]^.Tile[33], X + I - 1, (Y shl 3) + ScanPage);
          $A8: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
          $A9: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
          $AA: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
          $AB: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
          $AC: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
          $AD: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
          $AE: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
          $AF: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
          $B0: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
          $B1: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
          $B2: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
          $B3: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
          $B4: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
          $B5: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
          $B6: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
          $B7: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + ScanPage);
        end
      else
        DrawCellM(GfxSmall[3]^.Cell[P - $48], X + I - 1, (Y shl 3) + ScanPage);
  end;
end;
{$F-}
