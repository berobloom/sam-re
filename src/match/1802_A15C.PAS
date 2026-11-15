{ src: GUESS 1802:A15C (joystick prompt: Y -> JoyOn := JoyPresent, UseJoystick := 1; N -> both off) }
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
  EscHeld := 0;
  MenuReq := 0;
  UpHeld := 0;
  DownHeld := 0;
  LeftHeld := 0;
  RightHeld := 0;
  MemW[0:$41C] := MemW[0:$41A];
  ScanCode := 0;
end;
{$F-}
