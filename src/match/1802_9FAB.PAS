{ src: SAM1RE 1802:9FAB (../SAM: the alternate video setting prompt; Y sets W70EC, which picks
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
  B6820[1] := $15;
  B6820[2] := $31;
  B6820[3] := 1;
  W683A := Ord(TextWindow(False));
  if W683A = $15 then
    W70EC := 1
  else
    W70EC := 0;
  B6EEB := 0;
  B683C := 0;
  B6EE9 := 0;
  B6EEA := 0;
  B6EF0 := 0;
  B6EF1 := 0;
  MemW[0:$41C] := MemW[0:$41A];
  W684A := 0;
end;
{$F-}
