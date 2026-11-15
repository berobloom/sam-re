{ src: SAM1RE 0D9C:A1AE (../SAM level-load.md: the level loader. Resets slots 2..25 and the ten shots, then
  reads SAM103.GFX, 42-byte encrypted records: the world map (N = 1) is the first 25, level N (2..17) the
  25 after (N-1)*48. The first record's three chars are the number W6840, the next is row 24 (the sheet
  row), then rows 0..23 ('*' rows repeat the row). Then the page sweep, FadeIn(20) and sound $D) }
{ from: A1A3 }
{ interface }
{$I-}
{$F+}
procedure LoadLevel(N: Integer);
var
  I: Integer;
  F: file of TRow;
  Row: TRow;
  S: String[40];
begin
  SlotCount := 1;
  CopyPage;
  StatusCamX := -1;
  for I := 2 to 25 do
  begin
    Slots[I].W00 := 0;
    Slots[I].Sprite := 9;
    Slots[I].X := -41;
    Slots[I].Y := 0;
    Slots[I].PrevX := -41;
    Slots[I].PrevY := 0;
    Slots[I].DirX := 1;
    Slots[I].DirY := 0;
    Slots[I].Anim := 1;
    Slots[I].Speed := 1;
    Slots[I].W0C := 0;
    Slots[I].W0E := 0;
    Slots[I].W10 := 0;
    Slots[I].W12 := 0;
    Slots[I].Kind := 1;
    Slots[I].Free := 1;
    Slots[I].Remove := 1;
  end;
  for I := 1 to 10 do
  begin
    Shots[I].Sprite := 7;
    Shots[I].X := -41;
    Shots[I].Y := 0;
    Shots[I].PrevX := -41;
    Shots[I].PrevY := 0;
    Shots[I].DirX := 1;
    Shots[I].DirY := 0;
    Shots[I].Anim := 1;
    Shots[I].Speed := 8;
    Shots[I].W0C := 0;
    Shots[I].Kind := 1;
    Shots[I].Free := 1;
    Shots[I].Remove := 0;
  end;
  Bullets[N] := 0;
  if IOResult <> 0 then
    ;
  case N of
    1:
      begin
        SiteCounter := 0;
        Assign(F, 'SAM103.GFX');
        Reset(F);
        Read(F, Row);
        Decrypt(Row, 40);
        S := Row[1] + Row[2] + Row[3];
        Val(S, BackTile, I);
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
        Val(S, BackTile, I);
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
