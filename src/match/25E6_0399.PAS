{ src: GUESS 25E6:0399 (S downwards from column X, row Y, cut at row 26; T is assigned and never read) }
{ interface }
{ keep: WriteVert(1, 1, 0, 0, ''); }
procedure WriteVert(X, Y, Fg, Bg: Integer; S: String);
var
  I: Integer;
  T: String;
begin
  if Length(S) > 26 - Y then
    Delete(S, 27 - Y, 80);
  for I := 1 to Length(S) do
  begin
    T := S[I];
    FastWrite(X, Y - 1 + I, MakeAttr(Fg, Bg), S[I]);
  end;
end;
