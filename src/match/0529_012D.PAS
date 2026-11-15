{ src: GUESS 0529:012D (counts W6844 up and derives W6846 from it: a ramp to W69CA + 4, halved when B69D6 is set) }
{$F+}
procedure Ramp;
begin
  Inc(WalkHeld);
  if SlowWalk = 0 then
    case WalkHeld of
      1..2: WalkSpeed := 1;
      3: WalkSpeed := 2;
      4..6: WalkSpeed := 4;
      7..1000: WalkSpeed := SpeedBonus + 4;
    end
  else
    case WalkHeld of
      1..4: WalkSpeed := 1;
      5..6: WalkSpeed := 2;
      7..1000: WalkSpeed := (SpeedBonus + 4) shr 1;
    end;
end;
{$F-}
