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
          if W6858 <> CamX then
            DrawStatus;
          if W6852 > 7 then
          begin
            W6852 := 0;
            if JoyOn then
              ReadJoystick;
            if (Slots[1].W14 = 9) and (B6EF1 <> 0) then
              Slots[1].W14 := 1
            else
              if (Slots[1].W14 = $A) and (B6EF0 <> 0) then
                Slots[1].W14 := 5
              else
                if ((Slots[1].W14 = $A) or (Slots[1].W14 = 9)) and ((B6EEA <> 0) or (B6EE9 <> 0)) then
                  Slots[1].W14 := 1;
            FlipPage;
            DrawBack(Slots[1].W06 - $10, Slots[1].W08 - $10);
            DrawBack(Slots[1].W06 - $10, Slots[1].W08);
            DrawBack(Slots[1].W06 - $10, Slots[1].W08 + $10);
            DrawBack(Slots[1].W06, Slots[1].W08 - $10);
            DrawBack(Slots[1].W06, Slots[1].W08);
            DrawBack(Slots[1].W06, Slots[1].W08 + $10);
            DrawBack(Slots[1].W06 + $10, Slots[1].W08 - $10);
            DrawBack(Slots[1].W06 + $10, Slots[1].W08);
            DrawBack(Slots[1].W06 + $10, Slots[1].W08 + $10);
            for W684C := 2 to $19 do
              if Slots[W684C].Free = 0 then
                if Slots[W684C].B1F <> 0 then
                begin
                  Slots[W684C].Free := 1;
                  DrawBack(Slots[W684C].W06, Slots[W684C].W08);
                  DrawBack(Slots[W684C].W06 - $10, Slots[W684C].W08);
                  DrawBack(Slots[W684C].W06 + $10, Slots[W684C].W08);
                  DrawBack(Slots[W684C].W06 + $20, Slots[W684C].W08);
                  DrawBack(Slots[W684C].W06 - $10, Slots[W684C].W08 - $10);
                  DrawBack(Slots[W684C].W06 - $10, Slots[W684C].W08 + $10);
                  DrawBack(Slots[W684C].W06 + $10, Slots[W684C].W08 - $10);
                  DrawBack(Slots[W684C].W06 + $10, Slots[W684C].W08 + $10);
                  DrawBack(Slots[W684C].W06, Slots[W684C].W08 - $10);
                  DrawBack(Slots[W684C].W06, Slots[W684C].W08 + $10);
                end
                else
                  if OnScreen($28, W684C) or (Slots[W684C].W1C = $1C) or (Slots[W684C].W1C = $15)
                      or (Slots[W684E].W1C = $E) or (Slots[W684E].B1F <> 0) then
                  begin
                    DrawBack(Slots[W684C].W06, Slots[W684C].W08);
                    if Slots[W684C].W06 and $F > 0 then
                      DrawBack(Slots[W684C].W06 + $10, Slots[W684C].W08);
                    case Slots[W684C].W14 of
                      $353:
                      begin
                        DrawBack(Slots[W684C].W06 + $30, Slots[W684C].W08);
                        DrawBack(Slots[W684C].W06 + $20, Slots[W684C].W08);
                        DrawBack(Slots[W684C].W06 + $10, Slots[W684C].W08);
                      end;
                      $321..$383, $1389:
                      begin
                        DrawBack(Slots[W684C].W06, Slots[W684C].W08 - $10);
                        if Slots[W684C].W06 and $F > 0 then
                          DrawBack(Slots[W684C].W06 + $F, Slots[W684C].W08 - $10);
                      end;
                      $72:
                      begin
                        DrawBack(Slots[W684C].W06, Slots[W684C].W08 - $10);
                        DrawBack(Slots[W684C].W06, Slots[W684C].W08 + $10);
                        if Slots[W684C].W06 and $F > 0 then
                        begin
                          DrawBack(Slots[W684C].W06 + $F, Slots[W684C].W08 + $10);
                          DrawBack(Slots[W684C].W06 + $F, Slots[W684C].W08 - $10);
                        end;
                      end;
                      $65:
                      begin
                        DrawBack(Slots[W684C].W06, Slots[W684C].W08 - $10);
                        if Slots[W684C].W06 and $F > 0 then
                          DrawBack(Slots[W684C].W06 + $F, Slots[W684C].W08 - $10);
                      end;
                    end;
                  end;
            for W684C := 1 to Gun do
            begin
              DrawBack(Shots[W684C].W06, Shots[W684C].W08);
              DrawBack(Shots[W684C].W06 + $10, Shots[W684C].W08);
              DrawBack(Shots[W684C].W06, Shots[W684C].W08 + $10);
              DrawBack(Shots[W684C].W06 + $10, Shots[W684C].W08 + $10);
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
                Slots[1].W06 := Slots[1].X;
                Slots[1].W08 := Slots[1].Y;
                if Slots[1].W14 <> $F then
                  Slots[1].W14 := $F
                else
                  Slots[1].W14 := $10;
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
                  Slots[1].W06 := Slots[1].X;
                  Slots[1].W08 := Slots[1].Y;
                  if RespawnDelay = 8 then
                    PlaySound(8);
                  Dec(RespawnDelay);
                  if RespawnDelay = 0 then
                  begin
                    FadeOut($14);
                    Level := 1;
                    LevelReset;
                    LoadLevel(Level);
                    if B6868 <> 0 then
                      SecurityDone;
                  end
                  else
                    if RespawnDelay > 0 then
                      if Slots[1].W16 = -1 then
                        Dec(Slots[1].X, 2)
                      else
                        Inc(Slots[1].X, 2);
                end;
            ActorFrame;
            for W684C := 1 to Gun do
              if Shots[W684C].Free = 0 then
                if Shots[W684C].B1F <> 0 then
                begin
                  DrawBack(Shots[W684C].X, Shots[W684C].Y);
                  DrawBack(Shots[W684C].X + $10, Shots[W684C].Y);
                  DrawFront(Shots[W684C].X, Shots[W684C].Y);
                  DrawFront(Shots[W684C].X + $10, Shots[W684C].Y);
                  DrawBack(Shots[W684C].X, Shots[W684C].Y + $10);
                  DrawBack(Shots[W684C].X + $10, Shots[W684C].Y + $10);
                  DrawFront(Shots[W684C].X, Shots[W684C].Y + $10);
                  DrawFront(Shots[W684C].X + $10, Shots[W684C].Y + $10);
                  Shots[W684C].Free := 1;
                end
                else
                begin
                  if Shots[W684C].W14 = $272 then
                  begin
                    DrawTileB(Gfx[6]^.Tile[Shots[W684C].W0E shr 1 + $19], Shots[W684C].X,
                        Shots[W684C].Y + W6866);
                    Dec(Shots[W684C].W0E);
                    if Shots[W684C].W0E <= 0 then
                    begin
                      Shots[W684C].B1F := 1;
                      DrawBack(Shots[W684C].X, Shots[W684C].Y);
                      DrawBack(Shots[W684C].X - $10, Shots[W684C].Y);
                      DrawBack(Shots[W684C].X + $10, Shots[W684C].Y);
                      DrawBack(Shots[W684C].X, Shots[W684C].Y + $10);
                      DrawBack(Shots[W684C].X - $10, Shots[W684C].Y + $10);
                      DrawBack(Shots[W684C].X + $10, Shots[W684C].Y + $10);
                    end;
                  end
                  else
                    if not ShotOnScreen($28, W684C) then
                    begin
                      DrawBack(Shots[W684C].X, Shots[W684C].Y);
                      DrawBack(Shots[W684C].X + $10, Shots[W684C].Y);
                      DrawBack(Shots[W684C].X, Shots[W684C].Y + $10);
                      DrawBack(Shots[W684C].X + $10, Shots[W684C].Y + $10);
                      Shots[W684C].B1F := 1;
                    end
                    else
                    begin
                      DrawBack(Shots[W684C].X, Shots[W684C].Y);
                      DrawBack(Shots[W684C].X + $10, Shots[W684C].Y);
                      DrawBack(Shots[W684C].X, Shots[W684C].Y + $10);
                      DrawBack(Shots[W684C].X + $10, Shots[W684C].Y + $10);
                      DrawTile(Gfx[1]^.Tile[Shots[W684C].W14 - 1 + Shots[W684C].W0A], Shots[W684C].X shr 3,
                          Shots[W684C].Y + W6866);
                    end;
                  DrawFront(Shots[W684C].X, Shots[W684C].Y);
                  DrawFront(Shots[W684C].X + $10, Shots[W684C].Y);
                  DrawFront(Shots[W684C].X, Shots[W684C].Y + $10);
                  DrawFront(Shots[W684C].X + $10, Shots[W684C].Y + $10);
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
            W684C := 1;
            if (Slots[1].W14 = 1) or (Slots[1].W14 = 5) then
            begin
              Inc(Slots[1].W0A, Slots[1].W1A);
              if Slots[1].W0A > $13 then
                Slots[1].W0A := 1;
            end
            else
              Slots[1].W0A := 1;
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
              DrawSprite(Gfx[3]^.Tile[Slots[1].W0A div 5 + Slots[1].W14], Slots[1].X, Slots[1].Y + W6866);
              Dec(Slots[1].W00);
            end
            else
              if Slots[1].X and 7 = 0 then
                DrawTile(Gfx[3]^.Tile[Slots[1].W0A div 5 + Slots[1].W14], Slots[1].X shr 3,
                    Slots[1].Y + W6866)
              else
                DrawTileB(Gfx[3]^.Tile[Slots[1].W0A div 5 + Slots[1].W14], Slots[1].X, Slots[1].Y + W6866);
            if B6A06 <> 0 then
              if W6A08 < 0 then
                DrawTileB(Gfx[10]^.Tile[W6A08 div 5 + $28], Slots[1].X, Slots[1].Y + W6866)
              else
                DrawTileB(Gfx[10]^.Tile[$28 - W6A08 div 5], Slots[1].X, Slots[1].Y + W6866);
            if (B6EF0 <> 0) and (Slots[1].W14 = $C) then
              Slots[1].W14 := 5
            else
              if (B6EF1 <> 0) and (Slots[1].W14 = $B) then
                Slots[1].W14 := 1;
            for W684C := 2 to $19 do
              if (Slots[W684C].Free = 0) and (Slots[W684C].B1F = 0) and (OnScreen($20, W684C)
                  or (Slots[W684C].W1C = $1C) or (Slots[W684C].W1C = $15) or (Slots[W684E].W1C = $E)) then
                if Slots[W684C].W00 > 0 then
                begin
                  case Slots[W684C].W14 of
                    1..$32:
                      DrawSprite(Gfx[1]^.Tile[Slots[W684C].W14 + Slots[W684C].W0A div 5], Slots[W684C].X,
                          Slots[W684C].Y + W6866);
                    $65:
                      if Slots[W684C].W12 = 0 then
                      begin
                        DrawSprite(Gfx[2]^.Tile[Slots[W684C].W14 - $64 + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866 - $10);
                        if Slots[W684C].W16 < 0 then
                          DrawSprite(Gfx[2]^.Tile[5], Slots[W684C].X, Slots[W684C].Y + W6866)
                        else
                          DrawSprite(Gfx[2]^.Tile[45], Slots[W684C].X, Slots[W684C].Y + W6866);
                      end
                      else
                      begin
                        if Slots[W684C].W16 < 0 then
                          DrawSprite(Gfx[2]^.Tile, Slots[W684C].X, Slots[W684C].Y + W6866 - $10)
                        else
                          DrawSprite(Gfx[2]^.Tile[41], Slots[W684C].X, Slots[W684C].Y + W6866 - $10);
                        DrawSprite(Gfx[2]^.Tile[Slots[W684C].W14 - $60 + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      end;
                    $66..$96:
                      DrawSprite(Gfx[2]^.Tile[Slots[W684C].W14 - $64 + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $97..$C8:
                      DrawSprite(Gfx[10]^.Tile[Slots[W684C].W14 - $96 + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $FB..$12C:
                      DrawSprite(Gfx[15]^.Tile[Slots[W684C].W14 - $FA + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $12D..$15E:
                      DrawSprite(Gfx[13]^.Tile[Slots[W684C].W14 - $12C + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $15F..$190:
                      DrawSprite(Gfx[16]^.Tile[Slots[W684C].W14 - $15E + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $191..$1C2:
                      DrawSprite(Gfx[4]^.Tile[Slots[W684C].W14 - $190 + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $1C3..$1E7:
                      DrawSprite(Gfx[5]^.Tile[Slots[W684C].W14 - $1C2 + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $1E8..$1EA:
                      DrawSprite(Gfx[5]^.Tile[Slots[W684C].W14 - $1C2 + Slots[W684C].W0A shr 3],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $1EB:
                      DrawSprite(Gfx[5]^.Tile[Slots[W684C].W14 - $1C2 + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $1EC..$1EE:
                      DrawSprite(Gfx[5]^.Tile[Slots[W684C].W14 - $1C2 + (Slots[W684C].W0A - $15) shr 3],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $1EF..$1F4:
                      DrawSprite(Gfx[5]^.Tile[Slots[W684C].W14 - $1C2 + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $1F5..$226:
                      DrawSprite(Gfx[1]^.Tile[Slots[W684C].W14 - $1F4 + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $259..$28A:
                      DrawSprite(Gfx[6]^.Tile[Slots[W684C].W14 - $258 + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $28B..$2BC:
                      DrawSprite(Gfx[7]^.Tile[Slots[W684C].W14 - $28A + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $2BD..$2EE:
                      DrawSprite(Gfx[8]^.Tile[Slots[W684C].W14 - $2BC + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $2EF..$320:
                      DrawSprite(Gfx[9]^.Tile[Slots[W684C].W14 - $2EE + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $321:
                    begin
                      DrawSprite(Gfx[12]^.Tile[Slots[W684C].W14 - $320 + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866 - $10);
                      DrawSprite(Gfx[12]^.Tile[Slots[W684C].W14 - $31C + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    end;
                    $331:
                      if Slots[W684C].W12 = 0 then
                      begin
                        DrawSprite(Gfx[12]^.Tile[Slots[W684C].W14 - $320 + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866 - $10);
                        if Slots[W684C].W16 < 0 then
                          DrawSprite(Gfx[12]^.Tile[21], Slots[W684C].X, Slots[W684C].Y + W6866)
                        else
                          DrawSprite(Gfx[12]^.Tile[33], Slots[W684C].X, Slots[W684C].Y + W6866);
                      end
                      else
                      begin
                        if Slots[W684C].W16 < 0 then
                          DrawSprite(Gfx[12]^.Tile[17], Slots[W684C].X, Slots[W684C].Y + W6866 - $10)
                        else
                          DrawSprite(Gfx[12]^.Tile[29], Slots[W684C].X, Slots[W684C].Y + W6866 - $10);
                        DrawSprite(Gfx[12]^.Tile[Slots[W684C].W14 - $31C + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      end;
                    $339..$33C:
                      DrawSprite(Gfx[12]^.Tile[Slots[W684C].W14 - $320 + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $345..$352:
                      DrawSprite(Gfx[12]^.Tile[Slots[W684C].W14 - $320 + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                    $353:
                    begin
                      DrawSprite(Gfx[14]^.Tile[Slots[W684C].W14 - $352 + Slots[W684C].W0A div 5],
                          Slots[W684C].X, Slots[W684C].Y + W6866);
                      DrawSprite(Gfx[14]^.Tile[Slots[W684C].W14 - $34E + Slots[W684C].W0A div 5],
                          Slots[W684C].X + $10, Slots[W684C].Y + W6866);
                    end;
                  end;
                  Dec(Slots[W684C].W00);
                end
                else
                  if Slots[W684C].X and 7 = 0 then
                    case Slots[W684C].W14 of
                      1..$32:
                        DrawTile(Gfx[1]^.Tile[Slots[W684C].W14 + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $65:
                        if Slots[W684C].W12 = 0 then
                        begin
                          DrawTile(Gfx[2]^.Tile[Slots[W684C].W14 - $64 + Slots[W684C].W0A div 5],
                              Slots[W684C].X shr 3, Slots[W684C].Y + W6866 - $10);
                          if Slots[W684C].W16 < 0 then
                            DrawTile(Gfx[2]^.Tile[5], Slots[W684C].X shr 3, Slots[W684C].Y + W6866)
                          else
                            DrawTile(Gfx[2]^.Tile[45], Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                        end
                        else
                        begin
                          if Slots[W684C].W16 < 0 then
                            DrawTile(Gfx[2]^.Tile, Slots[W684C].X shr 3, Slots[W684C].Y + W6866 - $10)
                          else
                            DrawTile(Gfx[2]^.Tile[41], Slots[W684C].X shr 3, Slots[W684C].Y + W6866 - $10);
                          DrawTile(Gfx[2]^.Tile[Slots[W684C].W14 - $60 + Slots[W684C].W0A div 5],
                              Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                        end;
                      $66..$96:
                        DrawTile(Gfx[2]^.Tile[Slots[W684C].W14 - $64 + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $97..$C8:
                        DrawTile(Gfx[10]^.Tile[Slots[W684C].W14 - $96 + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $FB..$12C:
                        DrawTile(Gfx[15]^.Tile[Slots[W684C].W14 - $FA + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $12D..$15E:
                        DrawTile(Gfx[13]^.Tile[Slots[W684C].W14 - $12C + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $15F..$190:
                        DrawTile(Gfx[16]^.Tile[Slots[W684C].W14 - $15E + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $191..$1C2:
                        DrawTile(Gfx[4]^.Tile[Slots[W684C].W14 - $190 + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $1C3..$1E7:
                        DrawTile(Gfx[5]^.Tile[Slots[W684C].W14 - $1C2 + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $1E8..$1EA:
                        DrawTile(Gfx[5]^.Tile[Slots[W684C].W14 - $1C2 + Slots[W684C].W0A shr 3],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $1EB:
                        DrawTile(Gfx[5]^.Tile[Slots[W684C].W14 - $1C2 + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $1EC..$1EE:
                        DrawTile(Gfx[5]^.Tile[Slots[W684C].W14 - $1C2 + (Slots[W684C].W0A - $15) shr 3],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $1EF..$1F4:
                        DrawTile(Gfx[5]^.Tile[Slots[W684C].W14 - $1C2 + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $1F5..$226:
                        DrawTile(Gfx[1]^.Tile[Slots[W684C].W14 - $1F4 + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $259..$270:
                        DrawTile(Gfx[6]^.Tile[Slots[W684C].W14 - $258 + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $271:
                        DrawTile(Gfx[6]^.Tile[Slots[W684C].W14 - $258 + Slots[W684C].W0A div 3],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $272..$28A:
                        DrawTile(Gfx[6]^.Tile[Slots[W684C].W14 - $258 + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $28B..$2BC:
                        DrawTile(Gfx[7]^.Tile[Slots[W684C].W14 - $28A + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $2BD..$2EE:
                        DrawTile(Gfx[8]^.Tile[Slots[W684C].W14 - $2BC + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $2EF..$320:
                        DrawTile(Gfx[9]^.Tile[Slots[W684C].W14 - $2EE + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $321:
                      begin
                        DrawTile(Gfx[12]^.Tile[Slots[W684C].W14 - $320 + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866 - $10);
                        DrawTile(Gfx[12]^.Tile[Slots[W684C].W14 - $31C + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      end;
                      $331:
                        if Slots[W684C].W12 = 0 then
                        begin
                          DrawTile(Gfx[12]^.Tile[Slots[W684C].W14 - $320 + Slots[W684C].W0A div 5],
                              Slots[W684C].X shr 3, Slots[W684C].Y + W6866 - $10);
                          if Slots[W684C].W16 < 0 then
                            DrawTile(Gfx[12]^.Tile[21], Slots[W684C].X shr 3, Slots[W684C].Y + W6866)
                          else
                            DrawTile(Gfx[12]^.Tile[33], Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                        end
                        else
                        begin
                          if Slots[W684C].W16 < 0 then
                            DrawTile(Gfx[12]^.Tile[17], Slots[W684C].X shr 3, Slots[W684C].Y + W6866 - $10)
                          else
                            DrawTile(Gfx[12]^.Tile[29], Slots[W684C].X shr 3, Slots[W684C].Y + W6866 - $10);
                          DrawTile(Gfx[12]^.Tile[Slots[W684C].W14 - $31C + Slots[W684C].W0A div 5],
                              Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                        end;
                      $339..$33C:
                        DrawTile(Gfx[12]^.Tile[Slots[W684C].W14 - $320 + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $345..$352:
                        DrawTile(Gfx[12]^.Tile[Slots[W684C].W14 - $320 + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                      $353:
                      begin
                        DrawTile(Gfx[14]^.Tile[Slots[W684C].W14 - $352 + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3, Slots[W684C].Y + W6866);
                        DrawTile(Gfx[14]^.Tile[Slots[W684C].W14 - $34E + Slots[W684C].W0A div 5],
                            Slots[W684C].X shr 3 + 2, Slots[W684C].Y + W6866);
                      end;
                    end
                  else
                    case Slots[W684C].W14 of
                      1..$32:
                        DrawTileB(Gfx[1]^.Tile[Slots[W684C].W14 + Slots[W684C].W0A div 5], Slots[W684C].X,
                            Slots[W684C].Y + W6866);
                      $65:
                        if Slots[W684C].W12 = 0 then
                        begin
                          DrawTileB(Gfx[2]^.Tile[Slots[W684C].W14 - $64 + Slots[W684C].W0A div 5],
                              Slots[W684C].X, Slots[W684C].Y + W6866 - $10);
                          if Slots[W684C].W16 < 0 then
                            DrawTileB(Gfx[2]^.Tile[5], Slots[W684C].X, Slots[W684C].Y + W6866)
                          else
                            DrawTileB(Gfx[2]^.Tile[45], Slots[W684C].X, Slots[W684C].Y + W6866);
                        end
                        else
                        begin
                          if Slots[W684C].W16 < 0 then
                            DrawTileB(Gfx[2]^.Tile, Slots[W684C].X, Slots[W684C].Y + W6866 - $10)
                          else
                            DrawTileB(Gfx[2]^.Tile[41], Slots[W684C].X, Slots[W684C].Y + W6866 - $10);
                          DrawTileB(Gfx[2]^.Tile[Slots[W684C].W14 - $60 + Slots[W684C].W0A div 5],
                              Slots[W684C].X, Slots[W684C].Y + W6866);
                        end;
                      $66..$96:
                        DrawTileB(Gfx[2]^.Tile[Slots[W684C].W14 - $64 + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $97..$C8:
                        DrawTileB(Gfx[10]^.Tile[Slots[W684C].W14 - $96 + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $FB..$12C:
                        DrawTileB(Gfx[15]^.Tile[Slots[W684C].W14 - $FA + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $12D..$15E:
                        DrawTileB(Gfx[13]^.Tile[Slots[W684C].W14 - $12C + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $15F..$190:
                        DrawTileB(Gfx[16]^.Tile[Slots[W684C].W14 - $15E + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $191..$1C2:
                        DrawTileB(Gfx[4]^.Tile[Slots[W684C].W14 - $190 + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $1C3..$1E7:
                        DrawTileB(Gfx[5]^.Tile[Slots[W684C].W14 - $1C2 + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $1E8..$1EA:
                        DrawTileB(Gfx[5]^.Tile[Slots[W684C].W14 - $1C2 + Slots[W684C].W0A shr 3],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $1EB:
                        DrawTileB(Gfx[5]^.Tile[Slots[W684C].W14 - $1C2 + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $1EC..$1EE:
                        DrawTileB(Gfx[5]^.Tile[Slots[W684C].W14 - $1C2 + (Slots[W684C].W0A - $15) shr 3],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $1EF..$1F4:
                        DrawTileB(Gfx[5]^.Tile[Slots[W684C].W14 - $1C2 + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $1F5..$226:
                        DrawTileB(Gfx[1]^.Tile[Slots[W684C].W14 - $1F4 + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $259..$28A:
                        DrawTileB(Gfx[6]^.Tile[Slots[W684C].W14 - $258 + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $28B..$2BC:
                        DrawTileB(Gfx[7]^.Tile[Slots[W684C].W14 - $28A + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $2BD..$2EE:
                        DrawTileB(Gfx[8]^.Tile[Slots[W684C].W14 - $2BC + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $2EF..$320:
                        DrawTileB(Gfx[9]^.Tile[Slots[W684C].W14 - $2EE + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $321:
                      begin
                        DrawTileB(Gfx[12]^.Tile[Slots[W684C].W14 - $320 + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866 - $10);
                        DrawTileB(Gfx[12]^.Tile[Slots[W684C].W14 - $31C + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      end;
                      $331:
                        if Slots[W684C].W12 = 0 then
                        begin
                          DrawTileB(Gfx[12]^.Tile[Slots[W684C].W14 - $320 + Slots[W684C].W0A div 5],
                              Slots[W684C].X, Slots[W684C].Y + W6866 - $10);
                          if Slots[W684C].W16 < 0 then
                            DrawTileB(Gfx[12]^.Tile[21], Slots[W684C].X, Slots[W684C].Y + W6866)
                          else
                            DrawTileB(Gfx[12]^.Tile[33], Slots[W684C].X, Slots[W684C].Y + W6866);
                        end
                        else
                        begin
                          if Slots[W684C].W16 < 0 then
                            DrawTileB(Gfx[12]^.Tile[17], Slots[W684C].X, Slots[W684C].Y + W6866 - $10)
                          else
                            DrawTileB(Gfx[12]^.Tile[29], Slots[W684C].X, Slots[W684C].Y + W6866 - $10);
                          DrawTileB(Gfx[12]^.Tile[Slots[W684C].W14 - $31C + Slots[W684C].W0A div 5],
                              Slots[W684C].X, Slots[W684C].Y + W6866);
                        end;
                      $339..$33C:
                        DrawTileB(Gfx[12]^.Tile[Slots[W684C].W14 - $320 + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $345..$352:
                        DrawTileB(Gfx[12]^.Tile[Slots[W684C].W14 - $320 + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                      $353:
                      begin
                        DrawTileB(Gfx[14]^.Tile[Slots[W684C].W14 - $352 + Slots[W684C].W0A div 5],
                            Slots[W684C].X, Slots[W684C].Y + W6866);
                        DrawTileB(Gfx[14]^.Tile[Slots[W684C].W14 - $34E + Slots[W684C].W0A div 5],
                            Slots[W684C].X + $10, Slots[W684C].Y + W6866);
                      end;
                    end;
            DrawFront(Slots[1].W06 - $10, Slots[1].W08 - $10);
            DrawFront(Slots[1].W06 - $10, Slots[1].W08);
            DrawFront(Slots[1].W06 - $10, Slots[1].W08 + $10);
            DrawFront(Slots[1].W06, Slots[1].W08 - $10);
            DrawFront(Slots[1].W06, Slots[1].W08);
            DrawFront(Slots[1].W06, Slots[1].W08 + $10);
            DrawFront(Slots[1].W06 + $10, Slots[1].W08 - $10);
            DrawFront(Slots[1].W06 + $10, Slots[1].W08);
            DrawFront(Slots[1].W06 + $10, Slots[1].W08 + $10);
            for W684C := 2 to $19 do
              if Slots[W684C].Free = 0 then
                if Slots[W684C].B1F <> 0 then
                begin
                  DrawFront(Slots[W684C].W06, Slots[W684C].W08);
                  DrawFront(Slots[W684C].W06 - $10, Slots[W684C].W08);
                  DrawFront(Slots[W684C].W06 + $10, Slots[W684C].W08);
                  DrawFront(Slots[W684C].W06 - $10, Slots[W684C].W08 - $10);
                  DrawFront(Slots[W684C].W06 - $10, Slots[W684C].W08 + $10);
                  DrawFront(Slots[W684C].W06 + $10, Slots[W684C].W08 - $10);
                  DrawFront(Slots[W684C].W06 + $10, Slots[W684C].W08 + $10);
                  DrawFront(Slots[W684C].W06, Slots[W684C].W08 - $10);
                  DrawFront(Slots[W684C].W06, Slots[W684C].W08 + $10);
                end
                else
                  if OnScreen($20, W684C) or (Slots[W684C].W1C = $1C) or (Slots[W684C].W1C = $1B)
                      or (Slots[W684C].W1C = $15) or (Slots[W684E].W1C = $E) then
                  begin
                    DrawFront(Slots[W684C].X, Slots[W684C].Y);
                    if Slots[W684C].X and $F > 0 then
                      DrawFront(Slots[W684C].X + $F, Slots[W684C].Y);
                    if Slots[W684C].W1C = $1B then
                    begin
                      DrawFront(Slots[W684C].X, Slots[W684C].Y - $10);
                      DrawFront(Slots[W684C].X + $10, Slots[W684C].Y - $10);
                    end
                    else
                      case Slots[W684C].W14 of
                        $353:
                        begin
                          DrawFront(Slots[W684C].X + $30, Slots[W684C].Y);
                          DrawFront(Slots[W684C].X + $20, Slots[W684C].Y);
                          DrawFront(Slots[W684C].X + $10, Slots[W684C].Y);
                        end;
                        $321..$383, $1389:
                        begin
                          DrawFront(Slots[W684C].X, Slots[W684C].Y - $10);
                          if Slots[W684C].X and $F > 0 then
                            DrawFront(Slots[W684C].X + $F, Slots[W684C].Y - $10);
                        end;
                        $72:
                        begin
                          if Slots[W684C].Y > $F then
                            DrawFront(Slots[W684C].X, Slots[W684C].Y - $10);
                          DrawFront(Slots[W684C].X, Slots[W684C].Y + $10);
                          if Slots[W684C].X and $F > 0 then
                          begin
                            DrawFront(Slots[W684C].X + $F, Slots[W684C].Y + $10);
                            if Slots[W684C].Y > $F then
                              DrawFront(Slots[W684C].X + $F, Slots[W684C].Y - $10);
                          end;
                        end;
                        $65:
                        begin
                          DrawFront(Slots[W684C].X, Slots[W684C].Y - $10);
                          if Slots[W684C].X and $F > 0 then
                            DrawFront(Slots[W684C].X + $F, Slots[W684C].Y - $10);
                        end;
                      end;
                  end
                  else
                    if (Slots[W684C].W1C = 7) or (Slots[W684C].W1C = $E) or (Slots[W684C].W1C = $13)
                        or (Slots[W684C].W1C = $1388) then
                    begin
                      Slots[W684C].B1F := 1;
                      DrawFront(Slots[W684C].X, Slots[W684C].Y);
                      if Slots[W684C].X and $F > 0 then
                      begin
                        DrawFront(Slots[W684C].X + $F, Slots[W684C].Y);
                        DrawFront(Slots[W684C].X - $F, Slots[W684C].Y);
                      end;
                    end;
            if B6A1B <> 0 then
              DrawTileB(Gfx[3]^.Tile[Slots[1].W0A div 5 + Slots[1].W14], Slots[1].X, Slots[1].Y + W6866);
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
              W6858 := -1;
            end;
            if B69F9 <> 0 then
            begin
              B69F9 := 0;
              W684C := AskWarp;
              if (W684C >= 1) and (W684C <= $10) then
              begin
                Level := W684C + 1;
                FadeOut($14);
                SiteDone[MapSite] := 0;
                RestoreState;
                LoadLevel(Level);
                LevelReset;
                W6858 := -1;
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
