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
{ src: GUESS 0000:0BE5 (the int $1C handler: W6852 counts ticks; every 20th tick the timers W69CC, W69D4 and
  W69D0 run down (each end forces a status repaint, W6858 := -1); then the sound playing (287F) steps one
  note: Sound(note), NoSound every Period notes, and at the -1 end Playing stops) }
{ keep: - }
procedure TimerISR;
begin
  Inline($FA);
  Inc(Ticks);
  Inc(Tick);
  if Tick = 20 then
  begin
    Tick := 0;
    if SpeedTimer > 0 then
    begin
      Dec(SpeedTimer);
      if SpeedTimer = 0 then
      begin
        SpeedBonus := 0;
        StatusCamX := -1;
      end;
    end;
    if SlowTimer > 0 then
    begin
      Dec(SlowTimer, 2);
      if SlowTimer = 0 then
      begin
        SlowWalk := 0;
        StatusCamX := -1;
      end;
    end;
    if ConfuseTimer > 0 then
    begin
      Dec(ConfuseTimer, 2);
      if ConfuseTimer = 0 then
      begin
        UnconfuseMsg := 1;
        Confused := 0;
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
  Config.K70EC := AltVideo;
  Config.K70EE := UseJoystick;
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
    AltVideo := Config.K70EC;
    UseJoystick := Config.K70EE;
    if UseJoystick = 1 then
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
    AltVideo := 0;
    UseJoystick := 0;
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
        PageStride := SetStride($50);
        SetBorder(4);
        Blackout;
        if AltVideo = 0 then
          SetViewStart(0, $10)
        else
          SetViewStartAlt(0, $10);
        LevelReset;
        if SaveSlot <> 0 then
        begin
          case SaveSlot of
            2..$A:
              if LoadGame(SaveSlot - 1) then
                begin end;
            $B:
              if LoadGame(0) then
                begin end;
          end;
          SaveSlot := 0;
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
          if Ticks > 7 then
          begin
            Ticks := 0;
            if JoyOn then
              ReadJoystick;
            if (Slots[1].Sprite = 9) and (RightHeld <> 0) then
              Slots[1].Sprite := 1
            else
              if (Slots[1].Sprite = $A) and (LeftHeld <> 0) then
                Slots[1].Sprite := 5
              else
                if ((Slots[1].Sprite = $A) or (Slots[1].Sprite = 9)) and ((DownHeld <> 0) or (UpHeld <> 0)) then
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
            if (HitLock = 0) and (ExitLock = 0) then
            begin
              MovePlayer;
              if Level > 1 then
                Jump;
              MemW[0:$41C] := MemW[0:$41A];
              TouchPlayer;
              B6EE8 := 0;
            end
            else
              if HitLock <> 0 then
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
                if ExitLock <> 0 then
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
            if WarpArmed <> 0 then
            begin
              Dec(WarpTimer);
              if WarpTimer = 0 then
                B69FE := 1
              else
                if WarpTimer = -19 then
                begin
                  KeysOff := 0;
                  WarpArmed := 0;
                end;
            end;
            if B69FE <> 0 then
            begin
              B69FE := 0;
              Slots[1].X := WarpX;
              Slots[1].Y := WarpY;
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
              if AltVideo = 0 then
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
            if WarpArmed <> 0 then
              if WarpTimer < 0 then
                DrawTileB(Gfx[10]^.Tile[WarpTimer div 5 + $28], Slots[1].X, Slots[1].Y + PageY)
              else
                DrawTileB(Gfx[10]^.Tile[$28 - WarpTimer div 5], Slots[1].X, Slots[1].Y + PageY);
            if (LeftHeld <> 0) and (Slots[1].Sprite = $C) then
              Slots[1].Sprite := 5
            else
              if (RightHeld <> 0) and (Slots[1].Sprite = $B) then
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
            if HitLock <> 0 then
              DrawTileB(Gfx[3]^.Tile[Slots[1].Anim div 5 + Slots[1].Sprite], Slots[1].X, Slots[1].Y + PageY);
            ShowPage;
            if UnconfuseMsg <> 0 then
            begin
              UnconfuseMsg := 0;
              ShowMessage('YOU FEEL LESS CONFUSED');
            end;
            if MenuReq <> 0 then
            begin
              EscKey := EscapeMenu;
              MenuReq := 0;
            end;
            if B6EEE <> 0 then
            begin
              FadeOut($14);
              if Ammo < $F then
                Ammo := $F;
              SiteDone[MapSite] := 0;
              if HitLock = 0 then
                Level := 1;
              LevelReset;
              RestoreState;
              LoadLevel(Level);
              StatusCamX := -1;
            end;
            if WarpCheat <> 0 then
            begin
              WarpCheat := 0;
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
            if PjxDone <> 0 then
            begin
              PjxDone := 0;
              if Invulnerable <> 0 then
                ShowMessage('GOD Mode On')
              else
                ShowMessage('GOD Mode Off');
            end;
          end;
        end;
      end;
      if HasPix <> 0 then
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
