{ src: SAM1RE 286F:0058 (../SAM code-map.md: fire button, game port 0x201 bit 5, active low) }
{ interface }
{ keep: if FireButton then }
function FireButton: Boolean;
begin
  FireButton := (Port[$201] and $20) = 0;
end;
