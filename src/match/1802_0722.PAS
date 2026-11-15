{ src: GUESS 1802:0722 (empties the 299 text lines at DS:3838 and the 20 bytes at DS:6820) }
{ to: 0764 }
{ interface }
{ keep: ClearText; }
procedure ClearText;
var
  I: Integer;
begin
  for I := 1 to 299 do
    TextLines[I] := '';
  for I := 1 to 20 do
    KeyFilter[I] := 0;
end;
