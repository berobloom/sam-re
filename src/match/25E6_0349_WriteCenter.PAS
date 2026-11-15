{ src: GUESS 25E6:0349 (S centred on an 80-column row) }
{ interface }
procedure WriteCenter(Row, Fg, Bg: Integer; S: String);
begin
  FastWrite(40 - Length(S) div 2, Row, MakeAttr(Fg, Bg), S);
end;
