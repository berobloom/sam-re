{ src: SAM1RE 1802:01E5 (../SAM level-load.md: the status line repaint: the score as six digits, the ammo as
  two, the items and one icon per life; cell-aligned when CamX is a multiple of 8, else shifted by CamX and 7.
  the cells are those of SAM102.GFX record 1: 1..10 the digits) }
{ interface }
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
    if SpeedBonus > 0 then
      DrawCell(GfxSmall[1]^.Cell[14], 20, 1);
    if DoorKey <> 0 then
      DrawCell(GfxSmall[1]^.Cell[21], 25, 1);
    if B6A10 <> 0 then
      DrawCell(GfxSmall[1]^.Cell[18], 27, 1);
    if B6A11 <> 0 then
      DrawCell(GfxSmall[1]^.Cell[19], 28, 1);
    if B6A0F <> 0 then
      DrawCell(GfxSmall[1]^.Cell[20], 29, 1);
    if Floppy <> 0 then
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
    if SpeedBonus > 0 then
      DrawCellX(GfxSmall[1]^.Cell[14], Sh + $A0, 1);
    if DoorKey <> 0 then
      DrawCellX(GfxSmall[1]^.Cell[21], Sh + $C8, 1);
    if B6A10 <> 0 then
      DrawCellX(GfxSmall[1]^.Cell[18], Sh + $D8, 1);
    if B6A11 <> 0 then
      DrawCellX(GfxSmall[1]^.Cell[19], Sh + $E0, 1);
    if B6A0F <> 0 then
      DrawCellX(GfxSmall[1]^.Cell[20], Sh + $E8, 1);
    if Floppy <> 0 then
      DrawCellX(GfxSmall[1]^.Cell[22], Sh + $F0, 1);
    for I := 1 to Lives do
      DrawCellX(GfxSmall[1]^.Cell[12], Sh + $100 + (I shl 3), 1);
  end;
end;
