{ src: GUESS 25E6:0045 (N copies of Ch; N outside 1..80 counts as 1; the set constant is its literal) }
{ from: 0025 }
{ keep: - }
{$F+}
function Replicate(N: Byte; Ch: Char): String;
var
  Buf: String;
begin
  if not (N in [1..80]) then
    N := 1;
  FillChar(Buf, N + 1, Ch);
  Buf[0] := Chr(N);
  Replicate := Buf;
end;
{$F-}
