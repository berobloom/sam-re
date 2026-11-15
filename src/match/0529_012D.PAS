{ src: GUESS 0529:012D (counts W6844 up and derives W6846 from it: a ramp to W69CA + 4, halved when B69D6 is set) }
{$F+}
procedure Ramp;
begin
  Inc(W6844);
  if B69D6 = 0 then
    case W6844 of
      1..2: W6846 := 1;
      3: W6846 := 2;
      4..6: W6846 := 4;
      7..1000: W6846 := W69CA + 4;
    end
  else
    case W6844 of
      1..4: W6846 := 1;
      5..6: W6846 := 2;
      7..1000: W6846 := (W69CA + 4) shr 1;
    end;
end;
{$F-}
