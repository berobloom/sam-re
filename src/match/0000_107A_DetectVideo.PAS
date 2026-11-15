{ src: GUESS 0000:107A (finds the video adapter: the start mode; int $10 $1A00 gives the display code and
  VideoTab the adapter, else int $10 $12/$10 tells an EGA (3); default 1) }
{ to: 10F6 }
{$F+}
procedure DetectVideo;
begin
  Adapter := 1;
  Regs.AH := $0F;
  Intr($10, Regs);
  VideoMode := Regs.AL and $7F;
  Regs.AX := $1A00;
  Intr($10, Regs);
  if Regs.AL = $1A then
  begin
    if Regs.BL <> $FF then
      Adapter := VideoTab[Regs.BL];
  end
  else
  begin
    Regs.AH := $12;
    Regs.BL := $10;
    Intr($10, Regs);
    if Regs.BL <> $10 then
      Adapter := 3;
  end;
end;
{$F-}
