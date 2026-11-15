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
    if Ticks > 20 then
    begin
      Ticks := 0;
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
