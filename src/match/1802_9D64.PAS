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
