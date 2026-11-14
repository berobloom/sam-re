{ src: GUESS 1802:9C2D (quit menu by scan code: D $20 -> B6EEC, T $14 -> B6EED, I $17 -> B6EEE) }
{ from: 9BF2 }
{ to: 9D44 }
{$F+}
procedure QuitMenu;
begin
  ClearText;
  TextLines[1] := 'Quit to: ^';
  TextLines[2] := '';
  TextLines[3] := ' D)os';
  TextLines[4] := ' T)itle Screen';
  TextLines[5] := ' I)sland Map';
  TextLines[6] := 'END OF WINDOW';
  B6820[1] := $20;
  B6820[2] := $14;
  B6820[3] := $17;
  B6820[4] := 1;
  W683A := Ord(TextWindow(True));
  if W683A = $20 then
  begin
    CheckHighScore;
    B6EEC := 1;
    B6D8C := 0;
    PlaySound($12);
  end
  else if W683A = $14 then
  begin
    CheckHighScore;
    B6EED := 1;
    B6D8C := 0;
    PlaySound($12);
  end
  else if W683A = $17 then
  begin
    B6EEE := 1;
    B6D8C := 0;
  end;
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
