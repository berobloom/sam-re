{ src: GUESS 1802:A15C (joystick prompt: Y -> JoyOn := JoyPresent, W70EE := 1; N -> both off) }
{ from: A13A }
{ to: A207 }
{$F+}
procedure AskJoystick;
begin
  ClearText;
  TextLines[1] := 'Joystick On (Y-N) ^';
  TextLines[2] := 'END OF WINDOW';
  KeyFilter[1] := $15;
  KeyFilter[2] := $31;
  KeyFilter[3] := 1;
  WinKey := Ord(TextWindow(True));
  if WinKey = $15 then
  begin
    JoyOn := JoyPresent;
    UseJoystick := 1;
  end
  else if WinKey = $31 then
  begin
    JoyOn := False;
    UseJoystick := 0;
  end;
  B6EEB := 0;
  MenuReq := 0;
  B6EE9 := 0;
  B6EEA := 0;
  B6EF0 := 0;
  B6EF1 := 0;
  MemW[0:$41C] := MemW[0:$41A];
  ScanCode := 0;
end;
{$F-}
