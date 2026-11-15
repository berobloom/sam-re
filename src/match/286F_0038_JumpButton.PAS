{ src: SAM1RE 286F:0038 (../SAM code-map.md: jump button via game port 0x201) }
{ interface }
function JumpButton: Boolean;
begin
  JumpButton := (Port[$201] and $10) = 0;
end;
