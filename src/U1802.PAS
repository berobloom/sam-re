unit U1802;
{$S-,D+,L+}
interface
uses Crt, U29C3, U2891, U287F, U286F, GENUS, U25E6;

procedure FlipPage;
procedure ShowPage;
procedure FadeIn(D: Integer);
procedure FadeOut(D: Integer);
procedure DrawStatus;
procedure ClearText;
function TextWindow(Wait: Boolean): Char;
procedure ShowLogo;
procedure TitleLoop;
procedure LoadGraphics;
procedure Blackout;
procedure SaveState;
procedure RestoreState;
procedure SaveGame(N: Integer);
function LoadGame(N: Integer): Boolean;
function AskWarp: Integer;
function EscapeMenu: Char;
procedure ShowMessage(S: String);
procedure SecurityDone;
procedure HealthBonus;
procedure OrderScreen;
procedure ShowEnding;
implementation
{$F+} procedure DrawText(X, Y: Integer; S: String); forward; {$F-}
{$F+} function InputLine(N: Integer): String; forward; {$F-}
{$F+} function PageWindow(Wait: Boolean): Char; forward; {$F-}
{$F+} procedure CheckHighScore; forward; {$F-}
{$F+} procedure ShowHelp; forward; {$F-}
{$F+} procedure Story; forward; {$F-}
{$F+} procedure OrderInfo; forward; {$F-}
{$F+} procedure HighScoreEntry; forward; {$F-}
{$F+} procedure RedefineKeys; forward; {$F-}
{$F+} procedure SaveMenu; forward; {$F-}
{$F+} function RestoreMenu: Integer; forward; {$F-}
{$F+} function MainMenu: Char; forward; {$F-}
{$F+} procedure HallOfFame; forward; {$F-}
{$F+} procedure AskQuit; forward; {$F-}
{$F+} procedure QuitMenu; forward; {$F-}
{$F+} procedure AskSound; forward; {$F-}
{$F+} procedure AskAltVideo; forward; {$F-}
{$F+} procedure AskJoystick; forward; {$F-}
{$F+} procedure CalibrateJoystick; forward; {$F-}
{$F+} function KeyName(K: Integer): String; forward; {$F-}
{$F+} procedure NoOp; forward; {$F-}
{$F+} procedure OrderMailFax; forward; {$F-}
{$F+} procedure OrderPage; forward; {$F-}
{$F+} procedure OrderSeries; forward; {$F-}
{$F+} procedure ForeignOrders; forward; {$F-}
{$F+} procedure ApogeeBBS; forward; {$F-}
{$F+} procedure AboutApogee; forward; {$F-}
{ src: SAM1RE 1802:0000 (../SAM: the page flip: W6864 page 0/1, W6866 its y offset 16 or 416) }
{ interface }
{ keep: FlipPage; }
procedure FlipPage;
begin
  if W6864 = 0 then
  begin
    W6864 := 1;
    PageY := $1A0;
  end
  else
  begin
    W6864 := 0;
    PageY := $10;
  end;
end;
{ src: SAM1RE 1802:0027 (shows the page: view start at CamX, W6866 + CamY) }
{ interface }
{ keep: ShowPage; }
procedure ShowPage;
begin
  if W70EC = 0 then
    SetViewStart(CamX, PageY + CamY)
  else
    SetViewStartAlt(CamX, PageY + CamY);
  W6862 := PageY;
end;
{ src: SAM1RE 1802:005F (palette registers 0..7 -> 0..7, 8..15 -> $10..$17, Delay(D) after each) }
{ interface }
{ keep: FadeIn(0); }
procedure FadeIn(D: Integer);
begin
  SetPalReg(0, 0);
  Delay(D);
  SetPalReg(1, 1);
  Delay(D);
  SetPalReg(2, 2);
  Delay(D);
  SetPalReg(3, 3);
  Delay(D);
  SetPalReg(4, 4);
  Delay(D);
  SetPalReg(5, 5);
  Delay(D);
  SetPalReg(6, 6);
  Delay(D);
  SetPalReg(7, 7);
  Delay(D);
  SetPalReg(8, $10);
  Delay(D);
  SetPalReg(9, $11);
  Delay(D);
  SetPalReg(10, $12);
  Delay(D);
  SetPalReg(11, $13);
  Delay(D);
  SetPalReg(12, $14);
  Delay(D);
  SetPalReg(13, $15);
  Delay(D);
  SetPalReg(14, $16);
  Delay(D);
  SetPalReg(15, $17);
  Delay(D);
end;
{ src: SAM1RE 1802:01B6 (palette registers 0..15 to black, Delay(D) before each) }
{ interface }
{ keep: FadeOut(0); }
procedure FadeOut(D: Integer);
var
  I: Integer;
begin
  for I := 0 to 15 do
  begin
    Delay(D);
    SetPalReg(I, 0);
  end;
end;
{ src: SAM1RE 1802:01E5 (../SAM level-load.md: the status line repaint: the score as six digits, the ammo as
  two, the items and one icon per life; cell-aligned when CamX is a multiple of 8, else shifted by CamX and 7.
  the cells are those of SAM102.GFX record 1: 1..10 the digits) }
{ interface }
{ keep: DrawStatus; }
procedure DrawStatus;
var
  I, Sh: Integer;
  S: String[11];
begin
  CopyPage;
  StatusCamX := CamX;
  Sh := CamX and 7;
  Str(Score:6, S);
  for I := 1 to 6 do
    if S[I] = ' ' then
      S[I] := '0';
  if Sh = 0 then
  begin
    DrawCell(GfxSmall[1]^.Cell[Ord(S[1]) - $2F], 0, 1);
    DrawCell(GfxSmall[1]^.Cell[Ord(S[2]) - $2F], 1, 1);
    DrawCell(GfxSmall[1]^.Cell[Ord(S[3]) - $2F], 2, 1);
    DrawCell(GfxSmall[1]^.Cell[Ord(S[4]) - $2F], 3, 1);
    DrawCell(GfxSmall[1]^.Cell[Ord(S[5]) - $2F], 4, 1);
    DrawCell(GfxSmall[1]^.Cell[Ord(S[6]) - $2F], 5, 1);
    DrawCell(GfxSmall[1]^.Cell[13], 12, 1);
    DrawCell(GfxSmall[1]^.Cell[11], 13, 1);
    DrawCell(GfxSmall[1]^.Cell[Ammo div 10 + 1], 14, 1);
    DrawCell(GfxSmall[1]^.Cell[Ammo mod 10 + 1], 15, 1);
    if W69CA > 0 then
      DrawCell(GfxSmall[1]^.Cell[14], 20, 1);
    if B6A1A <> 0 then
      DrawCell(GfxSmall[1]^.Cell[21], 25, 1);
    if B6A10 <> 0 then
      DrawCell(GfxSmall[1]^.Cell[18], 27, 1);
    if B6A11 <> 0 then
      DrawCell(GfxSmall[1]^.Cell[19], 28, 1);
    if B6A0F <> 0 then
      DrawCell(GfxSmall[1]^.Cell[20], 29, 1);
    if B6A12 <> 0 then
      DrawCell(GfxSmall[1]^.Cell[22], 30, 1);
    for I := 1 to Lives do
      DrawCell(GfxSmall[1]^.Cell[12], I + $20, 1);
  end
  else
  begin
    DrawCellX(GfxSmall[1]^.Cell[Ord(S[1]) - $2F], Sh, 1);
    DrawCellX(GfxSmall[1]^.Cell[Ord(S[2]) - $2F], Sh + $08, 1);
    DrawCellX(GfxSmall[1]^.Cell[Ord(S[3]) - $2F], Sh + $10, 1);
    DrawCellX(GfxSmall[1]^.Cell[Ord(S[4]) - $2F], Sh + $18, 1);
    DrawCellX(GfxSmall[1]^.Cell[Ord(S[5]) - $2F], Sh + $20, 1);
    DrawCellX(GfxSmall[1]^.Cell[Ord(S[6]) - $2F], Sh + $28, 1);
    DrawCellX(GfxSmall[1]^.Cell[13], Sh + $60, 1);
    DrawCellX(GfxSmall[1]^.Cell[11], Sh + $68, 1);
    DrawCellX(GfxSmall[1]^.Cell[Ammo div 10 + 1], Sh + $70, 1);
    DrawCellX(GfxSmall[1]^.Cell[Ammo mod 10 + 1], Sh + $78, 1);
    if W69CA > 0 then
      DrawCellX(GfxSmall[1]^.Cell[14], Sh + $A0, 1);
    if B6A1A <> 0 then
      DrawCellX(GfxSmall[1]^.Cell[21], Sh + $C8, 1);
    if B6A10 <> 0 then
      DrawCellX(GfxSmall[1]^.Cell[18], Sh + $D8, 1);
    if B6A11 <> 0 then
      DrawCellX(GfxSmall[1]^.Cell[19], Sh + $E0, 1);
    if B6A0F <> 0 then
      DrawCellX(GfxSmall[1]^.Cell[20], Sh + $E8, 1);
    if B6A12 <> 0 then
      DrawCellX(GfxSmall[1]^.Cell[22], Sh + $F0, 1);
    for I := 1 to Lives do
      DrawCellX(GfxSmall[1]^.Cell[12], Sh + $100 + (I shl 3), 1);
  end;
end;
{ src: GUESS 1802:0722 (empties the 299 text lines at DS:3838 and the 20 bytes at DS:6820) }
{ to: 0764 }
{ interface }
{ keep: ClearText; }
procedure ClearText;
var
  I: Integer;
begin
  for I := 1 to 299 do
    TextLines[I] := '';
  for I := 1 to 20 do
    B6820[I] := 0;
end;
{ src: SAM1RE 1802:0816 (../SAM menus.md: the window font: each character of S is looked up in the table T;
  1..$48 are cells of SAM102.GFX record 2, $49..$75 of record 3, $76.. game tiles of SAM101.GFX; '^' is
  skipped (the caret). The table's own characters are CP437 bytes) }
{ from: 0764 }
{ keep: - }
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
        DrawCellM(GfxSmall[3]^.Cell[P - $5D + $15], X + I - 1, (Y shl 3) + W6862)
      else if P <= $48 then
        case P of
          $20..$48: DrawCellM(GfxSmall[2]^.Cell[P - $20 + $0A], X + I - 1, (Y shl 3) + W6862);
        end
      else if P >= $76 then
        case P of
          $76: DrawTile(Gfx[14]^.Tile[1], X + I - 1, (Y shl 3) + W6862);
          $77: DrawTile(Gfx[14]^.Tile[7], X + I - 1, (Y shl 3) + W6862);
          $78: DrawTile(Gfx[1]^.Tile[15], X + I - 1, (Y shl 3) + W6862);
          $79: DrawTile(Gfx[1]^.Tile[16], X + I - 1, (Y shl 3) + W6862);
          $7A: DrawTile(Gfx[1]^.Tile[13], X + I - 1, (Y shl 3) + W6862);
          $7B: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
          $7C: DrawTile(Gfx[2]^.Tile[4], X + I - 1, (Y shl 3) + W6862);
          $7D: DrawTile(Gfx[2]^.Tile[8], X + I - 1, (Y shl 3) + W6862);
          $7E: DrawTile(Gfx[2]^.Tile[34], X + I - 1, (Y shl 3) + W6862);
          $7F: DrawTile(Gfx[2]^.Tile[21], X + I - 1, (Y shl 3) + W6862);
          $80: DrawTile(Gfx[4]^.Tile[21], X + I - 1, (Y shl 3) + W6862);
          $81: DrawTile(Gfx[4]^.Tile[23], X + I - 1, (Y shl 3) + W6862);
          $82: DrawTile(Gfx[4]^.Tile[25], X + I - 1, (Y shl 3) + W6862);
          $83: DrawTile(Gfx[4]^.Tile[22], X + I - 1, (Y shl 3) + W6862);
          $84: DrawTile(Gfx[4]^.Tile[24], X + I - 1, (Y shl 3) + W6862);
          $85: DrawTile(Gfx[4]^.Tile[26], X + I - 1, (Y shl 3) + W6862);
          $86: DrawTile(Gfx[4]^.Tile[47], X + I - 1, (Y shl 3) + W6862);
          $87: DrawTile(Gfx[6]^.Tile[4], X + I - 1, (Y shl 3) + W6862);
          $88: DrawTile(Gfx[6]^.Tile[5], X + I - 1, (Y shl 3) + W6862);
          $89: DrawTile(Gfx[6]^.Tile[33], X + I - 1, (Y shl 3) + W6862);
          $8A: DrawTile(Gfx[6]^.Tile[37], X + I - 1, (Y shl 3) + W6862);
          $8B: DrawTile(Gfx[6]^.Tile[19], X + I - 1, (Y shl 3) + W6862);
          $8C: DrawTile(Gfx[6]^.Tile[18], X + I - 1, (Y shl 3) + W6862);
          $8D: DrawTile(Gfx[6]^.Tile[20], X + I - 1, (Y shl 3) + W6862);
          $8E: DrawTile(Gfx[6]^.Tile[29], X + I - 1, (Y shl 3) + W6862);
          $8F: DrawTile(Gfx[6]^.Tile[30], X + I - 1, (Y shl 3) + W6862);
          $90: DrawTile(Gfx[6]^.Tile[31], X + I - 1, (Y shl 3) + W6862);
          $91: DrawTile(Gfx[6]^.Tile[32], X + I - 1, (Y shl 3) + W6862);
          $92: DrawTile(Gfx[6]^.Tile[35], X + I - 1, (Y shl 3) + W6862);
          $93: DrawTile(Gfx[7]^.Tile[25], X + I - 1, (Y shl 3) + W6862);
          $94: DrawTile(Gfx[13]^.Tile[1], X + I - 1, (Y shl 3) + W6862);
          $95: DrawTile(Gfx[13]^.Tile[4], X + I - 1, (Y shl 3) + W6862);
          $96: DrawTile(Gfx[13]^.Tile[13], X + I - 1, (Y shl 3) + W6862);
          $97: DrawTile(Gfx[13]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
          $98: DrawTile(Gfx[13]^.Tile[16], X + I - 1, (Y shl 3) + W6862);
          $99: DrawTile(Gfx[12]^.Tile[1], X + I - 1, (Y shl 3) + W6862);
          $9A: DrawTile(Gfx[12]^.Tile[5], X + I - 1, (Y shl 3) + W6862);
          $9B: DrawTile(Gfx[12]^.Tile[32], X + I - 1, (Y shl 3) + W6862);
          $9C: DrawTile(Gfx[12]^.Tile[36], X + I - 1, (Y shl 3) + W6862);
          $9D: DrawTile(Gfx[12]^.Tile[37], X + I - 1, (Y shl 3) + W6862);
          $9E: DrawTile(Gfx[3]^.Tile[2], X + I - 1, (Y shl 3) + W6862);
          $9F: DrawTile(Gfx[3]^.Tile[1], X + I - 1, (Y shl 3) + W6862);
          $A0: DrawTile(Gfx[16]^.Tile[1], X + I - 1, (Y shl 3) + W6862);
          $A1: DrawTile(Gfx[16]^.Tile[9], X + I - 1, (Y shl 3) + W6862);
          $A2: DrawTile(Gfx[16]^.Tile[18], X + I - 1, (Y shl 3) + W6862);
          $A3: DrawTile(Gfx[16]^.Tile[25], X + I - 1, (Y shl 3) + W6862);
          $A4: DrawTile(Gfx[16]^.Tile[36], X + I - 1, (Y shl 3) + W6862);
          $A5: DrawTile(Gfx[10]^.Tile[2], X + I - 1, (Y shl 3) + W6862);
          $A6: DrawTile(Gfx[10]^.Tile[30], X + I - 1, (Y shl 3) + W6862);
          $A7: DrawTile(Gfx[10]^.Tile[33], X + I - 1, (Y shl 3) + W6862);
          $A8: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
          $A9: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
          $AA: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
          $AB: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
          $AC: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
          $AD: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
          $AE: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
          $AF: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
          $B0: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
          $B1: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
          $B2: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
          $B3: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
          $B4: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
          $B5: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
          $B6: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
          $B7: DrawTile(Gfx[1]^.Tile[14], X + I - 1, (Y shl 3) + W6862);
        end
      else
        DrawCellM(GfxSmall[3]^.Cell[P - $48], X + I - 1, (Y shl 3) + W6862);
  end;
end;
{$F-}
{ src: SAM1RE 1802:1585 (../SAM menus.md: the text window: TextLines up to 'END OF WINDOW' in a framed box
  centred on the camera, the screen under it saved and put back; '^' marks the blinking caret; a spark runs
  along the frame now and then. Wait: any key closes it, else only the scan codes in B6820. Returns the
  key's scan code (extended keys: the code less $80; $AA and $C5 read as $174)) }
{ from: 1535 }
{ to: 1D7E }
{ interface }
{ keep: if TextWindow(False) = #0 then; }
{$F+}
function TextWindow(Wait: Boolean): Char;
var
  CX, CY, Anim, MaxW, NLines, X1, Y1, X2, Y2, W16, K, SX, SY, ST: Integer;
  SH, Spark, Done: Boolean;
begin
  Anim := 1;
  CX := 0;
  CY := 0;
  MaxW := 0;
  NLines := 0;
  Done := False;
  Spark := False;
  for RowIdx := 1 to 20 do
  begin
    if RowIdx = 1 then
      MaxW := Length(TextLines[RowIdx]) - 1;
    if Length(TextLines[RowIdx]) > MaxW then
      MaxW := Length(TextLines[RowIdx]) - 1;
    if TextLines[RowIdx] = 'END OF WINDOW' then
      NLines := RowIdx - 2;
    for SlotIdx := 1 to Length(TextLines[RowIdx]) do
      if Copy(TextLines[RowIdx], SlotIdx, 1) = '^' then
      begin
        CX := Pos('^', TextLines[RowIdx]) + 1;
        CY := RowIdx + 1;
      end;
  end;
  Inc(NLines, 3);
  X1 := (($140 - (MaxW shl 3)) div 2 + CamX) div 8 - 3;
  Y1 := (($C8 - (NLines shl 3)) div 2 + CamY) div 8 - 2;
  if CX <> 0 then
    CX := CX + X1;
  CY := CY + Y1;
  GetMem(P681C, 30000);
  GetImage(P681C^, X1, (Y1 shl 3) + W6862, X1 + MaxW + 5 + 1, ((Y1 + NLines + 2 + 1) shl 3) + W6862);
  X2 := X1 + MaxW + 4;
  Y2 := Y1 + NLines + 1;
  for W6850 := 1 to Y2 - Y1 do
    for RowIdx := X1 + 1 to X2 - 1 do
      DrawCell(GfxSmall[2]^.Cell[9], RowIdx, ((Y1 + W6850) shl 3) + W6862);
  DrawCellM(GfxSmall[2]^.Cell[1], X1, (Y1 shl 3) + W6862);
  for RowIdx := X1 + 1 to X2 - 1 do
    DrawCellM(GfxSmall[2]^.Cell[2], RowIdx, (Y1 shl 3) + W6862);
  DrawCellM(GfxSmall[2]^.Cell[3], X2, (Y1 shl 3) + W6862);
  for RowIdx := 1 to Y2 - Y1 do
  begin
    DrawCellM(GfxSmall[2]^.Cell[6], X1, ((Y1 + RowIdx) shl 3) + W6862);
    DrawCellM(GfxSmall[2]^.Cell[8], X2, ((Y1 + RowIdx) shl 3) + W6862);
    DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y1 + RowIdx) shl 3) + W6862);
  end;
  DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y2 - Y1 + Y1 + 1) shl 3) + W6862);
  DrawCellM(GfxSmall[2]^.Cell[5], X1, (Y2 shl 3) + W6862);
  for RowIdx := X1 + 1 to X2 - 1 do
    DrawCellM(GfxSmall[2]^.Cell[7], RowIdx, (Y2 shl 3) + W6862);
  DrawCellM(GfxSmall[2]^.Cell[4], X2, (Y2 shl 3) + W6862);
  for RowIdx := X1 + 1 to X2 + 1 do
    DrawCellM(GfxSmall[2]^.Cell[10], RowIdx, ((Y2 + 1) shl 3) + W6862);
  for RowIdx := 1 to NLines do
    if TextLines[RowIdx] <> 'END OF WINDOW' then
      DrawText(X1 + 2, Y1 + RowIdx + 1, TextLines[RowIdx]);
  B6EE9 := 0;
  B6EEA := 0;
  B6EF0 := 0;
  B6EF1 := 0;
  repeat
    MemW[0:$41C] := MemW[0:$41A];
  until W684A > $80;
  PlaySound($11);
  repeat
    repeat
      MemW[0:$41C] := MemW[0:$41A];
      RowIdx := Random(100);
      if not Spark then
        if RowIdx >= 99 then
        begin
          Spark := True;
          ST := 0;
          case Random(2) of
            0:
              begin
                SX := X1 + Random(X2 - X1 - 2) + 1;
                SY := Y1 shl 3;
                SH := True;
              end;
            1:
              begin
                SX := X1;
                SY := (Y1 + Random(Y2 - Y1 - 2) + 1) * 8;
                SH := False;
              end;
          end;
        end;
      if CX <> 0 then
        if W6852 > 20 then
        begin
          W6852 := 0;
          DrawCell(GfxSmall[2]^.Cell[9], CX, (CY shl 3) + W6862);
          DrawCellM(GfxSmall[3]^.Cell[Anim + $2D], CX, (CY shl 3) + W6862);
          Inc(Anim);
          if Anim > 5 then
            Anim := 1;
          if Spark then
          begin
            Inc(ST);
            if ST > 4 then
            begin
              Spark := False;
              if SH then
                DrawCellM(GfxSmall[2]^.Cell[2], SX, SY + W6862)
              else
                DrawCellM(GfxSmall[2]^.Cell[6], SX, SY + W6862);
            end
            else
            begin
              if SH then
                DrawCellM(GfxSmall[2]^.Cell[2], SX, SY + W6862)
              else
                DrawCellM(GfxSmall[2]^.Cell[6], SX, SY + W6862);
              DrawCellM(GfxSmall[2]^.Cell[ST + $25], SX, SY + W6862);
            end;
          end;
        end;
    until (W684A < $80) or (W684A = $E0);
    K := W684A;
    if K = $E0 then
    begin
      repeat
        MemW[0:$41C] := MemW[0:$41A];
      until W684A in [$9C, $9D, $AA, $B5, $B8, $C5, $C7..$C9, $CB, $CD, $CF..$D3];
      if W684A in [$AA, $C5] then
        W684A := $1F4;
      K := W684A - $80;
    end
    else
      repeat
        MemW[0:$41C] := MemW[0:$41A];
      until W684A > $80;
    if not Wait then
    begin
      for RowIdx := 1 to 20 do
        if B6820[RowIdx] <> 0 then
          if B6820[RowIdx] = K then
          begin
            TextWindow := Chr(K);
            Done := True;
          end;
    end
    else
    begin
      TextWindow := Chr(K);
      Done := True;
    end;
  until Done;
  PutImage(P681C^, X1, (Y1 shl 3) + W6862);
  FreeMem(P681C, 30000);
  MemW[0:$41C] := MemW[0:$41A];
  B6EF2 := 0;
  B6EF0 := 0;
  B6EF1 := 0;
  B6EE9 := 0;
  B6EEA := 0;
end;
{$F-}
{ src: SAM1RE 1802:1DAE (../SAM menus.md: a text window with a line editor at the '^': letters, digits and
  space up to N characters, Backspace deletes, Enter ends; the caret blinks and a spark runs along the frame) }
{ from: 1D7E }
{ to: 2603 }
{ keep: - }
{$F+}
function InputLine(N: Integer): String;
var
  CX, CY, Anim, MaxW, NLines, X1, Y1, X2, Y2, Len, W16, SX, SY, ST: Integer;
  SH, Spark, Done: Boolean;
  S: String;
  Ch: Char;
begin
  Anim := 1;
  CX := 0;
  MaxW := 0;
  NLines := 0;
  Done := False;
  Spark := False;
  for RowIdx := 1 to 20 do
  begin
    if RowIdx = 1 then
      MaxW := Length(TextLines[RowIdx]) - 1;
    if Length(TextLines[RowIdx]) > MaxW then
      MaxW := Length(TextLines[RowIdx]) - 1;
    if TextLines[RowIdx] = 'END OF WINDOW' then
      NLines := RowIdx - 2;
    for SlotIdx := 1 to Length(TextLines[RowIdx]) do
      if Copy(TextLines[RowIdx], SlotIdx, 1) = '^' then
      begin
        CX := Pos('^', TextLines[RowIdx]) + 1;
        CY := RowIdx + 1;
      end;
  end;
  Inc(NLines, 3);
  X1 := (($140 - (MaxW shl 3)) div 2 + CamX) div 8 - 3;
  Y1 := (($C8 - (NLines shl 3)) div 2 + CamY) div 8 - 2;
  CX := CX + X1;
  CY := CY + Y1;
  GetMem(P681C, 30000);
  GetImage(P681C^, X1, (Y1 shl 3) + W6862, X1 + MaxW + 5 + 1, ((Y1 + NLines + 2 + 1) shl 3) + W6862);
  X2 := X1 + MaxW + 4;
  Y2 := Y1 + NLines + 1;
  for W6850 := 1 to Y2 - Y1 do
    for RowIdx := X1 + 1 to X2 - 1 do
      DrawCell(GfxSmall[2]^.Cell[9], RowIdx, ((Y1 + W6850) shl 3) + W6862);
  DrawCellM(GfxSmall[2]^.Cell[1], X1, (Y1 shl 3) + W6862);
  for RowIdx := X1 + 1 to X2 - 1 do
    DrawCellM(GfxSmall[2]^.Cell[2], RowIdx, (Y1 shl 3) + W6862);
  DrawCellM(GfxSmall[2]^.Cell[3], X2, (Y1 shl 3) + W6862);
  for RowIdx := 1 to Y2 - Y1 do
  begin
    DrawCellM(GfxSmall[2]^.Cell[6], X1, ((Y1 + RowIdx) shl 3) + W6862);
    DrawCellM(GfxSmall[2]^.Cell[8], X2, ((Y1 + RowIdx) shl 3) + W6862);
    DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y1 + RowIdx) shl 3) + W6862);
  end;
  DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y2 - Y1 + Y1 + 1) shl 3) + W6862);
  DrawCellM(GfxSmall[2]^.Cell[5], X1, (Y2 shl 3) + W6862);
  for RowIdx := X1 + 1 to X2 - 1 do
    DrawCellM(GfxSmall[2]^.Cell[7], RowIdx, (Y2 shl 3) + W6862);
  DrawCellM(GfxSmall[2]^.Cell[4], X2, (Y2 shl 3) + W6862);
  for RowIdx := X1 + 1 to X2 + 1 do
    DrawCellM(GfxSmall[2]^.Cell[10], RowIdx, ((Y2 + 1) shl 3) + W6862);
  for RowIdx := 1 to NLines do
    if TextLines[RowIdx] <> 'END OF WINDOW' then
      DrawText(X1 + 2, Y1 + RowIdx + 1, TextLines[RowIdx]);
  B6EE9 := 0;
  B6EF0 := 0;
  B6EF1 := 0;
  B6EEA := 0;
  repeat
    MemW[0:$41C] := MemW[0:$41A];
  until Port[$60] > $80;
  S := '';
  Len := 0;
  Ch := 'Z';
  while Ch <> #13 do
  begin
    if KeyPressed then
    begin
      Ch := ReadKey;
      if Ch in [' ', '0'..'9', 'A'..'Z', 'a'..'z'] then
      begin
        if Ch >= ' ' then
          if Ch <= #127 then
            if Len < N then
            begin
              S := S + Ch;
              Inc(Len);
              DrawCell(GfxSmall[2]^.Cell[9], CX, (CY shl 3) + W6862);
              DrawText(CX, CY, Ch);
              Inc(CX);
            end;
      end
      else
        if Ch = #8 then
          if Len > 0 then
          begin
            DrawCell(GfxSmall[2]^.Cell[9], CX, (CY shl 3) + W6862);
            Dec(CX);
            DrawCell(GfxSmall[2]^.Cell[9], CX, (CY shl 3) + W6862);
            Delete(S, Length(S), 1);
            Dec(Len);
          end;
    end;
    RowIdx := Random(100);
    if not Spark then
      if RowIdx >= 99 then
      begin
        Spark := True;
        ST := 0;
        case Random(2) of
          0:
            begin
              SX := X1 + Random(X2 - X1 - 2) + 1;
              SY := Y1 shl 3;
              SH := True;
            end;
          1:
            begin
              SX := X1;
              SY := (Y1 + Random(Y2 - Y1 - 2) + 1) * 8;
              SH := False;
            end;
        end;
      end;
    if W6852 > 20 then
    begin
      W6852 := 0;
      DrawCell(GfxSmall[2]^.Cell[9], CX, (CY shl 3) + W6862);
      DrawCellM(GfxSmall[3]^.Cell[Anim + $2D], CX, (CY shl 3) + W6862);
      Inc(Anim);
      if Anim > 5 then
        Anim := 1;
      if Spark then
      begin
        Inc(ST);
        if ST > 4 then
        begin
          Spark := False;
          if SH then
            DrawCellM(GfxSmall[2]^.Cell[2], SX, SY + W6862)
          else
            DrawCellM(GfxSmall[2]^.Cell[6], SX, SY + W6862);
        end
        else
        begin
          if SH then
            DrawCellM(GfxSmall[2]^.Cell[2], SX, SY + W6862)
          else
            DrawCellM(GfxSmall[2]^.Cell[6], SX, SY + W6862);
          DrawCellM(GfxSmall[2]^.Cell[ST + $25], SX, SY + W6862);
        end;
      end;
    end;
  end;
  InputLine := S;
  PutImage(P681C^, X1, (Y1 shl 3) + W6862);
  FreeMem(P681C, 30000);
  MemW[0:$41C] := MemW[0:$41A];
  B6EE9 := 0;
  B6EF0 := 0;
  B6EF1 := 0;
  B6EEA := 0;
end;
{$F-}
{ src: SAM1RE 1802:2653 (../SAM menus.md: the paged text window: TextWindow for up to 299 lines, 16 shown;
  Down/PgDn and Up/PgUp move by 17 lines and redraw the box; no caret animation and no start sound) }
{ from: 2603 }
{ keep: - }
{$F+}
function PageWindow(Wait: Boolean): Char;
var
  CX, CY, Anim, MaxW, NLines, Total, X1, Y1, X2, Y2, Top, W1A, K, SX, SY, ST: Integer;
  SH, Spark, Done: Boolean;
begin
  Anim := 1;
  CX := 0;
  MaxW := 0;
  NLines := 0;
  Total := 0;
  Top := 0;
  Done := False;
  Spark := False;
  for RowIdx := 1 to 299 do
  begin
    if RowIdx = 1 then
      MaxW := Length(TextLines[RowIdx]) - 1;
    if Length(TextLines[RowIdx]) > MaxW then
      MaxW := Length(TextLines[RowIdx]) - 1;
    if TextLines[RowIdx] = 'END OF WINDOW' then
      NLines := RowIdx - 2;
    for SlotIdx := 1 to Length(TextLines[RowIdx]) do
      if Copy(TextLines[RowIdx], SlotIdx, 1) = '^' then
      begin
        CX := Pos('^', TextLines[RowIdx]) + 1;
        CY := RowIdx + 1;
      end;
  end;
  Total := NLines;
  if NLines > 16 then
    NLines := 16;
  Inc(NLines, 3);
  X1 := (($140 - (MaxW shl 3)) div 2 + CamX) div 8 - 3;
  Y1 := (($C8 - (NLines shl 3)) div 2 + CamY) div 8 - 2;
  CX := CX + X1;
  CY := CY + Y1;
  GetMem(P681C, 30000);
  GetImage(P681C^, X1, (Y1 shl 3) + W6862, X1 + MaxW + 5 + 1, ((Y1 + NLines + 2 + 1) shl 3) + W6862);
  X2 := X1 + MaxW + 4;
  Y2 := Y1 + NLines + 1;
  for W6850 := 1 to Y2 - Y1 do
    for RowIdx := X1 + 1 to X2 - 1 do
      DrawCell(GfxSmall[2]^.Cell[9], RowIdx, ((Y1 + W6850) shl 3) + W6862);
  DrawCellM(GfxSmall[2]^.Cell[1], X1, (Y1 shl 3) + W6862);
  for RowIdx := X1 + 1 to X2 - 1 do
    DrawCellM(GfxSmall[2]^.Cell[2], RowIdx, (Y1 shl 3) + W6862);
  DrawCellM(GfxSmall[2]^.Cell[3], X2, (Y1 shl 3) + W6862);
  for RowIdx := 1 to Y2 - Y1 do
  begin
    DrawCellM(GfxSmall[2]^.Cell[6], X1, ((Y1 + RowIdx) shl 3) + W6862);
    DrawCellM(GfxSmall[2]^.Cell[8], X2, ((Y1 + RowIdx) shl 3) + W6862);
    DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y1 + RowIdx) shl 3) + W6862);
  end;
  DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y2 - Y1 + Y1 + 1) shl 3) + W6862);
  DrawCellM(GfxSmall[2]^.Cell[5], X1, (Y2 shl 3) + W6862);
  for RowIdx := X1 + 1 to X2 - 1 do
    DrawCellM(GfxSmall[2]^.Cell[7], RowIdx, (Y2 shl 3) + W6862);
  DrawCellM(GfxSmall[2]^.Cell[4], X2, (Y2 shl 3) + W6862);
  for RowIdx := X1 + 1 to X2 + 1 do
    DrawCellM(GfxSmall[2]^.Cell[10], RowIdx, ((Y2 + 1) shl 3) + W6862);
  for RowIdx := 1 to NLines - 2 do
    if TextLines[RowIdx] <> 'END OF WINDOW' then
      DrawText(X1 + 2, Y1 + RowIdx + 1, TextLines[RowIdx]);
  B6EE9 := 0;
  B6EEA := 0;
  B6EF0 := 0;
  B6EF1 := 0;
  repeat
    MemW[0:$41C] := MemW[0:$41A];
  until W684A > $80;
  repeat
    repeat
      MemW[0:$41C] := MemW[0:$41A];
      RowIdx := Random(100);
      if not Spark then
        if RowIdx >= 99 then
        begin
          Spark := True;
          ST := 0;
          case Random(2) of
            0:
              begin
                SX := X1 + Random(X2 - X1 - 2) + 1;
                SY := Y1 shl 3;
                SH := True;
              end;
            1:
              begin
                SX := X1;
                SY := (Y1 + Random(Y2 - Y1 - 2) + 1) * 8;
                SH := False;
              end;
          end;
        end;
      if CX <> 0 then
        if W6852 > 20 then
        begin
          W6852 := 0;
          if Spark then
          begin
            Inc(ST);
            if ST > 4 then
            begin
              Spark := False;
              if SH then
                DrawCellM(GfxSmall[2]^.Cell[2], SX, SY + W6862)
              else
                DrawCellM(GfxSmall[2]^.Cell[6], SX, SY + W6862);
            end
            else
            begin
              if SH then
                DrawCellM(GfxSmall[2]^.Cell[2], SX, SY + W6862)
              else
                DrawCellM(GfxSmall[2]^.Cell[6], SX, SY + W6862);
              DrawCellM(GfxSmall[2]^.Cell[ST + $25], SX, SY + W6862);
            end;
          end;
        end;
    until (W684A < $80) or (W684A = $E0);
    K := W684A;
    if K = $E0 then
    begin
      repeat
        MemW[0:$41C] := MemW[0:$41A];
      until W684A in [$9C, $9D, $AA, $B5, $B8, $C5, $C7..$C9, $CB, $CD, $CF..$D3];
      if W684A in [$AA, $C5] then
        W684A := $1F4;
      K := W684A - $80;
    end
    else
      repeat
        MemW[0:$41C] := MemW[0:$41A];
      until W684A > $80;
    if (K = $50) or (K = $51) then
    begin
      Inc(Top, 17);
      if Total - 16 < Top then
        Top := Total - 16;
      for W6850 := 1 to Y2 - Y1 - 1 do
        for RowIdx := X1 + 1 to X2 - 1 do
          DrawCell(GfxSmall[2]^.Cell[9], RowIdx, ((Y1 + W6850) shl 3) + W6862);
      DrawCellM(GfxSmall[2]^.Cell[1], X1, (Y1 shl 3) + W6862);
      for RowIdx := X1 + 1 to X2 - 1 do
        DrawCellM(GfxSmall[2]^.Cell[2], RowIdx, (Y1 shl 3) + W6862);
      DrawCellM(GfxSmall[2]^.Cell[3], X2, (Y1 shl 3) + W6862);
      for RowIdx := 1 to Y2 - Y1 do
      begin
        DrawCellM(GfxSmall[2]^.Cell[6], X1, ((Y1 + RowIdx) shl 3) + W6862);
        DrawCellM(GfxSmall[2]^.Cell[8], X2, ((Y1 + RowIdx) shl 3) + W6862);
        DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y1 + RowIdx) shl 3) + W6862);
      end;
      DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y2 - Y1 + Y1 + 1) shl 3) + W6862);
      DrawCellM(GfxSmall[2]^.Cell[5], X1, (Y2 shl 3) + W6862);
      for RowIdx := X1 + 1 to X2 - 1 do
        DrawCellM(GfxSmall[2]^.Cell[7], RowIdx, (Y2 shl 3) + W6862);
      DrawCellM(GfxSmall[2]^.Cell[4], X2, (Y2 shl 3) + W6862);
      for RowIdx := X1 + 1 to X2 + 1 do
        DrawCellM(GfxSmall[2]^.Cell[10], RowIdx, ((Y2 + 1) shl 3) + W6862);
      for RowIdx := 1 to NLines - 2 do
        if TextLines[RowIdx] <> 'END OF WINDOW' then
          DrawText(X1 + 2, Y1 + RowIdx + 1, TextLines[RowIdx + Top]);
    end;
    if (K = $48) or (K = $49) then
    begin
      Dec(Top, 17);
      if Top < 0 then
        Top := 0;
      for W6850 := 1 to Y2 - Y1 - 1 do
        for RowIdx := X1 + 1 to X2 - 1 do
          DrawCell(GfxSmall[2]^.Cell[9], RowIdx, ((Y1 + W6850) shl 3) + W6862);
      DrawCellM(GfxSmall[2]^.Cell[1], X1, (Y1 shl 3) + W6862);
      for RowIdx := X1 + 1 to X2 - 1 do
        DrawCellM(GfxSmall[2]^.Cell[2], RowIdx, (Y1 shl 3) + W6862);
      DrawCellM(GfxSmall[2]^.Cell[3], X2, (Y1 shl 3) + W6862);
      for RowIdx := 1 to Y2 - Y1 do
      begin
        DrawCellM(GfxSmall[2]^.Cell[6], X1, ((Y1 + RowIdx) shl 3) + W6862);
        DrawCellM(GfxSmall[2]^.Cell[8], X2, ((Y1 + RowIdx) shl 3) + W6862);
        DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y1 + RowIdx) shl 3) + W6862);
      end;
      DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y2 - Y1 + Y1 + 1) shl 3) + W6862);
      DrawCellM(GfxSmall[2]^.Cell[5], X1, (Y2 shl 3) + W6862);
      for RowIdx := X1 + 1 to X2 - 1 do
        DrawCellM(GfxSmall[2]^.Cell[7], RowIdx, (Y2 shl 3) + W6862);
      DrawCellM(GfxSmall[2]^.Cell[4], X2, (Y2 shl 3) + W6862);
      for RowIdx := X1 + 1 to X2 + 1 do
        DrawCellM(GfxSmall[2]^.Cell[10], RowIdx, ((Y2 + 1) shl 3) + W6862);
      for RowIdx := 1 to NLines - 2 do
        if TextLines[RowIdx] <> 'END OF WINDOW' then
          DrawText(X1 + 2, Y1 + RowIdx + 1, TextLines[RowIdx + Top]);
    end;
    if not Wait then
    begin
      for RowIdx := 1 to 20 do
        if B6820[RowIdx] <> 0 then
          if B6820[RowIdx] = K then
          begin
            PageWindow := Chr(K);
            Done := True;
          end;
    end
    else
    begin
      PageWindow := Chr(K);
      Done := True;
    end;
  until Done;
  PutImage(P681C^, X1, (Y1 shl 3) + W6862);
  FreeMem(P681C, 30000);
  MemW[0:$41C] := MemW[0:$41A];
  B6EF2 := 0;
  B6EF0 := 0;
  B6EF1 := 0;
  B6EE9 := 0;
  B6EEA := 0;
end;
{$F-}
{ src: SAM1RE 1802:33D0 (../SAM menus: the sam1.apo logo with sound $15, then a key or about 5 s on the
  W6852 tick counter). Only R of the four locals is used. }
{ from: 33C7 }
{ to: 3477 }
{ interface }
{ keep: ShowLogo; }
procedure ShowLogo;
var
  V1, V2, R, V4: Integer;
begin
  FadeOut(0);
  R := Genus000F(2);
  R := Genus0047(1);
  R := SetStride($28);
  CamX := 0;
  CamY := 0;
  W6862 := 0;
  PageY := 0;
  R := ShowPicture('sam1.apo', 1, 0, 0);
  FadeIn($14);
  PlaySound($15);
  MemW[0:$41C] := MemW[0:$41A];
  W6852 := 0;
  repeat
  until KeyPressed or (W6852 > $2D0);
  W6852 := 0;
  FadeOut(0);
end;
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
{ src: GUESS 1802:3696 (high-score check: if Score beats entry 10, ask the name, shift the table down,
  store name (padded to 22) + Str(Score:7) and show the table. P stays unset when no entry is lower,
  which cannot happen once Score > HiScore[10]) }
{ from: 3694 }
{ to: 381C }
{$F+}
procedure CheckHighScore;
var
  I, P: Integer;
  S: String;
begin
  if Score > HiScore[10] then
  begin
    HighScoreEntry;
    for I := 10 downto 1 do
      if HiScore[I] < Score then
        P := I;
    if P < 10 then
      for I := 10 downto P + 1 do
      begin
        HiScore[I] := HiScore[I - 1];
        HiName[I] := HiName[I - 1];
      end;
    for I := Length(NameInput) to 22 do
      NameInput := NameInput + ' ';
    Str(Score:7, S);
    NameInput := NameInput + S;
    HiScore[P] := Score;
    HiName[P] := NameInput;
    HallOfFame;
  end;
end;
{$F-}
{ src: SAM1RE 1802:3832 (../SAM: loads SAM101.GFX (16 records of $1F80) and SAM102.GFX (3 of $800)
  into the heap, each decrypted; the record order is the file order) }
{ from: 381C }
{ interface }
{ keep: LoadGraphics; }
{$I-}
procedure LoadGraphics;
begin
  Assign(GfxFile, 'SAM101.GFX');
  Reset(GfxFile);
  GetMem(Gfx[14], $1F80);
  Read(GfxFile, Gfx[14]^);
  Decrypt(Gfx[14]^, $1F80);
  GetMem(Gfx[1], $1F80);
  Read(GfxFile, Gfx[1]^);
  Decrypt(Gfx[1]^, $1F80);
  GetMem(Gfx[2], $1F80);
  Read(GfxFile, Gfx[2]^);
  Decrypt(Gfx[2]^, $1F80);
  GetMem(Gfx[4], $1F80);
  Read(GfxFile, Gfx[4]^);
  Decrypt(Gfx[4]^, $1F80);
  GetMem(Gfx[5], $1F80);
  Read(GfxFile, Gfx[5]^);
  Decrypt(Gfx[5]^, $1F80);
  GetMem(Gfx[6], $1F80);
  Read(GfxFile, Gfx[6]^);
  Decrypt(Gfx[6]^, $1F80);
  GetMem(Gfx[7], $1F80);
  Read(GfxFile, Gfx[7]^);
  Decrypt(Gfx[7]^, $1F80);
  GetMem(Gfx[8], $1F80);
  Read(GfxFile, Gfx[8]^);
  Decrypt(Gfx[8]^, $1F80);
  GetMem(Gfx[9], $1F80);
  Read(GfxFile, Gfx[9]^);
  Decrypt(Gfx[9]^, $1F80);
  GetMem(Gfx[13], $1F80);
  Read(GfxFile, Gfx[13]^);
  Decrypt(Gfx[13]^, $1F80);
  GetMem(Gfx[10], $1F80);
  Read(GfxFile, Gfx[10]^);
  Decrypt(Gfx[10]^, $1F80);
  GetMem(Gfx[11], $1F80);
  Read(GfxFile, Gfx[11]^);
  Decrypt(Gfx[11]^, $1F80);
  GetMem(Gfx[12], $1F80);
  Read(GfxFile, Gfx[12]^);
  Decrypt(Gfx[12]^, $1F80);
  GetMem(Gfx[3], $1F80);
  Read(GfxFile, Gfx[3]^);
  Decrypt(Gfx[3]^, $1F80);
  GetMem(Gfx[16], $1F80);
  Read(GfxFile, Gfx[16]^);
  Decrypt(Gfx[16]^, $1F80);
  GetMem(Gfx[15], $1F80);
  Read(GfxFile, Gfx[15]^);
  Decrypt(Gfx[15]^, $1F80);
  Close(GfxFile);
  Assign(GfxSmallFile, 'SAM102.GFX');
  Reset(GfxSmallFile);
  GetMem(GfxSmall[2], $800);
  Read(GfxSmallFile, GfxSmall[2]^);
  Decrypt(GfxSmall[2]^, $800);
  GetMem(GfxSmall[3], $800);
  Read(GfxSmallFile, GfxSmall[3]^);
  Decrypt(GfxSmall[3]^, $800);
  GetMem(GfxSmall[1], $800);
  Read(GfxSmallFile, GfxSmall[1]^);
  Decrypt(GfxSmall[1]^, $800);
  Close(GfxSmallFile);
end;
{$I+}
{ src: GUESS 1802:3C17 (palette registers 0..15 to black at once) }
{ interface }
{ keep: Blackout; }
procedure Blackout;
var
  I: Integer;
begin
  for I := 0 to 15 do
    SetPalReg(I, 0);
end;
{ src: SAM1RE 1802:3C3C (../SAM physics.md: saves the game state into the store DS:6D3E) }
{ interface }
{ keep: SaveState; }
procedure SaveState;
var
  I: Integer;
begin
  State.X := Slots[1].X;
  State.Y := Slots[1].Y;
  State.Score := Score;
  State.W08 := W69C4;
  State.Ammo := Ammo;
  State.Gun := Gun;
  for I := 1 to 20 do
    State.Bullets[I] := Bullets[I];
  State.W22 := W69CA;
  State.W24 := W69CC;
  State.B26 := B69D3;
  State.W27 := W69D0;
  State.B29 := B69D2;
  State.B2A := B69D6;
  State.W2B := W69D4;
  State.W2D := W69D8;
  State.W2F := W69DC;
  State.MapSite := MapSite;
  for I := 1 to 20 do
    State.SiteDone[I] := SiteDone[I];
  State.B47 := B6A02;
end;
{ src: SAM1RE 1802:3CEF (../SAM physics.md: restores the game state from the store DS:6D3E) }
{ to: 3DA2 }
{ interface }
{ keep: RestoreState; }
procedure RestoreState;
var
  I: Integer;
begin
  Slots[1].X := State.X;
  Slots[1].Y := State.Y;
  Score := State.Score;
  W69C4 := State.W08;
  Ammo := State.Ammo;
  Gun := State.Gun;
  for I := 1 to 20 do
    Bullets[I] := State.Bullets[I];
  W69CA := State.W22;
  W69CC := State.W24;
  B69D3 := State.B26;
  W69D0 := State.W27;
  B69D2 := State.B29;
  B69D6 := State.B2A;
  W69D4 := State.W2B;
  W69D8 := State.W2D;
  W69DC := State.W2F;
  MapSite := State.MapSite;
  for I := 1 to 20 do
    SiteDone[I] := State.SiteDone[I];
  B6A02 := State.B47;
end;
{ src: GUESS 1802:3DAD (like SaveState, with the position rounded to 16 (+8, and $FFF0), then the
  store written to SAM1-<N>.SAV; called from the menus in this unit) }
{ from: 3DA2 }
{ to: 3EF5 }
{ interface }
{ keep: SaveGame(1); }
{$I-}
procedure SaveGame(N: Integer);
var
  F: file of TState;
  I: Integer;
  S: String;
begin
  State.X := (Slots[1].X + 8) and $FFF0;
  State.Y := (Slots[1].Y + 8) and $FFF0;
  State.Score := Score;
  State.W08 := W69C4;
  State.Ammo := Ammo;
  State.Gun := Gun;
  for I := 1 to 20 do
    State.Bullets[I] := Bullets[I];
  State.W22 := W69CA;
  State.W24 := W69CC;
  State.B26 := B69D3;
  State.W27 := W69D0;
  State.B29 := B69D2;
  State.B2A := B69D6;
  State.W2B := W69D4;
  State.W2D := W69D8;
  State.W2F := W69DC;
  State.MapSite := MapSite;
  for I := 1 to 20 do
    State.SiteDone[I] := SiteDone[I];
  State.B47 := B6A02;
  Str(N:1, S);
  Assign(F, 'SAM1-' + S + '.SAV');
  Rewrite(F);
  Write(F, State);
  Close(F);
end;
{$I+}
{ src: SAM1RE 1802:3F10 (../SAM menus.md: loads SAM1-<N>.SAV into the state store and restores from it, as
  RestoreState does; Reset runs twice; a missing file shows 'File Not Found!' and returns False) }
{ from: 3EF5 }
{ to: 409B }
{ interface }
{ keep: if LoadGame(0) then; }
{$I-}
{$F+}
function LoadGame(N: Integer): Boolean;
var
  F: file of TState;
  I: Integer;
  S: String;
  Ok: Boolean;
begin
  Str(N:1, S);
  Assign(F, 'SAM1-' + S + '.SAV');
  Reset(F);
  Ok := IOResult = 0;
  Reset(F);
  Ok := IOResult = 0;
  if Ok then
  begin
    Read(F, State);
    Close(F);
    Slots[1].X := State.X;
    Slots[1].Y := State.Y;
    Score := State.Score;
    W69C4 := State.W08;
    Ammo := State.Ammo;
    Gun := State.Gun;
    for I := 1 to 20 do
      Bullets[I] := State.Bullets[I];
    W69CA := State.W22;
    W69CC := State.W24;
    B69D3 := State.B26;
    W69D0 := State.W27;
    B69D2 := State.B29;
    B69D6 := State.B2A;
    W69D4 := State.W2B;
    W69D8 := State.W2D;
    W69DC := State.W2F;
    MapSite := State.MapSite;
    for I := 1 to 20 do
      SiteDone[I] := State.SiteDone[I];
    B6A02 := State.B47;
    LoadGame := True;
  end
  else
  begin
    ShowMessage('File Not Found!');
    LoadGame := False;
  end;
end;
{$F-}
{$I+}
{ src: SAM1RE 1802:4DE8 (../SAM menus.md: the help pages (Escape menu H, title menu I), through PageWindow) }
{ from: 409B }
{ to: 68DA }
{$F+}
procedure ShowHelp;
var
  I: Integer;
begin
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := 'CONTROLLING AGENT 006     Pg. 1';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '         §       ¨  ';
  Inc(I);
  TextLines[I] := 'Key                     Action';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'ALT  (Button 1)         FIRE';
  Inc(I);
  TextLines[I] := 'CTRL (Button 0)         JUMP';
  Inc(I);
  TextLines[I] := 'ARROW KEYS              MOVE';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'You start in keyboard mode.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Press F1 during the game to';
  Inc(I);
  TextLines[I] := 'use the joystick, redefine the';
  Inc(I);
  TextLines[I] := 'keyboard or any other option.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'SHORT BRIEFING            Pg. 2';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Your mission is to infiltrate';
  Inc(I);
  TextLines[I] := 'the island fortress and';
  Inc(I);
  TextLines[I] := 'retrieve the missing satellite';
  Inc(I);
  TextLines[I] := 'blueprints.';
  Inc(I);
  TextLines[I] := '                  ƒ „';
  Inc(I);
  TextLines[I] := 'The main fortress      is well';
  Inc(I);
  TextLines[I] := 'guarded and you will have to';
  Inc(I);
  TextLines[I] := 'destroy the security radars ®';
  Inc(I);
  TextLines[I] := 'on each level in order to';
  Inc(I);
  TextLines[I] := 'access it.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'ITEMS OF INTEREST         Pg. 3';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '‰  Keys match colored doors. Œ';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '  Extra shots';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Ÿ  Extra speed';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '   Gun power-up';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'œ  Pushable barrel.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'ITEMS OF INTEREST         Pg. 4';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '®  Security radar. Destroy it.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '¯  Teleporter. Takes you to a';
  Inc(I);
  TextLines[I] := '   different spot on a level.';
  Inc(I);
  TextLines[I] := '°';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '›  Dynamite.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'ž  Blueprints.  The object of';
  Inc(I);
  TextLines[I] := '   your mission.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'ITEMS OF INTEREST         Pg. 5';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '’  Level exit doors.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '“';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '  Computer terminal.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '‘  Floppy disk.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'You will have to determine how';
  Inc(I);
  TextLines[I] := 'to use these objects, 006.';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'BONUS ITEMS               Pg. 6';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'There are many bonuses to grab';
  Inc(I);
  TextLines[I] := 'as you play.  There are even a';
  Inc(I);
  TextLines[I] := 'couple of hidden ones.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '”  Money bag.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '•  Briefcase.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '–  Toothpaste for that pearly';
  Inc(I);
  TextLines[I] := '   white superhero smile.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'BONUS ITEMS               Pg. 7';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '—  Magnifying glass.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '˜  Computer card.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'š  Spy watch.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '™  Walkie-Talkie.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '¡  Teddy Bear.  The bonus of';
  Inc(I);
  TextLines[I] := '   choice with Commander Keen.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'Enemies                   Pg. 8';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'You will face many types of ';
  Inc(I);
  TextLines[I] := 'Dr. No Body@s security force.';
  Inc(I);
  TextLines[I] := 'Following is a description';
  Inc(I);
  TextLines[I] := 'of each.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '©  Guard - Armed only with a';
  Inc(I);
  TextLines[I] := '   knife. Very little threat.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'ª  Sentry - Slightly stronger';
  Inc(I);
  TextLines[I] := '   than a guard, but no match';
  Inc(I);
  TextLines[I] := '   for your skills.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'Enemies                   Pg. 9';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '«  Ninja - Highly trained in';
  Inc(I);
  TextLines[I] := '   the art of Ninja. Watch out.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '¬  Ninja Master - A very deadly';
  Inc(I);
  TextLines[I] := '   enemy. Has ability to shoot.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '­  Thug - The most deadly human';
  Inc(I);
  TextLines[I] := '   enemy. Can fire at will.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'These enemies are deadly, but';
  Inc(I);
  TextLines[I] := 'the bureau has obtained details';
  Inc(I);
  TextLines[I] := 'on the robotic enemies as well.';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'Robotic Enemies          Pg. 10';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '¦  This robot moves along the';
  Inc(I);
  TextLines[I] := '   ceiling and fires at you.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '‡  A flying robot that shoots';
  Inc(I);
  TextLines[I] := '   deadly electricity downward.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'ˆ  A ground based tank that has';
  Inc(I);
  TextLines[I] := '   very heavy armor plating.';
  Inc(I);
  TextLines[I] := '¢';
  Inc(I);
  TextLines[I] := '   Robbie the Robot. Don@t get';
  Inc(I);
  TextLines[I] := '£  this enemy angry at you.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'Robotic Enemies          Pg. 11';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '¤';
  Inc(I);
  TextLines[I] := '   This robot is difficult to';
  Inc(I);
  TextLines[I] := '¥  destroy and fires at you.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '…  This half man-half robot ';
  Inc(I);
  TextLines[I] := '   has only one weakness.';
  Inc(I);
  TextLines[I] := '†';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := ' €  This robot dog is not';
  Inc(I);
  TextLines[I] := '     man@s best friend.';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'Player Health            Pg. 12';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'When you start a new level, you';
  Inc(I);
  TextLines[I] := 'will begin with three health';
  Inc(I);
  TextLines[I] := 'hits, designated by three';
  Inc(I);
  TextLines[I] := 'pictures of your man on the';
  Inc(I);
  TextLines[I] := 'status line.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Each time you are hit, your';
  Inc(I);
  TextLines[I] := 'health decreases.  If you get';
  Inc(I);
  TextLines[I] := 'hit three times then you must';
  Inc(I);
  TextLines[I] := 'restart the level in order to';
  Inc(I);
  TextLines[I] := 'complete it.  You have infinite';
  Inc(I);
  TextLines[I] := 'men in order to win the game.';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'Playing Tips             Pg. 13';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '* Some barrels can be pushed.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '* Use Save and Restore (F1) to';
  Inc(I);
  TextLines[I] := '  save your progress.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '* Watch the robots carefully.';
  Inc(I);
  TextLines[I] := '  They have certain weaknesses.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '* If you get stuck in a level,';
  Inc(I);
  TextLines[I] := '  then use the QUIT option to';
  Inc(I);
  TextLines[I] := '  the island map and restart.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'Playing Tips             Pg. 14';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '* You can only carry ONE key of';
  Inc(I);
  TextLines[I] := '  each color at a time.  For';
  Inc(I);
  TextLines[I] := '  example, you CAN@T carry two';
  Inc(I);
  TextLines[I] := '  blue keys at the same time.';
  Inc(I);
  TextLines[I] := '  You must use one first.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '* Conserve shots.  You may need';
  Inc(I);
  TextLines[I] := '  them later.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '* Avoid exploding dynamite.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '- END OF FILE...';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  B6820[1] := 1;
  W683A := Ord(PageWindow(False));
  B6EEB := 0;
  B683C := 0;
end;
{$F-}
{ src: SAM1RE 1802:6E2D (../SAM menus.md: the story pages of the title menu's S, through PageWindow) }
{ from: 68DA }
{ to: 76B6 }
{$F+}
procedure Story;
var
  I: Integer;
begin
  ClearText;
  I := 1;
  TextLines[I] := 'CONFIDENTIAL FILE         Pg. 1';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'To:        Agent 006';
  Inc(I);
  TextLines[I] := 'Priority:  For Your Eyes Only';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '**Destroy file after reading**';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Our government scientists have';
  Inc(I);
  TextLines[I] := 'been working on a secret';
  Inc(I);
  TextLines[I] := 'project: A ruby-powered laser';
  Inc(I);
  TextLines[I] := 'satellite with the ability to';
  Inc(I);
  TextLines[I] := 'pinpoint and fire upon any';
  Inc(I);
  TextLines[I] := 'target from Earth orbit, code';
  Inc(I);
  TextLines[I] := 'named "Red Rock Rover".';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'YOUR MISSION              Pg. 2';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Two weeks ago the blueprints';
  Inc(I);
  TextLines[I] := 'were stolen by the Diabolical';
  Inc(I);
  TextLines[I] := 'Villain Society (DVS), which';
  Inc(I);
  TextLines[I] := 'will use them to build the';
  Inc(I);
  TextLines[I] := 'ultimate terrorist threat.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'You@ve been chosen by the';
  Inc(I);
  TextLines[I] := 'Bureau to infiltrate DVS';
  Inc(I);
  TextLines[I] := 'headquarters and secure the';
  Inc(I);
  TextLines[I] := 'blueprints.  The headquarters';
  Inc(I);
  TextLines[I] := 'are located on a series of';
  Inc(I);
  TextLines[I] := 'islands in the Pacific basin.';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'YOUR MISSION              Pg. 3';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Your mission, should you choose';
  Inc(I);
  TextLines[I] := 'to accept it, is to bring back';
  Inc(I);
  TextLines[I] := 'the secret blueprints to the';
  Inc(I);
  TextLines[I] := '"Red Rock Rover" project.  You';
  Inc(I);
  TextLines[I] := 'will be isolated from outside';
  Inc(I);
  TextLines[I] := 'help.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'You should be warned that this';
  Inc(I);
  TextLines[I] := 'mission is of global importance';
  Inc(I);
  TextLines[I] := 'and must succeed in order to';
  Inc(I);
  TextLines[I] := 'maintain a balance of world';
  Inc(I);
  TextLines[I] := 'power.';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'YOUR MISSION              Pg. 4';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'We do not have a file on the';
  Inc(I);
  TextLines[I] := 'head of DVS, but he is';
  Inc(I);
  TextLines[I] := 'suspected to be very cunning';
  Inc(I);
  TextLines[I] := 'and dangerous.  DVS';
  Inc(I);
  TextLines[I] := 'headquarters are built up';
  Inc(I);
  TextLines[I] := 'as an elaborate series of';
  Inc(I);
  TextLines[I] := 'fortresses on three well';
  Inc(I);
  TextLines[I] := 'guarded islands.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'As always, should you be caught';
  Inc(I);
  TextLines[I] := 'the Bureau will disavow any';
  Inc(I);
  TextLines[I] := 'knowledge of your existence.';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  B6820[1] := 1;
  W683A := Ord(PageWindow(False));
  B6EEB := 0;
  B683C := 0;
end;
{$F-}
{ src: GUESS 1802:7B9B (the ordering-information pages, shown through PageWindow; the ending shows them) }
{ from: 76B6 }
{ to: 83CA }
{$F+}
procedure OrderInfo;
var
  I: Integer;
begin
  ClearText;
  I := 1;
  TextLines[I] := 'MISSION SUCCESSFUL        Pg. 1';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Congratulations 006, you have';
  Inc(I);
  TextLines[I] := 'successfully destroyed the';
  Inc(I);
  TextLines[I] := 'first DVS headquarters and';
  Inc(I);
  TextLines[I] := 'retrieved the first blueprint.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'The Bureau has hidden a jet';
  Inc(I);
  TextLines[I] := 'raft on the island that you can';
  Inc(I);
  TextLines[I] := 'use to reach the second island';
  Inc(I);
  TextLines[I] := 'fortress.  Once there, you will';
  Inc(I);
  TextLines[I] := 'overcome new dangers and traps';
  Inc(I);
  TextLines[I] := 'to secure the second blueprint';
  Inc(I);
  TextLines[I] := 'to the "Red Rock Rover" weapon.';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'HOW TO ORDER MORE GAMES   Pg. 2';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Be sure to play the next two';
  Inc(I);
  TextLines[I] := 'exciting missions, otherwise';
  Inc(I);
  TextLines[I] := 'the world will fall prey to the';
  Inc(I);
  TextLines[I] := 'evil intentions of the DVS!';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'The next two missions are:';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := ' * Kill Again Island';
  Inc(I);
  TextLines[I] := ' * Dr. No Body';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'HOW TO ORDER MORE GAMES   Pg. 3';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'In these two missions you will';
  Inc(I);
  TextLines[I] := 'encounter all-new challenges,';
  Inc(I);
  TextLines[I] := 'hazards, henchmen, levels,';
  Inc(I);
  TextLines[I] := 'puzzles, prizes, and basically';
  Inc(I);
  TextLines[I] := 'put to test all of your secret';
  Inc(I);
  TextLines[I] := 'agent skills!';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'To order, call 1-800-GAME-123';
  Inc(I);
  TextLines[I] := 'between the hours of 8am - 7pm';
  Inc(I);
  TextLines[I] := 'Central Standard Time (CST).';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Price: $34 (incl. $4 Shipping)';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'HOW TO ORDER MORE GAMES   Pg. 4';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'This price ($34) includes all';
  Inc(I);
  TextLines[I] := 'three Secret Agent missions,';
  Inc(I);
  TextLines[I] := 'which also sell for $15 apiece.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'You may also order by mail:';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '     Apogee Software';
  Inc(I);
  TextLines[I] := '     P.O. Box 476389';
  Inc(I);
  TextLines[I] := '     Garland, TX  75047';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'All orders include: hint sheet,';
  Inc(I);
  TextLines[I] := 'cheat password, and bonus game.';
  Inc(I);
  TextLines[I] := '-------------------------------';
  Inc(I);
  TextLines[I] := 'Press PgUp-PgDn        Esc-Exit';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  B6820[1] := 1;
  W683A := Ord(PageWindow(False));
  B6EEB := 0;
  B683C := 0;
end;
{$F-}
{ src: GUESS 1802:8412 (the high-score name prompt in the text window; the name goes to NameInput) }
{ from: 83CA }
{ to: 8493 }
{$F+}
procedure HighScoreEntry;
begin
  ClearText;
  TextLines[1] := 'Congratulations! High score!';
  TextLines[2] := '';
  TextLines[3] := '      Enter your name:';
  TextLines[4] := '';
  TextLines[5] := '    ^';
  TextLines[6] := 'END OF WINDOW';
  NameInput := InputLine(20);
end;
{$F-}
{ src: SAM1RE 1802:88AF (../SAM menus.md: the keyboard redefine menu; six prompts in the order left, right,
  up, down, jump, fire, each repeated until the key has a name and differs from the earlier ones; ESC (scan
  code 1) skips the rest; then the confirm window, N redoes it all. The fire check compares NameJump with
  NameUp and NameDown, not NameFire: a bug of the original) }
{ from: 8493 }
{ nested: 850B 8781 }
{$F+}
procedure RedefineKeys;
var
  Right, Left, Up, Down, Fire, Jump, W0E: Integer;
  Ok, Valid: Boolean;

  procedure ConfirmKeys;
  begin
    ClearText;
    NameLeft := 'LEFT  - ' + NameLeft;
    NameRight := 'RIGHT - ' + NameRight;
    NameUp := 'UP    - ' + NameUp;
    NameDown := 'DOWN  - ' + NameDown;
    NameJump := 'JUMP  - ' + NameJump;
    NameFire := 'FIRE  - ' + NameFire;
    TextLines[1] := 'KEYBOARD REDEFINED';
    TextLines[2] := '';
    TextLines[3] := NameLeft;
    TextLines[4] := NameRight;
    TextLines[5] := NameUp;
    TextLines[6] := NameDown;
    TextLines[7] := NameJump;
    TextLines[8] := NameFire;
    TextLines[9] := '';
    TextLines[10] := 'Are these selections ok (Y-N): ^';
    TextLines[11] := '';
    TextLines[12] := 'END OF WINDOW';
    B6820[1] := $15;
    B6820[2] := $31;
    W683A := Ord(TextWindow(False));
    if W683A = $31 then
      RedefineKeys
    else
    begin
      KeyFire := Fire;
      KeyLeft := Left;
      KeyRight := Right;
      KeyUp := Up;
      KeyDown := Down;
      KeyJump := Jump;
    end;
  end;

  procedure KeyUnavailable;
  var
    K: Integer;
  begin
    ClearText;
    TextLines[1] := 'Sorry, that key is unavailable.';
    TextLines[2] := '';
    TextLines[3] := '  Press any key to continue.';
    TextLines[4] := '';
    TextLines[5] := '               ^';
    TextLines[6] := 'END OF WINDOW';
    K := Ord(TextWindow(True));
  end;

begin
  Valid := True;

  repeat
    Ok := True;
    ClearText;
    TextLines[1] := 'KEYBOARD REDEFINE';
    TextLines[2] := '';
    TextLines[3] := 'Select key to move left: ^';
    TextLines[4] := 'END OF WINDOW';
    Left := Ord(TextWindow(True));
    if Left = 1 then
      Valid := False;
    NameLeft := KeyName(Left);
    if Valid then
      if NameLeft = 'NULL' then
      begin
        KeyUnavailable;
        Ok := False;
      end;
  until Ok;
  if Valid then
    repeat
      Ok := True;
      ClearText;
      TextLines[1] := 'KEYBOARD REDEFINE';
      TextLines[2] := '';
      TextLines[3] := 'Select key to move right: ^';
      TextLines[4] := 'END OF WINDOW';
      B6820[1] := 1;
      Right := Ord(TextWindow(True));
      if Right = 1 then
        Valid := False;
      NameRight := KeyName(Right);
      if Valid then
        if (NameRight = 'NULL') or (NameRight = NameLeft) then
        begin
          KeyUnavailable;
          Ok := False;
        end;
    until Ok;
  if Valid then
    repeat
      Ok := True;
      ClearText;
      TextLines[1] := 'KEYBOARD REDEFINE';
      TextLines[2] := '';
      TextLines[3] := 'Select key to move up: ^';
      TextLines[4] := 'END OF WINDOW';
      B6820[1] := 1;
      Up := Ord(TextWindow(True));
      if Up = 1 then
        Valid := False;
      NameUp := KeyName(Up);
      if Valid then
        if (NameUp = 'NULL') or (NameUp = NameLeft) or (NameUp = NameRight) then
        begin
          KeyUnavailable;
          Ok := False;
        end;
    until Ok;
  if Valid then
    repeat
      Ok := True;
      ClearText;
      TextLines[1] := 'KEYBOARD REDEFINE';
      TextLines[2] := '';
      TextLines[3] := 'Select key to move down: ^';
      TextLines[4] := 'END OF WINDOW';
      B6820[1] := 1;
      Down := Ord(TextWindow(True));
      if Down = 1 then
        Valid := False;
      NameDown := KeyName(Down);
      if Valid then
        if (NameDown = 'NULL') or (NameDown = NameLeft) or (NameDown = NameRight) or
          (NameDown = NameUp) then
        begin
          KeyUnavailable;
          Ok := False;
        end;
    until Ok;
  if Valid then
    repeat
      Ok := True;
      ClearText;
      TextLines[1] := 'KEYBOARD REDEFINE';
      TextLines[2] := '';
      TextLines[3] := 'Select key to jump: ^';
      TextLines[4] := 'END OF WINDOW';
      B6820[1] := 1;
      Jump := Ord(TextWindow(True));
      if Jump = 1 then
        Valid := False;
      NameJump := KeyName(Jump);
      if Valid then
        if (NameJump = 'NULL') or (NameJump = NameLeft) or (NameJump = NameRight) or
          (NameJump = NameUp) or (NameJump = NameDown) then
        begin
          KeyUnavailable;
          Ok := False;
        end;
    until Ok;
  if Valid then
    repeat
      Ok := True;
      ClearText;
      TextLines[1] := 'KEYBOARD REDEFINE';
      TextLines[2] := '';
      TextLines[3] := 'Select key to fire: ^';
      TextLines[4] := 'END OF WINDOW';
      Fire := Ord(TextWindow(True));
      if Fire = 1 then
        Valid := False;
      NameFire := KeyName(Fire);
      if Valid then
        if (NameFire = 'NULL') or (NameFire = NameLeft) or (NameFire = NameRight) or
          (NameJump = NameUp) or (NameJump = NameDown) or (NameFire = NameJump) then
        begin
          KeyUnavailable;
          Ok := False;
        end;
    until Ok;
  if Valid then
    ConfirmKeys;
  MemW[0:$41C] := MemW[0:$41A];
end;
{$F-}
{ src: SAM1RE 1802:8E27 (the debug level warp prompt; SAM1RE: DS:684C 1..$10 -> level) }
{ from: 8DDD }
{ to: 8EE1 }
{ interface }
{ keep: if AskWarp = 0 then; }
function AskWarp: Integer;
var
  N, Code: Integer;
begin
  ClearText;
  TextLines[1] := 'Warp to which level?';
  TextLines[2] := '--------------------';
  TextLines[3] := '';
  TextLines[4] := 'Select (1-16) : ^';
  TextLines[5] := '';
  TextLines[6] := 'END OF WINDOW';
  NameInput := InputLine(2);
  MemW[0:$41C] := MemW[0:$41A];
  Val(NameInput, N, Code);
  AskWarp := N;
  B6EEB := 0;
  B683C := 0;
end;
{ src: SAM1RE 1802:8F3A (../SAM menus.md: the save menu; keys 1..9 save to slots 1..9, 0 to slot 0, the first
  IOResult only clears the error state) }
{ from: 8EE1 }
{ to: 90A0 }
{$F+}
procedure SaveMenu;
begin
  ClearText;
  TextLines[1] := 'Save Which Game?';
  TextLines[2] := '----------------';
  TextLines[3] := '';
  TextLines[4] := 'Select (0-9) : ^';
  TextLines[5] := '';
  TextLines[6] := 'END OF WINDOW';
  B6820[1] := 2;
  B6820[2] := 3;
  B6820[3] := 4;
  B6820[4] := 5;
  B6820[5] := 6;
  B6820[6] := 7;
  B6820[7] := 8;
  B6820[8] := 9;
  B6820[9] := $0A;
  B6820[10] := $0B;
  B6820[11] := $1C;
  B6820[12] := 1;
  MemW[0:$41C] := MemW[0:$41A];
  W683A := Ord(TextWindow(False));
  if IOResult = 0 then;
  case W683A of
    2..10: SaveGame(W683A - 1);
    11: SaveGame(0);
  end;
  B6EEB := 0;
  B683C := 0;
  ClearText;
  if IOResult = 0 then
    TextLines[1] := 'Game Saved!'
  else
    TextLines[1] := 'File Error!';
  TextLines[2] := 'END OF WINDOW';
  B6820[1] := $1C;
  B6820[2] := 1;
  MemW[0:$41C] := MemW[0:$41A];
  W683A := Ord(TextWindow(True));
end;
{$F-}
{ src: SAM1RE 1802:90E7 (../SAM menus.md: the restore menu; keys 1..9 load slots 1..9, 0 slot 0; returns
  the key's scan code, $1C (Enter) when the load failed) }
{ from: 90A0 }
{ to: 91F2 }
{ keep: if RestoreMenu = 0 then; }
{$F+}
function RestoreMenu: Integer;
begin
  ClearText;
  TextLines[1] := 'Restore Which Game?';
  TextLines[2] := '-------------------';
  TextLines[3] := '';
  TextLines[4] := 'Select (0-9) : ^';
  TextLines[5] := '';
  TextLines[6] := 'END OF WINDOW';
  B6820[1] := 2;
  B6820[2] := 3;
  B6820[3] := 4;
  B6820[4] := 5;
  B6820[5] := 6;
  B6820[6] := 7;
  B6820[7] := 8;
  B6820[8] := 9;
  B6820[9] := $0A;
  B6820[10] := $0B;
  B6820[11] := $1C;
  B6820[12] := 1;
  MemW[0:$41C] := MemW[0:$41A];
  W683A := Ord(TextWindow(False));
  case W683A of
    2..10:
      if not LoadGame(W683A - 1) then
        W683A := $1C;
    11:
      if not LoadGame(0) then
        W683A := $1C;
  end;
  RestoreMenu := W683A;
  B6EEB := 0;
  B683C := 0;
end;
{$F-}
{ src: SAM1RE 1802:92C4 (../SAM menus.md: the title menu; N, Space and Enter start a game ('B'); a failed
  restore returns ' '; Escape returns ' ' too) }
{ from: 91F2 }
{ to: 963C }
{ keep: if MainMenu = ' ' then; }
{$F+}
function MainMenu: Char;
var
  I: Integer;
begin
  I := 0;
  ClearText;
  Inc(I);
  TextLines[I] := '     MAIN MENU';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := ' N)ew Game';
  Inc(I);
  TextLines[I] := ' R)estore Old Game';
  Inc(I);
  TextLines[I] := ' S)tory';
  Inc(I);
  TextLines[I] := ' I)nstructions';
  Inc(I);
  TextLines[I] := ' H)igh Scores';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := ' O)rdering Info.';
  Inc(I);
  TextLines[I] := ' F)oreign Orders';
  Inc(I);
  TextLines[I] := ' C)all Our BBS';
  Inc(I);
  TextLines[I] := ' V)ideo Support';
  Inc(I);
  TextLines[I] := ' A)bout Apogee';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := ' Q)uit to DOS';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Make a selection: ^';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  B6820[1] := $31;
  B6820[2] := $17;
  B6820[3] := $23;
  B6820[4] := $13;
  B6820[5] := $1F;
  B6820[6] := $18;
  B6820[7] := $10;
  B6820[8] := $01;
  B6820[9] := $39;
  B6820[10] := $1C;
  B6820[11] := $21;
  B6820[12] := $1E;
  B6820[13] := $2E;
  B6820[14] := $2F;
  W683A := Ord(TextWindow(False));
  case W683A of
    $31, $39, $1C:
      begin
        MainMenu := 'B';
        B6EED := 0;
        W69C4 := 1;
      end;
    $17:
      begin
        ShowHelp;
        MainMenu := 'I';
      end;
    $21:
      begin
        ForeignOrders;
        MainMenu := 'F';
      end;
    $2E:
      begin
        ApogeeBBS;
        MainMenu := 'A';
      end;
    $23:
      begin
        MainMenu := 'H';
        HallOfFame;
      end;
    $1E:
      begin
        MainMenu := 'A';
        AboutApogee;
      end;
    $2F:
      begin
        MainMenu := 'V';
        AskAltVideo;
      end;
    $13:
      begin
        MainMenu := 'R';
        W69C4 := 1;
        W6D86 := RestoreMenu;
        if W6D86 = $1C then
        begin
          W6D86 := 0;
          MainMenu := ' ';
        end
        else
          B6EED := 0;
      end;
    $1F:
      begin
        MainMenu := 'S';
        Story;
      end;
    $18:
      begin
        MainMenu := 'O';
        OrderSeries;
      end;
    $10:
      begin
        AskQuit;
        if B6EEC <> 0 then
          MainMenu := 'Q'
        else
          MainMenu := ' ';
      end;
    1:
      begin
        B6EEB := 0;
        MainMenu := ' ';
      end;
  end;
end;
{$F-}
{ src: SAM1RE 1802:973F (../SAM menus.md: the Escape menu; every option closes it; the letter of the option
  is returned, 'Q' after a confirmed quit, ' ' after a cancelled one; Escape leaves the result unset) }
{ from: 963C }
{ interface }
{ keep: if EscapeMenu = ' ' then; }
function EscapeMenu: Char;
var
  K: Integer;
begin
  ClearText;
  TextLines[1] := 'Operational Command Bank';
  TextLines[2] := '------------------------';
  TextLines[3] := '';
  TextLines[4] := 'H)elp';
  TextLines[5] := 'T)oggle Sounds';
  TextLines[6] := 'V)ideo Select';
  TextLines[7] := 'J)oystick Toggle';
  TextLines[8] := 'C)alibrate Joystick';
  TextLines[9] := 'K)eyboard Config';
  TextLines[10] := 'R)estore Game';
  TextLines[11] := 'S)ave Game';
  TextLines[12] := 'Q)uit';
  TextLines[13] := '';
  TextLines[14] := 'Selection: ^';
  TextLines[15] := '';
  TextLines[16] := 'END OF WINDOW';
  B6820[1] := $23;
  B6820[2] := $14;
  B6820[3] := $2F;
  B6820[4] := $24;
  B6820[5] := $2E;
  B6820[6] := $25;
  B6820[7] := $13;
  B6820[8] := $1F;
  B6820[9] := $10;
  B6820[10] := 1;
  W683A := Ord(TextWindow(False));
  case W683A of
    $23:
      begin
        EscapeMenu := 'H';
        ShowHelp;
      end;
    $14:
      begin
        EscapeMenu := 'T';
        AskSound;
      end;
    $2F:
      begin
        EscapeMenu := 'V';
        AskAltVideo;
      end;
    $24:
      begin
        EscapeMenu := 'J';
        AskJoystick;
      end;
    $2E:
      begin
        EscapeMenu := 'C';
        CalibrateJoystick;
      end;
    $25:
      begin
        EscapeMenu := 'K';
        RedefineKeys;
      end;
    $13:
      begin
        EscapeMenu := 'R';
        K := RestoreMenu;
        if K <> $1C then
          B6EEE := 1;
      end;
    $1F:
      begin
        EscapeMenu := 'S';
        if Level = 1 then
          SaveMenu
        else
        begin
          ClearText;
          TextLines[1] := 'You can only save your game';
          TextLines[2] := 'on the island map.  ';
          TextLines[3] := '';
          TextLines[4] := 'Press ESCAPE';
          TextLines[5] := 'END OF WINDOW';
          B6820[1] := 1;
          W683A := Ord(TextWindow(False));
          B6EEB := 0;
          B683C := 0;
        end;
      end;
    $10:
      begin
        QuitMenu;
        if B6EEC <> 0 then
          EscapeMenu := 'Q'
        else
          EscapeMenu := ' ';
      end;
  end;
end;
{ src: GUESS 1802:99F5 (the high-score table in the text window) }
{ from: 99BA }
{ to: 9AA7 }
{$F+}
procedure HallOfFame;
var
  I: Integer;
begin
  ClearText;
  TextLines[1] := '  Secret Agents Hall of Fame';
  TextLines[2] := '';
  TextLines[3] := '';
  for I := 1 to 10 do
    TextLines[I + 3] := HiName[I];
  TextLines[14] := '';
  TextLines[15] := 'Press any key ^';
  TextLines[16] := '';
  TextLines[17] := 'END OF WINDOW';
  B6820[1] := 1;
  W683A := Ord(TextWindow(True));
  B6EEB := 0;
  B683C := 0;
end;
{$F-}
{ src: GUESS 1802:9AC2 (a one-line message in the text window, closed with Escape) }
{ from: 9AA7 }
{ to: 9B41 }
{ interface }
{ keep: ShowMessage(''); }
procedure ShowMessage(S: String);
begin
  ClearText;
  TextLines[1] := S;
  TextLines[2] := '';
  TextLines[3] := 'Press ESCAPE';
  TextLines[4] := 'END OF WINDOW';
  B6820[1] := 1;
  W683A := Ord(TextWindow(False));
  B6EEB := 0;
  B683C := 0;
end;
{ src: GUESS 1802:9B63 (quit prompt: B6820 = [1, $15, $31] lists the accepted scan codes Y and N;
  Y sets B6EEC) }
{ from: 9B41 }
{ to: 9BF2 }
{$F+}
procedure AskQuit;
begin
  ClearText;
  TextLines[1] := 'Quit To Dos (Y-N) ^';
  TextLines[2] := 'END OF WINDOW';
  B6820[1] := 1;
  B6820[2] := $15;
  B6820[3] := $31;
  W683A := Ord(TextWindow(True));
  if W683A = $15 then
    B6EEC := 1;
  B6EEB := 0;
  B683C := 0;
  B6EE9 := 0;
  B6EEA := 0;
  B6EF0 := 0;
  B6EF1 := 0;
  MemW[0:$41C] := MemW[0:$41A];
  W684A := 0;
end;
{$F-}
{ src: GUESS 1802:9C2D (quit menu by scan code: D $20 -> B6EEC, T $14 -> B6EED, I $17 -> B6EEE) }
{ from: 9BF2 }
{ to: 9D44 }
{$F+}
procedure QuitMenu;
begin
  ClearText;
  TextLines[1] := 'Quit to: ^';
  TextLines[2] := '';
  TextLines[3] := ' D)os';
  TextLines[4] := ' T)itle Screen';
  TextLines[5] := ' I)sland Map';
  TextLines[6] := 'END OF WINDOW';
  B6820[1] := $20;
  B6820[2] := $14;
  B6820[3] := $17;
  B6820[4] := 1;
  W683A := Ord(TextWindow(True));
  if W683A = $20 then
  begin
    CheckHighScore;
    B6EEC := 1;
    B6D8C := 0;
    PlaySound($12);
  end
  else if W683A = $14 then
  begin
    CheckHighScore;
    B6EED := 1;
    B6D8C := 0;
    PlaySound($12);
  end
  else if W683A = $17 then
  begin
    B6EEE := 1;
    B6D8C := 0;
  end;
  B6EEB := 0;
  B683C := 0;
  B6EE9 := 0;
  B6EEA := 0;
  B6EF0 := 0;
  B6EF1 := 0;
  MemW[0:$41C] := MemW[0:$41A];
  W684A := 0;
end;
{$F-}
{ src: GUESS 1802:9D64 (sound on/off prompt: Y $15 sets SoundOn, else off) }
{ from: 9D44 }
{ to: 9DFA }
{$F+}
procedure AskSound;
begin
  ClearText;
  TextLines[1] := 'Sounds On (Y-N) ^';
  TextLines[2] := 'END OF WINDOW';
  B6820[1] := $15;
  B6820[2] := $31;
  B6820[3] := 1;
  W683A := Ord(TextWindow(True));
  if W683A = $15 then
    SoundOn := True
  else
    SoundOn := False;
  B6EEB := 0;
  B683C := 0;
  B6EE9 := 0;
  B6EEA := 0;
  B6EF0 := 0;
  B6EF1 := 0;
  MemW[0:$41C] := MemW[0:$41A];
  W684A := 0;
end;
{$F-}
{ src: SAM1RE 1802:9FAB (../SAM: the alternate video setting prompt; Y sets W70EC, which picks
  SetViewStartAlt) }
{ from: 9DFA }
{ to: A13A }
{$F+}
procedure AskAltVideo;
begin
  ClearText;
  TextLines[1] := '    VIDEO BOARD COMPATIBILITY';
  TextLines[2] := '';
  TextLines[3] := '    Some SuperVGA boards have';
  TextLines[4] := '   compatibility problems that';
  TextLines[5] := '  cause the screen to jerk when';
  TextLines[6] := 'scrolling, or perform unreliably.';
  TextLines[7] := '';
  TextLines[8] := ' This is the fault of the video';
  TextLines[9] := ' board makers not producing 100%';
  TextLines[10] := '   compatible graphics cards.';
  TextLines[11] := '';
  TextLines[12] := ' We have tried to support all the';
  TextLines[13] := 'boards we know of, but if you have';
  TextLines[14] := '    problems, then toggle this';
  TextLines[15] := '   setting and see if it helps.';
  TextLines[16] := '';
  TextLines[17] := '  Alternate video setting (Y-N) ^ ';
  TextLines[18] := 'END OF WINDOW';
  B6820[1] := $15;
  B6820[2] := $31;
  B6820[3] := 1;
  W683A := Ord(TextWindow(False));
  if W683A = $15 then
    W70EC := 1
  else
    W70EC := 0;
  B6EEB := 0;
  B683C := 0;
  B6EE9 := 0;
  B6EEA := 0;
  B6EF0 := 0;
  B6EF1 := 0;
  MemW[0:$41C] := MemW[0:$41A];
  W684A := 0;
end;
{$F-}
{ src: GUESS 1802:A15C (joystick prompt: Y -> JoyOn := JoyPresent, W70EE := 1; N -> both off) }
{ from: A13A }
{ to: A207 }
{$F+}
procedure AskJoystick;
begin
  ClearText;
  TextLines[1] := 'Joystick On (Y-N) ^';
  TextLines[2] := 'END OF WINDOW';
  B6820[1] := $15;
  B6820[2] := $31;
  B6820[3] := 1;
  W683A := Ord(TextWindow(True));
  if W683A = $15 then
  begin
    JoyOn := JoyPresent;
    W70EE := 1;
  end
  else if W683A = $31 then
  begin
    JoyOn := False;
    W70EE := 0;
  end;
  B6EEB := 0;
  B683C := 0;
  B6EE9 := 0;
  B6EEA := 0;
  B6EF0 := 0;
  B6EF1 := 0;
  MemW[0:$41C] := MemW[0:$41A];
  W684A := 0;
end;
{$F-}
{ src: GUESS 1802:A33A (joystick calibration: Space ($39) with the stick centred stores both axes) }
{ from: A207 }
{ to: A5B6 }
{$F+}
procedure CalibrateJoystick;
var
  N: Integer;
begin
  ClearText;
  N := 0;
  Inc(N);
  TextLines[N] := '  Set your joystick so that';
  Inc(N);
  TextLines[N] := 'it is in the middle position.';
  Inc(N);
  TextLines[N] := ' ';
  Inc(N);
  TextLines[N] := '   Press SPACE when this is';
  Inc(N);
  TextLines[N] := ' done, and the joystick will';
  Inc(N);
  TextLines[N] := '       be calibrated.';
  Inc(N);
  TextLines[N] := ' ';
  Inc(N);
  TextLines[N] := 'This step is not necessary if';
  Inc(N);
  TextLines[N] := ' your joystick is set in the';
  Inc(N);
  TextLines[N] := ' middle when the game loads.';
  Inc(N);
  TextLines[N] := ' ';
  Inc(N);
  TextLines[N] := 'Press Escape if your joystick';
  Inc(N);
  TextLines[N] := '         is not on.';
  Inc(N);
  TextLines[N] := '              ^';
  Inc(N);
  TextLines[N] := 'END OF WINDOW';
  B6820[1] := 1;
  B6820[2] := $39;
  W683A := Ord(TextWindow(False));
  if W683A = $39 then
  begin
    JoyOn := JoyPresent;
    if JoyOn then
    begin
      JoyCenterX := ReadAxis(0);
      JoyCenterY := ReadAxis(1);
    end;
  end;
  B6EEB := 0;
  B683C := 0;
  B6EE9 := 0;
  B6EEA := 0;
  B6EF0 := 0;
  B6EF1 := 0;
  MemW[0:$41C] := MemW[0:$41A];
  W684A := 0;
end;
{$F-}
{ src: SAM1RE 1802:A67A (../SAM menus.md: the name of a set-1 scan code; NULL for keys that cannot be used) }
{ from: A5B6 }
{ keep: - }
{$F+}
function KeyName(K: Integer): String;
begin
  case K of
    $02: KeyName := '1';
    $03: KeyName := '2';
    $04: KeyName := '3';
    $05: KeyName := '4';
    $06: KeyName := '5';
    $07: KeyName := '6';
    $08: KeyName := '7';
    $09: KeyName := '8';
    $0A: KeyName := '9';
    $0B: KeyName := '0';
    $10: KeyName := 'Q';
    $11: KeyName := 'W';
    $12: KeyName := 'E';
    $13: KeyName := 'R';
    $14: KeyName := 'T';
    $15: KeyName := 'Y';
    $16: KeyName := 'U';
    $17: KeyName := 'I';
    $18: KeyName := 'O';
    $19: KeyName := 'P';
    $1C: KeyName := 'ENTER';
    $1D: KeyName := 'CTRL';
    $1E: KeyName := 'A';
    $1F: KeyName := 'S';
    $20: KeyName := 'D';
    $21: KeyName := 'F';
    $22: KeyName := 'G';
    $23: KeyName := 'H';
    $24: KeyName := 'J';
    $25: KeyName := 'K';
    $26: KeyName := 'L';
    $2A: KeyName := 'L-SHIFT';
    $2C: KeyName := 'Z';
    $2D: KeyName := 'X';
    $2E: KeyName := 'C';
    $2F: KeyName := 'V';
    $30: KeyName := 'B';
    $31: KeyName := 'N';
    $32: KeyName := 'M';
    $33: KeyName := ',';
    $34: KeyName := '.';
    $35: KeyName := '/';
    $36: KeyName := 'R-SHIFT';
    $38: KeyName := 'ALT';
    $39: KeyName := 'SPACE';
    $47: KeyName := 'HOME';
    $48: KeyName := 'UP ARROW';
    $49: KeyName := 'PGUP';
    $4B: KeyName := 'LEFT ARROW';
    $4D: KeyName := 'RIGHT ARROW';
    $4F: KeyName := 'END';
    $50: KeyName := 'DOWN ARROW';
    $51: KeyName := 'PGDN';
    $52: KeyName := 'INSERT';
    $53: KeyName := 'DELETE';
  else
    KeyName := 'NULL';
  end;
end;
{$F-}
{ src: GUESS 1802:AC61 (an empty procedure; the security-done window calls it last) }
{ to: AC68 }
{$F+}
procedure NoOp;
begin
end;
{$F-}
{ src: GUESS 1802:AEDA (two ordering windows: by mail or phone, then by FAX) }
{ from: AC68 }
{ to: B2E1 }
{$F+}
procedure OrderMailFax;
var
  I, K: Integer;
begin
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := 'ORDERING THE SECRET AGENT SERIES!';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '    Please specify disk size:';
  Inc(I);
  TextLines[I] := '         5.25"  or  3.5"';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '   To order send $34, check or';
  Inc(I);
  TextLines[I] := '   money order (USA funds) to:';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '         Apogee Software';
  Inc(I);
  TextLines[I] := '         P.O. Box 476386';
  Inc(I);
  TextLines[I] := '     Garland, TX 75047  (USA)';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '     Or CALL NOW toll free:';
  Inc(I);
  TextLines[I] := '         1-800-GAME123';
  Inc(I);
  TextLines[I] := '     (Visa and MasterCard)';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '    Continued...Press Any Key';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(True));
  B6EEB := 1;
  NoOp;
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := ' USE YOUR FAX MACHINE TO ORDER!';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'You can now use your FAX machine';
  Inc(I);
  TextLines[I] := ' to order your favorite Apogee';
  Inc(I);
  TextLines[I] := '   games quickly and easily.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := ' Simply print out the ORDER.FRM';
  Inc(I);
  TextLines[I] := '  file, fill it out and FAX it';
  Inc(I);
  TextLines[I] := '  to us for prompt processing.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '   FAX Orders: (214) 278-4670';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '          Press Any Key';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(True));
  B6EEB := 1;
  NoOp;
end;
{$F-}
{ src: GUESS 1802:B45A (the first ordering window; sets B6EEB, unlike the other windows) }
{ from: B2E1 }
{ to: B69D }
{$F+}
procedure OrderPage;
var
  I, K: Integer;
begin
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := 'ORDERING THE SECRET AGENT SERIES!';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '     Order now and receive:';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '  * All three devious missions';
  Inc(I);
  TextLines[I] := '  * The hints and tricks sheet';
  Inc(I);
  TextLines[I] := '  * The secret cheat password';
  Inc(I);
  TextLines[I] := '  * Exciting new bonus game';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '    To order, call toll free:';
  Inc(I);
  TextLines[I] := '         1-800-426-3123';
  Inc(I);
  TextLines[I] := '  (Visa and MasterCard Welcome)';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Foreign orders:  Please read the';
  Inc(I);
  TextLines[I] := '  "Foreign Orders" menu option.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '    Continued...Press Any Key';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(True));
  B6EEB := 1;
  NoOp;
end;
{$F-}
{ src: GUESS 1802:B81C (the ordering sequence: the series window, then OrderPage and OrderMailFax) }
{ from: B69D }
{ to: BA67 }
{$F+}
procedure OrderSeries;
var
  I, K: Integer;
begin
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := 'ORDERING THE SECRET AGENT SERIES!';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := ' Secret Agent consists of three';
  Inc(I);
  TextLines[I] := 'original and incredible missions:';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '  1) The Hunt for Red Rock Rover';
  Inc(I);
  TextLines[I] := '  2) Kill Again Island';
  Inc(I);
  TextLines[I] := '  3) Dr. No Body';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := ' You may order the entire series';
  Inc(I);
  TextLines[I] := ' for only $30, plus $4 shipping.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := ' Each episode is set on a unique';
  Inc(I);
  TextLines[I] := 'island, with all-new dangers, new';
  Inc(I);
  TextLines[I] := ' levels, and all-new challenges.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '    Continued...Press Any Key';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(True));
  B6EEB := 1;
  NoOp;
  OrderPage;
  OrderMailFax;
end;
{$F-}
{ src: SAM1RE 1802:C091 (../SAM menus.md: the foreign orders windows: an introduction, then the dealers
  of Australia (two), Canada, Germany and the United Kingdom; '/' is the pound sign of the font) }
{ from: BA67 }
{ to: CD4C }
{$F+}
procedure ForeignOrders;
var
  I, K: Integer;
begin
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := '       FOREIGN CUSTOMERS';
  Inc(I);
  TextLines[I] := '       -----------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'The following screens list our';
  Inc(I);
  TextLines[I] := '  dealers outside the United';
  Inc(I);
  TextLines[I] := 'States, for Australia, Germany,';
  Inc(I);
  TextLines[I] := 'Canada and the United Kingdom.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '  These are official Apogee';
  Inc(I);
  TextLines[I] := '   dealers with the latest';
  Inc(I);
  TextLines[I] := '      games and updates.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'If your country is not listed,';
  Inc(I);
  TextLines[I] := ' you may order directly from';
  Inc(I);
  TextLines[I] := 'Apogee by phone or USA check.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '        Press Any Key ^';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  W684A := 999;
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(True));
  NoOp;
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := '      AUSTRALIAN CUSTOMERS';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'PRICE: $45 + $5 shipping.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'BudgetWare';
  Inc(I);
  TextLines[I] := 'P.O. Box 496';
  Inc(I);
  TextLines[I] := 'Newtown, NSW  2042';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Phone:      (02) 519-4233';
  Inc(I);
  TextLines[I] := 'Toll free:  (008) 022-064';
  Inc(I);
  TextLines[I] := 'Fax:        (02) 516-4236';
  Inc(I);
  TextLines[I] := 'CompuServe: 71520,1475';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Use MasterCard, Visa, Bankcard,';
  Inc(I);
  TextLines[I] := 'cheques.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  W684A := 999;
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(True));
  NoOp;
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := '      AUSTRALIAN CUSTOMERS';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'PRICE: $45 + $5 shipping.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Manaccom';
  Inc(I);
  TextLines[I] := '9 Camford Str.';
  Inc(I);
  TextLines[I] := 'Milton, Qld. 4064';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Phone: (07) 368-2366';
  Inc(I);
  TextLines[I] := 'Fax:   (07) 369-7589';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Use MasterCard, Visa, Bankcard,';
  Inc(I);
  TextLines[I] := 'American Express, or cheques.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  W684A := 999;
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(True));
  NoOp;
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := '    CANADIAN CUSTOMERS';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'PRICE: $42 Canadian.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Distant Markets';
  Inc(I);
  TextLines[I] := 'Box 1149';
  Inc(I);
  TextLines[I] := '194 - 3803 Calgary Trail S.';
  Inc(I);
  TextLines[I] := 'Edmondton, Alb.  T6J 5M8';
  Inc(I);
  TextLines[I] := 'CANADA';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Orders:    1-800-661-7383';
  Inc(I);
  TextLines[I] := 'Inquiries: (403) 436-3009';
  Inc(I);
  TextLines[I] := 'Fax:       (403) 435-0928';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Use MasterCard, Visa or';
  Inc(I);
  TextLines[I] := 'money orders.';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  W684A := 999;
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(True));
  NoOp;
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := '        GERMAN CUSTOMERS';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Price: 49,-- DM plus 10,-- DM';
  Inc(I);
  TextLines[I] := 'Total: 59,-- DM (Deutsche Mark)';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'CDV-Software';
  Inc(I);
  TextLines[I] := 'Ettlingerstr. 5';
  Inc(I);
  TextLines[I] := '7500 Karlsruhe 1  GERMANY';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Phone: 0721-22295';
  Inc(I);
  TextLines[I] := 'Fax:   0721-21314';
  Inc(I);
  TextLines[I] := 'Compuserve: 1000022,274';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Use Visa, MasterCard, EuroCard,';
  Inc(I);
  TextLines[I] := 'American Express, cheque, money';
  Inc(I);
  TextLines[I] := 'order, or C.O.D.';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  W684A := 999;
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(True));
  NoOp;
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := '    UNITED KINGDOM CUSTOMERS';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Price: /29 + VAT + /2 P&P';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Precision Software Applications';
  Inc(I);
  TextLines[I] := 'Unit 3, Valley Court Offices';
  Inc(I);
  TextLines[I] := 'Lower Rd';
  Inc(I);
  TextLines[I] := 'Croydon, Near Royston';
  Inc(I);
  TextLines[I] := 'Harts. SG8 0HF, United Kingdom';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Phone: +44 (0) 223 208 288';
  Inc(I);
  TextLines[I] := 'FAX:   +44 (0) 223 208 089';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Credit cards, Access, cheques,';
  Inc(I);
  TextLines[I] := 'postal & Bankers orders.';
  Inc(I);
  TextLines[I] := 'Make cheques payable to PSA.';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  W684A := 999;
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(True));
  NoOp;
end;
{$F-}
{ src: SAM1RE 1802:CEC4 (../SAM menus.md: the Apogee BBS window of the main menu) }
{ from: CD4C }
{ to: D117 }
{$F+}
procedure ApogeeBBS;
var
  I, K: Integer;
begin
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := '   THE OFFICIAL APOGEE BBS';
  Inc(I);
  TextLines[I] := '   -----------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'The SOFTWARE CREATIONS BBS is';
  Inc(I);
  TextLines[I] := ' the home BBS for the latest';
  Inc(I);
  TextLines[I] := ' Apogee games.  Check out our';
  Inc(I);
  TextLines[I] := 'FREE "Apogee" file section for';
  Inc(I);
  TextLines[I] := '  new releases and updates.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '       BBS phone lines:';
  Inc(I);
  TextLines[I] := '(508) 365-2359  2400 baud';
  Inc(I);
  TextLines[I] := '(508) 365-9825  9600 baud';
  Inc(I);
  TextLines[I] := '(508) 365-9668  14.4k dual HST';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '  Many node lines available!';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '        Press Any Key ^';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  W684A := 999;
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(True));
  NoOp;
end;
{$F-}
{ src: SAM1RE 1802:D2A7 (../SAM menus.md: the About Apogee window of the main menu) }
{ from: D117 }
{ to: D4FA }
{$F+}
procedure AboutApogee;
var
  I, K: Integer;
begin
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := '     About Apogee Software';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Our goal is to establish Apogee';
  Inc(I);
  TextLines[I] := '  as the leader in commercial';
  Inc(I);
  TextLines[I] := ' quality shareware games. With';
  Inc(I);
  TextLines[I] := ' enthusiasm and dedication we';
  Inc(I);
  TextLines[I] := 'think our goal can be achieved.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'However,  we need your support.';
  Inc(I);
  TextLines[I] := 'Shareware is not free software.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '  We thank you in advance for';
  Inc(I);
  TextLines[I] := '   your contribution to the';
  Inc(I);
  TextLines[I] := '  growing shareware community.';
  Inc(I);
  TextLines[I] := '      Your honesty pays...';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '        Press any key ^';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  W684A := 999;
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(True));
  NoOp;
end;
{$F-}
{ src: SAM1RE 1802:D5C9 (../SAM level-load.md: the window after all 15 sites are done, shown on the island
  map; '@' is the apostrophe glyph of the font) }
{ from: D4FA }
{ to: D739 }
{ interface }
{ keep: SecurityDone; }
procedure SecurityDone;
var
  I, K: Integer;
begin
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := 'Good work 006, you@ve knocked';
  Inc(I);
  TextLines[I] := 'out the island security system';
  Inc(I);
  TextLines[I] := '  and can now infiltrate the';
  Inc(I);
  TextLines[I] := '     level containing the';
  Inc(I);
  TextLines[I] := ' blueprints to the "Red Rock';
  Inc(I);
  TextLines[I] := '      Rover" satellite.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Press ESCAPE!          ';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  B6820[1] := 1;
  B6820[2] := $1C;
  B6820[3] := $39;
  W684A := 999;
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(False));
  B6EEB := 0;
  B683C := 0;
  NoOp;
end;
{ src: SAM1RE 1802:D7A4 (../SAM physics.md: the perfect-health bonus window; the caller adds the 25000) }
{ from: D739 }
{ to: D8B1 }
{ interface }
{ keep: HealthBonus; }
procedure HealthBonus;
var
  I, K: Integer;
begin
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := ' 25,000 point BONUS for';
  Inc(I);
  TextLines[I] := 'finishing the level with';
  Inc(I);
  TextLines[I] := '    perfect health!';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Press ESCAPE!          ';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  B6820[1] := 1;
  B6820[2] := $1C;
  B6820[3] := $39;
  W684A := 999;
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(False));
  B6EEB := 0;
  B683C := 0;
  NoOp;
end;
{ src: SAM1RE 1802:DB46 (../SAM menus.md: the text-mode order screen of episodes 2 and 3; 20 columns of
  shade bars, a framed title, a framed body, the cursor left on row 24; locals J..L are never used) }
{ from: D8B1 }
{ to: DD4D }
{ interface }
{ keep: OrderScreen; }
procedure OrderScreen;
var
  I, J, K, L: Integer;
begin
  TextMode(3);
  ClrScr;
  GotoXY(1, 1);
  for I := 0 to 19 do
  begin
    WriteVert((I shl 2) + 1, 1, 8, 0, '°°°°°°°°°°°°°°°°°°°°°°°');
    WriteVert((I shl 2) + 2, 1, 7, 0, '°°°°°°°°°°°°°°°°°°°°°°°');
    WriteVert((I shl 2) + 3, 1, 15, 0, '°°°°°°°°°°°°°°°°°°°°°°°');
    WriteVert((I shl 2) + 4, 1, 7, 0, '°°°°°°°°°°°°°°°°°°°°°°°');
  end;
  Window(9, 2, 72, 4, 15, 4, 3);
  WriteCenter(3, 15, 4, ' HOW TO ORDER THE FINAL TWO AMAZING EPISODES OF SECRET AGENT');
  Window(5, 7, 76, 21, 3, 4, 3);
  WriteCenter(8, 14, 4, ' The final two episodes of SECRET AGENT continue your adventure');
  WriteCenter(9, 14, 4, ' as the heroic super spy 006«.  You''ll encounter fun and danger');
  WriteCenter(10, 14, 4, ' on two all-new islands, packed with new graphics and challenges.');
  WriteCenter(12, 14, 4, ' By ordering the final two episodes of SECRET AGENT you''ll get:');
  WriteCenter(13, 14, 4, ' The hints and tricks sheet, the cheat password, and an all-new');
  WriteCenter(14, 14, 4, ' bonus game from Apogee Software for you to try out.');
  WriteCenter(16, 15, 4, ' Apogee Software             CALL TOLL FREE!  ');
  WriteCenter(17, 15, 4, ' P.O. Box 476389              1-800-GAME123   ');
  WriteCenter(18, 15, 4, ' Garland, TX 75047          Visa or MasterCard ');
  WriteCenter(20, 14, 4, ' Or mail $34 (check or money order) to order SECRET AGENT.');
  TextColor(3);
  TextBackground(0);
  GotoXY(1, 24);
end;
{ src: SAM1RE 1802:DD56 (../SAM: the ending: SAM1.END, 30 x 50 ms with the keyboard buffer flushed, the
  ordering pages, a key, the high-score check, then back to the title) }
{ from: DD4D }
{ interface }
{ keep: ShowEnding; }
procedure ShowEnding;
var
  I, R: Integer;
begin
  SetGraphMode(0);
  R := Genus000F(2);
  R := Genus0047(1);
  R := SetStride($28);
  CamX := 0;
  CamY := 0;
  W6862 := 0;
  PageY := 0;
  R := ShowPicture('SAM1.END', 1, 0, 0);
  FadeIn(0);
  for I := 1 to 30 do
  begin
    Delay(50);
    MemW[0:$41C] := MemW[0:$41A];
  end;
  OrderInfo;
  MemW[0:$41C] := MemW[0:$41A];
  repeat
  until KeyPressed;
  MemW[0:$41C] := MemW[0:$41A];
  CheckHighScore;
  B6EED := 1;
  B6D8C := 0;
  B6EEC := 0;
end;
begin
{ init }
end.
