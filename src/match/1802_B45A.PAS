{ src: GUESS 1802:B45A (the first ordering window; sets B6EEB, unlike the other windows) }
{ from: B2E1 }
{ to: B69D }
{$F+}
procedure OrderPage;
var
  I, K: Integer;
begin
  ClearText;
  I := 0;
  Inc(I);
  TextLines[I] := 'ORDERING THE SECRET AGENT SERIES!';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '     Order now and receive:';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '  * All three devious missions';
  Inc(I);
  TextLines[I] := '  * The hints and tricks sheet';
  Inc(I);
  TextLines[I] := '  * The secret cheat password';
  Inc(I);
  TextLines[I] := '  * Exciting new bonus game';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '    To order, call toll free:';
  Inc(I);
  TextLines[I] := '         1-800-426-3123';
  Inc(I);
  TextLines[I] := '  (Visa and MasterCard Welcome)';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Foreign orders:  Please read the';
  Inc(I);
  TextLines[I] := '  "Foreign Orders" menu option.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '    Continued...Press Any Key';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(True));
  B6EEB := 1;
  NoOp;
end;
{$F-}
