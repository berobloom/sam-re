{ src: GUESS 1802:B81C (the ordering sequence: the series window, then OrderPage and OrderMailFax) }
{ from: B69D }
{ to: BA67 }
{$F+}
procedure OrderSeries;
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
  TextLines[I] := ' Secret Agent consists of three';
  Inc(I);
  TextLines[I] := 'original and incredible missions:';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '  1) The Hunt for Red Rock Rover';
  Inc(I);
  TextLines[I] := '  2) Kill Again Island';
  Inc(I);
  TextLines[I] := '  3) Dr. No Body';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := ' You may order the entire series';
  Inc(I);
  TextLines[I] := ' for only $30, plus $4 shipping.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := ' Each episode is set on a unique';
  Inc(I);
  TextLines[I] := 'island, with all-new dangers, new';
  Inc(I);
  TextLines[I] := ' levels, and all-new challenges.';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := '    Continued...Press Any Key';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  MemW[0:$41C] := MemW[0:$41A];
  K := Ord(TextWindow(True));
  EscHeld := 1;
  NoOp;
  OrderPage;
  OrderMailFax;
end;
{$F-}
