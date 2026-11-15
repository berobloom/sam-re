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
