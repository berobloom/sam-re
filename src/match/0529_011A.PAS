{ src: SAM1RE 0529:011A (../SAM input.md: B6A19 is the GOD mode toggle; without it the player dies: B6EEE) }
{ interface }
{ keep: KillPlayer; }
procedure KillPlayer;
begin
  if B6A19 = 0 then
    B6EEE := 1;
end;
