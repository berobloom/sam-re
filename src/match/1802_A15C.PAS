{ src: GUESS 1802:A15C (joystick prompt: Y -> JoyOn := JoyPresent, W70EE := 1; N -> both off) }
{ from: A13A }
{ to: A207 }
{$F+}
procedure AskJoystick;
begin
  ClearText;
  TextLines[1] := 'Joystick On (Y-N) ^';
  TextLines[2] := 'END OF WINDOW';
  B6820[1] := $15;
  B6820[2] := $31;
  B6820[3] := 1;
  W683A := Ord(TextWindow(True));
  if W683A = $15 then
  begin
    JoyOn := JoyPresent;
    W70EE := 1;
  end
  else if W683A = $31 then
  begin
    JoyOn := False;
    W70EE := 0;
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
