{ src: SAM1RE 0529:0837 (../SAM objects.md, physics.md: the actor behaviour switch on Slots[I].W1C (kind), the
  first of the two chains (kinds below $1E); NewX, NewY: the frame pass's proposed position; CX, CY: never
  written by the caller, the kind-$16 body's cell loop counters) }
{ keep: - }
{$F+}
procedure ActorAI(NewX, NewY, I, CX, CY: Integer);
var
  Col1, Row2, Col2, Row: Integer;
begin
  case Slots[I].W1C of
    1:
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
        PlaySound($13);
        Score := Score + $64;
        W6858 := -1;
        Slots[I].W1C := $1388;
        Slots[I].W14 := $187;
        Slots[I].W0A := 1;
        Slots[I].W1A := 0;
        DrawTileB(Gfx[16]^.Tile[41], Slots[I].X, Slots[I].Y + $10);
        DrawTileB(Gfx[16]^.Tile[41], Slots[I].X, Slots[I].Y + $1A0);
      end;
    end;
    2:
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
        PlaySound(8);
        Dec(Slots[I].W1C);
        Slots[I].W00 := 3;
        Slots[I].W14 := $15F;
        Slots[I].W1A := 1;
        Slots[I].W0C := Random($32) + $32;
        Slots[I].W0E := 0;
        if Slots[I].X < Slots[1].X then
          Slots[I].W16 := 1
        else
          Slots[I].W16 := -1;
        if Slots[I].W16 = 1 then
          Slots[I].W0A := 1
        else
          Slots[I].W0A := $15;
      end;
    end;
    3:
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
      if ShotHit(Slots[I].X, Slots[I].Y) then
      begin
        PlaySound(8);
        Dec(Slots[I].W1C);
        Slots[I].W14 := $167;
        Slots[I].W00 := 3;
        Slots[I].W1A := 2;
        if Slots[I].X < Slots[1].X then
          Slots[I].W16 := 1
        else
          Slots[I].W16 := -1;
        if Slots[I].W16 = 1 then
          Slots[I].W0A := 1
        else
          Slots[I].W0A := $15;
      end
      else
        HitPlayer(Slots[I].X, Slots[I].Y);
    end;
    4:
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
      Inc(Slots[I].W0E);
      if (Slots[I].W0E >= Slots[I].W0C) and (Slots[I].Y shr 4 = (Slots[1].Y + 8) shr 4)
          and ((Slots[I].X < Slots[1].X) and (Slots[I].W16 = 1) or (Slots[I].X > Slots[1].X)
          and (Slots[I].W16 = -1)) then
      begin
        Slots[I].W0E := 0;
        SpawnObject(Slots[I].X, Slots[I].Y, Slots[I].W16, 4, 0);
      end;
      Slots[I].X := NewX;
      HitPlayer(Slots[I].X, Slots[I].Y);
      if ShotHit(Slots[I].X, Slots[I].Y) then
      begin
        PlaySound(8);
        Dec(Slots[I].W1C);
        Slots[I].W14 := $16F;
        Slots[I].W00 := 3;
        Slots[I].W1A := 3;
        if Slots[I].X < Slots[1].X then
          Slots[I].W16 := 1
        else
          Slots[I].W16 := -1;
        if Slots[I].W16 = 1 then
          Slots[I].W0A := 1
        else
          Slots[I].W0A := $15;
      end;
    end;
    5:
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
      Inc(Slots[I].W0E);
      if (Slots[I].W0E >= Slots[I].W0C) and (Slots[I].Y shr 4 = (Slots[1].Y + 8) shr 4)
          and ((Slots[I].X < Slots[1].X) and (Slots[I].W16 = 1) or (Slots[I].X > Slots[1].X)
          and (Slots[I].W16 = -1)) then
      begin
        Slots[I].W0E := 0;
        SpawnObject(Slots[I].X, Slots[I].Y, Slots[I].W16, 4, 0);
      end;
      Slots[I].X := NewX;
      HitPlayer(Slots[I].X, Slots[I].Y);
      if ShotHit(Slots[I].X, Slots[I].Y) then
      begin
        PlaySound(8);
        Dec(Slots[I].W1C);
        Slots[I].W14 := $177;
        Slots[I].W00 := 3;
        if Slots[I].X < Slots[1].X then
          Slots[I].W16 := 1
        else
          Slots[I].W16 := -1;
        if Slots[I].W16 = 1 then
          Slots[I].W0A := 1
        else
          Slots[I].W0A := $15;
      end;
    end;
    6:
    begin
      if (Map[NewX shr 4 + 1, NewY shr 4 + 1].Solid <> 0) or (Map[(NewX + $F) shr 4 + 1,
          NewY shr 4 + 1].Solid <> 0) then
        Slots[I].W16 := -Slots[I].W16;
      Inc(Slots[I].W0A);
      if Slots[I].W0A > $13 then
        Slots[I].W0A := 1;
      Slots[I].X := NewX;
      HitPlayer(Slots[I].X, Slots[I].Y);
      if Slots[I].W14 = $271 then
      begin
        Dec(Slots[I].W0E);
        if Slots[I].W0E <= 0 then
        begin
          Slots[I].B1F := 1;
          DrawBack(NewX, NewY);
          DrawBack(NewX - $10, NewY);
          DrawBack(NewX + $10, NewY);
          DrawFront(NewX, NewY);
          DrawFront(NewX - $10, NewY);
          DrawFront(NewX + $10, NewY);
        end;
      end
      else
        if ShotHit(Slots[I].X, Slots[I].Y) then
        begin
          PlaySound(8);
          Dec(Slots[I].W0C);
          Slots[I].W00 := 3;
          if Slots[I].W0C <= 0 then
          begin
            Slots[I].W14 := $271;
            Slots[I].W0A := 1;
            Slots[I].W1A := 1;
          end;
        end;
    end;
    7:
    begin
      Row2 := NewY shr 4 + 1;
      if (Map[NewX shr 4 + 1, Row2].Solid <> 0) or (Map[(NewX + $F) shr 4 + 1, Row2].Solid <> 0) then
      begin
        Slots[I].B1F := 1;
        DrawBack(NewX, NewY);
        DrawBack(NewX - $10, NewY);
        DrawBack(NewX + $10, NewY);
        DrawFront(NewX, NewY);
        DrawFront(NewX - $10, NewY);
        DrawFront(NewX + $10, NewY);
      end
      else
      begin
        Slots[I].X := NewX;
        Col1 := Slots[1].X - Slots[I].X;
        Row2 := Slots[1].Y - Slots[I].Y;
        if (Col1 < 8) and (Col1 > -8) and (Row2 < 8) and (Row2 > -8) and (B6A19 = 0) and (B6A1B = 0) then
          if Lives > 1 then
          begin
            if B6A67 = 0 then
            begin
              B6A67 := 1;
              B6A68 := $1E;
              Dec(Lives);
              W6858 := -1;
              Slots[1].W00 := 5;
            end;
          end
          else
            if B6A67 = 0 then
            begin
              B6A1B := 1;
              ArcLen := $23;
            end;
      end;
    end;
    $A, $C:
    begin
      Inc(Slots[I].W0E);
      if (Slots[I].W0E >= Slots[I].W0C) and (Slots[I].Y and $FFF0 = (Slots[1].Y + 8) and $FFF0)
          and (Slots[I].X < Slots[1].X) then
      begin
        Slots[I].W0E := 0;
        if Slots[I].W1C = $A then
          SpawnObject(Slots[I].X + 8, Slots[I].Y, 1, 4, $1D6)
        else
          SpawnObject(Slots[I].X + $10, Slots[I].Y, 1, 4, $1E8);
      end;
    end;
    $B, $D:
    begin
      Inc(Slots[I].W0E);
      if (Slots[I].W0E >= Slots[I].W0C) and (Slots[I].Y and $FFF0 = (Slots[1].Y + 8) and $FFF0)
          and (Slots[I].X > Slots[1].X) then
      begin
        Slots[I].W0E := 0;
        if Slots[I].W1C = $B then
          SpawnObject(Slots[I].X - 8, Slots[I].Y, -1, 4, $1D6)
        else
          SpawnObject(Slots[I].X - $10, Slots[I].Y, -1, 4, $1EC);
      end;
    end;
    $E:
    begin
      Row2 := NewY shr 4 + 1;
      if (Map[NewX shr 4 + 1, Row2].Solid <> 0) or (Map[(NewX + $F) shr 4 + 1, Row2].Solid <> 0) then
      begin
        Slots[I].B1F := 1;
        DrawBack(NewX, NewY);
        DrawBack(NewX - $10, NewY);
        DrawBack(NewX + $10, NewY);
        DrawFront(NewX, NewY);
        DrawFront(NewX - $10, NewY);
        DrawFront(NewX + $10, NewY);
      end
      else
      begin
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
      end;
    end;
    $F:
    begin
      Inc(Slots[I].W0E);
      if Slots[I].W0E >= Slots[I].W0C then
      begin
        Slots[I].W14 := (Slots[I].W0E - Slots[I].W0C) shr 2 + $1AD;
        if Slots[I].W0E = $2D then
        begin
          Slots[I].W0E := 0;
          Slots[I].W14 := $1B3;
        end;
        HitPlayer(Slots[I].X, Slots[I].Y);
      end;
    end;
    $10:
    begin
      Inc(Slots[I].W0E);
      if Slots[I].W0E >= Slots[I].W0C then
      begin
        Slots[I].W14 := (Slots[I].W0E - Slots[I].W0C) shr 2 + $1B5;
        if Slots[I].W0E = $2D then
        begin
          Slots[I].W0E := 0;
          Slots[I].W14 := $1B3;
        end;
        HitPlayer(Slots[I].X, Slots[I].Y);
      end;
    end;
    $11:
    begin
      Inc(Slots[I].W0E);
      Col1 := Slots[I].W0E - Slots[I].W0C;
      if Col1 >= 0 then
      begin
        Slots[I].W14 := Col1 shr 2 + $1D7;
        if Slots[I].W0E = $3C then
        begin
          Slots[I].W0E := 0;
          Slots[I].W14 := $1B3;
        end;
        HitPlayer(Slots[I].X, Slots[I].Y + 8);
      end;
    end;
    $12:
    begin
      Inc(Slots[I].W0E);
      Col1 := Slots[I].W0E - Slots[I].W0C;
      if Col1 >= 0 then
      begin
        Slots[I].W14 := Col1 shr 2 + $1DF;
        if Slots[I].W0E = $3C then
        begin
          Slots[I].W0E := 0;
          Slots[I].W14 := $1B3;
        end;
        HitPlayer(Slots[I].X, Slots[I].Y - 8);
      end;
    end;
    $13:
    begin
      Row2 := NewY shr 4 + 1;
      if (Map[NewX shr 4 + 1, Row2].Solid <> 0) or (Map[(NewX + $F) shr 4 + 1, Row2].Solid <> 0) then
      begin
        Slots[I].B1F := 1;
        DrawBack(NewX, NewY);
        DrawBack(NewX - $10, NewY);
        DrawBack(NewX + $10, NewY);
        DrawFront(NewX, NewY);
        DrawFront(NewX - $10, NewY);
        DrawFront(NewX + $10, NewY);
      end
      else
      begin
        Inc(Slots[I].W0A);
        if Slots[I].W0A > 9 then
          Slots[I].W0A := 1;
        Slots[I].X := NewX;
        HitPlayer(Slots[I].X, Slots[I].Y);
      end;
    end;
    $14:
    begin
      Row2 := (NewY + 8) shr 4 + 1;
      Col1 := (NewX + 8) shr 4 + 1;
      if (Map[(NewX + 3) shr 4 + 1, Row2].Solid <> 0) or (Map[(NewX + $C) shr 4 + 1, Row2].Solid <> 0)
          or (Map[Col1, Row2 + 1].Solid = 0) and (Map[Col1, Row2 + 1].FlagB = 0) then
        Slots[I].W16 := -Slots[I].W16;
      Inc(Slots[I].W0A);
      if Slots[I].W0A > $13 then
        Slots[I].W0A := 1;
      Slots[I].X := NewX;
      HitPlayer(Slots[I].X, Slots[I].Y);
    end;
    $15:
    begin
      if Map[(NewX + 8) shr 4 + 1 + Slots[I].W16, (NewY + 8) shr 4 + 1].Solid <> 0 then
      begin
        Slots[I].W16 := -Slots[I].W16;
        if Slots[I].W16 = 1 then
          Slots[I].W14 := $1F1
        else
          Slots[I].W14 := $1EF;
      end;
      Inc(Slots[I].W0A);
      if Slots[I].W0A > 9 then
        Slots[I].W0A := 1;
      Slots[I].X := NewX;
      HitPlayer(Slots[I].X, Slots[I].Y);
    end;
    $16:
    begin
      Inc(Slots[I].W0A);
      Inc(Slots[I].W0E);
      if (Slots[I].W0E = Slots[I].W0C) and (Slots[I].W14 = $27B) then
      begin
        Slots[I].W0A := 1;
        Slots[I].W14 := $271;
        Slots[I].W0E := Slots[I].W0E - $A;
      end
      else
        if Slots[I].W0E = Slots[I].W0C then
        begin
          PlaySound($B);
          for CY := 1 to $18 do
            for CX := 1 to $28 do
              if Map[CX, CY].Front = $27D then
              begin
                Map[CX, CY].Front := $27E;
                Map[CX, CY].Solid := 0;
                Map[CX, CY - 1].Front := 0;
                Map[CX, CY - 1].Mid := $27A;
                Map[CX, CY - 1].Solid := 0;
                Dec(CX);
                Dec(CY);
                CX := CX shl 4;
                CY := CY shl 4;
                DrawBack(CX, CY);
                DrawFront(CX, CY);
                DrawBack(CX - $10, CY);
                DrawFront(CX - $10, CY);
                DrawBack(CX + $10, CY);
                DrawFront(CX + $10, CY);
                DrawBack(CX, CY - $10);
                DrawFront(CX, CY - $10);
                W6866 := $1B0 - W6866;
                DrawBack(CX, CY);
                DrawFront(CX, CY);
                DrawBack(CX - $10, CY);
                DrawFront(CX - $10, CY);
                DrawBack(CX + $10, CY);
                DrawFront(CX + $10, CY);
                DrawBack(CX, CY - $10);
                DrawFront(CX, CY - $10);
                W6866 := $1B0 - W6866;
                CX := CX shr 4;
                CY := CY shr 4;
                Inc(CX);
                Inc(CY);
              end;
          HitPlayer(Slots[I].X, Slots[I].Y);
        end;
      if Slots[I].W14 = $271 then
      begin
        if Slots[I].W0A > $B then
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
        end;
      end
      else
        if Slots[I].W0A > 9 then
          Slots[I].W0A := 1;
    end;
    $17:
    begin
      Inc(Slots[I].W0A);
      if Slots[I].W0A = $B then
        HitPlayer(Slots[I].X, Slots[I].Y);
      if Slots[I].W14 = $271 then
      begin
        if Slots[I].W0A > $B then
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
        end;
      end
      else
        if Slots[I].W0A > 9 then
          Slots[I].W0A := 1;
    end;
    $19:
    begin
      Inc(Slots[I].W0E);
      if Slots[I].W0E = Slots[I].W0C then
      begin
        Slots[I].W0E := 0;
        Slots[I].W16 := -Slots[I].W16;
      end;
      Inc(Slots[I].W0A);
      if Slots[I].W0A > $13 then
        Slots[I].W0A := 1;
      Slots[I].X := NewX;
      if ShotHit(Slots[I].X, Slots[I].Y) then
      begin
        PlaySound(8);
        Slots[I].B1F := 0;
        Score := Score + $64;
        W6858 := -1;
        Slots[I].W1C := $1388;
        Slots[I].W14 := $187;
        Slots[I].W0A := 1;
        Slots[I].W1A := 0;
        DrawTileB(Gfx[16]^.Tile[41], Slots[I].X, Slots[I].Y + $10);
        DrawTileB(Gfx[16]^.Tile[41], Slots[I].X, Slots[I].Y + $1A0);
      end;
    end;
    $1A:
    begin
      Inc(Slots[I].W0A);
      if Slots[I].W0A > $13 then
        Slots[I].W0A := 1;
      if ((Slots[I].X <= Slots[1].X) and (Slots[I].X + 9 >= Slots[1].X) or (Slots[1].X + 9 >= Slots[I].X)
          and (Slots[I].X >= Slots[1].X)) and ((Slots[I].Y <= Slots[1].Y)
          and (Slots[I].Y + $F >= Slots[1].Y) or (Slots[1].Y + $F >= Slots[I].Y)
          and (Slots[I].Y >= Slots[1].Y)) then
      begin
        PlaySound(5);
        Score := Score + $2710;
        W6858 := -1;
        Slots[I].W1C := $1389;
        Slots[I].W0E := $10;
        Slots[I].W14 := $AD;
        Slots[I].W0A := 1;
        Slots[I].W1A := 0;
        DrawTileB(Gfx[10]^.Tile[23], Slots[I].X, Slots[I].Y + $10);
        DrawTileB(Gfx[10]^.Tile[23], Slots[I].X, Slots[I].Y + $1A0);
      end;
    end;
    $1B:
    begin
      Col1 := (Slots[I].X + 3) shr 4 + 1;
      Col2 := (Slots[I].X + $D) shr 4 + 1;
      Row2 := Slots[I].Y shr 4 + 2;
      if (Map[Col1, Row2].Solid = 0) and (Map[Col2, Row2].Solid = 0) and (Map[Col1, Row2].FlagB = 0)
          and (Map[Col2, Row2].FlagB = 0) then
      begin
        DrawBack(Slots[I].X, Slots[I].Y);
        DrawBack(Slots[I].X, Slots[I].Y - $10);
        DrawBack(Slots[I].X + $10, Slots[I].Y);
        DrawBack(Slots[I].X + $10, Slots[I].Y - $10);
        DrawBack(Slots[I].X, Slots[I].Y + 8);
        DrawBack(Slots[I].X + $10, Slots[I].Y + 8);
        Slots[I].Y := Slots[I].Y + 8;
        Slots[I].W10 := -1;
        B6EE8 := 0;
      end
      else
      begin
        Slots[I].W18 := 0;
        Slots[I].Y := Slots[I].Y and $FFF0;
        if Slots[I].W10 = -1 then
        begin
          PlaySound($1D);
          Slots[I].W10 := 0;
        end;
      end;
      if (Slots[I].X <= Slots[1].X) and (Slots[I].X + 9 >= Slots[1].X) or (Slots[1].X + 9 >= Slots[I].X)
          and (Slots[I].X >= Slots[1].X) then
        if Slots[I].Y = Slots[1].Y then
        begin
          if Slots[I].X < Slots[1].X then
          begin
            if Map[(Slots[I].X - 3) shr 4 + 1, Slots[I].Y shr 4 + 1].Solid = 0 then
              Slots[I].X := Slots[1].X - $D;
          end
          else
            if (Slots[I].X > Slots[1].X) and (Map[(Slots[I].X + 3) shr 4 + 2,
                Slots[I].Y shr 4 + 1].Solid = 0) then
              Slots[I].X := Slots[1].X + $D;
        end
        else
          if (Slots[1].Y + $10 >= Slots[I].Y) and (Slots[I].Y >= Slots[1].Y) and (B6EE7 = 0) then
          begin
            Slots[1].Y := Slots[I].Y - $10;
            B6EE7 := 0;
            B6EE6 := 0;
            B6EE8 := 1;
            if Slots[1].W14 = $D then
              Slots[1].W14 := 9
            else
              if Slots[1].W14 = $E then
                Slots[1].W14 := $A;
          end;
    end;
    $1C:
    begin
      Row2 := NewY shr 4 + 1;
      if (Map[NewX shr 4 + 1, Row2].Solid <> 0) or (Map[(NewX + $F) shr 4 + 1, Row2].Solid <> 0) then
        Slots[I].W16 := -Slots[I].W16;
      if ((Slots[I].X <= Slots[1].X) and (Slots[I].X + 9 >= Slots[1].X) or (Slots[1].X + 9 >= Slots[I].X)
          and (Slots[I].X >= Slots[1].X)) and (Slots[1].Y + $10 >= Slots[I].Y)
          and (Slots[I].Y > Slots[1].Y) and (B6EE7 = 0) then
      begin
        Slots[1].Y := Slots[I].Y - $10;
        B6EE7 := 0;
        B6EE6 := 0;
        B6EE8 := 1;
        if Slots[1].W14 = $D then
          Slots[1].W14 := 9
        else
          if Slots[1].W14 = $E then
            Slots[1].W14 := $A;
        if Slots[I].W16 = 1 then
          Slots[1].X := Slots[I].W1A + Slots[1].X
        else
          if Slots[I].W16 = -1 then
            Slots[1].X := Slots[1].X - Slots[I].W1A;
        if (CamX < $140) and (CamX + $AA < Slots[1].X) then
        begin
          Inc(CamX, Slots[I].W1A);
          if CamX > $140 then
            CamX := $140;
        end;
        if (CamX > 0) and (CamX + $96 > Slots[1].X) then
        begin
          Dec(CamX, Slots[I].W1A);
          if CamX < 0 then
            CamX := 0;
        end;
      end;
      if Slots[I].W16 = 1 then
        Slots[I].X := Slots[I].X + Slots[I].W1A
      else
        if Slots[I].W16 = -1 then
          Slots[I].X := Slots[I].X - Slots[I].W1A;
    end;
  end;
end;
{$F-}
