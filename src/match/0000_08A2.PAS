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
  if Shot <> 0 then
  begin
    Shot := 0;
    if Slots[1].Sprite = $B then
      Slots[1].Sprite := 9
    else if Slots[1].Sprite = $C then
      Slots[1].Sprite := $A;
  end;
  if JoyCenterX - $32 > JoyX then
  begin
    LeftHeld := 1;
    RightHeld := 0;
    B6EE8 := 0;
    JoyMovedX := True;
    if (Jumping = 0) and (Falling = 0) then
      Slots[1].Sprite := 5
    else
      Slots[1].Sprite := $E;
  end
  else if JoyCenterX + $32 < JoyX then
  begin
    RightHeld := 1;
    LeftHeld := 0;
    B6EE8 := 0;
    JoyMovedX := True;
    if (Jumping = 0) and (Falling = 0) then
      Slots[1].Sprite := 1
    else
      Slots[1].Sprite := $D;
  end
  else if JoyMovedX then
  begin
    if (RightHeld = 1) or (Slots[1].Sprite = 1) then
      Slots[1].Sprite := 9
    else
      Slots[1].Sprite := $A;
    RightHeld := 0;
    LeftHeld := 0;
    JoyMovedX := False;
  end;
  if Level = 1 then
    if JoyCenterY - $32 > JoyY then
    begin
      UpHeld := 1;
      JoyMovedY := True;
      if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) then
        Slots[1].Sprite := 1
      else
        Slots[1].Sprite := 5;
    end
    else if JoyCenterY + $32 < JoyY then
    begin
      DownHeld := 1;
      JoyMovedY := True;
      if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) then
        Slots[1].Sprite := 1
      else
        Slots[1].Sprite := 5;
    end
    else if JoyMovedY then
    begin
      JoyMovedY := False;
      UpHeld := 0;
      DownHeld := 0;
      if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) then
        Slots[1].Sprite := 9
      else
        Slots[1].Sprite := $A;
    end;
  if FireButton and (Ammo > 0) and (Level > 1) and (HitLock = 0) then
  begin
    Fired := False;
    I := 0;
    repeat
      Inc(I);
      if Shots[I].Free = 1 then
      begin
        Shots[I].X := Slots[1].X;
        Shots[I].Y := Slots[1].Y;
        Shots[I].PrevX := Slots[1].PrevX;
        Shots[I].PrevY := Slots[1].PrevY;
        Shots[I].Sprite := $27;
        if (Slots[1].Sprite = 1) or (Slots[1].Sprite = $D) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) then
        begin
          Shots[I].DirX := 1;
          Shot := 1;
          Slots[1].Sprite := $B;
        end
        else
        begin
          Shots[I].DirX := -1;
          Shot := 1;
          Slots[1].Sprite := $C;
        end;
        Shots[I].DirY := 0;
        Shots[I].Anim := 1;
        Shots[I].Speed := 8;
        Shots[I].W0C := 0;
        Shots[I].W0E := 0;
        Shots[I].Kind := 7;
        Shots[I].Free := 0;
        Shots[I].Remove := 0;
        Fired := True;
        Dec(Ammo);
        StatusCamX := -1;
        PlaySound(2);
        if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $D) or (Slots[1].Sprite = $B) then
          Slots[1].Sprite := $B
        else
          Slots[1].Sprite := $C;
      end;
    until (I = Gun) or Fired;
  end;
end;
{$F-}
