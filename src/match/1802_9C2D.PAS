{ src: GUESS 1802:9C2D (quit menu by scan code: D $20 -> QuitDos, T $14 -> QuitTitle, I $17 -> QuitMap) }
{ from: 9BF2 }
{ to: 9D44 }
{$F+}
procedure QuitMenu;
begin
  ClearText;
  TextLines[1] := 'Quit to: ^';
  TextLines[2] := '';
  TextLines[3] := ' D)os';
  TextLines[4] := ' T)itle Screen';
  TextLines[5] := ' I)sland Map';
  TextLines[6] := 'END OF WINDOW';
  KeyFilter[1] := $20;
  KeyFilter[2] := $14;
  KeyFilter[3] := $17;
  KeyFilter[4] := 1;
  WinKey := Ord(TextWindow(True));
  if WinKey = $20 then
  begin
    CheckHighScore;
    QuitDos := 1;
    HasPix := 0;
    PlaySound($12);
  end
  else if WinKey = $14 then
  begin
    CheckHighScore;
    QuitTitle := 1;
    HasPix := 0;
    PlaySound($12);
  end
  else if WinKey = $17 then
  begin
    QuitMap := 1;
    HasPix := 0;
  end;
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
