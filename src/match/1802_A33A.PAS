{ src: GUESS 1802:A33A (joystick calibration: Space ($39) with the stick centred stores both axes) }
{ from: A207 }
{ to: A5B6 }
{$F+}
procedure CalibrateJoystick;
var
  N: Integer;
begin
  ClearText;
  N := 0;
  Inc(N);
  TextLines[N] := '  Set your joystick so that';
  Inc(N);
  TextLines[N] := 'it is in the middle position.';
  Inc(N);
  TextLines[N] := ' ';
  Inc(N);
  TextLines[N] := '   Press SPACE when this is';
  Inc(N);
  TextLines[N] := ' done, and the joystick will';
  Inc(N);
  TextLines[N] := '       be calibrated.';
  Inc(N);
  TextLines[N] := ' ';
  Inc(N);
  TextLines[N] := 'This step is not necessary if';
  Inc(N);
  TextLines[N] := ' your joystick is set in the';
  Inc(N);
  TextLines[N] := ' middle when the game loads.';
  Inc(N);
  TextLines[N] := ' ';
  Inc(N);
  TextLines[N] := 'Press Escape if your joystick';
  Inc(N);
  TextLines[N] := '         is not on.';
  Inc(N);
  TextLines[N] := '              ^';
  Inc(N);
  TextLines[N] := 'END OF WINDOW';
  KeyFilter[1] := 1;
  KeyFilter[2] := $39;
  WinKey := Ord(TextWindow(False));
  if WinKey = $39 then
  begin
    JoyOn := JoyPresent;
    if JoyOn then
    begin
      JoyCenterX := ReadAxis(0);
      JoyCenterY := ReadAxis(1);
    end;
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
