{ src: SAM1RE 1802:2653 (../SAM menus.md: the paged text window: TextWindow for up to 299 lines, 16 shown;
  Down/PgDn and Up/PgUp move by 17 lines and redraw the box; no caret animation and no start sound) }
{ from: 2603 }
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
  GetImage(P681C^, X1, (Y1 shl 3) + ScanPage, X1 + MaxW + 5 + 1, ((Y1 + NLines + 2 + 1) shl 3) + ScanPage);
  X2 := X1 + MaxW + 4;
  Y2 := Y1 + NLines + 1;
  for WinRow := 1 to Y2 - Y1 do
    for RowIdx := X1 + 1 to X2 - 1 do
      DrawCell(GfxSmall[2]^.Cell[9], RowIdx, ((Y1 + WinRow) shl 3) + ScanPage);
  DrawCellM(GfxSmall[2]^.Cell[1], X1, (Y1 shl 3) + ScanPage);
  for RowIdx := X1 + 1 to X2 - 1 do
    DrawCellM(GfxSmall[2]^.Cell[2], RowIdx, (Y1 shl 3) + ScanPage);
  DrawCellM(GfxSmall[2]^.Cell[3], X2, (Y1 shl 3) + ScanPage);
  for RowIdx := 1 to Y2 - Y1 do
  begin
    DrawCellM(GfxSmall[2]^.Cell[6], X1, ((Y1 + RowIdx) shl 3) + ScanPage);
    DrawCellM(GfxSmall[2]^.Cell[8], X2, ((Y1 + RowIdx) shl 3) + ScanPage);
    DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y1 + RowIdx) shl 3) + ScanPage);
  end;
  DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y2 - Y1 + Y1 + 1) shl 3) + ScanPage);
  DrawCellM(GfxSmall[2]^.Cell[5], X1, (Y2 shl 3) + ScanPage);
  for RowIdx := X1 + 1 to X2 - 1 do
    DrawCellM(GfxSmall[2]^.Cell[7], RowIdx, (Y2 shl 3) + ScanPage);
  DrawCellM(GfxSmall[2]^.Cell[4], X2, (Y2 shl 3) + ScanPage);
  for RowIdx := X1 + 1 to X2 + 1 do
    DrawCellM(GfxSmall[2]^.Cell[10], RowIdx, ((Y2 + 1) shl 3) + ScanPage);
  for RowIdx := 1 to NLines - 2 do
    if TextLines[RowIdx] <> 'END OF WINDOW' then
      DrawText(X1 + 2, Y1 + RowIdx + 1, TextLines[RowIdx]);
  UpHeld := 0;
  DownHeld := 0;
  LeftHeld := 0;
  RightHeld := 0;
  repeat
    MemW[0:$41C] := MemW[0:$41A];
  until ScanCode > $80;
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
        if Ticks > 20 then
        begin
          Ticks := 0;
          if Spark then
          begin
            Inc(ST);
            if ST > 4 then
            begin
              Spark := False;
              if SH then
                DrawCellM(GfxSmall[2]^.Cell[2], SX, SY + ScanPage)
              else
                DrawCellM(GfxSmall[2]^.Cell[6], SX, SY + ScanPage);
            end
            else
            begin
              if SH then
                DrawCellM(GfxSmall[2]^.Cell[2], SX, SY + ScanPage)
              else
                DrawCellM(GfxSmall[2]^.Cell[6], SX, SY + ScanPage);
              DrawCellM(GfxSmall[2]^.Cell[ST + $25], SX, SY + ScanPage);
            end;
          end;
        end;
    until (ScanCode < $80) or (ScanCode = $E0);
    K := ScanCode;
    if K = $E0 then
    begin
      repeat
        MemW[0:$41C] := MemW[0:$41A];
      until ScanCode in [$9C, $9D, $AA, $B5, $B8, $C5, $C7..$C9, $CB, $CD, $CF..$D3];
      if ScanCode in [$AA, $C5] then
        ScanCode := $1F4;
      K := ScanCode - $80;
    end
    else
      repeat
        MemW[0:$41C] := MemW[0:$41A];
      until ScanCode > $80;
    if (K = $50) or (K = $51) then
    begin
      Inc(Top, 17);
      if Total - 16 < Top then
        Top := Total - 16;
      for WinRow := 1 to Y2 - Y1 - 1 do
        for RowIdx := X1 + 1 to X2 - 1 do
          DrawCell(GfxSmall[2]^.Cell[9], RowIdx, ((Y1 + WinRow) shl 3) + ScanPage);
      DrawCellM(GfxSmall[2]^.Cell[1], X1, (Y1 shl 3) + ScanPage);
      for RowIdx := X1 + 1 to X2 - 1 do
        DrawCellM(GfxSmall[2]^.Cell[2], RowIdx, (Y1 shl 3) + ScanPage);
      DrawCellM(GfxSmall[2]^.Cell[3], X2, (Y1 shl 3) + ScanPage);
      for RowIdx := 1 to Y2 - Y1 do
      begin
        DrawCellM(GfxSmall[2]^.Cell[6], X1, ((Y1 + RowIdx) shl 3) + ScanPage);
        DrawCellM(GfxSmall[2]^.Cell[8], X2, ((Y1 + RowIdx) shl 3) + ScanPage);
        DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y1 + RowIdx) shl 3) + ScanPage);
      end;
      DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y2 - Y1 + Y1 + 1) shl 3) + ScanPage);
      DrawCellM(GfxSmall[2]^.Cell[5], X1, (Y2 shl 3) + ScanPage);
      for RowIdx := X1 + 1 to X2 - 1 do
        DrawCellM(GfxSmall[2]^.Cell[7], RowIdx, (Y2 shl 3) + ScanPage);
      DrawCellM(GfxSmall[2]^.Cell[4], X2, (Y2 shl 3) + ScanPage);
      for RowIdx := X1 + 1 to X2 + 1 do
        DrawCellM(GfxSmall[2]^.Cell[10], RowIdx, ((Y2 + 1) shl 3) + ScanPage);
      for RowIdx := 1 to NLines - 2 do
        if TextLines[RowIdx] <> 'END OF WINDOW' then
          DrawText(X1 + 2, Y1 + RowIdx + 1, TextLines[RowIdx + Top]);
    end;
    if (K = $48) or (K = $49) then
    begin
      Dec(Top, 17);
      if Top < 0 then
        Top := 0;
      for WinRow := 1 to Y2 - Y1 - 1 do
        for RowIdx := X1 + 1 to X2 - 1 do
          DrawCell(GfxSmall[2]^.Cell[9], RowIdx, ((Y1 + WinRow) shl 3) + ScanPage);
      DrawCellM(GfxSmall[2]^.Cell[1], X1, (Y1 shl 3) + ScanPage);
      for RowIdx := X1 + 1 to X2 - 1 do
        DrawCellM(GfxSmall[2]^.Cell[2], RowIdx, (Y1 shl 3) + ScanPage);
      DrawCellM(GfxSmall[2]^.Cell[3], X2, (Y1 shl 3) + ScanPage);
      for RowIdx := 1 to Y2 - Y1 do
      begin
        DrawCellM(GfxSmall[2]^.Cell[6], X1, ((Y1 + RowIdx) shl 3) + ScanPage);
        DrawCellM(GfxSmall[2]^.Cell[8], X2, ((Y1 + RowIdx) shl 3) + ScanPage);
        DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y1 + RowIdx) shl 3) + ScanPage);
      end;
      DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y2 - Y1 + Y1 + 1) shl 3) + ScanPage);
      DrawCellM(GfxSmall[2]^.Cell[5], X1, (Y2 shl 3) + ScanPage);
      for RowIdx := X1 + 1 to X2 - 1 do
        DrawCellM(GfxSmall[2]^.Cell[7], RowIdx, (Y2 shl 3) + ScanPage);
      DrawCellM(GfxSmall[2]^.Cell[4], X2, (Y2 shl 3) + ScanPage);
      for RowIdx := X1 + 1 to X2 + 1 do
        DrawCellM(GfxSmall[2]^.Cell[10], RowIdx, ((Y2 + 1) shl 3) + ScanPage);
      for RowIdx := 1 to NLines - 2 do
        if TextLines[RowIdx] <> 'END OF WINDOW' then
          DrawText(X1 + 2, Y1 + RowIdx + 1, TextLines[RowIdx + Top]);
    end;
    if not Wait then
    begin
      for RowIdx := 1 to 20 do
        if KeyFilter[RowIdx] <> 0 then
          if KeyFilter[RowIdx] = K then
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
  PutImage(P681C^, X1, (Y1 shl 3) + ScanPage);
  FreeMem(P681C, 30000);
  MemW[0:$41C] := MemW[0:$41A];
  B6EF2 := 0;
  LeftHeld := 0;
  RightHeld := 0;
  UpHeld := 0;
  DownHeld := 0;
end;
{$F-}
