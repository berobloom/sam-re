{ src: SAM1RE 1802:D7A4 (../SAM physics.md: the perfect-health bonus window; the caller adds the 25000) }
{ from: D739 }
{ to: D8B1 }
{ interface }
{ keep: HealthBonus; }
procedure HealthBonus;
var
  I, K: Integer;
begin
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := ' 25,000 point BONUS for';
  Inc(I);
  TextLines[I] := 'finishing the level with';
  Inc(I);
  TextLines[I] := '    perfect health!';
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
