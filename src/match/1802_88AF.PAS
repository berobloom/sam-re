{ src: SAM1RE 1802:88AF (../SAM menus.md: the keyboard redefine menu; six prompts in the order left, right,
  up, down, jump, fire, each repeated until the key has a name and differs from the earlier ones; ESC (scan
  code 1) skips the rest; then the confirm window, N redoes it all. The fire check compares NameJump with
  NameUp and NameDown, not NameFire: a bug of the original) }
{ from: 8493 }
{ nested: 850B 8781 }
{$F+}
procedure RedefineKeys;
var
  Right, Left, Up, Down, Fire, Jump, W0E: Integer;
  Ok, Valid: Boolean;

  procedure ConfirmKeys;
  begin
    ClearText;
    NameLeft := 'LEFT  - ' + NameLeft;
    NameRight := 'RIGHT - ' + NameRight;
    NameUp := 'UP    - ' + NameUp;
    NameDown := 'DOWN  - ' + NameDown;
    NameJump := 'JUMP  - ' + NameJump;
    NameFire := 'FIRE  - ' + NameFire;
    TextLines[1] := 'KEYBOARD REDEFINED';
    TextLines[2] := '';
    TextLines[3] := NameLeft;
    TextLines[4] := NameRight;
    TextLines[5] := NameUp;
    TextLines[6] := NameDown;
    TextLines[7] := NameJump;
    TextLines[8] := NameFire;
    TextLines[9] := '';
    TextLines[10] := 'Are these selections ok (Y-N): ^';
    TextLines[11] := '';
    TextLines[12] := 'END OF WINDOW';
    KeyFilter[1] := $15;
    KeyFilter[2] := $31;
    WinKey := Ord(TextWindow(False));
    if WinKey = $31 then
      RedefineKeys
    else
    begin
      KeyFire := Fire;
      KeyLeft := Left;
      KeyRight := Right;
      KeyUp := Up;
      KeyDown := Down;
      KeyJump := Jump;
    end;
  end;

  procedure KeyUnavailable;
  var
    K: Integer;
  begin
    ClearText;
    TextLines[1] := 'Sorry, that key is unavailable.';
    TextLines[2] := '';
    TextLines[3] := '  Press any key to continue.';
    TextLines[4] := '';
    TextLines[5] := '               ^';
    TextLines[6] := 'END OF WINDOW';
    K := Ord(TextWindow(True));
  end;

begin
  Valid := True;

  repeat
    Ok := True;
    ClearText;
    TextLines[1] := 'KEYBOARD REDEFINE';
    TextLines[2] := '';
    TextLines[3] := 'Select key to move left: ^';
    TextLines[4] := 'END OF WINDOW';
    Left := Ord(TextWindow(True));
    if Left = 1 then
      Valid := False;
    NameLeft := KeyName(Left);
    if Valid then
      if NameLeft = 'NULL' then
      begin
        KeyUnavailable;
        Ok := False;
      end;
  until Ok;
  if Valid then
    repeat
      Ok := True;
      ClearText;
      TextLines[1] := 'KEYBOARD REDEFINE';
      TextLines[2] := '';
      TextLines[3] := 'Select key to move right: ^';
      TextLines[4] := 'END OF WINDOW';
      KeyFilter[1] := 1;
      Right := Ord(TextWindow(True));
      if Right = 1 then
        Valid := False;
      NameRight := KeyName(Right);
      if Valid then
        if (NameRight = 'NULL') or (NameRight = NameLeft) then
        begin
          KeyUnavailable;
          Ok := False;
        end;
    until Ok;
  if Valid then
    repeat
      Ok := True;
      ClearText;
      TextLines[1] := 'KEYBOARD REDEFINE';
      TextLines[2] := '';
      TextLines[3] := 'Select key to move up: ^';
      TextLines[4] := 'END OF WINDOW';
      KeyFilter[1] := 1;
      Up := Ord(TextWindow(True));
      if Up = 1 then
        Valid := False;
      NameUp := KeyName(Up);
      if Valid then
        if (NameUp = 'NULL') or (NameUp = NameLeft) or (NameUp = NameRight) then
        begin
          KeyUnavailable;
          Ok := False;
        end;
    until Ok;
  if Valid then
    repeat
      Ok := True;
      ClearText;
      TextLines[1] := 'KEYBOARD REDEFINE';
      TextLines[2] := '';
      TextLines[3] := 'Select key to move down: ^';
      TextLines[4] := 'END OF WINDOW';
      KeyFilter[1] := 1;
      Down := Ord(TextWindow(True));
      if Down = 1 then
        Valid := False;
      NameDown := KeyName(Down);
      if Valid then
        if (NameDown = 'NULL') or (NameDown = NameLeft) or (NameDown = NameRight) or
          (NameDown = NameUp) then
        begin
          KeyUnavailable;
          Ok := False;
        end;
    until Ok;
  if Valid then
    repeat
      Ok := True;
      ClearText;
      TextLines[1] := 'KEYBOARD REDEFINE';
      TextLines[2] := '';
      TextLines[3] := 'Select key to jump: ^';
      TextLines[4] := 'END OF WINDOW';
      KeyFilter[1] := 1;
      Jump := Ord(TextWindow(True));
      if Jump = 1 then
        Valid := False;
      NameJump := KeyName(Jump);
      if Valid then
        if (NameJump = 'NULL') or (NameJump = NameLeft) or (NameJump = NameRight) or
          (NameJump = NameUp) or (NameJump = NameDown) then
        begin
          KeyUnavailable;
          Ok := False;
        end;
    until Ok;
  if Valid then
    repeat
      Ok := True;
      ClearText;
      TextLines[1] := 'KEYBOARD REDEFINE';
      TextLines[2] := '';
      TextLines[3] := 'Select key to fire: ^';
      TextLines[4] := 'END OF WINDOW';
      Fire := Ord(TextWindow(True));
      if Fire = 1 then
        Valid := False;
      NameFire := KeyName(Fire);
      if Valid then
        if (NameFire = 'NULL') or (NameFire = NameLeft) or (NameFire = NameRight) or
          (NameJump = NameUp) or (NameJump = NameDown) or (NameFire = NameJump) then
        begin
          KeyUnavailable;
          Ok := False;
        end;
    until Ok;
  if Valid then
    ConfirmKeys;
  MemW[0:$41C] := MemW[0:$41A];
end;
{$F-}
