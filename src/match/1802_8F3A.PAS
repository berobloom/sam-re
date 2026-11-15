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
  KeyFilter[1] := 2;
  KeyFilter[2] := 3;
  KeyFilter[3] := 4;
  KeyFilter[4] := 5;
  KeyFilter[5] := 6;
  KeyFilter[6] := 7;
  KeyFilter[7] := 8;
  KeyFilter[8] := 9;
  KeyFilter[9] := $0A;
  KeyFilter[10] := $0B;
  KeyFilter[11] := $1C;
  KeyFilter[12] := 1;
  MemW[0:$41C] := MemW[0:$41A];
  WinKey := Ord(TextWindow(False));
  if IOResult = 0 then;
  case WinKey of
    2..10: SaveGame(WinKey - 1);
    11: SaveGame(0);
  end;
  EscHeld := 0;
  MenuReq := 0;
  ClearText;
  if IOResult = 0 then
    TextLines[1] := 'Game Saved!'
  else
    TextLines[1] := 'File Error!';
  TextLines[2] := 'END OF WINDOW';
  KeyFilter[1] := $1C;
  KeyFilter[2] := 1;
  MemW[0:$41C] := MemW[0:$41A];
  WinKey := Ord(TextWindow(True));
end;
{$F-}
