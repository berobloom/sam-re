{ src: SAM1RE 1802:A67A (../SAM menus.md: the name of a set-1 scan code; NULL for keys that cannot be used) }
{ from: A5B6 }
{ keep: - }
{$F+}
function KeyName(K: Integer): String;
begin
  case K of
    $02: KeyName := '1';
    $03: KeyName := '2';
    $04: KeyName := '3';
    $05: KeyName := '4';
    $06: KeyName := '5';
    $07: KeyName := '6';
    $08: KeyName := '7';
    $09: KeyName := '8';
    $0A: KeyName := '9';
    $0B: KeyName := '0';
    $10: KeyName := 'Q';
    $11: KeyName := 'W';
    $12: KeyName := 'E';
    $13: KeyName := 'R';
    $14: KeyName := 'T';
    $15: KeyName := 'Y';
    $16: KeyName := 'U';
    $17: KeyName := 'I';
    $18: KeyName := 'O';
    $19: KeyName := 'P';
    $1C: KeyName := 'ENTER';
    $1D: KeyName := 'CTRL';
    $1E: KeyName := 'A';
    $1F: KeyName := 'S';
    $20: KeyName := 'D';
    $21: KeyName := 'F';
    $22: KeyName := 'G';
    $23: KeyName := 'H';
    $24: KeyName := 'J';
    $25: KeyName := 'K';
    $26: KeyName := 'L';
    $2A: KeyName := 'L-SHIFT';
    $2C: KeyName := 'Z';
    $2D: KeyName := 'X';
    $2E: KeyName := 'C';
    $2F: KeyName := 'V';
    $30: KeyName := 'B';
    $31: KeyName := 'N';
    $32: KeyName := 'M';
    $33: KeyName := ',';
    $34: KeyName := '.';
    $35: KeyName := '/';
    $36: KeyName := 'R-SHIFT';
    $38: KeyName := 'ALT';
    $39: KeyName := 'SPACE';
    $47: KeyName := 'HOME';
    $48: KeyName := 'UP ARROW';
    $49: KeyName := 'PGUP';
    $4B: KeyName := 'LEFT ARROW';
    $4D: KeyName := 'RIGHT ARROW';
    $4F: KeyName := 'END';
    $50: KeyName := 'DOWN ARROW';
    $51: KeyName := 'PGDN';
    $52: KeyName := 'INSERT';
    $53: KeyName := 'DELETE';
  else
    KeyName := 'NULL';
  end;
end;
{$F-}
