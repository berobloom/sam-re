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
  W684A := Port[$60];
  if B69D3 = 1 then
    if W684A = KeyLeft then
      W684A := KeyRight
    else if KeyLeft + $80 = W684A then
      W684A := KeyRight + $80
    else if W684A = KeyRight then
      W684A := KeyLeft
    else if KeyRight + $80 = W684A then
      W684A := KeyLeft + $80;
  if B69DA = 0 then
    if W684A = KeyLeft then
    begin
      B6EF0 := 1;
      B6EF1 := 0;
      B6EE8 := 0;
      Slots[1].W14 := 5;
      if B6EE7 <> 0 then
        Slots[1].W14 := $E;
    end
    else if KeyLeft + $80 = W684A then
    begin
      B6EF0 := 0;
      if B6EE7 = 0 then
      begin
        if B6EF1 = 0 then
          Slots[1].W14 := $A
        else
          Slots[1].W14 := 1;
      end
      else if B6EF1 = 1 then
        Slots[1].W14 := $D
      else
        Slots[1].W14 := $E;
    end
    else if W684A = KeyRight then
    begin
      B6EF1 := 1;
      B6EF0 := 0;
      B6EE8 := 0;
      Slots[1].W14 := 1;
      if B6EE7 <> 0 then
        Slots[1].W14 := $D;
    end
    else if KeyRight + $80 = W684A then
    begin
      B6EF1 := 0;
      if B6EE7 = 0 then
      begin
        if B6EF0 = 0 then
          Slots[1].W14 := 9
        else
          Slots[1].W14 := 5;
      end
      else if B6EF0 = 1 then
        Slots[1].W14 := $E
      else
        Slots[1].W14 := $D;
    end
    else if W684A = KeyFire then
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
            Shots[I].W06 := Slots[1].W06;
            Shots[I].W08 := Slots[1].W08;
            Shots[I].W14 := $27;
            if (Slots[1].W14 = 1) or (Slots[1].W14 = $D) or (Slots[1].W14 = 9) or (Slots[1].W14 = $B) then
            begin
              Shots[I].W16 := 1;
              Slots[1].W14 := $B;
            end
            else
            begin
              Shots[I].W16 := -1;
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
    end
    else if KeyFire + $80 = W684A then
    begin
      if Slots[1].W14 = $B then
        Slots[1].W14 := 9
      else if Slots[1].W14 = $C then
        Slots[1].W14 := $A;
    end
    else if W684A = KeyJump then
      B6EF3 := 1
    else if KeyJump + $80 = W684A then
      B6EF3 := 0
    else if W684A = KeyUp then
    begin
      if Level = 1 then
      begin
        B6EE9 := 1;
        B6EEA := 0;
        if (Slots[1].W14 = 1) or (Slots[1].W14 = 9) or (Slots[1].W14 = $B) then
          Slots[1].W14 := 1
        else
          Slots[1].W14 := 5;
      end;
    end
    else if KeyUp + $80 = W684A then
    begin
      if Level = 1 then
      begin
        B6EE9 := 0;
        if (Slots[1].W14 = 1) or (Slots[1].W14 = 9) or (Slots[1].W14 = $B) then
          Slots[1].W14 := 9
        else
          Slots[1].W14 := $A;
      end;
    end
    else if W684A = KeyDown then
    begin
      if Level = 1 then
      begin
        B6EEA := 1;
        B6EE9 := 0;
        if (Slots[1].W14 = 1) or (Slots[1].W14 = 9) or (Slots[1].W14 = $B) then
          Slots[1].W14 := 1
        else
          Slots[1].W14 := 5;
      end;
    end
    else if KeyDown + $80 = W684A then
    begin
      if Level = 1 then
      begin
        B6EEA := 0;
        if (Slots[1].W14 = 1) or (Slots[1].W14 = 9) or (Slots[1].W14 = $B) then
          Slots[1].W14 := 9
        else
          Slots[1].W14 := $A;
      end;
    end
    else if W684A = 1 then
    begin
      B6EEB := 1;
      B683C := 1;
    end
    else if W684A = $10 then
      B683C := 1
    else if W684A = $3B then
      B683C := 1
    else if W684A = $3C then
      B683C := 1
    else if W684A = $3D then
      B683C := 1
    else if W684A = $3E then
      B683C := 1
    else if W684A = $3F then
      B683C := 1
    else if W684A = $40 then
      B683C := 1
    else if W684A = $41 then
      B683C := 1
    else if W684A = $42 then
      B683C := 1
    else if W684A = $43 then
      B683C := 1
    else if W684A = $44 then
      B683C := 1
    else if W684A = $16 then
    begin
      B69FF := 1;
      if (B6A00 <> 0) and (B6A01 <> 0) and (B6A02 = 0) then
      begin
        Ammo := Ammo + $19;
        B6A02 := 1;
        W6858 := -1;
      end;
    end
    else if W684A = $96 then
      B69FF := 0
    else if W684A = $2F then
    begin
      B6A00 := 1;
      if (B69FF <> 0) and (B6A01 <> 0) and (B6A02 = 0) then
      begin
        Ammo := Ammo + $19;
        B6A02 := 1;
        W6858 := -1;
      end;
    end
    else if W684A = $AF then
      B6A00 := 0
    else if W684A = $25 then
    begin
      B6A01 := 1;
      if (B69FF <> 0) and (B6A00 <> 0) and (B6A02 = 0) then
      begin
        Ammo := Ammo + $19;
        B6A02 := 1;
        W6858 := -1;
      end;
    end
    else if W684A = $A5 then
      B6A01 := 0
    else if W684A = $2C then
    begin
      B6A03 := 1;
      if (B6A04 <> 0) and (B6A05 <> 0) then
      begin
        B6A12 := 1;
        B6A1A := 1;
        W6858 := -1;
      end;
    end
    else if W684A = $AC then
      B6A03 := 0
    else if W684A = $22 then
    begin
      B6A04 := 1;
      if (B6A03 <> 0) and (B6A05 <> 0) then
      begin
        B6A12 := 1;
        B6A1A := 1;
        W6858 := -1;
      end;
    end
    else if W684A = $A2 then
      B6A04 := 0
    else if W684A = $17 then
    begin
      B6A05 := 1;
      if (B6A04 <> 0) and (B6A03 <> 0) then
      begin
        B6A12 := 1;
        B6A1A := 1;
        W6858 := -1;
      end;
    end
    else if W684A = $97 then
      B6A05 := 0
    else if W684A = $19 then
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
    else if W684A = $99 then
    begin
      B69FA := 0;
      B69F8 := 0;
    end
    else if W684A = $24 then
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
    else if W684A = $A4 then
      B69FB := 0
    else if W684A = $2D then
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
    else if W684A = $30 then
      B69F8 := 1
    else if W684A = $B0 then
      B69F8 := 0
    else if W684A = $AD then
      B69FC := 0
    else if W684A = $18 then
    begin
      B69F5 := 1;
      if (B69F8 <> 0) and (B69F6 <> 0) and (B69F7 <> 0) then
        B69F9 := 1;
    end
    else if W684A = $98 then
      B69F5 := 0
    else if W684A = $31 then
    begin
      B69F6 := 1;
      if (B69F5 <> 0) and (B69F8 <> 0) and (B69F7 <> 0) then
        B69F9 := 1;
    end
    else if W684A = $B1 then
      B69F6 := 0
    else if W684A = $20 then
    begin
      B69F7 := 1;
      if (B69F5 <> 0) and (B69F6 <> 0) and (B69F8 <> 0) then
        B69F9 := 1;
    end
    else if W684A = $A0 then
      B69F7 := 0;
  if (B6EE9 = 0) and (B6EEA = 0) and (B6EF1 = 0) and (B6EF0 = 0) then
    W6844 := 0;
  Inline($FF/$36/>OldInt9 + 2/$FF/$36/>OldInt9/$5B/$58/$87/$5E/$0E/$87/$46/$10/$89/$EC/$5D/$07/$1F/$5F/$5E/
    $5A/$59/$CB);
  Inline($E4/$61/$8A/$E0/$0C/$80/$E6/$61/$86/$E0/$E6/$61/$80/$20/$E6/$20);
end;
