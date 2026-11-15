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
            if (B6A1B = 0) and (ExitLock = 0) then
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
            if B6A06 <> 0 then
            begin
              Dec(WarpTimer);
              if WarpTimer = 0 then
                B69FE := 1
              else
                if WarpTimer = -19 then
                begin
                  KeysOff := 0;
                  B6A06 := 0;
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
            if B6A06 <> 0 then
              if WarpTimer < 0 then
                DrawTileB(Gfx[10]^.Tile[WarpTimer div 5 + $28], Slots[1].X, Slots[1].Y + PageY)
              else
                DrawTileB(Gfx[10]^.Tile[$28 - WarpTimer div 5], Slots[1].X, Slots[1].Y + PageY);
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
