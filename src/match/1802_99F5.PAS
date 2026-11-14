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
