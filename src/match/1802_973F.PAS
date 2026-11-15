{ src: SAM1RE 1802:973F (../SAM menus.md: the Escape menu; every option closes it; the letter of the option
  is returned, 'Q' after a confirmed quit, ' ' after a cancelled one; Escape leaves the result unset) }
{ from: 963C }
{ interface }
{ keep: if EscapeMenu = ' ' then; }
function EscapeMenu: Char;
var
  K: Integer;
begin
  ClearText;
  TextLines[1] := 'Operational Command Bank';
  TextLines[2] := '------------------------';
  TextLines[3] := '';
  TextLines[4] := 'H)elp';
  TextLines[5] := 'T)oggle Sounds';
  TextLines[6] := 'V)ideo Select';
  TextLines[7] := 'J)oystick Toggle';
  TextLines[8] := 'C)alibrate Joystick';
  TextLines[9] := 'K)eyboard Config';
  TextLines[10] := 'R)estore Game';
  TextLines[11] := 'S)ave Game';
  TextLines[12] := 'Q)uit';
  TextLines[13] := '';
  TextLines[14] := 'Selection: ^';
  TextLines[15] := '';
  TextLines[16] := 'END OF WINDOW';
  KeyFilter[1] := $23;
  KeyFilter[2] := $14;
  KeyFilter[3] := $2F;
  KeyFilter[4] := $24;
  KeyFilter[5] := $2E;
  KeyFilter[6] := $25;
  KeyFilter[7] := $13;
  KeyFilter[8] := $1F;
  KeyFilter[9] := $10;
  KeyFilter[10] := 1;
  WinKey := Ord(TextWindow(False));
  case WinKey of
    $23:
      begin
        EscapeMenu := 'H';
        ShowHelp;
      end;
    $14:
      begin
        EscapeMenu := 'T';
        AskSound;
      end;
    $2F:
      begin
        EscapeMenu := 'V';
        AskAltVideo;
      end;
    $24:
      begin
        EscapeMenu := 'J';
        AskJoystick;
      end;
    $2E:
      begin
        EscapeMenu := 'C';
        CalibrateJoystick;
      end;
    $25:
      begin
        EscapeMenu := 'K';
        RedefineKeys;
      end;
    $13:
      begin
        EscapeMenu := 'R';
        K := RestoreMenu;
        if K <> $1C then
          B6EEE := 1;
      end;
    $1F:
      begin
        EscapeMenu := 'S';
        if Level = 1 then
          SaveMenu
        else
        begin
          ClearText;
          TextLines[1] := 'You can only save your game';
          TextLines[2] := 'on the island map.  ';
          TextLines[3] := '';
          TextLines[4] := 'Press ESCAPE';
          TextLines[5] := 'END OF WINDOW';
          KeyFilter[1] := 1;
          WinKey := Ord(TextWindow(False));
          B6EEB := 0;
          MenuReq := 0;
        end;
      end;
    $10:
      begin
        QuitMenu;
        if B6EEC <> 0 then
          EscapeMenu := 'Q'
        else
          EscapeMenu := ' ';
      end;
  end;
end;
