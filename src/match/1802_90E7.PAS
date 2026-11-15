{ src: SAM1RE 1802:90E7 (../SAM menus.md: the restore menu; keys 1..9 load slots 1..9, 0 slot 0; returns
  the key's scan code, $1C (Enter) when the load failed) }
{ from: 90A0 }
{ to: 91F2 }
{ keep: if RestoreMenu = 0 then; }
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
  case W683A of
    2..10:
      if not LoadGame(W683A - 1) then
        W683A := $1C;
    11:
      if not LoadGame(0) then
        W683A := $1C;
  end;
  RestoreMenu := W683A;
  B6EEB := 0;
  B683C := 0;
end;
{$F-}
