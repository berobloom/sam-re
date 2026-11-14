unit U286F;
{$S-,D+,L+}
interface

procedure S286F_0000;
function JumpButton: Boolean;
function FireButton: Boolean;
implementation
{$L OBJ286F.OBJ}
procedure OBJ286F; external;
procedure S286F_0000;
begin
if JumpButton then;
if FireButton then;
OBJ286F;
Inline(>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000)
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
Inline(>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/
>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/>$0000/$00)
end.
