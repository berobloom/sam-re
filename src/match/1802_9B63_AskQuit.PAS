{ src: GUESS 1802:9B63 (quit prompt: KeyFilter = [1, $15, $31] lists the accepted scan codes Y and N;
  Y sets QuitDos) }
{ from: 9B41 }
{ to: 9BF2 }
{$F+}
procedure AskQuit;
begin
  ClearText;
  TextLines[1] := 'Quit To Dos (Y-N) ^';
  TextLines[2] := 'END OF WINDOW';
  KeyFilter[1] := 1;
  KeyFilter[2] := $15;
  KeyFilter[3] := $31;
  WinKey := Ord(TextWindow(True));
  if WinKey = $15 then
    QuitDos := 1;
  EscHeld := 0;
  MenuReq := 0;
  UpHeld := 0;
  DownHeld := 0;
  LeftHeld := 0;
  RightHeld := 0;
  MemW[0:$41C] := MemW[0:$41A];
  ScanCode := 0;
end;
{$F-}
