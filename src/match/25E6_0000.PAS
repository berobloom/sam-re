{ src: GUESS 25E6:0000 (text attribute from foreground and background) }
{ keep: - }
{$F+}
function MakeAttr(Fg, Bg: Byte): Byte;
begin
  MakeAttr := (Bg shl 4) or Fg;
end;
{$F-}
