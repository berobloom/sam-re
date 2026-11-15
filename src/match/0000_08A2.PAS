{ src: GUESS 0000:08A2 (the joystick: the stick against its centre +-$32 walks left/right (and up/down on the
  world map, Level 1) with poses; the fire button, with ammo, outside the world map and unless B6A1B, puts a
  shot in the first free Shots slot (up to Gun) going the facing's way: sound 2, Ammo less one) }
{$F+}
procedure ReadJoystick;
var
  I: Integer;
  Fired: Boolean;
begin
  JoyX := ReadAxis(0);
  JoyY := ReadAxis(1);
  if B6EE5 <> 0 then
  begin
    B6EE5 := 0;
    if Slots[1].W14 = $B then
      Slots[1].W14 := 9
    else if Slots[1].W14 = $C then
      Slots[1].W14 := $A;
  end;
  if JoyCenterX - $32 > JoyX then
  begin
    B6EF0 := 1;
    B6EF1 := 0;
    B6EE8 := 0;
    JoyMovedX := True;
    if (B6EE7 = 0) and (B6EE6 = 0) then
      Slots[1].W14 := 5
    else
      Slots[1].W14 := $E;
  end
  else if JoyCenterX + $32 < JoyX then
  begin
    B6EF1 := 1;
    B6EF0 := 0;
    B6EE8 := 0;
    JoyMovedX := True;
    if (B6EE7 = 0) and (B6EE6 = 0) then
      Slots[1].W14 := 1
    else
      Slots[1].W14 := $D;
  end
  else if JoyMovedX then
  begin
    if (B6EF1 = 1) or (Slots[1].W14 = 1) then
      Slots[1].W14 := 9
    else
      Slots[1].W14 := $A;
    B6EF1 := 0;
    B6EF0 := 0;
    JoyMovedX := False;
  end;
  if Level = 1 then
    if JoyCenterY - $32 > JoyY then
    begin
      B6EE9 := 1;
      JoyMovedY := True;
      if (Slots[1].W14 = 1) or (Slots[1].W14 = 9) or (Slots[1].W14 = $B) then
        Slots[1].W14 := 1
      else
        Slots[1].W14 := 5;
    end
    else if JoyCenterY + $32 < JoyY then
    begin
      B6EEA := 1;
      JoyMovedY := True;
      if (Slots[1].W14 = 1) or (Slots[1].W14 = 9) or (Slots[1].W14 = $B) then
        Slots[1].W14 := 1
      else
        Slots[1].W14 := 5;
    end
    else if JoyMovedY then
    begin
      JoyMovedY := False;
      B6EE9 := 0;
      B6EEA := 0;
      if (Slots[1].W14 = 1) or (Slots[1].W14 = 9) or (Slots[1].W14 = $B) then
        Slots[1].W14 := 9
      else
        Slots[1].W14 := $A;
    end;
  if FireButton and (Ammo > 0) and (Level > 1) and (B6A1B = 0) then
  begin
    Fired := False;
    I := 0;
    repeat
      Inc(I);
      if Shots[I].Free = 1 then
      begin
        Shots[I].X := Slots[1].X;
        Shots[I].Y := Slots[1].Y;
        Shots[I].W06 := Slots[1].W06;
        Shots[I].W08 := Slots[1].W08;
        Shots[I].W14 := $27;
        if (Slots[1].W14 = 1) or (Slots[1].W14 = $D) or (Slots[1].W14 = 9) or (Slots[1].W14 = $B) then
        begin
          Shots[I].W16 := 1;
          B6EE5 := 1;
          Slots[1].W14 := $B;
        end
        else
        begin
          Shots[I].W16 := -1;
          B6EE5 := 1;
          Slots[1].W14 := $C;
        end;
        Shots[I].W18 := 0;
        Shots[I].W0A := 1;
        Shots[I].W1A := 8;
        Shots[I].W0C := 0;
        Shots[I].W0E := 0;
        Shots[I].W1C := 7;
        Shots[I].Free := 0;
        Shots[I].B1F := 0;
        Fired := True;
        Dec(Ammo);
        W6858 := -1;
        PlaySound(2);
        if (Slots[1].W14 = 1) or (Slots[1].W14 = 9) or (Slots[1].W14 = $D) or (Slots[1].W14 = $B) then
          Slots[1].W14 := $B
        else
          Slots[1].W14 := $C;
      end;
    until (I = Gun) or Fired;
  end;
end;
{$F-}
