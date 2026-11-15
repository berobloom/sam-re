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
  for W684E := 1 to 299 do
  begin
    if W684E = 1 then
      MaxW := Length(TextLines[W684E]) - 1;
    if Length(TextLines[W684E]) > MaxW then
      MaxW := Length(TextLines[W684E]) - 1;
    if TextLines[W684E] = 'END OF WINDOW' then
      NLines := W684E - 2;
    for W684C := 1 to Length(TextLines[W684E]) do
      if Copy(TextLines[W684E], W684C, 1) = '^' then
      begin
        CX := Pos('^', TextLines[W684E]) + 1;
        CY := W684E + 1;
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
    for W684E := X1 + 1 to X2 - 1 do
      DrawCell(GfxSmall[2]^.Cell[9], W684E, ((Y1 + W6850) shl 3) + W6862);
  DrawCellM(GfxSmall[2]^.Cell[1], X1, (Y1 shl 3) + W6862);
  for W684E := X1 + 1 to X2 - 1 do
    DrawCellM(GfxSmall[2]^.Cell[2], W684E, (Y1 shl 3) + W6862);
  DrawCellM(GfxSmall[2]^.Cell[3], X2, (Y1 shl 3) + W6862);
  for W684E := 1 to Y2 - Y1 do
  begin
    DrawCellM(GfxSmall[2]^.Cell[6], X1, ((Y1 + W684E) shl 3) + W6862);
    DrawCellM(GfxSmall[2]^.Cell[8], X2, ((Y1 + W684E) shl 3) + W6862);
    DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y1 + W684E) shl 3) + W6862);
  end;
  DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y2 - Y1 + Y1 + 1) shl 3) + W6862);
  DrawCellM(GfxSmall[2]^.Cell[5], X1, (Y2 shl 3) + W6862);
  for W684E := X1 + 1 to X2 - 1 do
    DrawCellM(GfxSmall[2]^.Cell[7], W684E, (Y2 shl 3) + W6862);
  DrawCellM(GfxSmall[2]^.Cell[4], X2, (Y2 shl 3) + W6862);
  for W684E := X1 + 1 to X2 + 1 do
    DrawCellM(GfxSmall[2]^.Cell[10], W684E, ((Y2 + 1) shl 3) + W6862);
  for W684E := 1 to NLines - 2 do
    if TextLines[W684E] <> 'END OF WINDOW' then
      DrawText(X1 + 2, Y1 + W684E + 1, TextLines[W684E]);
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
      W684E := Random(100);
      if not Spark then
        if W684E >= 99 then
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
        for W684E := X1 + 1 to X2 - 1 do
          DrawCell(GfxSmall[2]^.Cell[9], W684E, ((Y1 + W6850) shl 3) + W6862);
      DrawCellM(GfxSmall[2]^.Cell[1], X1, (Y1 shl 3) + W6862);
      for W684E := X1 + 1 to X2 - 1 do
        DrawCellM(GfxSmall[2]^.Cell[2], W684E, (Y1 shl 3) + W6862);
      DrawCellM(GfxSmall[2]^.Cell[3], X2, (Y1 shl 3) + W6862);
      for W684E := 1 to Y2 - Y1 do
      begin
        DrawCellM(GfxSmall[2]^.Cell[6], X1, ((Y1 + W684E) shl 3) + W6862);
        DrawCellM(GfxSmall[2]^.Cell[8], X2, ((Y1 + W684E) shl 3) + W6862);
        DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y1 + W684E) shl 3) + W6862);
      end;
      DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y2 - Y1 + Y1 + 1) shl 3) + W6862);
      DrawCellM(GfxSmall[2]^.Cell[5], X1, (Y2 shl 3) + W6862);
      for W684E := X1 + 1 to X2 - 1 do
        DrawCellM(GfxSmall[2]^.Cell[7], W684E, (Y2 shl 3) + W6862);
      DrawCellM(GfxSmall[2]^.Cell[4], X2, (Y2 shl 3) + W6862);
      for W684E := X1 + 1 to X2 + 1 do
        DrawCellM(GfxSmall[2]^.Cell[10], W684E, ((Y2 + 1) shl 3) + W6862);
      for W684E := 1 to NLines - 2 do
        if TextLines[W684E] <> 'END OF WINDOW' then
          DrawText(X1 + 2, Y1 + W684E + 1, TextLines[W684E + Top]);
    end;
    if (K = $48) or (K = $49) then
    begin
      Dec(Top, 17);
      if Top < 0 then
        Top := 0;
      for W6850 := 1 to Y2 - Y1 - 1 do
        for W684E := X1 + 1 to X2 - 1 do
          DrawCell(GfxSmall[2]^.Cell[9], W684E, ((Y1 + W6850) shl 3) + W6862);
      DrawCellM(GfxSmall[2]^.Cell[1], X1, (Y1 shl 3) + W6862);
      for W684E := X1 + 1 to X2 - 1 do
        DrawCellM(GfxSmall[2]^.Cell[2], W684E, (Y1 shl 3) + W6862);
      DrawCellM(GfxSmall[2]^.Cell[3], X2, (Y1 shl 3) + W6862);
      for W684E := 1 to Y2 - Y1 do
      begin
        DrawCellM(GfxSmall[2]^.Cell[6], X1, ((Y1 + W684E) shl 3) + W6862);
        DrawCellM(GfxSmall[2]^.Cell[8], X2, ((Y1 + W684E) shl 3) + W6862);
        DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y1 + W684E) shl 3) + W6862);
      end;
      DrawCellM(GfxSmall[2]^.Cell[10], X2 + 1, ((Y2 - Y1 + Y1 + 1) shl 3) + W6862);
      DrawCellM(GfxSmall[2]^.Cell[5], X1, (Y2 shl 3) + W6862);
      for W684E := X1 + 1 to X2 - 1 do
        DrawCellM(GfxSmall[2]^.Cell[7], W684E, (Y2 shl 3) + W6862);
      DrawCellM(GfxSmall[2]^.Cell[4], X2, (Y2 shl 3) + W6862);
      for W684E := X1 + 1 to X2 + 1 do
        DrawCellM(GfxSmall[2]^.Cell[10], W684E, ((Y2 + 1) shl 3) + W6862);
      for W684E := 1 to NLines - 2 do
        if TextLines[W684E] <> 'END OF WINDOW' then
          DrawText(X1 + 2, Y1 + W684E + 1, TextLines[W684E + Top]);
    end;
    if not Wait then
    begin
      for W684E := 1 to 20 do
        if B6820[W684E] <> 0 then
          if B6820[W684E] = K then
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
