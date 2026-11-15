{ src: SAM1RE 1802:D2A7 (../SAM menus.md: the About Apogee window of the main menu) }
{ from: D117 }
{ to: D4FA }
{$F+}
procedure AboutApogee;
var
  I, K: Integer;
begin
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := '     About Apogee Software';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Our goal is to establish Apogee';
  Inc(I);
  TextLines[I] := '  as the leader in commercial';
  Inc(I);
  TextLines[I] := ' quality shareware games. With';
  Inc(I);
  TextLines[I] := ' enthusiasm and dedication we';
  Inc(I);
  TextLines[I] := 'think our goal can be achieved.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'However,  we need your support.';
  Inc(I);
  TextLines[I] := 'Shareware is not free software.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '  We thank you in advance for';
  Inc(I);
  TextLines[I] := '   your contribution to the';
  Inc(I);
  TextLines[I] := '  growing shareware community.';
  Inc(I);
  TextLines[I] := '      Your honesty pays...';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '        Press any key ^';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  W684A := 999;
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(True));
  NoOp;
end;
{$F-}
