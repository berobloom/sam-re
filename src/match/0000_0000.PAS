{ src: GUESS 0000:0000 (the int 9 handler: reads the scan code into W684A (left/right swapped while B69D3 = 1,
  the "confused" body), and unless B69DA turns the defined keys into the walk/jump/fire flags and poses (up and
  down on the world map only; fire with no ammo plays sound $14); Esc, Tab and F1..F10 set B683C. Held-key
  cheats: U+V+K Ammo + 25 once (B6A02); Z+G+I B6A12/B6A1A; P+J+X toggles B6A19 (B69FD); O+N+D with B (or P)
  B69F9. Then it chains to the old int 9; the inline tail after the chain is dead (an EOI whose
  `mov al,$20` reads $80/$20) }
{ keep: - }
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
      B6EF0 := 1;
      B6EF1 := 0;
      B6EE8 := 0;
      Slots[1].Sprite := 5;
      if B6EE7 <> 0 then
        Slots[1].Sprite := $E;
    end
    else if KeyLeft + $80 = ScanCode then
    begin
      B6EF0 := 0;
      if B6EE7 = 0 then
      begin
        if B6EF1 = 0 then
          Slots[1].Sprite := $A
        else
          Slots[1].Sprite := 1;
      end
      else if B6EF1 = 1 then
        Slots[1].Sprite := $D
      else
        Slots[1].Sprite := $E;
    end
    else if ScanCode = KeyRight then
    begin
      B6EF1 := 1;
      B6EF0 := 0;
      B6EE8 := 0;
      Slots[1].Sprite := 1;
      if B6EE7 <> 0 then
        Slots[1].Sprite := $D;
    end
    else if KeyRight + $80 = ScanCode then
    begin
      B6EF1 := 0;
      if B6EE7 = 0 then
      begin
        if B6EF0 = 0 then
          Slots[1].Sprite := 9
        else
          Slots[1].Sprite := 5;
      end
      else if B6EF0 = 1 then
        Slots[1].Sprite := $E
      else
        Slots[1].Sprite := $D;
    end
    else if ScanCode = KeyFire then
    begin
      if Ammo = 0 then
        PlaySound($14)
      else if (Ammo > 0) and (B6A1B = 0) and (Level > 1) then
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
      B6EF3 := 1
    else if KeyJump + $80 = ScanCode then
      B6EF3 := 0
    else if ScanCode = KeyUp then
    begin
      if Level = 1 then
      begin
        B6EE9 := 1;
        B6EEA := 0;
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
        B6EE9 := 0;
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
        B6EEA := 1;
        B6EE9 := 0;
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
        B6EEA := 0;
        if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) then
          Slots[1].Sprite := 9
        else
          Slots[1].Sprite := $A;
      end;
    end
    else if ScanCode = 1 then
    begin
      B6EEB := 1;
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
      B69FF := 1;
      if (B6A00 <> 0) and (B6A01 <> 0) and (B6A02 = 0) then
      begin
        Ammo := Ammo + $19;
        B6A02 := 1;
        StatusCamX := -1;
      end;
    end
    else if ScanCode = $96 then
      B69FF := 0
    else if ScanCode = $2F then
    begin
      B6A00 := 1;
      if (B69FF <> 0) and (B6A01 <> 0) and (B6A02 = 0) then
      begin
        Ammo := Ammo + $19;
        B6A02 := 1;
        StatusCamX := -1;
      end;
    end
    else if ScanCode = $AF then
      B6A00 := 0
    else if ScanCode = $25 then
    begin
      B6A01 := 1;
      if (B69FF <> 0) and (B6A00 <> 0) and (B6A02 = 0) then
      begin
        Ammo := Ammo + $19;
        B6A02 := 1;
        StatusCamX := -1;
      end;
    end
    else if ScanCode = $A5 then
      B6A01 := 0
    else if ScanCode = $2C then
    begin
      B6A03 := 1;
      if (B6A04 <> 0) and (B6A05 <> 0) then
      begin
        B6A12 := 1;
        B6A1A := 1;
        StatusCamX := -1;
      end;
    end
    else if ScanCode = $AC then
      B6A03 := 0
    else if ScanCode = $22 then
    begin
      B6A04 := 1;
      if (B6A03 <> 0) and (B6A05 <> 0) then
      begin
        B6A12 := 1;
        B6A1A := 1;
        StatusCamX := -1;
      end;
    end
    else if ScanCode = $A2 then
      B6A04 := 0
    else if ScanCode = $17 then
    begin
      B6A05 := 1;
      if (B6A04 <> 0) and (B6A03 <> 0) then
      begin
        B6A12 := 1;
        B6A1A := 1;
        StatusCamX := -1;
      end;
    end
    else if ScanCode = $97 then
      B6A05 := 0
    else if ScanCode = $19 then
    begin
      B69FA := 1;
      if (B69FB <> 0) and (B69FC <> 0) then
      begin
        if B6A19 = 0 then
          B6A19 := 1
        else
          B6A19 := 0;
        B69FD := 1;
      end;
      B69F8 := 1;
      if (B69F5 <> 0) and (B69F6 <> 0) and (B69F7 <> 0) then
        B69F9 := 1;
    end
    else if ScanCode = $99 then
    begin
      B69FA := 0;
      B69F8 := 0;
    end
    else if ScanCode = $24 then
    begin
      B69FB := 1;
      if (B69FA <> 0) and (B69FC <> 0) then
      begin
        if B6A19 = 0 then
          B6A19 := 1
        else
          B6A19 := 0;
        B69FD := 1;
      end;
    end
    else if ScanCode = $A4 then
      B69FB := 0
    else if ScanCode = $2D then
    begin
      B69FC := 1;
      if (B69FA <> 0) and (B69FB <> 0) then
      begin
        if B6A19 = 0 then
          B6A19 := 1
        else
          B6A19 := 0;
        B69FD := 1;
      end;
    end
    else if ScanCode = $30 then
      B69F8 := 1
    else if ScanCode = $B0 then
      B69F8 := 0
    else if ScanCode = $AD then
      B69FC := 0
    else if ScanCode = $18 then
    begin
      B69F5 := 1;
      if (B69F8 <> 0) and (B69F6 <> 0) and (B69F7 <> 0) then
        B69F9 := 1;
    end
    else if ScanCode = $98 then
      B69F5 := 0
    else if ScanCode = $31 then
    begin
      B69F6 := 1;
      if (B69F5 <> 0) and (B69F8 <> 0) and (B69F7 <> 0) then
        B69F9 := 1;
    end
    else if ScanCode = $B1 then
      B69F6 := 0
    else if ScanCode = $20 then
    begin
      B69F7 := 1;
      if (B69F5 <> 0) and (B69F6 <> 0) and (B69F8 <> 0) then
        B69F9 := 1;
    end
    else if ScanCode = $A0 then
      B69F7 := 0;
  if (B6EE9 = 0) and (B6EEA = 0) and (B6EF1 = 0) and (B6EF0 = 0) then
    WalkHeld := 0;
  Inline($FF/$36/>OldInt9 + 2/$FF/$36/>OldInt9/$5B/$58/$87/$5E/$0E/$87/$46/$10/$89/$EC/$5D/$07/$1F/$5F/$5E/
    $5A/$59/$CB);
  Inline($E4/$61/$8A/$E0/$0C/$80/$E6/$61/$86/$E0/$E6/$61/$80/$20/$E6/$20);
end;
