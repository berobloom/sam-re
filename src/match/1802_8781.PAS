{ src: GUESS 1802:8781 (the "key is unavailable" window; X is never read, K never used) }
{ from: 8725 }
{ to: 87F3 }
{ keep: KeyUnavailable(0); }
{$F+}
procedure KeyUnavailable(X: Integer);
var
  K: Integer;
begin
  ClearText;
  TextLines[1] := 'Sorry, that key is unavailable.';
  TextLines[2] := '';
  TextLines[3] := '  Press any key to continue.';
  TextLines[4] := '';
  TextLines[5] := '               ^';
  TextLines[6] := 'END OF WINDOW';
  K := Ord(TextWindow(True));
end;
{$F-}
