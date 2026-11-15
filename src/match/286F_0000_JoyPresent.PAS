{ src: GUESS 286F:0000 (confidence: high): both X and Y axis of stick A time out -> no joystick }
{ interface }
function JoyPresent: Boolean;
var A, B: Integer;
begin
  A := ReadAxis(0);
  B := ReadAxis(1);
  if (A = -1) and (B = -1) then JoyPresent := False else JoyPresent := True;
end;
