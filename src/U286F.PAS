unit U286F;
{$S-,D+,L+}
interface

function JoyPresent: Boolean;
function JumpButton: Boolean;
function FireButton: Boolean;
procedure OBJ286F;
implementation
{$L OBJ286F.OBJ}
procedure OBJ286F; external;
{ src: GUESS 286F:00CC (confidence: high): times game-port axis Axis (bit 1 shl Axis), returns the count, -1 if none }
{$F+} function ReadAxis(Axis: Word): Word; external; {$F-}
{ src: GUESS 286F:0000 (confidence: high): both X and Y axis of stick A time out -> no joystick }
{ interface }
{ keep: if JoyPresent then }
function JoyPresent: Boolean;
var A, B: Integer;
begin
  A := ReadAxis(0);
  B := ReadAxis(1);
  if (A = -1) and (B = -1) then JoyPresent := False else JoyPresent := True;
end;
{ src: SAM1RE 286F:0038 (../SAM code-map.md: jump button via game port 0x201) }
{ interface }
{ keep: if JumpButton then }
function JumpButton: Boolean;
begin
  JumpButton := (Port[$201] and $10) = 0;
end;
{ src: SAM1RE 286F:0058 (../SAM code-map.md: fire button, game port 0x201 bit 5, active low) }
{ interface }
{ keep: if FireButton then }
function FireButton: Boolean;
begin
  FireButton := (Port[$201] and $20) = 0;
end;
begin
{ init }
{ src: EXE 286F:0078: the unit has no initialization statements; TP emits an empty frame }
end.
