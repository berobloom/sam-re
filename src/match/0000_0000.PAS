{ src: GUESS 0000:0000 (the int 9 handler: reads the scan code into W684A (left/right swapped while B69D3 = 1,
  the "confused" body), and unless B69DA turns the defined keys into the walk/jump/fire flags and poses (up and
  down on the world map only; fire with no ammo plays sound $14); Esc, Tab and F1..F10 set B683C. Held-key
  cheats: U+V+K Ammo + 25 once (B6A02); Z+G+I B6A12/B6A1A; P+J+X toggles B6A19 (B69FD); O+N+D with B (or P)
  B69F9. Then it chains to the old int 9; the inline tail after the chain is dead (an EOI whose
  `mov al,$20` reads $80/$20) }
procedure KeyISR; interrupt;
var
  I: Integer;
  Fired: Boolean;
begin
  ScanCode := Port[$60];
  if Confused = 1 then
    if ScanCode = KeyLeft then
      ScanCode := KeyRight
    else if KeyLeft + $80 = ScanCode then
      ScanCode := KeyRight + $80
    else if ScanCode = KeyRight then
      ScanCode := KeyLeft
    else if KeyRight + $80 = ScanCode then
      ScanCode := KeyLeft + $80;
  if KeysOff = 0 then
    if ScanCode = KeyLeft then
    begin
      LeftHeld := 1;
      RightHeld := 0;
      B6EE8 := 0;
      Slots[1].Sprite := 5;
      if Jumping <> 0 then
        Slots[1].Sprite := $E;
    end
    else if KeyLeft + $80 = ScanCode then
    begin
      LeftHeld := 0;
      if Jumping = 0 then
      begin
        if RightHeld = 0 then
          Slots[1].Sprite := $A
        else
          Slots[1].Sprite := 1;
      end
      else if RightHeld = 1 then
        Slots[1].Sprite := $D
      else
        Slots[1].Sprite := $E;
    end
    else if ScanCode = KeyRight then
    begin
      RightHeld := 1;
      LeftHeld := 0;
      B6EE8 := 0;
      Slots[1].Sprite := 1;
      if Jumping <> 0 then
        Slots[1].Sprite := $D;
    end
    else if KeyRight + $80 = ScanCode then
    begin
      RightHeld := 0;
      if Jumping = 0 then
      begin
        if LeftHeld = 0 then
          Slots[1].Sprite := 9
        else
          Slots[1].Sprite := 5;
      end
      else if LeftHeld = 1 then
        Slots[1].Sprite := $E
      else
        Slots[1].Sprite := $D;
    end
    else if ScanCode = KeyFire then
    begin
      if Ammo = 0 then
        PlaySound($14)
      else if (Ammo > 0) and (HitLock = 0) and (Level > 1) then
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
              Slots[1].Sprite := $B;
            end
            else
            begin
              Shots[I].DirX := -1;
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
    end
    else if KeyFire + $80 = ScanCode then
    begin
      if Slots[1].Sprite = $B then
        Slots[1].Sprite := 9
      else if Slots[1].Sprite = $C then
        Slots[1].Sprite := $A;
    end
    else if ScanCode = KeyJump then
      JumpHeld := 1
    else if KeyJump + $80 = ScanCode then
      JumpHeld := 0
    else if ScanCode = KeyUp then
    begin
      if Level = 1 then
      begin
        UpHeld := 1;
        DownHeld := 0;
        if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) then
          Slots[1].Sprite := 1
        else
          Slots[1].Sprite := 5;
      end;
    end
    else if KeyUp + $80 = ScanCode then
    begin
      if Level = 1 then
      begin
        UpHeld := 0;
        if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) then
          Slots[1].Sprite := 9
        else
          Slots[1].Sprite := $A;
      end;
    end
    else if ScanCode = KeyDown then
    begin
      if Level = 1 then
      begin
        DownHeld := 1;
        UpHeld := 0;
        if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) then
          Slots[1].Sprite := 1
        else
          Slots[1].Sprite := 5;
      end;
    end
    else if KeyDown + $80 = ScanCode then
    begin
      if Level = 1 then
      begin
        DownHeld := 0;
        if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) then
          Slots[1].Sprite := 9
        else
          Slots[1].Sprite := $A;
      end;
    end
    else if ScanCode = 1 then
    begin
      EscHeld := 1;
      MenuReq := 1;
    end
    else if ScanCode = $10 then
      MenuReq := 1
    else if ScanCode = $3B then
      MenuReq := 1
    else if ScanCode = $3C then
      MenuReq := 1
    else if ScanCode = $3D then
      MenuReq := 1
    else if ScanCode = $3E then
      MenuReq := 1
    else if ScanCode = $3F then
      MenuReq := 1
    else if ScanCode = $40 then
      MenuReq := 1
    else if ScanCode = $41 then
      MenuReq := 1
    else if ScanCode = $42 then
      MenuReq := 1
    else if ScanCode = $43 then
      MenuReq := 1
    else if ScanCode = $44 then
      MenuReq := 1
    else if ScanCode = $16 then
    begin
      ChordU := 1;
      if (ChordV <> 0) and (ChordK <> 0) and (AmmoCheat = 0) then
      begin
        Ammo := Ammo + $19;
        AmmoCheat := 1;
        StatusCamX := -1;
      end;
    end
    else if ScanCode = $96 then
      ChordU := 0
    else if ScanCode = $2F then
    begin
      ChordV := 1;
      if (ChordU <> 0) and (ChordK <> 0) and (AmmoCheat = 0) then
      begin
        Ammo := Ammo + $19;
        AmmoCheat := 1;
        StatusCamX := -1;
      end;
    end
    else if ScanCode = $AF then
      ChordV := 0
    else if ScanCode = $25 then
    begin
      ChordK := 1;
      if (ChordU <> 0) and (ChordV <> 0) and (AmmoCheat = 0) then
      begin
        Ammo := Ammo + $19;
        AmmoCheat := 1;
        StatusCamX := -1;
      end;
    end
    else if ScanCode = $A5 then
      ChordK := 0
    else if ScanCode = $2C then
    begin
      ChordZ := 1;
      if (ChordG <> 0) and (ChordI <> 0) then
      begin
        Floppy := 1;
        DoorKey := 1;
        StatusCamX := -1;
      end;
    end
    else if ScanCode = $AC then
      ChordZ := 0
    else if ScanCode = $22 then
    begin
      ChordG := 1;
      if (ChordZ <> 0) and (ChordI <> 0) then
      begin
        Floppy := 1;
        DoorKey := 1;
        StatusCamX := -1;
      end;
    end
    else if ScanCode = $A2 then
      ChordG := 0
    else if ScanCode = $17 then
    begin
      ChordI := 1;
      if (ChordG <> 0) and (ChordZ <> 0) then
      begin
        Floppy := 1;
        DoorKey := 1;
        StatusCamX := -1;
      end;
    end
    else if ScanCode = $97 then
      ChordI := 0
    else if ScanCode = $19 then
    begin
      ChordP := 1;
      if (ChordJ <> 0) and (ChordX <> 0) then
      begin
        if Invulnerable = 0 then
          Invulnerable := 1
        else
          Invulnerable := 0;
        PjxDone := 1;
      end;
      ChordPB := 1;
      if (ChordO <> 0) and (ChordN <> 0) and (ChordD <> 0) then
        WarpCheat := 1;
    end
    else if ScanCode = $99 then
    begin
      ChordP := 0;
      ChordPB := 0;
    end
    else if ScanCode = $24 then
    begin
      ChordJ := 1;
      if (ChordP <> 0) and (ChordX <> 0) then
      begin
        if Invulnerable = 0 then
          Invulnerable := 1
        else
          Invulnerable := 0;
        PjxDone := 1;
      end;
    end
    else if ScanCode = $A4 then
      ChordJ := 0
    else if ScanCode = $2D then
    begin
      ChordX := 1;
      if (ChordP <> 0) and (ChordJ <> 0) then
      begin
        if Invulnerable = 0 then
          Invulnerable := 1
        else
          Invulnerable := 0;
        PjxDone := 1;
      end;
    end
    else if ScanCode = $30 then
      ChordPB := 1
    else if ScanCode = $B0 then
      ChordPB := 0
    else if ScanCode = $AD then
      ChordX := 0
    else if ScanCode = $18 then
    begin
      ChordO := 1;
      if (ChordPB <> 0) and (ChordN <> 0) and (ChordD <> 0) then
        WarpCheat := 1;
    end
    else if ScanCode = $98 then
      ChordO := 0
    else if ScanCode = $31 then
    begin
      ChordN := 1;
      if (ChordO <> 0) and (ChordPB <> 0) and (ChordD <> 0) then
        WarpCheat := 1;
    end
    else if ScanCode = $B1 then
      ChordN := 0
    else if ScanCode = $20 then
    begin
      ChordD := 1;
      if (ChordO <> 0) and (ChordN <> 0) and (ChordPB <> 0) then
        WarpCheat := 1;
    end
    else if ScanCode = $A0 then
      ChordD := 0;
  if (UpHeld = 0) and (DownHeld = 0) and (RightHeld = 0) and (LeftHeld = 0) then
    WalkHeld := 0;
  Inline($FF/$36/>OldInt9 + 2/$FF/$36/>OldInt9/$5B/$58/$87/$5E/$0E/$87/$46/$10/$89/$EC/$5D/$07/$1F/$5F/$5E/
    $5A/$59/$CB);
  Inline($E4/$61/$8A/$E0/$0C/$80/$E6/$61/$86/$E0/$E6/$61/$80/$20/$E6/$20);
end;
