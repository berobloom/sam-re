{ src: SAM1RE 1802:CEC4 (../SAM menus.md: the Apogee BBS window of the main menu) }
{ from: CD4C }
{ to: D117 }
{$F+}
procedure ApogeeBBS;
var
  I, K: Integer;
begin
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := '   THE OFFICIAL APOGEE BBS';
  Inc(I);
  TextLines[I] := '   -----------------------';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'The SOFTWARE CREATIONS BBS is';
  Inc(I);
  TextLines[I] := ' the home BBS for the latest';
  Inc(I);
  TextLines[I] := ' Apogee games.  Check out our';
  Inc(I);
  TextLines[I] := 'FREE "Apogee" file section for';
  Inc(I);
  TextLines[I] := '  new releases and updates.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '       BBS phone lines:';
  Inc(I);
  TextLines[I] := '(508) 365-2359  2400 baud';
  Inc(I);
  TextLines[I] := '(508) 365-9825  9600 baud';
  Inc(I);
  TextLines[I] := '(508) 365-9668  14.4k dual HST';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '  Many node lines available!';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '        Press Any Key ^';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  ScanCode := 999;
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(True));
  NoOp;
end;
{$F-}
