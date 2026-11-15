{ src: GUESS 1802:9AC2 (a one-line message in the text window, closed with Escape) }
{ from: 9AA7 }
{ to: 9B41 }
{ interface }
{ keep: ShowMessage(''); }
procedure ShowMessage(S: String);
begin
  ClearText;
  TextLines[1] := S;
  TextLines[2] := '';
  TextLines[3] := 'Press ESCAPE';
  TextLines[4] := 'END OF WINDOW';
  KeyFilter[1] := 1;
  WinKey := Ord(TextWindow(False));
  B6EEB := 0;
  MenuReq := 0;
end;
