{ src: SAM1RE 1802:8F3A (../SAM menus.md: the save menu; keys 1..9 save to slots 1..9, 0 to slot 0, the first
  IOResult only clears the error state) }
{ from: 8EE1 }
{ to: 90A0 }
{$F+}
procedure SaveMenu;
begin
  ClearText;
  TextLines[1] := 'Save Which Game?';
  TextLines[2] := '----------------';
  TextLines[3] := '';
  TextLines[4] := 'Select (0-9) : ^';
  TextLines[5] := '';
  TextLines[6] := 'END OF WINDOW';
  B6820[1] := 2;
  B6820[2] := 3;
  B6820[3] := 4;
  B6820[4] := 5;
  B6820[5] := 6;
  B6820[6] := 7;
  B6820[7] := 8;
  B6820[8] := 9;
  B6820[9] := $0A;
  B6820[10] := $0B;
  B6820[11] := $1C;
  B6820[12] := 1;
  MemW[0:$41C] := MemW[0:$41A];
  W683A := Ord(TextWindow(False));
  if IOResult = 0 then;
  case W683A of
    2..10: SaveGame(W683A - 1);
    11: SaveGame(0);
  end;
  B6EEB := 0;
  B683C := 0;
  ClearText;
  if IOResult = 0 then
    TextLines[1] := 'Game Saved!'
  else
    TextLines[1] := 'File Error!';
  TextLines[2] := 'END OF WINDOW';
  B6820[1] := $1C;
  B6820[2] := 1;
  MemW[0:$41C] := MemW[0:$41A];
  W683A := Ord(TextWindow(True));
end;
{$F-}
