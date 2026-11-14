{ src: GUESS 1802:9B63 (quit prompt: B6820 = [1, $15, $31] lists the accepted scan codes Y and N;
  Y sets B6EEC) }
{ from: 9B41 }
{ to: 9BF2 }
{$F+}
procedure AskQuit;
begin
  ClearText;
  TextLines[1] := 'Quit To Dos (Y-N) ^';
  TextLines[2] := 'END OF WINDOW';
  B6820[1] := 1;
  B6820[2] := $15;
  B6820[3] := $31;
  W683A := Ord(TextWindow(True));
  if W683A = $15 then
    B6EEC := 1;
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
