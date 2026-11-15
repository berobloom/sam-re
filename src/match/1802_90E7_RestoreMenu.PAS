{ src: SAM1RE 1802:90E7 (../SAM menus.md: the restore menu; keys 1..9 load slots 1..9, 0 slot 0; returns
  the key's scan code, $1C (Enter) when the load failed) }
{ from: 90A0 }
{ to: 91F2 }
{$F+}
function RestoreMenu: Integer;
begin
  ClearText;
  TextLines[1] := 'Restore Which Game?';
  TextLines[2] := '-------------------';
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
  case WinKey of
    2..10:
      if not LoadGame(WinKey - 1) then
        WinKey := $1C;
    11:
      if not LoadGame(0) then
        WinKey := $1C;
  end;
  RestoreMenu := WinKey;
  EscHeld := 0;
  MenuReq := 0;
end;
{$F-}
