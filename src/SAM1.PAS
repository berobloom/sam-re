program SAM1;
{$S-,D+,L+}
uses Dos, U29C3, Crt, U2891, U287F, U286F, GENUS, U25E6, U1802, U0D9C, U0529;
type KRec = array[0..41] of Byte;
var KF: file of KRec absolute TextLines; KT: Text absolute TextLines; KR: KRec absolute TextLines;
    KS: string absolute TextLines; KS2: string absolute TextLines; KRegs: Registers absolute TextLines;
    KL: LongInt absolute TextLines; KP: Pointer absolute TextLines; KI: Integer absolute TextLines;
    KC: Char absolute TextLines; KB: Boolean absolute TextLines;
{ main's data: typed constants DS:0000..000D, variables DS:02A2..02BB }
const
  VideoTab: array[0..12] of Byte = (5, 0, 1, 5, 3, 3, 5, 4, 4, 5, 1, 1, 1); { @0000; adapter by display code (int $10 $1A) }
var
  Tick: Byte; { @02A2; TimerISR's 1/20 divider }
  Regs: Registers; { @02A4 }
  VideoMode: Integer; { @02B8; the mode at start, bit 7 off }
  Adapter: Byte; { @02BA; 0 mono, 1 CGA, 3 EGA, 4 VGA, 5 other (VideoTab), GUESS }
{$L OBJ0000.OBJ}
procedure KeyISR; interrupt; forward;
{$F+} procedure ReadJoystick; forward; {$F-}
procedure TimerISR; interrupt; forward;
{$F+} procedure ExitHandler; forward; {$F-}
procedure InstallHandlers; forward;
procedure RestoreInts; forward;
{$F+} procedure SaveConfig; forward; {$F-}
{$F+} procedure LoadConfig; forward; {$F-}
{$F+} procedure DetectVideo; forward; {$F-}
procedure OBJ0000; external;
{$F+} procedure ReadCMOSClock; external; {$F-}
{$F+} procedure FastTimer; external; {$F-}
{$F+} procedure NormalTimer; external; {$F-}
{ src: GUESS 0000:0000 (the int 9 handler: reads the scan code into W684A (left/right swapped while B69D3 = 1,
  the "confused" body), and unless B69DA turns the defined keys into the walk/jump/fire flags and poses (up and
  down on the world map only; fire with no ammo plays sound $14); Esc, Tab and F1..F10 set B683C. Held-key
  cheats: U+V+K Ammo + 25 once (B6A02); Z+G+I B6A12/B6A1A; P+J+X toggles B6A19 (B69FD); O+N+D with B (or P)
  B69F9. Then it chains to the old int 9; the inline tail after the chain is dead (an EOI whose
  `mov al,$20` reads $80/$20) }
{ keep: - }
procedure KeyISR;
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
      Slots[1].Sprite := 5;
      if B6EE7 <> 0 then
        Slots[1].Sprite := $E;
    end
    else if KeyLeft + $80 = W684A then
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
    else if W684A = KeyRight then
    begin
      B6EF1 := 1;
      B6EF0 := 0;
      B6EE8 := 0;
      Slots[1].Sprite := 1;
      if B6EE7 <> 0 then
        Slots[1].Sprite := $D;
    end
    else if KeyRight + $80 = W684A then
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
    else if KeyFire + $80 = W684A then
    begin
      if Slots[1].Sprite = $B then
        Slots[1].Sprite := 9
      else if Slots[1].Sprite = $C then
        Slots[1].Sprite := $A;
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
        if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) then
          Slots[1].Sprite := 1
        else
          Slots[1].Sprite := 5;
      end;
    end
    else if KeyUp + $80 = W684A then
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
    else if W684A = KeyDown then
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
    else if KeyDown + $80 = W684A then
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
        StatusCamX := -1;
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
        StatusCamX := -1;
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
        StatusCamX := -1;
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
        StatusCamX := -1;
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
        StatusCamX := -1;
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
        StatusCamX := -1;
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
    if Slots[1].Sprite = $B then
      Slots[1].Sprite := 9
    else if Slots[1].Sprite = $C then
      Slots[1].Sprite := $A;
  end;
  if JoyCenterX - $32 > JoyX then
  begin
    B6EF0 := 1;
    B6EF1 := 0;
    B6EE8 := 0;
    JoyMovedX := True;
    if (B6EE7 = 0) and (B6EE6 = 0) then
      Slots[1].Sprite := 5
    else
      Slots[1].Sprite := $E;
  end
  else if JoyCenterX + $32 < JoyX then
  begin
    B6EF1 := 1;
    B6EF0 := 0;
    B6EE8 := 0;
    JoyMovedX := True;
    if (B6EE7 = 0) and (B6EE6 = 0) then
      Slots[1].Sprite := 1
    else
      Slots[1].Sprite := $D;
  end
  else if JoyMovedX then
  begin
    if (B6EF1 = 1) or (Slots[1].Sprite = 1) then
      Slots[1].Sprite := 9
    else
      Slots[1].Sprite := $A;
    B6EF1 := 0;
    B6EF0 := 0;
    JoyMovedX := False;
  end;
  if Level = 1 then
    if JoyCenterY - $32 > JoyY then
    begin
      B6EE9 := 1;
      JoyMovedY := True;
      if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) then
        Slots[1].Sprite := 1
      else
        Slots[1].Sprite := 5;
    end
    else if JoyCenterY + $32 < JoyY then
    begin
      B6EEA := 1;
      JoyMovedY := True;
      if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) then
        Slots[1].Sprite := 1
      else
        Slots[1].Sprite := 5;
    end
    else if JoyMovedY then
    begin
      JoyMovedY := False;
      B6EE9 := 0;
      B6EEA := 0;
      if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) then
        Slots[1].Sprite := 9
      else
        Slots[1].Sprite := $A;
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
        Shots[I].PrevX := Slots[1].PrevX;
        Shots[I].PrevY := Slots[1].PrevY;
        Shots[I].Sprite := $27;
        if (Slots[1].Sprite = 1) or (Slots[1].Sprite = $D) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) then
        begin
          Shots[I].DirX := 1;
          B6EE5 := 1;
          Slots[1].Sprite := $B;
        end
        else
        begin
          Shots[I].DirX := -1;
          B6EE5 := 1;
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
{ src: GUESS 0000:0BE5 (the int $1C handler: W6852 counts ticks; every 20th tick the timers W69CC, W69D4 and
  W69D0 run down (each end forces a status repaint, W6858 := -1); then the sound playing (287F) steps one
  note: Sound(note), NoSound every Period notes, and at the -1 end Playing stops) }
{ keep: - }
procedure TimerISR;
begin
  Inline($FA);
  Inc(W6852);
  Inc(Tick);
  if Tick = 20 then
  begin
    Tick := 0;
    if W69CC > 0 then
    begin
      Dec(W69CC);
      if W69CC = 0 then
      begin
        W69CA := 0;
        StatusCamX := -1;
      end;
    end;
    if W69D4 > 0 then
    begin
      Dec(W69D4, 2);
      if W69D4 = 0 then
      begin
        B69D6 := 0;
        StatusCamX := -1;
      end;
    end;
    if W69D0 > 0 then
    begin
      Dec(W69D0, 2);
      if W69D0 = 0 then
      begin
        B69D2 := 1;
        B69D3 := 0;
        StatusCamX := -1;
      end;
    end;
  end;
  if Playing and SoundOn then
    case CurSound of
    1..12:
      begin
        Sound(Bank1^[CurSound].Notes[NoteIdx]);
        Inc(NoteIdx);
        if NoteIdx mod Bank1^[CurSound].Period = 0 then
          NoSound;
        if Bank1^[CurSound].Notes[NoteIdx] = -1 then
        begin
          Playing := False;
          NoteIdx := 1;
          NoSound;
        end;
      end;
    13..24:
      begin
        Sound(Bank2^[CurSound - 12].Notes[NoteIdx]);
        Inc(NoteIdx);
        if NoteIdx mod Bank2^[CurSound - 12].Period = 0 then
          NoSound;
        if Bank2^[CurSound - 12].Notes[NoteIdx] = -1 then
        begin
          Playing := False;
          NoteIdx := 1;
          NoSound;
        end;
      end;
    25..36:
      begin
        Sound(Bank3^[CurSound - 24].Notes[NoteIdx]);
        Inc(NoteIdx);
        if NoteIdx mod Bank3^[CurSound - 24].Period = 0 then
          NoSound;
        if Bank3^[CurSound - 24].Notes[NoteIdx] = -1 then
        begin
          Playing := False;
          NoteIdx := 1;
          NoSound;
        end;
      end;
    end;
  Inline($FB);
end;
{ src: GUESS 0000:0E33 (the exit procedure: puts back ExitProc and the int $1C and int 9 vectors) }
{ keep: - }
{$F+}
procedure ExitHandler;
begin
  ExitProc := OldExit;
  SetIntVec($1C, OldInt1C);
  SetIntVec(9, OldInt9);
end;
{$F-}
{ src: GUESS 0000:0E67 (installs ExitHandler as ExitProc and the timer and keyboard handlers, saving the old
  ones) }
procedure InstallHandlers;
begin
  OldExit := ExitProc;
  ExitProc := @ExitHandler;
  GetIntVec($1C, OldInt1C);
  SetIntVec($1C, @TimerISR);
  GetIntVec(9, OldInt9);
  SetIntVec(9, @KeyISR);
end;
{ src: GUESS 0000:0EC2 (puts back the int $1C and int 9 vectors, ExitProc left hooked) }
{ to: 0EE9 }
procedure RestoreInts;
begin
  SetIntVec($1C, OldInt1C);
  SetIntVec(9, OldInt9);
end;
{ src: GUESS 0000:0EF2 (writes SAM1.CFG: the sound switch and keys go into Config, then the record) }
{ from: 0EE9 }
{ to: 0F6C }
{$I-}
{$F+}
procedure SaveConfig;
var
  F: file of TConfig;
begin
  Config.Sound := SoundOn;
  Config.KUp := KeyUp;
  Config.KDown := KeyDown;
  Config.KLeft := KeyLeft;
  Config.KRight := KeyRight;
  Config.KJump := KeyJump;
  Config.KFire := KeyFire;
  Config.K70EC := W70EC;
  Config.K70EE := W70EE;
  Assign(F, 'SAM1.CFG');
  Rewrite(F);
  Write(F, Config);
  Close(F);
end;
{$F-}
{$I+}
{ src: GUESS 0000:0F75 (reads SAM1.CFG into Config and takes the sound switch and keys from it, the joystick
  when K70EE = 1 and one is present; without the file: sound on, the arrow keys, Ctrl ($1D) jumps, Alt ($38) fires) }
{ from: 0F6C }
{$I-}
{$F+}
procedure LoadConfig;
var
  F: file of TConfig;
  Ok: Boolean;
begin
  Assign(F, 'SAM1.CFG');
  Reset(F);
  Ok := IOResult = 0;
  Reset(F);
  Ok := IOResult = 0;
  if Ok then
  begin
    Read(F, Config);
    Close(F);
    SoundOn := Config.Sound;
    KeyUp := Config.KUp;
    KeyDown := Config.KDown;
    KeyLeft := Config.KLeft;
    KeyRight := Config.KRight;
    KeyJump := Config.KJump;
    KeyFire := Config.KFire;
    W70EC := Config.K70EC;
    W70EE := Config.K70EE;
    if W70EE = 1 then
      JoyOn := JoyPresent
    else
      JoyOn := False;
  end
  else
  begin
    SoundOn := True;
    KeyUp := $48;
    KeyDown := $50;
    KeyLeft := $4B;
    KeyRight := $4D;
    KeyJump := $1D;
    KeyFire := $38;
    W70EC := 0;
    W70EE := 0;
    JoyOn := False;
  end;
end;
{$F-}
{$I+}
{ src: GUESS 0000:107A (finds the video adapter: the start mode; int $10 $1A00 gives the display code and
  VideoTab the adapter, else int $10 $12/$10 tells an EGA (3); default 1) }
{ to: 10F6 }
{$F+}
procedure DetectVideo;
begin
  Adapter := 1;
  Regs.AH := $0F;
  Intr($10, Regs);
  VideoMode := Regs.AL and $7F;
  Regs.AX := $1A00;
  Intr($10, Regs);
  if Regs.AL = $1A then
  begin
    if Regs.BL <> $FF then
      Adapter := VideoTab[Regs.BL];
  end
  else
  begin
    Regs.AH := $12;
    Regs.BL := $10;
    Intr($10, Regs);
    if Regs.BL <> $10 then
      Adapter := 3;
  end;
end;
{$F-}
begin
{ init }
{ from: 10F6 }
{ src: EXE 0000:11FA, the program body (../SAM code-map.md: start-up, the title and game loops, the frame body
  with its draw passes, shut-down); pasgen.py output }
{$I-}
  if MemAvail < 200000 then
  begin
    WriteLn('Secret Agent Requires 450k free Memory to run!');
    Halt;
  end;
  DetectVideo;
  if (Adapter = 3) or (Adapter = 4) then
  begin
    InstallHandlers;
    FastTimer;
    Playing := False;
    GetMem(Bank1, $1C98);
    Assign(SndFile, 'SAM101E.SND');
    Reset(SndFile);
    Read(SndFile, Bank1^);
    Decrypt(Bank1^, $1C98);
    Close(SndFile);
    GetMem(Bank2, $1C98);
    Assign(SndFile, 'SAM102E.SND');
    Reset(SndFile);
    Read(SndFile, Bank2^);
    Decrypt(Bank2^, $1C98);
    Close(SndFile);
    GetMem(Bank3, $1C98);
    Assign(SndFile, 'SAM103E.SND');
    Reset(SndFile);
    Read(SndFile, Bank3^);
    Decrypt(Bank3^, $1C98);
    Close(SndFile);
    SoundOn := True;
    StartupInit;
    SaveState;
    W3832 := 0;
    W3834 := 0;
    W3836 := 0;
    FadeIn(0);
    JoyOn := JoyPresent;
    JoyMovedX := False;
    if JoyOn then
    begin
      JoyCenterX := ReadAxis(0);
      JoyCenterY := ReadAxis(1);
    end;
    LoadConfig;
    WriteLn('Decompressing Graphics Files...');
    LoadGraphics;
    SetGraphMode(0);
    ShowLogo;
    while B6EEC = 0 do
    begin
      SetGraphMode(0);
      TitleLoop;
      if B6EEC = 0 then
        NewGame;
      if (B6EEC = 0) and (B6EED = 0) then
      begin
        W6848 := SetStride($50);
        SetBorder(4);
        Blackout;
        if W70EC = 0 then
          SetViewStart(0, $10)
        else
          SetViewStartAlt(0, $10);
        LevelReset;
        if W6D86 <> 0 then
        begin
          case W6D86 of
            2..$A:
              if LoadGame(W6D86 - 1) then
                begin end;
            $B:
              if LoadGame(0) then
                begin end;
          end;
          W6D86 := 0;
        end;
        LoadLevel(1);
        if Adapter = 4 then
          SetSplitVGA($180)
        else
          SetSplit($BE);
        while (B6EEC = 0) and (B6EED = 0) do
        begin
          if StatusCamX <> CamX then
            DrawStatus;
          if W6852 > 7 then
          begin
            W6852 := 0;
            if JoyOn then
              ReadJoystick;
            if (Slots[1].Sprite = 9) and (B6EF1 <> 0) then
              Slots[1].Sprite := 1
            else
              if (Slots[1].Sprite = $A) and (B6EF0 <> 0) then
                Slots[1].Sprite := 5
              else
                if ((Slots[1].Sprite = $A) or (Slots[1].Sprite = 9)) and ((B6EEA <> 0) or (B6EE9 <> 0)) then
                  Slots[1].Sprite := 1;
            FlipPage;
            DrawBack(Slots[1].PrevX - $10, Slots[1].PrevY - $10);
            DrawBack(Slots[1].PrevX - $10, Slots[1].PrevY);
            DrawBack(Slots[1].PrevX - $10, Slots[1].PrevY + $10);
            DrawBack(Slots[1].PrevX, Slots[1].PrevY - $10);
            DrawBack(Slots[1].PrevX, Slots[1].PrevY);
            DrawBack(Slots[1].PrevX, Slots[1].PrevY + $10);
            DrawBack(Slots[1].PrevX + $10, Slots[1].PrevY - $10);
            DrawBack(Slots[1].PrevX + $10, Slots[1].PrevY);
            DrawBack(Slots[1].PrevX + $10, Slots[1].PrevY + $10);
            for SlotIdx := 2 to $19 do
              if Slots[SlotIdx].Free = 0 then
                if Slots[SlotIdx].Remove <> 0 then
                begin
                  Slots[SlotIdx].Free := 1;
                  DrawBack(Slots[SlotIdx].PrevX, Slots[SlotIdx].PrevY);
                  DrawBack(Slots[SlotIdx].PrevX - $10, Slots[SlotIdx].PrevY);
                  DrawBack(Slots[SlotIdx].PrevX + $10, Slots[SlotIdx].PrevY);
                  DrawBack(Slots[SlotIdx].PrevX + $20, Slots[SlotIdx].PrevY);
                  DrawBack(Slots[SlotIdx].PrevX - $10, Slots[SlotIdx].PrevY - $10);
                  DrawBack(Slots[SlotIdx].PrevX - $10, Slots[SlotIdx].PrevY + $10);
                  DrawBack(Slots[SlotIdx].PrevX + $10, Slots[SlotIdx].PrevY - $10);
                  DrawBack(Slots[SlotIdx].PrevX + $10, Slots[SlotIdx].PrevY + $10);
                  DrawBack(Slots[SlotIdx].PrevX, Slots[SlotIdx].PrevY - $10);
                  DrawBack(Slots[SlotIdx].PrevX, Slots[SlotIdx].PrevY + $10);
                end
                else
                  if OnScreen($28, SlotIdx) or (Slots[SlotIdx].Kind = $1C) or (Slots[SlotIdx].Kind = $15)
                      or (Slots[RowIdx].Kind = $E) or (Slots[RowIdx].Remove <> 0) then
                  begin
                    DrawBack(Slots[SlotIdx].PrevX, Slots[SlotIdx].PrevY);
                    if Slots[SlotIdx].PrevX and $F > 0 then
                      DrawBack(Slots[SlotIdx].PrevX + $10, Slots[SlotIdx].PrevY);
                    case Slots[SlotIdx].Sprite of
                      $353:
                      begin
                        DrawBack(Slots[SlotIdx].PrevX + $30, Slots[SlotIdx].PrevY);
                        DrawBack(Slots[SlotIdx].PrevX + $20, Slots[SlotIdx].PrevY);
                        DrawBack(Slots[SlotIdx].PrevX + $10, Slots[SlotIdx].PrevY);
                      end;
                      $321..$383, $1389:
                      begin
                        DrawBack(Slots[SlotIdx].PrevX, Slots[SlotIdx].PrevY - $10);
                        if Slots[SlotIdx].PrevX and $F > 0 then
                          DrawBack(Slots[SlotIdx].PrevX + $F, Slots[SlotIdx].PrevY - $10);
                      end;
                      $72:
                      begin
                        DrawBack(Slots[SlotIdx].PrevX, Slots[SlotIdx].PrevY - $10);
                        DrawBack(Slots[SlotIdx].PrevX, Slots[SlotIdx].PrevY + $10);
                        if Slots[SlotIdx].PrevX and $F > 0 then
                        begin
                          DrawBack(Slots[SlotIdx].PrevX + $F, Slots[SlotIdx].PrevY + $10);
                          DrawBack(Slots[SlotIdx].PrevX + $F, Slots[SlotIdx].PrevY - $10);
                        end;
                      end;
                      $65:
                      begin
                        DrawBack(Slots[SlotIdx].PrevX, Slots[SlotIdx].PrevY - $10);
                        if Slots[SlotIdx].PrevX and $F > 0 then
                          DrawBack(Slots[SlotIdx].PrevX + $F, Slots[SlotIdx].PrevY - $10);
                      end;
                    end;
                  end;
            for SlotIdx := 1 to Gun do
            begin
              DrawBack(Shots[SlotIdx].PrevX, Shots[SlotIdx].PrevY);
              DrawBack(Shots[SlotIdx].PrevX + $10, Shots[SlotIdx].PrevY);
              DrawBack(Shots[SlotIdx].PrevX, Shots[SlotIdx].PrevY + $10);
              DrawBack(Shots[SlotIdx].PrevX + $10, Shots[SlotIdx].PrevY + $10);
            end;
            if (B6A1B = 0) and (B6A64 = 0) then
            begin
              MovePlayer;
              if Level > 1 then
                Jump;
              MemW[0:$41C] := MemW[0:$41A];
              TouchPlayer;
              B6EE8 := 0;
            end
            else
              if B6A1B <> 0 then
              begin
                Slots[1].PrevX := Slots[1].X;
                Slots[1].PrevY := Slots[1].Y;
                if Slots[1].Sprite <> $F then
                  Slots[1].Sprite := $F
                else
                  Slots[1].Sprite := $10;
                if ArcLen = $23 then
                  PlaySound($16);
                Dec(ArcLen);
                if ArcLen = 0 then
                  KillPlayer;
                if ArcLen > 0 then
                begin
                  Dec(Slots[1].Y, Arc[ArcLen]);
                  if Slots[1].Y < $10 then
                    Slots[1].Y := $10
                  else
                    if CamY + $B8 < Slots[1].Y then
                      Slots[1].Y := CamY + $B8;
                end;
              end
              else
                if B6A64 <> 0 then
                begin
                  Slots[1].PrevX := Slots[1].X;
                  Slots[1].PrevY := Slots[1].Y;
                  if RespawnDelay = 8 then
                    PlaySound(8);
                  Dec(RespawnDelay);
                  if RespawnDelay = 0 then
                  begin
                    FadeOut($14);
                    Level := 1;
                    LevelReset;
                    LoadLevel(Level);
                    if AllDone <> 0 then
                      SecurityDone;
                  end
                  else
                    if RespawnDelay > 0 then
                      if Slots[1].DirX = -1 then
                        Dec(Slots[1].X, 2)
                      else
                        Inc(Slots[1].X, 2);
                end;
            ActorFrame;
            for SlotIdx := 1 to Gun do
              if Shots[SlotIdx].Free = 0 then
                if Shots[SlotIdx].Remove <> 0 then
                begin
                  DrawBack(Shots[SlotIdx].X, Shots[SlotIdx].Y);
                  DrawBack(Shots[SlotIdx].X + $10, Shots[SlotIdx].Y);
                  DrawFront(Shots[SlotIdx].X, Shots[SlotIdx].Y);
                  DrawFront(Shots[SlotIdx].X + $10, Shots[SlotIdx].Y);
                  DrawBack(Shots[SlotIdx].X, Shots[SlotIdx].Y + $10);
                  DrawBack(Shots[SlotIdx].X + $10, Shots[SlotIdx].Y + $10);
                  DrawFront(Shots[SlotIdx].X, Shots[SlotIdx].Y + $10);
                  DrawFront(Shots[SlotIdx].X + $10, Shots[SlotIdx].Y + $10);
                  Shots[SlotIdx].Free := 1;
                end
                else
                begin
                  if Shots[SlotIdx].Sprite = $272 then
                  begin
                    DrawTileB(Gfx[6]^.Tile[Shots[SlotIdx].W0E shr 1 + $19], Shots[SlotIdx].X,
                        Shots[SlotIdx].Y + PageY);
                    Dec(Shots[SlotIdx].W0E);
                    if Shots[SlotIdx].W0E <= 0 then
                    begin
                      Shots[SlotIdx].Remove := 1;
                      DrawBack(Shots[SlotIdx].X, Shots[SlotIdx].Y);
                      DrawBack(Shots[SlotIdx].X - $10, Shots[SlotIdx].Y);
                      DrawBack(Shots[SlotIdx].X + $10, Shots[SlotIdx].Y);
                      DrawBack(Shots[SlotIdx].X, Shots[SlotIdx].Y + $10);
                      DrawBack(Shots[SlotIdx].X - $10, Shots[SlotIdx].Y + $10);
                      DrawBack(Shots[SlotIdx].X + $10, Shots[SlotIdx].Y + $10);
                    end;
                  end
                  else
                    if not ShotOnScreen($28, SlotIdx) then
                    begin
                      DrawBack(Shots[SlotIdx].X, Shots[SlotIdx].Y);
                      DrawBack(Shots[SlotIdx].X + $10, Shots[SlotIdx].Y);
                      DrawBack(Shots[SlotIdx].X, Shots[SlotIdx].Y + $10);
                      DrawBack(Shots[SlotIdx].X + $10, Shots[SlotIdx].Y + $10);
                      Shots[SlotIdx].Remove := 1;
                    end
                    else
                    begin
                      DrawBack(Shots[SlotIdx].X, Shots[SlotIdx].Y);
                      DrawBack(Shots[SlotIdx].X + $10, Shots[SlotIdx].Y);
                      DrawBack(Shots[SlotIdx].X, Shots[SlotIdx].Y + $10);
                      DrawBack(Shots[SlotIdx].X + $10, Shots[SlotIdx].Y + $10);
                      DrawTile(Gfx[1]^.Tile[Shots[SlotIdx].Sprite - 1 + Shots[SlotIdx].Anim], Shots[SlotIdx].X shr 3,
                          Shots[SlotIdx].Y + PageY);
                    end;
                  DrawFront(Shots[SlotIdx].X, Shots[SlotIdx].Y);
                  DrawFront(Shots[SlotIdx].X + $10, Shots[SlotIdx].Y);
                  DrawFront(Shots[SlotIdx].X, Shots[SlotIdx].Y + $10);
                  DrawFront(Shots[SlotIdx].X + $10, Shots[SlotIdx].Y + $10);
                end;
            if B6A06 <> 0 then
            begin
              Dec(W6A08);
              if W6A08 = 0 then
                B69FE := 1
              else
                if W6A08 = -19 then
                begin
                  B69DA := 0;
                  B6A06 := 0;
                end;
            end;
            if B69FE <> 0 then
            begin
              B69FE := 0;
              Slots[1].X := W6A0A;
              Slots[1].Y := W6A0C;
              CamX := Slots[1].X - $A0;
              if CamX < 0 then
                CamX := 0;
              if CamX > $140 then
                CamX := $140;
              CamY := Slots[1].Y - $64;
              if CamY < 0 then
                CamY := 0;
              if CamY > $B8 then
                CamY := $B8;
              if W70EC = 0 then
                SetViewStart(CamX, CamY + $10)
              else
                SetViewStartAlt(CamX, CamY + $10);
            end;
            SlotIdx := 1;
            if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 5) then
            begin
              Inc(Slots[1].Anim, Slots[1].Speed);
              if Slots[1].Anim > $13 then
                Slots[1].Anim := 1;
            end
            else
              Slots[1].Anim := 1;
            if B6A67 <> 0 then
            begin
              Dec(B6A68);
              case B6A68 of
                0:
                  B6A67 := 0;
                $A:
                  Slots[1].W00 := 5;
                $14:
                  Slots[1].W00 := 5;
                $1E:
                  Slots[1].W00 := 5;
              end;
            end;
            if Slots[1].W00 > 0 then
            begin
              DrawSprite(Gfx[3]^.Tile[Slots[1].Anim div 5 + Slots[1].Sprite], Slots[1].X, Slots[1].Y + PageY);
              Dec(Slots[1].W00);
            end
            else
              if Slots[1].X and 7 = 0 then
                DrawTile(Gfx[3]^.Tile[Slots[1].Anim div 5 + Slots[1].Sprite], Slots[1].X shr 3,
                    Slots[1].Y + PageY)
              else
                DrawTileB(Gfx[3]^.Tile[Slots[1].Anim div 5 + Slots[1].Sprite], Slots[1].X, Slots[1].Y + PageY);
            if B6A06 <> 0 then
              if W6A08 < 0 then
                DrawTileB(Gfx[10]^.Tile[W6A08 div 5 + $28], Slots[1].X, Slots[1].Y + PageY)
              else
                DrawTileB(Gfx[10]^.Tile[$28 - W6A08 div 5], Slots[1].X, Slots[1].Y + PageY);
            if (B6EF0 <> 0) and (Slots[1].Sprite = $C) then
              Slots[1].Sprite := 5
            else
              if (B6EF1 <> 0) and (Slots[1].Sprite = $B) then
                Slots[1].Sprite := 1;
            for SlotIdx := 2 to $19 do
              if (Slots[SlotIdx].Free = 0) and (Slots[SlotIdx].Remove = 0) and (OnScreen($20, SlotIdx)
                  or (Slots[SlotIdx].Kind = $1C) or (Slots[SlotIdx].Kind = $15) or (Slots[RowIdx].Kind = $E)) then
                if Slots[SlotIdx].W00 > 0 then
                begin
                  case Slots[SlotIdx].Sprite of
                    1..$32:
                      DrawSprite(Gfx[1]^.Tile[Slots[SlotIdx].Sprite + Slots[SlotIdx].Anim div 5], Slots[SlotIdx].X,
                          Slots[SlotIdx].Y + PageY);
                    $65:
                      if Slots[SlotIdx].W12 = 0 then
                      begin
                        DrawSprite(Gfx[2]^.Tile[Slots[SlotIdx].Sprite - $64 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY - $10);
                        if Slots[SlotIdx].DirX < 0 then
                          DrawSprite(Gfx[2]^.Tile[5], Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY)
                        else
                          DrawSprite(Gfx[2]^.Tile[45], Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      end
                      else
                      begin
                        if Slots[SlotIdx].DirX < 0 then
                          DrawSprite(Gfx[2]^.Tile, Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY - $10)
                        else
                          DrawSprite(Gfx[2]^.Tile[41], Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY - $10);
                        DrawSprite(Gfx[2]^.Tile[Slots[SlotIdx].Sprite - $60 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      end;
                    $66..$96:
                      DrawSprite(Gfx[2]^.Tile[Slots[SlotIdx].Sprite - $64 + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $97..$C8:
                      DrawSprite(Gfx[10]^.Tile[Slots[SlotIdx].Sprite - $96 + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $FB..$12C:
                      DrawSprite(Gfx[15]^.Tile[Slots[SlotIdx].Sprite - $FA + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $12D..$15E:
                      DrawSprite(Gfx[13]^.Tile[Slots[SlotIdx].Sprite - $12C + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $15F..$190:
                      DrawSprite(Gfx[16]^.Tile[Slots[SlotIdx].Sprite - $15E + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $191..$1C2:
                      DrawSprite(Gfx[4]^.Tile[Slots[SlotIdx].Sprite - $190 + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $1C3..$1E7:
                      DrawSprite(Gfx[5]^.Tile[Slots[SlotIdx].Sprite - $1C2 + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $1E8..$1EA:
                      DrawSprite(Gfx[5]^.Tile[Slots[SlotIdx].Sprite - $1C2 + Slots[SlotIdx].Anim shr 3],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $1EB:
                      DrawSprite(Gfx[5]^.Tile[Slots[SlotIdx].Sprite - $1C2 + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $1EC..$1EE:
                      DrawSprite(Gfx[5]^.Tile[Slots[SlotIdx].Sprite - $1C2 + (Slots[SlotIdx].Anim - $15) shr 3],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $1EF..$1F4:
                      DrawSprite(Gfx[5]^.Tile[Slots[SlotIdx].Sprite - $1C2 + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $1F5..$226:
                      DrawSprite(Gfx[1]^.Tile[Slots[SlotIdx].Sprite - $1F4 + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $259..$28A:
                      DrawSprite(Gfx[6]^.Tile[Slots[SlotIdx].Sprite - $258 + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $28B..$2BC:
                      DrawSprite(Gfx[7]^.Tile[Slots[SlotIdx].Sprite - $28A + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $2BD..$2EE:
                      DrawSprite(Gfx[8]^.Tile[Slots[SlotIdx].Sprite - $2BC + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $2EF..$320:
                      DrawSprite(Gfx[9]^.Tile[Slots[SlotIdx].Sprite - $2EE + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $321:
                    begin
                      DrawSprite(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $320 + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY - $10);
                      DrawSprite(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $31C + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    end;
                    $331:
                      if Slots[SlotIdx].W12 = 0 then
                      begin
                        DrawSprite(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $320 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY - $10);
                        if Slots[SlotIdx].DirX < 0 then
                          DrawSprite(Gfx[12]^.Tile[21], Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY)
                        else
                          DrawSprite(Gfx[12]^.Tile[33], Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      end
                      else
                      begin
                        if Slots[SlotIdx].DirX < 0 then
                          DrawSprite(Gfx[12]^.Tile[17], Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY - $10)
                        else
                          DrawSprite(Gfx[12]^.Tile[29], Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY - $10);
                        DrawSprite(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $31C + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      end;
                    $339..$33C:
                      DrawSprite(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $320 + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $345..$352:
                      DrawSprite(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $320 + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                    $353:
                    begin
                      DrawSprite(Gfx[14]^.Tile[Slots[SlotIdx].Sprite - $352 + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      DrawSprite(Gfx[14]^.Tile[Slots[SlotIdx].Sprite - $34E + Slots[SlotIdx].Anim div 5],
                          Slots[SlotIdx].X + $10, Slots[SlotIdx].Y + PageY);
                    end;
                  end;
                  Dec(Slots[SlotIdx].W00);
                end
                else
                  if Slots[SlotIdx].X and 7 = 0 then
                    case Slots[SlotIdx].Sprite of
                      1..$32:
                        DrawTile(Gfx[1]^.Tile[Slots[SlotIdx].Sprite + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $65:
                        if Slots[SlotIdx].W12 = 0 then
                        begin
                          DrawTile(Gfx[2]^.Tile[Slots[SlotIdx].Sprite - $64 + Slots[SlotIdx].Anim div 5],
                              Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY - $10);
                          if Slots[SlotIdx].DirX < 0 then
                            DrawTile(Gfx[2]^.Tile[5], Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY)
                          else
                            DrawTile(Gfx[2]^.Tile[45], Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                        end
                        else
                        begin
                          if Slots[SlotIdx].DirX < 0 then
                            DrawTile(Gfx[2]^.Tile, Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY - $10)
                          else
                            DrawTile(Gfx[2]^.Tile[41], Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY - $10);
                          DrawTile(Gfx[2]^.Tile[Slots[SlotIdx].Sprite - $60 + Slots[SlotIdx].Anim div 5],
                              Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                        end;
                      $66..$96:
                        DrawTile(Gfx[2]^.Tile[Slots[SlotIdx].Sprite - $64 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $97..$C8:
                        DrawTile(Gfx[10]^.Tile[Slots[SlotIdx].Sprite - $96 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $FB..$12C:
                        DrawTile(Gfx[15]^.Tile[Slots[SlotIdx].Sprite - $FA + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $12D..$15E:
                        DrawTile(Gfx[13]^.Tile[Slots[SlotIdx].Sprite - $12C + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $15F..$190:
                        DrawTile(Gfx[16]^.Tile[Slots[SlotIdx].Sprite - $15E + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $191..$1C2:
                        DrawTile(Gfx[4]^.Tile[Slots[SlotIdx].Sprite - $190 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $1C3..$1E7:
                        DrawTile(Gfx[5]^.Tile[Slots[SlotIdx].Sprite - $1C2 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $1E8..$1EA:
                        DrawTile(Gfx[5]^.Tile[Slots[SlotIdx].Sprite - $1C2 + Slots[SlotIdx].Anim shr 3],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $1EB:
                        DrawTile(Gfx[5]^.Tile[Slots[SlotIdx].Sprite - $1C2 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $1EC..$1EE:
                        DrawTile(Gfx[5]^.Tile[Slots[SlotIdx].Sprite - $1C2 + (Slots[SlotIdx].Anim - $15) shr 3],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $1EF..$1F4:
                        DrawTile(Gfx[5]^.Tile[Slots[SlotIdx].Sprite - $1C2 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $1F5..$226:
                        DrawTile(Gfx[1]^.Tile[Slots[SlotIdx].Sprite - $1F4 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $259..$270:
                        DrawTile(Gfx[6]^.Tile[Slots[SlotIdx].Sprite - $258 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $271:
                        DrawTile(Gfx[6]^.Tile[Slots[SlotIdx].Sprite - $258 + Slots[SlotIdx].Anim div 3],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $272..$28A:
                        DrawTile(Gfx[6]^.Tile[Slots[SlotIdx].Sprite - $258 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $28B..$2BC:
                        DrawTile(Gfx[7]^.Tile[Slots[SlotIdx].Sprite - $28A + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $2BD..$2EE:
                        DrawTile(Gfx[8]^.Tile[Slots[SlotIdx].Sprite - $2BC + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $2EF..$320:
                        DrawTile(Gfx[9]^.Tile[Slots[SlotIdx].Sprite - $2EE + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $321:
                      begin
                        DrawTile(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $320 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY - $10);
                        DrawTile(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $31C + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      end;
                      $331:
                        if Slots[SlotIdx].W12 = 0 then
                        begin
                          DrawTile(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $320 + Slots[SlotIdx].Anim div 5],
                              Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY - $10);
                          if Slots[SlotIdx].DirX < 0 then
                            DrawTile(Gfx[12]^.Tile[21], Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY)
                          else
                            DrawTile(Gfx[12]^.Tile[33], Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                        end
                        else
                        begin
                          if Slots[SlotIdx].DirX < 0 then
                            DrawTile(Gfx[12]^.Tile[17], Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY - $10)
                          else
                            DrawTile(Gfx[12]^.Tile[29], Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY - $10);
                          DrawTile(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $31C + Slots[SlotIdx].Anim div 5],
                              Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                        end;
                      $339..$33C:
                        DrawTile(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $320 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $345..$352:
                        DrawTile(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $320 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                      $353:
                      begin
                        DrawTile(Gfx[14]^.Tile[Slots[SlotIdx].Sprite - $352 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3, Slots[SlotIdx].Y + PageY);
                        DrawTile(Gfx[14]^.Tile[Slots[SlotIdx].Sprite - $34E + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X shr 3 + 2, Slots[SlotIdx].Y + PageY);
                      end;
                    end
                  else
                    case Slots[SlotIdx].Sprite of
                      1..$32:
                        DrawTileB(Gfx[1]^.Tile[Slots[SlotIdx].Sprite + Slots[SlotIdx].Anim div 5], Slots[SlotIdx].X,
                            Slots[SlotIdx].Y + PageY);
                      $65:
                        if Slots[SlotIdx].W12 = 0 then
                        begin
                          DrawTileB(Gfx[2]^.Tile[Slots[SlotIdx].Sprite - $64 + Slots[SlotIdx].Anim div 5],
                              Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY - $10);
                          if Slots[SlotIdx].DirX < 0 then
                            DrawTileB(Gfx[2]^.Tile[5], Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY)
                          else
                            DrawTileB(Gfx[2]^.Tile[45], Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                        end
                        else
                        begin
                          if Slots[SlotIdx].DirX < 0 then
                            DrawTileB(Gfx[2]^.Tile, Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY - $10)
                          else
                            DrawTileB(Gfx[2]^.Tile[41], Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY - $10);
                          DrawTileB(Gfx[2]^.Tile[Slots[SlotIdx].Sprite - $60 + Slots[SlotIdx].Anim div 5],
                              Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                        end;
                      $66..$96:
                        DrawTileB(Gfx[2]^.Tile[Slots[SlotIdx].Sprite - $64 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $97..$C8:
                        DrawTileB(Gfx[10]^.Tile[Slots[SlotIdx].Sprite - $96 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $FB..$12C:
                        DrawTileB(Gfx[15]^.Tile[Slots[SlotIdx].Sprite - $FA + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $12D..$15E:
                        DrawTileB(Gfx[13]^.Tile[Slots[SlotIdx].Sprite - $12C + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $15F..$190:
                        DrawTileB(Gfx[16]^.Tile[Slots[SlotIdx].Sprite - $15E + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $191..$1C2:
                        DrawTileB(Gfx[4]^.Tile[Slots[SlotIdx].Sprite - $190 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $1C3..$1E7:
                        DrawTileB(Gfx[5]^.Tile[Slots[SlotIdx].Sprite - $1C2 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $1E8..$1EA:
                        DrawTileB(Gfx[5]^.Tile[Slots[SlotIdx].Sprite - $1C2 + Slots[SlotIdx].Anim shr 3],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $1EB:
                        DrawTileB(Gfx[5]^.Tile[Slots[SlotIdx].Sprite - $1C2 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $1EC..$1EE:
                        DrawTileB(Gfx[5]^.Tile[Slots[SlotIdx].Sprite - $1C2 + (Slots[SlotIdx].Anim - $15) shr 3],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $1EF..$1F4:
                        DrawTileB(Gfx[5]^.Tile[Slots[SlotIdx].Sprite - $1C2 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $1F5..$226:
                        DrawTileB(Gfx[1]^.Tile[Slots[SlotIdx].Sprite - $1F4 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $259..$28A:
                        DrawTileB(Gfx[6]^.Tile[Slots[SlotIdx].Sprite - $258 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $28B..$2BC:
                        DrawTileB(Gfx[7]^.Tile[Slots[SlotIdx].Sprite - $28A + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $2BD..$2EE:
                        DrawTileB(Gfx[8]^.Tile[Slots[SlotIdx].Sprite - $2BC + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $2EF..$320:
                        DrawTileB(Gfx[9]^.Tile[Slots[SlotIdx].Sprite - $2EE + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $321:
                      begin
                        DrawTileB(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $320 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY - $10);
                        DrawTileB(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $31C + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      end;
                      $331:
                        if Slots[SlotIdx].W12 = 0 then
                        begin
                          DrawTileB(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $320 + Slots[SlotIdx].Anim div 5],
                              Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY - $10);
                          if Slots[SlotIdx].DirX < 0 then
                            DrawTileB(Gfx[12]^.Tile[21], Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY)
                          else
                            DrawTileB(Gfx[12]^.Tile[33], Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                        end
                        else
                        begin
                          if Slots[SlotIdx].DirX < 0 then
                            DrawTileB(Gfx[12]^.Tile[17], Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY - $10)
                          else
                            DrawTileB(Gfx[12]^.Tile[29], Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY - $10);
                          DrawTileB(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $31C + Slots[SlotIdx].Anim div 5],
                              Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                        end;
                      $339..$33C:
                        DrawTileB(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $320 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $345..$352:
                        DrawTileB(Gfx[12]^.Tile[Slots[SlotIdx].Sprite - $320 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                      $353:
                      begin
                        DrawTileB(Gfx[14]^.Tile[Slots[SlotIdx].Sprite - $352 + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X, Slots[SlotIdx].Y + PageY);
                        DrawTileB(Gfx[14]^.Tile[Slots[SlotIdx].Sprite - $34E + Slots[SlotIdx].Anim div 5],
                            Slots[SlotIdx].X + $10, Slots[SlotIdx].Y + PageY);
                      end;
                    end;
            DrawFront(Slots[1].PrevX - $10, Slots[1].PrevY - $10);
            DrawFront(Slots[1].PrevX - $10, Slots[1].PrevY);
            DrawFront(Slots[1].PrevX - $10, Slots[1].PrevY + $10);
            DrawFront(Slots[1].PrevX, Slots[1].PrevY - $10);
            DrawFront(Slots[1].PrevX, Slots[1].PrevY);
            DrawFront(Slots[1].PrevX, Slots[1].PrevY + $10);
            DrawFront(Slots[1].PrevX + $10, Slots[1].PrevY - $10);
            DrawFront(Slots[1].PrevX + $10, Slots[1].PrevY);
            DrawFront(Slots[1].PrevX + $10, Slots[1].PrevY + $10);
            for SlotIdx := 2 to $19 do
              if Slots[SlotIdx].Free = 0 then
                if Slots[SlotIdx].Remove <> 0 then
                begin
                  DrawFront(Slots[SlotIdx].PrevX, Slots[SlotIdx].PrevY);
                  DrawFront(Slots[SlotIdx].PrevX - $10, Slots[SlotIdx].PrevY);
                  DrawFront(Slots[SlotIdx].PrevX + $10, Slots[SlotIdx].PrevY);
                  DrawFront(Slots[SlotIdx].PrevX - $10, Slots[SlotIdx].PrevY - $10);
                  DrawFront(Slots[SlotIdx].PrevX - $10, Slots[SlotIdx].PrevY + $10);
                  DrawFront(Slots[SlotIdx].PrevX + $10, Slots[SlotIdx].PrevY - $10);
                  DrawFront(Slots[SlotIdx].PrevX + $10, Slots[SlotIdx].PrevY + $10);
                  DrawFront(Slots[SlotIdx].PrevX, Slots[SlotIdx].PrevY - $10);
                  DrawFront(Slots[SlotIdx].PrevX, Slots[SlotIdx].PrevY + $10);
                end
                else
                  if OnScreen($20, SlotIdx) or (Slots[SlotIdx].Kind = $1C) or (Slots[SlotIdx].Kind = $1B)
                      or (Slots[SlotIdx].Kind = $15) or (Slots[RowIdx].Kind = $E) then
                  begin
                    DrawFront(Slots[SlotIdx].X, Slots[SlotIdx].Y);
                    if Slots[SlotIdx].X and $F > 0 then
                      DrawFront(Slots[SlotIdx].X + $F, Slots[SlotIdx].Y);
                    if Slots[SlotIdx].Kind = $1B then
                    begin
                      DrawFront(Slots[SlotIdx].X, Slots[SlotIdx].Y - $10);
                      DrawFront(Slots[SlotIdx].X + $10, Slots[SlotIdx].Y - $10);
                    end
                    else
                      case Slots[SlotIdx].Sprite of
                        $353:
                        begin
                          DrawFront(Slots[SlotIdx].X + $30, Slots[SlotIdx].Y);
                          DrawFront(Slots[SlotIdx].X + $20, Slots[SlotIdx].Y);
                          DrawFront(Slots[SlotIdx].X + $10, Slots[SlotIdx].Y);
                        end;
                        $321..$383, $1389:
                        begin
                          DrawFront(Slots[SlotIdx].X, Slots[SlotIdx].Y - $10);
                          if Slots[SlotIdx].X and $F > 0 then
                            DrawFront(Slots[SlotIdx].X + $F, Slots[SlotIdx].Y - $10);
                        end;
                        $72:
                        begin
                          if Slots[SlotIdx].Y > $F then
                            DrawFront(Slots[SlotIdx].X, Slots[SlotIdx].Y - $10);
                          DrawFront(Slots[SlotIdx].X, Slots[SlotIdx].Y + $10);
                          if Slots[SlotIdx].X and $F > 0 then
                          begin
                            DrawFront(Slots[SlotIdx].X + $F, Slots[SlotIdx].Y + $10);
                            if Slots[SlotIdx].Y > $F then
                              DrawFront(Slots[SlotIdx].X + $F, Slots[SlotIdx].Y - $10);
                          end;
                        end;
                        $65:
                        begin
                          DrawFront(Slots[SlotIdx].X, Slots[SlotIdx].Y - $10);
                          if Slots[SlotIdx].X and $F > 0 then
                            DrawFront(Slots[SlotIdx].X + $F, Slots[SlotIdx].Y - $10);
                        end;
                      end;
                  end
                  else
                    if (Slots[SlotIdx].Kind = 7) or (Slots[SlotIdx].Kind = $E) or (Slots[SlotIdx].Kind = $13)
                        or (Slots[SlotIdx].Kind = $1388) then
                    begin
                      Slots[SlotIdx].Remove := 1;
                      DrawFront(Slots[SlotIdx].X, Slots[SlotIdx].Y);
                      if Slots[SlotIdx].X and $F > 0 then
                      begin
                        DrawFront(Slots[SlotIdx].X + $F, Slots[SlotIdx].Y);
                        DrawFront(Slots[SlotIdx].X - $F, Slots[SlotIdx].Y);
                      end;
                    end;
            if B6A1B <> 0 then
              DrawTileB(Gfx[3]^.Tile[Slots[1].Anim div 5 + Slots[1].Sprite], Slots[1].X, Slots[1].Y + PageY);
            ShowPage;
            if B69D2 <> 0 then
            begin
              B69D2 := 0;
              ShowMessage('YOU FEEL LESS CONFUSED');
            end;
            if B683C <> 0 then
            begin
              EscKey := EscapeMenu;
              B683C := 0;
            end;
            if B6EEE <> 0 then
            begin
              FadeOut($14);
              if Ammo < $F then
                Ammo := $F;
              SiteDone[MapSite] := 0;
              if B6A1B = 0 then
                Level := 1;
              LevelReset;
              RestoreState;
              LoadLevel(Level);
              StatusCamX := -1;
            end;
            if B69F9 <> 0 then
            begin
              B69F9 := 0;
              SlotIdx := AskWarp;
              if (SlotIdx >= 1) and (SlotIdx <= $10) then
              begin
                Level := SlotIdx + 1;
                FadeOut($14);
                SiteDone[MapSite] := 0;
                RestoreState;
                LoadLevel(Level);
                LevelReset;
                StatusCamX := -1;
              end;
            end;
            if B69FD <> 0 then
            begin
              B69FD := 0;
              if B6A19 <> 0 then
                ShowMessage('GOD Mode On')
              else
                ShowMessage('GOD Mode Off');
            end;
          end;
        end;
      end;
      if B6D8C <> 0 then
        ShowEnding;
    end;
    FadeOut($14);
    SetBiosMode(3);
    if SoundOn then
      while Playing do
        begin end;
    NoSound;
    OrderScreen;
    NormalTimer;
    RestoreInts;
    ReadCMOSClock;
    SaveConfig;
  end
  else
  begin
    SetBiosMode(3);
    WriteLn('This game requires an EGA or VGA Adapter!');
    NoSound;
  end;
end.
