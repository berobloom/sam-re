{ src: SAM1RE 1802:9FAB (../SAM: the alternate video setting prompt; Y sets AltVideo, which picks
  SetViewStartAlt) }
{ from: 9DFA }
{ to: A13A }
{$F+}
procedure AskAltVideo;
begin
  ClearText;
  TextLines[1] := '    VIDEO BOARD COMPATIBILITY';
  TextLines[2] := '';
  TextLines[3] := '    Some SuperVGA boards have';
  TextLines[4] := '   compatibility problems that';
  TextLines[5] := '  cause the screen to jerk when';
  TextLines[6] := 'scrolling, or perform unreliably.';
  TextLines[7] := '';
  TextLines[8] := ' This is the fault of the video';
  TextLines[9] := ' board makers not producing 100%';
  TextLines[10] := '   compatible graphics cards.';
  TextLines[11] := '';
  TextLines[12] := ' We have tried to support all the';
  TextLines[13] := 'boards we know of, but if you have';
  TextLines[14] := '    problems, then toggle this';
  TextLines[15] := '   setting and see if it helps.';
  TextLines[16] := '';
  TextLines[17] := '  Alternate video setting (Y-N) ^ ';
  TextLines[18] := 'END OF WINDOW';
  KeyFilter[1] := $15;
  KeyFilter[2] := $31;
  KeyFilter[3] := 1;
  WinKey := Ord(TextWindow(False));
  if WinKey = $15 then
    AltVideo := 1
  else
    AltVideo := 0;
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
