{ src: SAM1RE 1802:D5C9 (../SAM level-load.md: the window after all 15 sites are done, shown on the island
  map; '@' is the apostrophe glyph of the font) }
{ from: D4FA }
{ to: D739 }
{ interface }
{ keep: SecurityDone; }
procedure SecurityDone;
var
  I, K: Integer;
begin
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := 'Good work 006, you@ve knocked';
  Inc(I);
  TextLines[I] := 'out the island security system';
  Inc(I);
  TextLines[I] := '  and can now infiltrate the';
  Inc(I);
  TextLines[I] := '     level containing the';
  Inc(I);
  TextLines[I] := ' blueprints to the "Red Rock';
  Inc(I);
  TextLines[I] := '      Rover" satellite.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Press ESCAPE!          ';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  B6820[1] := 1;
  B6820[2] := $1C;
  B6820[3] := $39;
  W684A := 999;
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(False));
  B6EEB := 0;
  B683C := 0;
  NoOp;
end;
