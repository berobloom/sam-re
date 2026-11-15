{ src: SAM1RE 0529:011A (../SAM input.md: Invulnerable is the GOD mode toggle; without it the player dies: QuitMap) }
{ interface }
procedure KillPlayer;
begin
  if Invulnerable = 0 then
    QuitMap := 1;
end;
