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
  B6820[1] := 1;
  B6820[2] := $39;
  W683A := Ord(TextWindow(False));
  if W683A = $39 then
  begin
    JoyOn := JoyPresent;
    if JoyOn then
    begin
      JoyCenterX := ReadAxis(0);
      JoyCenterY := ReadAxis(1);
    end;
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
