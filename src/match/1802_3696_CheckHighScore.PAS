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
