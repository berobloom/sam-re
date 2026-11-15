{ src: SAM1RE 0529:2F6B (../SAM objects.md: the actor update pass, once a frame from main 0000:1BDF: slots 2..25
  that are live and on screen (or one of the gate-exempt kinds) get their proposed position from the
  direction and speed fields, then their behaviour: ActorAI for kinds below $1E, the inline chain for the
  rest and the 5000/5001 score puffs; then the player's shots move and stop at solid cells) }
{ interface }
{ keep: ActorFrame; }
{$F+}
procedure ActorFrame;
var
  NewX, NewY, I, CX, CY, Col1, Row2, Col2, Row: Integer;
begin
  for I := 2 to $19 do
    if (Slots[I].Free = 0) and (OnScreen($20, I) or (Slots[I].Kind = $1C) or (Slots[I].Kind = $15)
        or (Slots[I].Kind = $E)) then
    begin
      if Slots[I].DirX = 1 then
        NewX := Slots[I].X + Slots[I].Speed
      else
        if Slots[I].DirX = -1 then
          NewX := Slots[I].X - Slots[I].Speed
        else
          NewX := Slots[I].X;
      if Slots[I].DirY = 1 then
        NewY := Slots[I].Y + Slots[I].Speed
      else
        if Slots[I].DirY = -1 then
          NewY := Slots[I].Y - Slots[I].Speed
        else
          NewY := Slots[I].Y;
      Slots[I].PrevX := Slots[I].X;
      Slots[I].PrevY := Slots[I].Y;
      if Slots[I].Kind < $1E then
        ActorAI(NewX, NewY, I, CX, CY)
      else
        case Slots[I].Kind of
          $1388:
            if ShotHit(Slots[I].X, Slots[I].Y) then
            begin
              PlaySound($14);
              Score := Score + $64;
              StatusCamX := -1;
              Slots[I].Kind := $1389;
              Slots[I].W0E := $10;
              Slots[I].Sprite := $A7;
              Slots[I].Anim := 1;
              Slots[I].Speed := 0;
              DrawTileB(Gfx[10]^.Tile[17], Slots[I].X, Slots[I].Y + $10);
              DrawTileB(Gfx[10]^.Tile[17], Slots[I].X, Slots[I].Y + $1A0);
            end
            else
              if ((Slots[1].X + 3 >= Slots[I].X + 3) and (Slots[1].X + 3 <= Slots[I].X + $C)
                  or (Slots[1].X + $C >= Slots[I].X + 3) and (Slots[1].X + $C <= Slots[I].X + $C))
                  and ((Slots[I].Y <= Slots[1].Y) and (Slots[I].Y + $F >= Slots[1].Y)
                  or (Slots[1].Y + $F >= Slots[I].Y) and (Slots[1].Y + $F <= Slots[I].Y + $F)) then
              begin
                PlaySound(4);
                Score := Score + $3E8;
                StatusCamX := -1;
                Slots[I].Kind := $1389;
                Slots[I].W0E := $10;
                Slots[I].Sprite := $AA;
                Slots[I].Anim := 1;
                Slots[I].Speed := 0;
                DrawTileB(Gfx[10]^.Tile[21], Slots[I].X, Slots[I].Y + $10);
                DrawTileB(Gfx[10]^.Tile[21], Slots[I].X, Slots[I].Y + $1A0);
              end;
          $1389:
          begin
            Slots[I].PrevX := NewX;
            Slots[I].PrevY := NewY;
            Dec(Slots[I].Y, 2);
            if Slots[I].Y < $10 then
            begin
              NewY := $10;
              Slots[I].Y := $10;
              Slots[I].PrevY := $10;
            end;
            Dec(Slots[I].W0E);
            if Slots[I].W0E <= 0 then
            begin
              Slots[I].Remove := 1;
              DrawBack(NewX, NewY);
              DrawBack(NewX, NewY - $10);
              DrawBack(NewX, NewY + $10);
              DrawFront(NewX, NewY);
              DrawFront(NewX, NewY + $10);
              DrawFront(NewX, NewY - $10);
              DrawBack(NewX + $10, NewY);
              DrawBack(NewX + $10, NewY + $10);
              DrawBack(NewX + $10, NewY - $10);
              DrawFront(NewX + $10, NewY);
              DrawFront(NewX + $10, NewY + $10);
              DrawFront(NewX + $10, NewY - $10);
            end
            else
            begin
              DrawBack(NewX, NewY);
              DrawBack(NewX, NewY + $10);
              DrawFront(NewX, NewY);
              DrawFront(NewX, NewY + $10);
              DrawBack(NewX + $10, NewY);
              DrawBack(NewX + $10, NewY + $10);
              DrawFront(NewX + $10, NewY);
              DrawFront(NewX + $10, NewY + $10);
              DrawBack(NewX - $10, NewY);
              DrawBack(NewX - $10, NewY + $10);
              DrawFront(NewX - $10, NewY);
              DrawFront(NewX - $10, NewY + $10);
            end;
          end;
          $2A:
          begin
            Col1 := NewX shr 4 + 1;
            Row := NewY shr 4 + 1;
            Row2 := Row + 1;
            Col2 := (NewX + $F) shr 4 + 2;
            if Map[Col1, Row].Solid <> 0 then
            begin
              Slots[I].DirX := 1;
              Slots[I].Anim := 1;
            end
            else
              if Map[Col2, Row].Solid <> 0 then
              begin
                Slots[I].DirX := -1;
                Slots[I].Anim := $29;
              end
              else
                if (Map[Col1, Row2].Solid = 0) and (Map[Col1, Row2].FlagB = 0) then
                begin
                  Slots[I].DirX := 1;
                  Slots[I].Anim := 1;
                end
                else
                  if (Map[Col2, Row2].Solid = 0) and (Map[Col2, Row2].FlagB = 0) then
                  begin
                    Slots[I].DirX := -1;
                    Slots[I].Anim := $29;
                  end;
            Inc(Slots[I].Anim);
            if Slots[I].DirX = 1 then
            begin
              if Slots[I].Anim > $13 then
                Slots[I].Anim := 1;
            end
            else
              if Slots[I].Anim > $3B then
                Slots[I].Anim := $29;
            Slots[I].X := NewX;
            HitPlayer(Slots[I].X, Slots[I].Y);
            HitPlayer(Slots[I].X + $10, Slots[I].Y);
            if ShotHit(Slots[I].X, Slots[I].Y) or ShotHit(Slots[I].X + $10, Slots[I].Y) then
            begin
              PlaySound(8);
              Slots[I].W00 := 3;
              Dec(Slots[I].W10);
              if Slots[I].W10 = 0 then
              begin
                PlaySound($13);
                Slots[I].Remove := 1;
                DrawBack(Slots[I].X, Slots[I].Y);
                DrawBack(Slots[I].X - $10, Slots[I].Y);
                DrawBack(Slots[I].X + $10, Slots[I].Y);
                DrawBack(Slots[I].X + $20, Slots[I].Y);
                Spawn(Slots[I].X and $FFF0, Slots[I].Y and $FFF0, $13);
                Score := Score + $1F4;
                StatusCamX := -1;
              end;
              if Slots[I].X < Slots[1].X then
                Slots[I].DirX := 1
              else
                Slots[I].DirX := -1;
              if Slots[I].DirX = 1 then
                Slots[I].Anim := 1
              else
                Slots[I].Anim := $29;
            end;
          end;
          $1E:
          begin
            Col1 := NewX shr 4;
            Row2 := NewY shr 4;
            Col2 := (NewX + $F) shr 4 + 1;
            if (Map[Col1 + 1, Row2].Solid <> 0) or (Map[Col2, Row2].Solid <> 0) or (Map[Col1 + 1,
                Row2 + 1].Solid <> 0) or (Map[Col2, Row2 + 1].Solid <> 0) then
            begin
              Slots[I].DirX := -Slots[I].DirX;
              if Slots[I].DirX = -1 then
                Slots[I].Anim := $29
              else
                Slots[I].Anim := 1;
            end
            else
              if (Map[Col1 + 1, Row2 + 2].Solid = 0) and (Map[Col1 + 1, Row2 + 2].FlagB = 0) then
              begin
                Slots[I].DirX := 1;
                Slots[I].Anim := 1;
              end
              else
                if (Map[Col2, Row2 + 2].Solid = 0) and (Map[Col2, Row2 + 2].FlagB = 0) then
                begin
                  Slots[I].DirX := -1;
                  Slots[I].Anim := $29;
                end;
            Inc(Slots[I].Anim);
            if Slots[I].DirX = 1 then
            begin
              if Slots[I].Anim > $13 then
                Slots[I].Anim := 1;
            end
            else
              if Slots[I].Anim > $3B then
                Slots[I].Anim := $29;
            if Slots[I].W0E > 0 then
              Dec(Slots[I].W0E);
            if (Slots[I].W0E = 0) and (Slots[I].Y shr 4 = (Slots[1].Y + 8) shr 4)
                and ((Slots[I].X < Slots[1].X) and (Slots[I].DirX = 1) or (Slots[I].X > Slots[1].X)
                and (Slots[I].DirX = -1)) then
            begin
              Slots[I].W0E := $46;
              SpawnObject(Slots[I].X, Slots[I].Y, Slots[I].DirX, 4, $339);
            end;
            Slots[I].X := NewX;
            if ShotHit(Slots[I].X, Slots[I].Y) or ShotHit(Slots[I].X, Slots[I].Y - $10) then
            begin
              if Slots[I].X < Slots[1].X then
              begin
                if (Map[(Slots[I].X + $F) shr 4 + 1, Row2 + 1].Solid = 0)
                    and (Map[(Slots[I].X + $F) shr 4 + 1, Row2].Solid = 0) then
                begin
                  Slots[I].DirX := 1;
                  Slots[I].Anim := 1;
                end;
              end
              else
                if (Map[Slots[I].X shr 4 + 1, Row2 + 1].Solid = 0) and (Map[Slots[I].X shr 4 + 1,
                    Row2].Solid = 0) then
                begin
                  Slots[I].DirX := -1;
                  Slots[I].Anim := $29;
                end;
              Slots[I].W00 := 3;
              Dec(Slots[I].W10);
              if Slots[I].W10 = 0 then
              begin
                PlaySound($13);
                Score := Score + $3E8;
                StatusCamX := -1;
                Slots[I].Remove := 1;
                DrawBack(Slots[I].X, Slots[I].Y);
                DrawBack(Slots[I].X - $10, Slots[I].Y);
                DrawBack(Slots[I].X + $10, Slots[I].Y);
                DrawBack(Slots[I].X + $10, Slots[I].Y - $10);
                DrawBack(Slots[I].X - $10, Slots[I].Y - $10);
                DrawBack(Slots[I].X, Slots[I].Y - $10);
                Spawn(Slots[I].X and $FFF0, Slots[I].Y and $FFF0, $14);
              end
              else
                PlaySound(8);
            end
            else
            begin
              HitPlayer(Slots[I].X, Slots[I].Y);
              HitPlayer(Slots[I].X, Slots[I].Y - $10);
            end;
          end;
          $1F:
          begin
            Col1 := NewX shr 4;
            Row2 := NewY shr 4;
            Col2 := (NewX + $F) shr 4 + 1;
            if (Map[Col1 + 1, Row2].Solid <> 0) or (Map[Col2, Row2].Solid <> 0) or (Map[Col1 + 1,
                Row2 + 1].Solid <> 0) or (Map[Col2, Row2 + 1].Solid <> 0) then
            begin
              Slots[I].DirX := -Slots[I].DirX;
              if Slots[I].DirX = -1 then
                Slots[I].Anim := 1
              else
                Slots[I].Anim := $3D;
            end
            else
              if (Map[Col1 + 1, Row2 + 2].Solid = 0) and (Map[Col1 + 1, Row2 + 2].FlagB = 0) then
              begin
                Slots[I].DirX := 1;
                Slots[I].Anim := $3D;
              end
              else
                if (Map[Col2, Row2 + 2].Solid = 0) and (Map[Col2, Row2 + 2].FlagB = 0) then
                begin
                  Slots[I].DirX := -1;
                  Slots[I].Anim := 1;
                end;
            Inc(Slots[I].W0E);
            if Slots[I].W0E >= Slots[I].W0C then
            begin
              Slots[I].W0E := 0;
              if (Slots[I].Y shr 4 = (Slots[1].Y + 8) shr 4) and ((Slots[I].X < Slots[1].X)
                  and (Slots[I].DirX = 1) or (Slots[I].X > Slots[1].X) and (Slots[I].DirX = -1)) then
                SpawnObject(Slots[I].X, Slots[I].Y, Slots[I].DirX, 4, $33B);
            end;
            if Slots[I].W12 > 0 then
              Dec(Slots[I].W12);
            if Slots[I].W12 = 1 then
              Slots[I].W10 := $1E
            else
              if Slots[I].W12 = 0 then
              begin
                Inc(Slots[I].Anim);
                if Slots[I].DirX = -1 then
                begin
                  if Slots[I].Anim > $13 then
                    Slots[I].Anim := $13;
                end
                else
                  if Slots[I].Anim > $4F then
                    Slots[I].Anim := $4F;
                Dec(Slots[I].W10);
                if Slots[I].W10 = 0 then
                  Slots[I].W12 := $50;
              end
              else
              begin
                Inc(Slots[I].Anim);
                if Slots[I].DirX = -1 then
                begin
                  if Slots[I].Anim > $13 then
                    Slots[I].Anim := 1;
                end
                else
                  if Slots[I].Anim > $4F then
                    Slots[I].Anim := $3D;
                Slots[I].X := NewX;
              end;
            HitPlayer(Slots[I].X, Slots[I].Y);
            HitPlayer(Slots[I].X, Slots[I].Y - $10);
            if ShotHit(Slots[I].X, Slots[I].Y) then
            begin
              PlaySound(8);
              if Slots[I].X < Slots[1].X then
              begin
                if (Map[(Slots[I].X + $F) shr 4 + 1, Row2 + 1].Solid = 0)
                    and (Map[(Slots[I].X + $F) shr 4 + 1, Row2].Solid = 0) then
                begin
                  Slots[I].DirX := 1;
                  Slots[I].Anim := $3D;
                end;
              end
              else
                if (Map[Slots[I].X shr 4 + 1, Row2 + 1].Solid = 0) and (Map[Slots[I].X shr 4 + 1,
                    Row2].Solid = 0) then
                begin
                  Slots[I].DirX := -1;
                  Slots[I].Anim := 1;
                end;
            end
            else
              if ShotHit(Slots[I].X, Slots[I].Y - $10) then
              begin
                if Slots[I].X < Slots[1].X then
                begin
                  if (Map[(Slots[I].X + $F) shr 4 + 1, Row2 + 1].Solid = 0)
                      and (Map[(Slots[I].X + $F) shr 4 + 1, Row2].Solid = 0) then
                  begin
                    Slots[I].DirX := 1;
                    Slots[I].Anim := $3D;
                  end;
                end
                else
                  if (Map[Slots[I].X shr 4 + 1, Row2 + 1].Solid = 0) and (Map[Slots[I].X shr 4 + 1,
                      Row2].Solid = 0) then
                  begin
                    Slots[I].DirX := -1;
                    Slots[I].Anim := 1;
                  end;
                if Slots[I].W12 = 0 then
                begin
                  PlaySound($13);
                  Score := Score + $3E8;
                  StatusCamX := -1;
                  Slots[I].Remove := 1;
                  DrawBack(Slots[I].X, Slots[I].Y);
                  DrawBack(Slots[I].X - $10, Slots[I].Y);
                  DrawBack(Slots[I].X + $10, Slots[I].Y);
                  DrawBack(Slots[I].X + $10, Slots[I].Y - $10);
                  DrawBack(Slots[I].X - $10, Slots[I].Y - $10);
                  DrawBack(Slots[I].X, Slots[I].Y - $10);
                  Spawn(Slots[I].X and $FFF0, Slots[I].Y and $FFF0, $14);
                end
                else
                  PlaySound(8);
              end;
          end;
          $20:
          begin
            Inc(Slots[I].Anim);
            if Slots[I].Anim > $13 then
              Slots[I].Anim := 1;
            if ShotHit(Slots[I].X, Slots[I].Y) then
            begin
              Dec(Slots[I].W0C);
              Slots[I].W00 := 3;
              if Slots[I].W0C <= 0 then
              begin
                for Col1 := 0 to $F do
                  SetPalReg(Col1, $C);
                Playing := False;
                PlaySound($A);
                ExitArmed := 1;
                Score := Score + $1388;
                StatusCamX := -1;
                Slots[I].Kind := $1389;
                Slots[I].W0E := $10;
                Slots[I].Sprite := $AC;
                Slots[I].Anim := 1;
                DrawTileB(Gfx[10]^.Tile[22], Slots[I].X, Slots[I].Y + $10);
                DrawTileB(Gfx[10]^.Tile[22], Slots[I].X, Slots[I].Y + $1A0);
                FadeIn(0);
              end
              else
                PlaySound(8);
            end;
          end;
          $21:
          begin
            if (Map[NewX shr 4 + 1, NewY shr 4 + 1].Solid <> 0) or (Map[(NewX + $F) shr 4 + 1,
                NewY shr 4 + 1].Solid <> 0) or (Map[(NewX + 8) shr 4 + 1, NewY shr 4].FlagB = 0)
                and (Map[(NewX + 8) shr 4 + 1, NewY shr 4].Solid = 0) then
            begin
              Slots[I].DirX := -Slots[I].DirX;
              if Slots[I].DirX = -1 then
                Slots[I].Anim := 1
              else
                Slots[I].Anim := $15;
            end;
            Inc(Slots[I].Anim);
            if Slots[I].DirX = -1 then
            begin
              if Slots[I].Anim > $13 then
                Slots[I].Anim := 1;
            end
            else
              if Slots[I].Anim > $27 then
                Slots[I].Anim := $15;
            Inc(Slots[I].W0E);
            if Slots[I].W0E = Slots[I].W0C then
              if (Slots[I].X - $10 < Slots[1].X) and (Slots[I].X + $10 > Slots[1].X)
                  and (Slots[I].Y < Slots[1].Y) then
              begin
                Slots[I].W0E := 0;
                SpawnObject(NewX, Slots[I].Y + 8, 1, 8, $C7);
              end
              else
                Dec(Slots[I].W0E);
            Slots[I].X := NewX;
            HitPlayer(Slots[I].X, Slots[I].Y);
            if ShotHit(Slots[I].X, Slots[I].Y) then
            begin
              Slots[I].W00 := 3;
              Dec(Slots[I].W10);
              if Slots[I].W10 <= 0 then
              begin
                PlaySound($13);
                Score := Score + $1F4;
                StatusCamX := -1;
                DrawBack(Slots[I].X, Slots[I].Y);
                DrawBack(Slots[I].X - $10, Slots[I].Y);
                DrawBack(Slots[I].X + $10, Slots[I].Y);
                Slots[I].Kind := $1389;
                Slots[I].W0E := $10;
                Slots[I].Sprite := $A9;
                Slots[I].Anim := 1;
                Slots[I].X := (Slots[I].X + 8) and $FFF0;
                DrawTileB(Gfx[10]^.Tile[19], Slots[I].X, Slots[I].Y + $10);
                DrawTileB(Gfx[10]^.Tile[19], Slots[I].X, Slots[I].Y + $1A0);
              end
              else
                PlaySound(8);
            end;
          end;
          $22:
          begin
            Col1 := NewX shr 4 + 1;
            Row := NewY shr 4 + 1;
            Row2 := Row + 1;
            Col2 := (NewX + $F) shr 4 + 1;
            if Map[Col1, Row].Solid <> 0 then
            begin
              Slots[I].DirX := 1;
              Slots[I].Anim := 1;
            end
            else
              if Map[Col2, Row].Solid <> 0 then
              begin
                Slots[I].DirX := -1;
                Slots[I].Anim := $15;
              end
              else
                if (Map[Col1, Row2].Solid = 0) and (Map[Col1, Row2].FlagB = 0) then
                begin
                  Slots[I].DirX := 1;
                  Slots[I].Anim := 1;
                end
                else
                  if (Map[Col2, Row2].Solid = 0) and (Map[Col2, Row2].FlagB = 0) then
                  begin
                    Slots[I].DirX := -1;
                    Slots[I].Anim := $15;
                  end;
            Inc(Slots[I].Anim);
            if Slots[I].DirX = 1 then
            begin
              if Slots[I].Anim > $13 then
                Slots[I].Anim := 1;
            end
            else
              if Slots[I].Anim > $27 then
                Slots[I].Anim := $15;
            Slots[I].X := NewX;
            HitPlayer(Slots[I].X, Slots[I].Y);
            if ShotHit(Slots[I].X, Slots[I].Y) then
            begin
              Slots[I].W00 := 3;
              Dec(Slots[I].W10);
              if Slots[I].W10 <= 0 then
              begin
                PlaySound($13);
                Score := Score + $3E8;
                StatusCamX := -1;
                DrawBack(Slots[I].X, Slots[I].Y);
                DrawBack(Slots[I].X - $10, Slots[I].Y);
                DrawBack(Slots[I].X + $10, Slots[I].Y);
                Slots[I].Kind := $1389;
                Slots[I].W0E := $10;
                Slots[I].Sprite := $AA;
                Slots[I].Anim := 1;
                Slots[I].X := (Slots[I].X + 8) and $FFF0;
                DrawTileB(Gfx[10]^.Tile[20], Slots[I].X, Slots[I].Y + $10);
                DrawTileB(Gfx[10]^.Tile[20], Slots[I].X, Slots[I].Y + $1A0);
                SpawnObject(Slots[I].X, Slots[I].Y, -1, 4, $7D);
                SpawnObject(Slots[I].X, Slots[I].Y, 1, 4, $7E);
              end
              else
                PlaySound(8);
            end;
          end;
          $23:
          begin
            Inc(Slots[I].Anim);
            if Slots[I].Anim > $13 then
              Slots[I].Anim := 1;
            Slots[I].X := NewX;
            HitPlayer(Slots[I].X, Slots[I].Y);
            if ShotHit(Slots[I].X, Slots[I].Y) then
            begin
              Slots[I].W00 := 3;
              Dec(Slots[I].W10);
              if Slots[I].W10 <= 0 then
              begin
                PlaySound($13);
                Score := Score + $3E8;
                StatusCamX := -1;
                Slots[I].Kind := $1389;
                Slots[I].W0E := $10;
                Slots[I].Sprite := $AA;
                Slots[I].Anim := 1;
                Slots[I].X := (Slots[I].X + 8) and $FFF0;
                DrawTileB(Gfx[10]^.Tile[20], Slots[I].X, Slots[I].Y + $10);
                DrawTileB(Gfx[10]^.Tile[20], Slots[I].X, Slots[I].Y + $1A0);
                VGunOff := 1;
              end
              else
                PlaySound(8);
            end;
          end;
          $24:
          begin
            Slots[I].X := NewX;
            Inc(Slots[I].W0E);
            if Slots[I].W0E >= Slots[I].W10 then
            begin
              Slots[I].W0E := Slots[I].W10;
              if (Slots[1].X + 8 >= Slots[I].X - 4) and (Slots[1].X + 8 <= Slots[I].X + 4)
                  and (Slots[I].Y >= Slots[1].Y) and (VGunOff = 0) then
              begin
                SpawnObject(Slots[I].X, Slots[I].Y + 8, -1, 8, $72);
                Slots[I].W0E := 0;
              end;
            end;
          end;
          $89:
          begin
            Row2 := Slots[I].Y shr 4 + 1;
            if (Map[Slots[I].X shr 4 + 1, Row2].Solid <> 0) or (Map[(Slots[I].X + $F) shr 4 + 1,
                Row2].Solid <> 0) then
            begin
              if Slots[I].Remove <> 0 then
                Slots[I].Free := 1;
              Slots[I].Remove := 1;
              if Slots[I].Y < 0 then
                Slots[I].Y := 0;
              DrawBack(Slots[I].X, Slots[I].Y);
              DrawBack(Slots[I].X + $10, Slots[I].Y);
              DrawBack(Slots[I].X, Slots[I].Y + $10);
              DrawBack(Slots[I].X + $10, Slots[I].Y + $10);
              DrawFront(Slots[I].X, Slots[I].Y);
              DrawFront(Slots[I].X + $10, Slots[I].Y);
              DrawFront(Slots[I].X, Slots[I].Y + $10);
              DrawFront(Slots[I].X + $10, Slots[I].Y + $10);
            end
            else
            begin
              Inc(Slots[I].Anim);
              if Slots[I].Anim > 9 then
                Slots[I].Anim := 1;
              Slots[I].Y := NewY;
              if Slots[I].Y < 0 then
                Slots[I].Y := 0;
              HitPlayer(Slots[I].X, Slots[I].Y);
            end;
          end;
          $25:
          begin
            Row2 := Slots[I].Y shr 4;
            if (Map[Slots[I].X shr 4 + 1, Row2].Solid <> 0) or (Map[(Slots[I].X + $F) shr 4 + 1,
                Row2].Solid <> 0) then
            begin
              if Slots[I].Remove <> 0 then
                Slots[I].Free := 1;
              Slots[I].Remove := 1;
              if Slots[I].Y < 0 then
                Slots[I].Y := 0;
              DrawBack(Slots[I].X, Slots[I].Y);
              DrawBack(Slots[I].X + $10, Slots[I].Y);
              DrawBack(Slots[I].X, Slots[I].Y + $10);
              DrawBack(Slots[I].X + $10, Slots[I].Y + $10);
              DrawFront(Slots[I].X, Slots[I].Y);
              DrawFront(Slots[I].X + $10, Slots[I].Y);
              DrawFront(Slots[I].X, Slots[I].Y + $10);
              DrawFront(Slots[I].X + $10, Slots[I].Y + $10);
            end
            else
            begin
              Inc(Slots[I].Anim);
              if Slots[I].Anim > 9 then
                Slots[I].Anim := 1;
              Slots[I].Y := NewY;
              if Slots[I].Y < 0 then
                Slots[I].Y := 0;
              if (Invulnerable = 0) and ((Slots[I].X <= Slots[1].X) and (Slots[I].X + 9 >= Slots[1].X)
                  or (Slots[1].X + 9 >= Slots[I].X) and (Slots[I].X >= Slots[1].X))
                  and ((Slots[I].Y <= Slots[1].Y) and (Slots[I].Y + $F >= Slots[1].Y)
                  or (Slots[1].Y + $F >= Slots[I].Y) and (Slots[I].Y >= Slots[1].Y)) and (HitLock = 0) then
              begin
                HitLock := 1;
                ArcLen := $23;
                PlaySound($16);
              end;
            end;
          end;
          $26:
          begin
            if (Map[NewX shr 4 + 1, NewY shr 4 + 1].Solid <> 0) or (Map[(NewX + $F) shr 4 + 1,
                NewY shr 4 + 1].Solid <> 0) then
              Slots[I].DirX := -Slots[I].DirX;
            Inc(Slots[I].Anim);
            if Slots[I].Anim > $13 then
              Slots[I].Anim := 1;
            if Slots[I].W12 > 0 then
              Dec(Slots[I].W12);
            if Slots[I].W12 = 0 then
            begin
              if Slots[I].W0E = 0 then
                SpawnObject(Slots[I].X, Slots[I].Y + $10, 1, 0, $89);
              Inc(Slots[I].W0E);
              if Slots[I].W0E = Slots[I].W0C then
              begin
                Slots[I].W0E := 0;
                Slots[I].W12 := $6E;
              end;
            end
            else
              Slots[I].X := NewX;
            HitPlayer(Slots[I].X, Slots[I].Y);
            if ShotHit(Slots[I].X, Slots[I].Y) then
              PlaySound(8);
          end;
          $27:
          begin
            Col1 := NewX shr 4;
            Row2 := NewY shr 4;
            Col2 := (NewX + $F) shr 4 + 1;
            if (Map[Col1 + 1, Row2].Solid <> 0) or (Map[Col2, Row2].Solid <> 0) or (Map[Col1 + 1,
                Row2 + 1].Solid <> 0) or (Map[Col2, Row2 + 1].Solid <> 0) then
            begin
              Slots[I].DirX := -Slots[I].DirX;
              if Slots[I].DirX = -1 then
                Slots[I].Anim := 1
              else
                Slots[I].Anim := $C9;
            end
            else
              if (Map[Col1 + 1, Row2 + 2].Solid = 0) and (Map[Col1 + 1, Row2 + 2].FlagB = 0) then
              begin
                Slots[I].DirX := 1;
                Slots[I].Anim := $C9;
              end
              else
                if (Map[Col2, Row2 + 2].Solid = 0) and (Map[Col2, Row2 + 2].FlagB = 0) then
                begin
                  Slots[I].DirX := -1;
                  Slots[I].Anim := 1;
                end;
            Inc(Slots[I].W0E);
            if Slots[I].W0E >= Slots[I].W0C then
            begin
              Slots[I].W0E := 0;
              if (Slots[I].Y shr 4 = (Slots[1].Y + 8) shr 4) and ((Slots[I].X < Slots[1].X)
                  and (Slots[I].DirX = 1) or (Slots[I].X > Slots[1].X) and (Slots[I].DirX = -1)) then
                SpawnObject(Slots[I].X, Slots[I].Y, Slots[I].DirX, 4, $33B);
            end;
            if Slots[I].W12 > 0 then
              Dec(Slots[I].W12);
            if Slots[I].W12 = 1 then
              Slots[I].W10 := $1E
            else
              if Slots[I].W12 = 0 then
              begin
                Inc(Slots[I].Anim);
                if Slots[I].DirX = -1 then
                begin
                  if Slots[I].Anim > $13 then
                    Slots[I].Anim := $13;
                end
                else
                  if Slots[I].Anim > $DB then
                    Slots[I].Anim := $DB;
                Dec(Slots[I].W10);
                if Slots[I].W10 = 0 then
                  Slots[I].W12 := $50;
              end
              else
              begin
                Inc(Slots[I].Anim);
                if Slots[I].DirX = -1 then
                begin
                  if Slots[I].Anim > $13 then
                    Slots[I].Anim := 1;
                end
                else
                  if Slots[I].Anim > $DB then
                    Slots[I].Anim := $C9;
                Slots[I].X := NewX;
              end;
            HitPlayer(Slots[I].X, Slots[I].Y);
            HitPlayer(Slots[I].X, Slots[I].Y - $10);
            if ShotHit(Slots[I].X, Slots[I].Y) then
            begin
              PlaySound(8);
              if Slots[I].X < Slots[1].X then
              begin
                if (Map[(Slots[I].X + $F) shr 4 + 1, Row2 + 1].Solid = 0)
                    and (Map[(Slots[I].X + $F) shr 4 + 1, Row2].Solid = 0) then
                begin
                  Slots[I].DirX := 1;
                  Slots[I].Anim := $C9;
                end;
              end
              else
                if (Map[Slots[I].X shr 4 + 1, Row2 + 1].Solid = 0) and (Map[Slots[I].X shr 4 + 1,
                    Row2].Solid = 0) then
                begin
                  Slots[I].DirX := -1;
                  Slots[I].Anim := 1;
                end;
            end
            else
              if ShotHit(Slots[I].X, Slots[I].Y - $10) then
              begin
                if Slots[I].X < Slots[1].X then
                begin
                  if (Map[(Slots[I].X + $F) shr 4 + 1, Row2 + 1].Solid = 0)
                      and (Map[(Slots[I].X + $F) shr 4 + 1, Row2].Solid = 0) then
                  begin
                    Slots[I].DirX := 1;
                    Slots[I].Anim := $C9;
                  end;
                end
                else
                  if (Map[Slots[I].X shr 4 + 1, Row2 + 1].Solid = 0) and (Map[Slots[I].X shr 4 + 1,
                      Row2].Solid = 0) then
                  begin
                    Slots[I].DirX := -1;
                    Slots[I].Anim := 1;
                  end;
                if Slots[I].W12 = 0 then
                begin
                  PlaySound($13);
                  Score := Score + $3E8;
                  StatusCamX := -1;
                  Slots[I].Remove := 1;
                  DrawBack(Slots[I].X, Slots[I].Y);
                  DrawBack(Slots[I].X - $10, Slots[I].Y);
                  DrawBack(Slots[I].X + $10, Slots[I].Y);
                  DrawBack(Slots[I].X + $10, Slots[I].Y - $10);
                  DrawBack(Slots[I].X - $10, Slots[I].Y - $10);
                  DrawBack(Slots[I].X, Slots[I].Y - $10);
                  Spawn(Slots[I].X and $FFF0, Slots[I].Y and $FFF0, $14);
                end
                else
                  PlaySound(8);
              end;
          end;
          $28:
          begin
            Inc(Slots[I].Anim);
            if Slots[I].Anim > $13 then
              Slots[I].Anim := 1;
            Dec(Slots[I].W0E);
            if Slots[I].W0E = 0 then
            begin
              Slots[I].Remove := 1;
              DrawBack(NewX, NewY);
              DrawBack(NewX - $10, NewY);
              DrawBack(NewX + $10, NewY);
              DrawFront(NewX, NewY);
              DrawFront(NewX - $10, NewY);
              DrawFront(NewX + $10, NewY);
              PageY := $1B0 - PageY;
              DrawBack(NewX, NewY);
              DrawBack(NewX + $10, NewY);
              DrawBack(NewX - $10, NewY);
              DrawFront(NewX, NewY);
              DrawFront(NewX + $10, NewY);
              DrawFront(NewX - $10, NewY);
              PageY := $1B0 - PageY;
            end
            else
              HitPlayer(Slots[I].X, Slots[I].Y);
          end;
          $29:
            if Slots[I].Sprite = $1B3 then
            begin
              Col1 := Slots[1].X - Slots[I].X;
              Row2 := Slots[1].Y - Slots[I].Y;
              if (Col1 < 8) and (Col1 > -8) and (Row2 < 8) and (Row2 > -8) then
              begin
                while Map[NewX shr 4 + 1, NewY shr 4].Solid = 0 do
                  Dec(NewY, $10);
                PlaySound(9);
                Slots[I].Y := NewY;
                Slots[I].Sprite := $26B;
                Slots[I].Speed := 8;
                Slots[I].DirY := 1;
              end;
            end
            else
            begin
              Row2 := Slots[I].Y shr 4 + 2;
              Col1 := (Slots[I].X + 3) shr 4 + 1;
              Col2 := (Slots[I].X + $C) shr 4 + 1;
              if (Map[Col1, Row2].Solid = 0) and (Map[Col2, Row2].Solid = 0) and (Map[Col1,
                  Row2].FlagB = 0) and (Map[Col2, Row2].FlagB = 0) then
              begin
                Slots[I].Y := Slots[I].Y + 4;
                DrawBack(Slots[I].X, Slots[I].Y);
                DrawBack(Slots[I].X, Slots[I].Y);
                DrawBack(Slots[I].X - $10, Slots[I].Y - $10);
                DrawBack(Slots[I].X - $10, Slots[I].Y - $10);
              end
              else
              begin
                Slots[I].Remove := 1;
                DrawBack(NewX, NewY);
                DrawBack(NewX - $10, NewY);
                DrawBack(NewX + $10, NewY);
                DrawBack(NewX, NewY - $10);
                DrawBack(NewX - $10, NewY - $10);
                DrawBack(NewX + $10, NewY - $10);
                DrawFront(NewX, NewY);
                DrawFront(NewX - $10, NewY);
                DrawFront(NewX + $10, NewY);
                DrawFront(NewX, NewY - $10);
                DrawFront(NewX - $10, NewY - $10);
                DrawFront(NewX + $10, NewY - $10);
                PageY := $1B0 - PageY;
                DrawBack(NewX, NewY);
                DrawBack(NewX + $10, NewY);
                DrawBack(NewX - $10, NewY);
                DrawBack(NewX, NewY - $10);
                DrawBack(NewX + $10, NewY - $10);
                DrawBack(NewX - $10, NewY - $10);
                DrawFront(NewX, NewY);
                DrawFront(NewX + $10, NewY);
                DrawFront(NewX - $10, NewY);
                DrawFront(NewX, NewY - $10);
                DrawFront(NewX + $10, NewY - $10);
                DrawFront(NewX - $10, NewY - $10);
                PageY := $1B0 - PageY;
              end;
              Col1 := Slots[1].X - Slots[I].X;
              Row2 := Slots[1].Y - Slots[I].Y;
              if (Col1 < $A) and (Col1 > -10) and (Row2 < $A) and (Row2 > -10) then
              begin
                Score := Score + $1388;
                StatusCamX := -1;
                Slots[I].Kind := $1389;
                Slots[I].W0E := $10;
                Slots[I].Sprite := $AC;
                Slots[I].Anim := 1;
                Slots[I].Speed := 0;
                DrawTileB(Gfx[10]^.Tile[21], Slots[I].X, Slots[I].Y + $10);
                DrawTileB(Gfx[10]^.Tile[21], Slots[I].X, Slots[I].Y + $1A0);
              end;
            end;
          $2B:
          begin
            Inc(Slots[I].W0C);
            if Slots[I].W0C = Slots[I].W0E then
            begin
              Inc(Slots[I].Anim);
              if Slots[I].Anim > $13 then
                Slots[I].Anim := Random(5) + 1;
              Slots[I].W0C := 0;
            end;
          end;
          $2C:
          begin
            Inc(Slots[I].Anim);
            if Slots[I].Sprite = $103 then
            begin
              Inc(Slots[I].Anim);
              HitPlayer(Slots[I].X, Slots[I].Y);
            end;
            if Slots[I].Anim > $13 then
              Slots[I].Anim := 1;
          end;
        end;
    end;
  for I := 1 to Gun do
    if (Shots[I].Free = 0) and (Shots[I].Sprite <> $272) then
    begin
      Shots[I].PrevX := Shots[I].X;
      Shots[I].PrevY := Shots[I].Y;
      if Shots[I].DirX = 1 then
        NewX := Shots[I].X + Shots[I].Speed
      else
        if Shots[I].DirX = -1 then
          NewX := Shots[I].X - Shots[I].Speed
        else
          NewX := Shots[I].X;
      NewY := (Shots[I].Y + 8) shr 4 + 1;
      if (Map[NewX shr 4 + 1, NewY].Solid <> 0) or (Map[(NewX + 8) shr 4 + 1, NewY].Solid <> 0) then
      begin
        PlaySound(7);
        Shots[I].Sprite := $272;
        Shots[I].Speed := 0;
        Shots[I].W0E := 7;
      end;
      Shots[I].X := NewX;
    end;
end;
{$F-}
