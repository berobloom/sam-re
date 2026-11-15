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
