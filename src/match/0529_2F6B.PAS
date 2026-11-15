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
    if (Slots[I].Free = 0) and (OnScreen($20, I) or (Slots[I].W1C = $1C) or (Slots[I].W1C = $15)
        or (Slots[I].W1C = $E)) then
    begin
      if Slots[I].W16 = 1 then
        NewX := Slots[I].X + Slots[I].W1A
      else
        if Slots[I].W16 = -1 then
          NewX := Slots[I].X - Slots[I].W1A
        else
          NewX := Slots[I].X;
      if Slots[I].W18 = 1 then
        NewY := Slots[I].Y + Slots[I].W1A
      else
        if Slots[I].W18 = -1 then
          NewY := Slots[I].Y - Slots[I].W1A
        else
          NewY := Slots[I].Y;
      Slots[I].W06 := Slots[I].X;
      Slots[I].W08 := Slots[I].Y;
      if Slots[I].W1C < $1E then
        ActorAI(NewX, NewY, I, CX, CY)
      else
        case Slots[I].W1C of
          $1388:
            if ShotHit(Slots[I].X, Slots[I].Y) then
            begin
              PlaySound($14);
              Score := Score + $64;
              W6858 := -1;
              Slots[I].W1C := $1389;
              Slots[I].W0E := $10;
              Slots[I].W14 := $A7;
              Slots[I].W0A := 1;
              Slots[I].W1A := 0;
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
                W6858 := -1;
                Slots[I].W1C := $1389;
                Slots[I].W0E := $10;
                Slots[I].W14 := $AA;
                Slots[I].W0A := 1;
                Slots[I].W1A := 0;
                DrawTileB(Gfx[10]^.Tile[21], Slots[I].X, Slots[I].Y + $10);
                DrawTileB(Gfx[10]^.Tile[21], Slots[I].X, Slots[I].Y + $1A0);
              end;
          $1389:
          begin
            Slots[I].W06 := NewX;
            Slots[I].W08 := NewY;
            Dec(Slots[I].Y, 2);
            if Slots[I].Y < $10 then
            begin
              NewY := $10;
              Slots[I].Y := $10;
              Slots[I].W08 := $10;
            end;
            Dec(Slots[I].W0E);
            if Slots[I].W0E <= 0 then
            begin
              Slots[I].B1F := 1;
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
              Slots[I].W16 := 1;
              Slots[I].W0A := 1;
            end
            else
              if Map[Col2, Row].Solid <> 0 then
              begin
                Slots[I].W16 := -1;
                Slots[I].W0A := $29;
              end
              else
                if (Map[Col1, Row2].Solid = 0) and (Map[Col1, Row2].FlagB = 0) then
                begin
                  Slots[I].W16 := 1;
                  Slots[I].W0A := 1;
                end
                else
                  if (Map[Col2, Row2].Solid = 0) and (Map[Col2, Row2].FlagB = 0) then
                  begin
                    Slots[I].W16 := -1;
                    Slots[I].W0A := $29;
                  end;
            Inc(Slots[I].W0A);
            if Slots[I].W16 = 1 then
            begin
              if Slots[I].W0A > $13 then
                Slots[I].W0A := 1;
            end
            else
              if Slots[I].W0A > $3B then
                Slots[I].W0A := $29;
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
                Slots[I].B1F := 1;
                DrawBack(Slots[I].X, Slots[I].Y);
                DrawBack(Slots[I].X - $10, Slots[I].Y);
                DrawBack(Slots[I].X + $10, Slots[I].Y);
                DrawBack(Slots[I].X + $20, Slots[I].Y);
                Spawn(Slots[I].X and $FFF0, Slots[I].Y and $FFF0, $13);
                Score := Score + $1F4;
                W6858 := -1;
              end;
              if Slots[I].X < Slots[1].X then
                Slots[I].W16 := 1
              else
                Slots[I].W16 := -1;
              if Slots[I].W16 = 1 then
                Slots[I].W0A := 1
              else
                Slots[I].W0A := $29;
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
              Slots[I].W16 := -Slots[I].W16;
              if Slots[I].W16 = -1 then
                Slots[I].W0A := $29
              else
                Slots[I].W0A := 1;
            end
            else
              if (Map[Col1 + 1, Row2 + 2].Solid = 0) and (Map[Col1 + 1, Row2 + 2].FlagB = 0) then
              begin
                Slots[I].W16 := 1;
                Slots[I].W0A := 1;
              end
              else
                if (Map[Col2, Row2 + 2].Solid = 0) and (Map[Col2, Row2 + 2].FlagB = 0) then
                begin
                  Slots[I].W16 := -1;
                  Slots[I].W0A := $29;
                end;
            Inc(Slots[I].W0A);
            if Slots[I].W16 = 1 then
            begin
              if Slots[I].W0A > $13 then
                Slots[I].W0A := 1;
            end
            else
              if Slots[I].W0A > $3B then
                Slots[I].W0A := $29;
            if Slots[I].W0E > 0 then
              Dec(Slots[I].W0E);
            if (Slots[I].W0E = 0) and (Slots[I].Y shr 4 = (Slots[1].Y + 8) shr 4)
                and ((Slots[I].X < Slots[1].X) and (Slots[I].W16 = 1) or (Slots[I].X > Slots[1].X)
                and (Slots[I].W16 = -1)) then
            begin
              Slots[I].W0E := $46;
              SpawnObject(Slots[I].X, Slots[I].Y, Slots[I].W16, 4, $339);
            end;
            Slots[I].X := NewX;
            if ShotHit(Slots[I].X, Slots[I].Y) or ShotHit(Slots[I].X, Slots[I].Y - $10) then
            begin
              if Slots[I].X < Slots[1].X then
              begin
                if (Map[(Slots[I].X + $F) shr 4 + 1, Row2 + 1].Solid = 0)
                    and (Map[(Slots[I].X + $F) shr 4 + 1, Row2].Solid = 0) then
                begin
                  Slots[I].W16 := 1;
                  Slots[I].W0A := 1;
                end;
              end
              else
                if (Map[Slots[I].X shr 4 + 1, Row2 + 1].Solid = 0) and (Map[Slots[I].X shr 4 + 1,
                    Row2].Solid = 0) then
                begin
                  Slots[I].W16 := -1;
                  Slots[I].W0A := $29;
                end;
              Slots[I].W00 := 3;
              Dec(Slots[I].W10);
              if Slots[I].W10 = 0 then
              begin
                PlaySound($13);
                Score := Score + $3E8;
                W6858 := -1;
                Slots[I].B1F := 1;
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
              Slots[I].W16 := -Slots[I].W16;
              if Slots[I].W16 = -1 then
                Slots[I].W0A := 1
              else
                Slots[I].W0A := $3D;
            end
            else
              if (Map[Col1 + 1, Row2 + 2].Solid = 0) and (Map[Col1 + 1, Row2 + 2].FlagB = 0) then
              begin
                Slots[I].W16 := 1;
                Slots[I].W0A := $3D;
              end
              else
                if (Map[Col2, Row2 + 2].Solid = 0) and (Map[Col2, Row2 + 2].FlagB = 0) then
                begin
                  Slots[I].W16 := -1;
                  Slots[I].W0A := 1;
                end;
            Inc(Slots[I].W0E);
            if Slots[I].W0E >= Slots[I].W0C then
            begin
              Slots[I].W0E := 0;
              if (Slots[I].Y shr 4 = (Slots[1].Y + 8) shr 4) and ((Slots[I].X < Slots[1].X)
                  and (Slots[I].W16 = 1) or (Slots[I].X > Slots[1].X) and (Slots[I].W16 = -1)) then
                SpawnObject(Slots[I].X, Slots[I].Y, Slots[I].W16, 4, $33B);
            end;
            if Slots[I].W12 > 0 then
              Dec(Slots[I].W12);
            if Slots[I].W12 = 1 then
              Slots[I].W10 := $1E
            else
              if Slots[I].W12 = 0 then
              begin
                Inc(Slots[I].W0A);
                if Slots[I].W16 = -1 then
                begin
                  if Slots[I].W0A > $13 then
                    Slots[I].W0A := $13;
                end
                else
                  if Slots[I].W0A > $4F then
                    Slots[I].W0A := $4F;
                Dec(Slots[I].W10);
                if Slots[I].W10 = 0 then
                  Slots[I].W12 := $50;
              end
              else
              begin
                Inc(Slots[I].W0A);
                if Slots[I].W16 = -1 then
                begin
                  if Slots[I].W0A > $13 then
                    Slots[I].W0A := 1;
                end
                else
                  if Slots[I].W0A > $4F then
                    Slots[I].W0A := $3D;
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
                  Slots[I].W16 := 1;
                  Slots[I].W0A := $3D;
                end;
              end
              else
                if (Map[Slots[I].X shr 4 + 1, Row2 + 1].Solid = 0) and (Map[Slots[I].X shr 4 + 1,
                    Row2].Solid = 0) then
                begin
                  Slots[I].W16 := -1;
                  Slots[I].W0A := 1;
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
                    Slots[I].W16 := 1;
                    Slots[I].W0A := $3D;
                  end;
                end
                else
                  if (Map[Slots[I].X shr 4 + 1, Row2 + 1].Solid = 0) and (Map[Slots[I].X shr 4 + 1,
                      Row2].Solid = 0) then
                  begin
                    Slots[I].W16 := -1;
                    Slots[I].W0A := 1;
                  end;
                if Slots[I].W12 = 0 then
                begin
                  PlaySound($13);
                  Score := Score + $3E8;
                  W6858 := -1;
                  Slots[I].B1F := 1;
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
            Inc(Slots[I].W0A);
            if Slots[I].W0A > $13 then
              Slots[I].W0A := 1;
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
                B69F4 := 1;
                Score := Score + $1388;
                W6858 := -1;
                Slots[I].W1C := $1389;
                Slots[I].W0E := $10;
                Slots[I].W14 := $AC;
                Slots[I].W0A := 1;
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
              Slots[I].W16 := -Slots[I].W16;
              if Slots[I].W16 = -1 then
                Slots[I].W0A := 1
              else
                Slots[I].W0A := $15;
            end;
            Inc(Slots[I].W0A);
            if Slots[I].W16 = -1 then
            begin
              if Slots[I].W0A > $13 then
                Slots[I].W0A := 1;
            end
            else
              if Slots[I].W0A > $27 then
                Slots[I].W0A := $15;
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
                W6858 := -1;
                DrawBack(Slots[I].X, Slots[I].Y);
                DrawBack(Slots[I].X - $10, Slots[I].Y);
                DrawBack(Slots[I].X + $10, Slots[I].Y);
                Slots[I].W1C := $1389;
                Slots[I].W0E := $10;
                Slots[I].W14 := $A9;
                Slots[I].W0A := 1;
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
              Slots[I].W16 := 1;
              Slots[I].W0A := 1;
            end
            else
              if Map[Col2, Row].Solid <> 0 then
              begin
                Slots[I].W16 := -1;
                Slots[I].W0A := $15;
              end
              else
                if (Map[Col1, Row2].Solid = 0) and (Map[Col1, Row2].FlagB = 0) then
                begin
                  Slots[I].W16 := 1;
                  Slots[I].W0A := 1;
                end
                else
                  if (Map[Col2, Row2].Solid = 0) and (Map[Col2, Row2].FlagB = 0) then
                  begin
                    Slots[I].W16 := -1;
                    Slots[I].W0A := $15;
                  end;
            Inc(Slots[I].W0A);
            if Slots[I].W16 = 1 then
            begin
              if Slots[I].W0A > $13 then
                Slots[I].W0A := 1;
            end
            else
              if Slots[I].W0A > $27 then
                Slots[I].W0A := $15;
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
                W6858 := -1;
                DrawBack(Slots[I].X, Slots[I].Y);
                DrawBack(Slots[I].X - $10, Slots[I].Y);
                DrawBack(Slots[I].X + $10, Slots[I].Y);
                Slots[I].W1C := $1389;
                Slots[I].W0E := $10;
                Slots[I].W14 := $AA;
                Slots[I].W0A := 1;
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
            Inc(Slots[I].W0A);
            if Slots[I].W0A > $13 then
              Slots[I].W0A := 1;
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
                W6858 := -1;
                Slots[I].W1C := $1389;
                Slots[I].W0E := $10;
                Slots[I].W14 := $AA;
                Slots[I].W0A := 1;
                Slots[I].X := (Slots[I].X + 8) and $FFF0;
                DrawTileB(Gfx[10]^.Tile[20], Slots[I].X, Slots[I].Y + $10);
                DrawTileB(Gfx[10]^.Tile[20], Slots[I].X, Slots[I].Y + $1A0);
                B6A15 := 1;
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
                  and (Slots[I].Y >= Slots[1].Y) and (B6A15 = 0) then
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
              if Slots[I].B1F <> 0 then
                Slots[I].Free := 1;
              Slots[I].B1F := 1;
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
              Inc(Slots[I].W0A);
              if Slots[I].W0A > 9 then
                Slots[I].W0A := 1;
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
              if Slots[I].B1F <> 0 then
                Slots[I].Free := 1;
              Slots[I].B1F := 1;
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
              Inc(Slots[I].W0A);
              if Slots[I].W0A > 9 then
                Slots[I].W0A := 1;
              Slots[I].Y := NewY;
              if Slots[I].Y < 0 then
                Slots[I].Y := 0;
              if (B6A19 = 0) and ((Slots[I].X <= Slots[1].X) and (Slots[I].X + 9 >= Slots[1].X)
                  or (Slots[1].X + 9 >= Slots[I].X) and (Slots[I].X >= Slots[1].X))
                  and ((Slots[I].Y <= Slots[1].Y) and (Slots[I].Y + $F >= Slots[1].Y)
                  or (Slots[1].Y + $F >= Slots[I].Y) and (Slots[I].Y >= Slots[1].Y)) and (B6A1B = 0) then
              begin
                B6A1B := 1;
                ArcLen := $23;
                PlaySound($16);
              end;
            end;
          end;
          $26:
          begin
            if (Map[NewX shr 4 + 1, NewY shr 4 + 1].Solid <> 0) or (Map[(NewX + $F) shr 4 + 1,
                NewY shr 4 + 1].Solid <> 0) then
              Slots[I].W16 := -Slots[I].W16;
            Inc(Slots[I].W0A);
            if Slots[I].W0A > $13 then
              Slots[I].W0A := 1;
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
              Slots[I].W16 := -Slots[I].W16;
              if Slots[I].W16 = -1 then
                Slots[I].W0A := 1
              else
                Slots[I].W0A := $C9;
            end
            else
              if (Map[Col1 + 1, Row2 + 2].Solid = 0) and (Map[Col1 + 1, Row2 + 2].FlagB = 0) then
              begin
                Slots[I].W16 := 1;
                Slots[I].W0A := $C9;
              end
              else
                if (Map[Col2, Row2 + 2].Solid = 0) and (Map[Col2, Row2 + 2].FlagB = 0) then
                begin
                  Slots[I].W16 := -1;
                  Slots[I].W0A := 1;
                end;
            Inc(Slots[I].W0E);
            if Slots[I].W0E >= Slots[I].W0C then
            begin
              Slots[I].W0E := 0;
              if (Slots[I].Y shr 4 = (Slots[1].Y + 8) shr 4) and ((Slots[I].X < Slots[1].X)
                  and (Slots[I].W16 = 1) or (Slots[I].X > Slots[1].X) and (Slots[I].W16 = -1)) then
                SpawnObject(Slots[I].X, Slots[I].Y, Slots[I].W16, 4, $33B);
            end;
            if Slots[I].W12 > 0 then
              Dec(Slots[I].W12);
            if Slots[I].W12 = 1 then
              Slots[I].W10 := $1E
            else
              if Slots[I].W12 = 0 then
              begin
                Inc(Slots[I].W0A);
                if Slots[I].W16 = -1 then
                begin
                  if Slots[I].W0A > $13 then
                    Slots[I].W0A := $13;
                end
                else
                  if Slots[I].W0A > $DB then
                    Slots[I].W0A := $DB;
                Dec(Slots[I].W10);
                if Slots[I].W10 = 0 then
                  Slots[I].W12 := $50;
              end
              else
              begin
                Inc(Slots[I].W0A);
                if Slots[I].W16 = -1 then
                begin
                  if Slots[I].W0A > $13 then
                    Slots[I].W0A := 1;
                end
                else
                  if Slots[I].W0A > $DB then
                    Slots[I].W0A := $C9;
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
                  Slots[I].W16 := 1;
                  Slots[I].W0A := $C9;
                end;
              end
              else
                if (Map[Slots[I].X shr 4 + 1, Row2 + 1].Solid = 0) and (Map[Slots[I].X shr 4 + 1,
                    Row2].Solid = 0) then
                begin
                  Slots[I].W16 := -1;
                  Slots[I].W0A := 1;
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
                    Slots[I].W16 := 1;
                    Slots[I].W0A := $C9;
                  end;
                end
                else
                  if (Map[Slots[I].X shr 4 + 1, Row2 + 1].Solid = 0) and (Map[Slots[I].X shr 4 + 1,
                      Row2].Solid = 0) then
                  begin
                    Slots[I].W16 := -1;
                    Slots[I].W0A := 1;
                  end;
                if Slots[I].W12 = 0 then
                begin
                  PlaySound($13);
                  Score := Score + $3E8;
                  W6858 := -1;
                  Slots[I].B1F := 1;
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
            Inc(Slots[I].W0A);
            if Slots[I].W0A > $13 then
              Slots[I].W0A := 1;
            Dec(Slots[I].W0E);
            if Slots[I].W0E = 0 then
            begin
              Slots[I].B1F := 1;
              DrawBack(NewX, NewY);
              DrawBack(NewX - $10, NewY);
              DrawBack(NewX + $10, NewY);
              DrawFront(NewX, NewY);
              DrawFront(NewX - $10, NewY);
              DrawFront(NewX + $10, NewY);
              W6866 := $1B0 - W6866;
              DrawBack(NewX, NewY);
              DrawBack(NewX + $10, NewY);
              DrawBack(NewX - $10, NewY);
              DrawFront(NewX, NewY);
              DrawFront(NewX + $10, NewY);
              DrawFront(NewX - $10, NewY);
              W6866 := $1B0 - W6866;
            end
            else
              HitPlayer(Slots[I].X, Slots[I].Y);
          end;
          $29:
            if Slots[I].W14 = $1B3 then
            begin
              Col1 := Slots[1].X - Slots[I].X;
              Row2 := Slots[1].Y - Slots[I].Y;
              if (Col1 < 8) and (Col1 > -8) and (Row2 < 8) and (Row2 > -8) then
              begin
                while Map[NewX shr 4 + 1, NewY shr 4].Solid = 0 do
                  Dec(NewY, $10);
                PlaySound(9);
                Slots[I].Y := NewY;
                Slots[I].W14 := $26B;
                Slots[I].W1A := 8;
                Slots[I].W18 := 1;
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
                Slots[I].B1F := 1;
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
                W6866 := $1B0 - W6866;
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
                W6866 := $1B0 - W6866;
              end;
              Col1 := Slots[1].X - Slots[I].X;
              Row2 := Slots[1].Y - Slots[I].Y;
              if (Col1 < $A) and (Col1 > -10) and (Row2 < $A) and (Row2 > -10) then
              begin
                Score := Score + $1388;
                W6858 := -1;
                Slots[I].W1C := $1389;
                Slots[I].W0E := $10;
                Slots[I].W14 := $AC;
                Slots[I].W0A := 1;
                Slots[I].W1A := 0;
                DrawTileB(Gfx[10]^.Tile[21], Slots[I].X, Slots[I].Y + $10);
                DrawTileB(Gfx[10]^.Tile[21], Slots[I].X, Slots[I].Y + $1A0);
              end;
            end;
          $2B:
          begin
            Inc(Slots[I].W0C);
            if Slots[I].W0C = Slots[I].W0E then
            begin
              Inc(Slots[I].W0A);
              if Slots[I].W0A > $13 then
                Slots[I].W0A := Random(5) + 1;
              Slots[I].W0C := 0;
            end;
          end;
          $2C:
          begin
            Inc(Slots[I].W0A);
            if Slots[I].W14 = $103 then
            begin
              Inc(Slots[I].W0A);
              HitPlayer(Slots[I].X, Slots[I].Y);
            end;
            if Slots[I].W0A > $13 then
              Slots[I].W0A := 1;
          end;
        end;
    end;
  for I := 1 to Gun do
    if (Shots[I].Free = 0) and (Shots[I].W14 <> $272) then
    begin
      Shots[I].W06 := Shots[I].X;
      Shots[I].W08 := Shots[I].Y;
      if Shots[I].W16 = 1 then
        NewX := Shots[I].X + Shots[I].W1A
      else
        if Shots[I].W16 = -1 then
          NewX := Shots[I].X - Shots[I].W1A
        else
          NewX := Shots[I].X;
      NewY := (Shots[I].Y + 8) shr 4 + 1;
      if (Map[NewX shr 4 + 1, NewY].Solid <> 0) or (Map[(NewX + 8) shr 4 + 1, NewY].Solid <> 0) then
      begin
        PlaySound(7);
        Shots[I].W14 := $272;
        Shots[I].W1A := 0;
        Shots[I].W0E := 7;
      end;
      Shots[I].X := NewX;
    end;
end;
{$F-}
