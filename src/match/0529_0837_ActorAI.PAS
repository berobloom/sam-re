{ src: SAM1RE 0529:0837 (../SAM objects.md, physics.md: the actor behaviour switch on Slots[I].Kind, the
  first of the two chains (kinds below $1E); NewX, NewY: the frame pass's proposed position; CX, CY: never
  written by the caller, the kind-$16 body's cell loop counters) }
{$F+}
procedure ActorAI(NewX, NewY, I, CX, CY: Integer);
var
  Col1, Row2, Col2, Row: Integer;
begin
  case Slots[I].Kind of
    1:
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
        PlaySound($13);
        Score := Score + $64;
        StatusCamX := -1;
        Slots[I].Kind := $1388;
        Slots[I].Sprite := $187;
        Slots[I].Anim := 1;
        Slots[I].Speed := 0;
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
        PlaySound(8);
        Dec(Slots[I].Kind);
        Slots[I].MaskFrames := 3;
        Slots[I].Sprite := $15F;
        Slots[I].Speed := 1;
        Slots[I].Limit := Random($32) + $32;
        Slots[I].Count := 0;
        if Slots[I].X < Slots[1].X then
          Slots[I].DirX := 1
        else
          Slots[I].DirX := -1;
        if Slots[I].DirX = 1 then
          Slots[I].Anim := 1
        else
          Slots[I].Anim := $15;
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
      if ShotHit(Slots[I].X, Slots[I].Y) then
      begin
        PlaySound(8);
        Dec(Slots[I].Kind);
        Slots[I].Sprite := $167;
        Slots[I].MaskFrames := 3;
        Slots[I].Speed := 2;
        if Slots[I].X < Slots[1].X then
          Slots[I].DirX := 1
        else
          Slots[I].DirX := -1;
        if Slots[I].DirX = 1 then
          Slots[I].Anim := 1
        else
          Slots[I].Anim := $15;
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
      Inc(Slots[I].Count);
      if (Slots[I].Count >= Slots[I].Limit) and (Slots[I].Y shr 4 = (Slots[1].Y + 8) shr 4)
          and ((Slots[I].X < Slots[1].X) and (Slots[I].DirX = 1) or (Slots[I].X > Slots[1].X)
          and (Slots[I].DirX = -1)) then
      begin
        Slots[I].Count := 0;
        SpawnObject(Slots[I].X, Slots[I].Y, Slots[I].DirX, 4, 0);
      end;
      Slots[I].X := NewX;
      HitPlayer(Slots[I].X, Slots[I].Y);
      if ShotHit(Slots[I].X, Slots[I].Y) then
      begin
        PlaySound(8);
        Dec(Slots[I].Kind);
        Slots[I].Sprite := $16F;
        Slots[I].MaskFrames := 3;
        Slots[I].Speed := 3;
        if Slots[I].X < Slots[1].X then
          Slots[I].DirX := 1
        else
          Slots[I].DirX := -1;
        if Slots[I].DirX = 1 then
          Slots[I].Anim := 1
        else
          Slots[I].Anim := $15;
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
      Inc(Slots[I].Count);
      if (Slots[I].Count >= Slots[I].Limit) and (Slots[I].Y shr 4 = (Slots[1].Y + 8) shr 4)
          and ((Slots[I].X < Slots[1].X) and (Slots[I].DirX = 1) or (Slots[I].X > Slots[1].X)
          and (Slots[I].DirX = -1)) then
      begin
        Slots[I].Count := 0;
        SpawnObject(Slots[I].X, Slots[I].Y, Slots[I].DirX, 4, 0);
      end;
      Slots[I].X := NewX;
      HitPlayer(Slots[I].X, Slots[I].Y);
      if ShotHit(Slots[I].X, Slots[I].Y) then
      begin
        PlaySound(8);
        Dec(Slots[I].Kind);
        Slots[I].Sprite := $177;
        Slots[I].MaskFrames := 3;
        if Slots[I].X < Slots[1].X then
          Slots[I].DirX := 1
        else
          Slots[I].DirX := -1;
        if Slots[I].DirX = 1 then
          Slots[I].Anim := 1
        else
          Slots[I].Anim := $15;
      end;
    end;
    6:
    begin
      if (Map[NewX shr 4 + 1, NewY shr 4 + 1].Solid <> 0) or (Map[(NewX + $F) shr 4 + 1,
          NewY shr 4 + 1].Solid <> 0) then
        Slots[I].DirX := -Slots[I].DirX;
      Inc(Slots[I].Anim);
      if Slots[I].Anim > $13 then
        Slots[I].Anim := 1;
      Slots[I].X := NewX;
      HitPlayer(Slots[I].X, Slots[I].Y);
      if Slots[I].Sprite = $271 then
      begin
        Dec(Slots[I].Count);
        if Slots[I].Count <= 0 then
        begin
          Slots[I].Remove := 1;
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
          Dec(Slots[I].Limit);
          Slots[I].MaskFrames := 3;
          if Slots[I].Limit <= 0 then
          begin
            Slots[I].Sprite := $271;
            Slots[I].Anim := 1;
            Slots[I].Speed := 1;
          end;
        end;
    end;
    7:
    begin
      Row2 := NewY shr 4 + 1;
      if (Map[NewX shr 4 + 1, Row2].Solid <> 0) or (Map[(NewX + $F) shr 4 + 1, Row2].Solid <> 0) then
      begin
        Slots[I].Remove := 1;
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
        if (Col1 < 8) and (Col1 > -8) and (Row2 < 8) and (Row2 > -8) and (Invulnerable = 0) and (HitLock = 0) then
          if Lives > 1 then
          begin
            if HitRecover = 0 then
            begin
              HitRecover := 1;
              HitTimer := $1E;
              Dec(Lives);
              StatusCamX := -1;
              Slots[1].MaskFrames := 5;
            end;
          end
          else
            if HitRecover = 0 then
            begin
              HitLock := 1;
              ArcLen := $23;
            end;
      end;
    end;
    $A, $C:
    begin
      Inc(Slots[I].Count);
      if (Slots[I].Count >= Slots[I].Limit) and (Slots[I].Y and $FFF0 = (Slots[1].Y + 8) and $FFF0)
          and (Slots[I].X < Slots[1].X) then
      begin
        Slots[I].Count := 0;
        if Slots[I].Kind = $A then
          SpawnObject(Slots[I].X + 8, Slots[I].Y, 1, 4, $1D6)
        else
          SpawnObject(Slots[I].X + $10, Slots[I].Y, 1, 4, $1E8);
      end;
    end;
    $B, $D:
    begin
      Inc(Slots[I].Count);
      if (Slots[I].Count >= Slots[I].Limit) and (Slots[I].Y and $FFF0 = (Slots[1].Y + 8) and $FFF0)
          and (Slots[I].X > Slots[1].X) then
      begin
        Slots[I].Count := 0;
        if Slots[I].Kind = $B then
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
        Slots[I].Remove := 1;
        DrawBack(NewX, NewY);
        DrawBack(NewX - $10, NewY);
        DrawBack(NewX + $10, NewY);
        DrawFront(NewX, NewY);
        DrawFront(NewX - $10, NewY);
        DrawFront(NewX + $10, NewY);
      end
      else
      begin
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
      end;
    end;
    $F:
    begin
      Inc(Slots[I].Count);
      if Slots[I].Count >= Slots[I].Limit then
      begin
        Slots[I].Sprite := (Slots[I].Count - Slots[I].Limit) shr 2 + $1AD;
        if Slots[I].Count = $2D then
        begin
          Slots[I].Count := 0;
          Slots[I].Sprite := $1B3;
        end;
        HitPlayer(Slots[I].X, Slots[I].Y);
      end;
    end;
    $10:
    begin
      Inc(Slots[I].Count);
      if Slots[I].Count >= Slots[I].Limit then
      begin
        Slots[I].Sprite := (Slots[I].Count - Slots[I].Limit) shr 2 + $1B5;
        if Slots[I].Count = $2D then
        begin
          Slots[I].Count := 0;
          Slots[I].Sprite := $1B3;
        end;
        HitPlayer(Slots[I].X, Slots[I].Y);
      end;
    end;
    $11:
    begin
      Inc(Slots[I].Count);
      Col1 := Slots[I].Count - Slots[I].Limit;
      if Col1 >= 0 then
      begin
        Slots[I].Sprite := Col1 shr 2 + $1D7;
        if Slots[I].Count = $3C then
        begin
          Slots[I].Count := 0;
          Slots[I].Sprite := $1B3;
        end;
        HitPlayer(Slots[I].X, Slots[I].Y + 8);
      end;
    end;
    $12:
    begin
      Inc(Slots[I].Count);
      Col1 := Slots[I].Count - Slots[I].Limit;
      if Col1 >= 0 then
      begin
        Slots[I].Sprite := Col1 shr 2 + $1DF;
        if Slots[I].Count = $3C then
        begin
          Slots[I].Count := 0;
          Slots[I].Sprite := $1B3;
        end;
        HitPlayer(Slots[I].X, Slots[I].Y - 8);
      end;
    end;
    $13:
    begin
      Row2 := NewY shr 4 + 1;
      if (Map[NewX shr 4 + 1, Row2].Solid <> 0) or (Map[(NewX + $F) shr 4 + 1, Row2].Solid <> 0) then
      begin
        Slots[I].Remove := 1;
        DrawBack(NewX, NewY);
        DrawBack(NewX - $10, NewY);
        DrawBack(NewX + $10, NewY);
        DrawFront(NewX, NewY);
        DrawFront(NewX - $10, NewY);
        DrawFront(NewX + $10, NewY);
      end
      else
      begin
        Inc(Slots[I].Anim);
        if Slots[I].Anim > 9 then
          Slots[I].Anim := 1;
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
        Slots[I].DirX := -Slots[I].DirX;
      Inc(Slots[I].Anim);
      if Slots[I].Anim > $13 then
        Slots[I].Anim := 1;
      Slots[I].X := NewX;
      HitPlayer(Slots[I].X, Slots[I].Y);
    end;
    $15:
    begin
      if Map[(NewX + 8) shr 4 + 1 + Slots[I].DirX, (NewY + 8) shr 4 + 1].Solid <> 0 then
      begin
        Slots[I].DirX := -Slots[I].DirX;
        if Slots[I].DirX = 1 then
          Slots[I].Sprite := $1F1
        else
          Slots[I].Sprite := $1EF;
      end;
      Inc(Slots[I].Anim);
      if Slots[I].Anim > 9 then
        Slots[I].Anim := 1;
      Slots[I].X := NewX;
      HitPlayer(Slots[I].X, Slots[I].Y);
    end;
    $16:
    begin
      Inc(Slots[I].Anim);
      Inc(Slots[I].Count);
      if (Slots[I].Count = Slots[I].Limit) and (Slots[I].Sprite = $27B) then
      begin
        Slots[I].Anim := 1;
        Slots[I].Sprite := $271;
        Slots[I].Count := Slots[I].Count - $A;
      end
      else
        if Slots[I].Count = Slots[I].Limit then
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
                PageY := $1B0 - PageY;
                DrawBack(CX, CY);
                DrawFront(CX, CY);
                DrawBack(CX - $10, CY);
                DrawFront(CX - $10, CY);
                DrawBack(CX + $10, CY);
                DrawFront(CX + $10, CY);
                DrawBack(CX, CY - $10);
                DrawFront(CX, CY - $10);
                PageY := $1B0 - PageY;
                CX := CX shr 4;
                CY := CY shr 4;
                Inc(CX);
                Inc(CY);
              end;
          HitPlayer(Slots[I].X, Slots[I].Y);
        end;
      if Slots[I].Sprite = $271 then
      begin
        if Slots[I].Anim > $B then
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
        end;
      end
      else
        if Slots[I].Anim > 9 then
          Slots[I].Anim := 1;
    end;
    $17:
    begin
      Inc(Slots[I].Anim);
      if Slots[I].Anim = $B then
        HitPlayer(Slots[I].X, Slots[I].Y);
      if Slots[I].Sprite = $271 then
      begin
        if Slots[I].Anim > $B then
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
        end;
      end
      else
        if Slots[I].Anim > 9 then
          Slots[I].Anim := 1;
    end;
    $19:
    begin
      Inc(Slots[I].Count);
      if Slots[I].Count = Slots[I].Limit then
      begin
        Slots[I].Count := 0;
        Slots[I].DirX := -Slots[I].DirX;
      end;
      Inc(Slots[I].Anim);
      if Slots[I].Anim > $13 then
        Slots[I].Anim := 1;
      Slots[I].X := NewX;
      if ShotHit(Slots[I].X, Slots[I].Y) then
      begin
        PlaySound(8);
        Slots[I].Remove := 0;
        Score := Score + $64;
        StatusCamX := -1;
        Slots[I].Kind := $1388;
        Slots[I].Sprite := $187;
        Slots[I].Anim := 1;
        Slots[I].Speed := 0;
        DrawTileB(Gfx[16]^.Tile[41], Slots[I].X, Slots[I].Y + $10);
        DrawTileB(Gfx[16]^.Tile[41], Slots[I].X, Slots[I].Y + $1A0);
      end;
    end;
    $1A:
    begin
      Inc(Slots[I].Anim);
      if Slots[I].Anim > $13 then
        Slots[I].Anim := 1;
      if ((Slots[I].X <= Slots[1].X) and (Slots[I].X + 9 >= Slots[1].X) or (Slots[1].X + 9 >= Slots[I].X)
          and (Slots[I].X >= Slots[1].X)) and ((Slots[I].Y <= Slots[1].Y)
          and (Slots[I].Y + $F >= Slots[1].Y) or (Slots[1].Y + $F >= Slots[I].Y)
          and (Slots[I].Y >= Slots[1].Y)) then
      begin
        PlaySound(5);
        Score := Score + $2710;
        StatusCamX := -1;
        Slots[I].Kind := $1389;
        Slots[I].Count := $10;
        Slots[I].Sprite := $AD;
        Slots[I].Anim := 1;
        Slots[I].Speed := 0;
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
        Slots[I].Health := -1;
        Riding := 0;
      end
      else
      begin
        Slots[I].DirY := 0;
        Slots[I].Y := Slots[I].Y and $FFF0;
        if Slots[I].Health = -1 then
        begin
          PlaySound($1D);
          Slots[I].Health := 0;
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
          if (Slots[1].Y + $10 >= Slots[I].Y) and (Slots[I].Y >= Slots[1].Y) and (Jumping = 0) then
          begin
            Slots[1].Y := Slots[I].Y - $10;
            Jumping := 0;
            Falling := 0;
            Riding := 1;
            if Slots[1].Sprite = $D then
              Slots[1].Sprite := 9
            else
              if Slots[1].Sprite = $E then
                Slots[1].Sprite := $A;
          end;
    end;
    $1C:
    begin
      Row2 := NewY shr 4 + 1;
      if (Map[NewX shr 4 + 1, Row2].Solid <> 0) or (Map[(NewX + $F) shr 4 + 1, Row2].Solid <> 0) then
        Slots[I].DirX := -Slots[I].DirX;
      if ((Slots[I].X <= Slots[1].X) and (Slots[I].X + 9 >= Slots[1].X) or (Slots[1].X + 9 >= Slots[I].X)
          and (Slots[I].X >= Slots[1].X)) and (Slots[1].Y + $10 >= Slots[I].Y)
          and (Slots[I].Y > Slots[1].Y) and (Jumping = 0) then
      begin
        Slots[1].Y := Slots[I].Y - $10;
        Jumping := 0;
        Falling := 0;
        Riding := 1;
        if Slots[1].Sprite = $D then
          Slots[1].Sprite := 9
        else
          if Slots[1].Sprite = $E then
            Slots[1].Sprite := $A;
        if Slots[I].DirX = 1 then
          Slots[1].X := Slots[I].Speed + Slots[1].X
        else
          if Slots[I].DirX = -1 then
            Slots[1].X := Slots[1].X - Slots[I].Speed;
        if (CamX < $140) and (CamX + $AA < Slots[1].X) then
        begin
          Inc(CamX, Slots[I].Speed);
          if CamX > $140 then
            CamX := $140;
        end;
        if (CamX > 0) and (CamX + $96 > Slots[1].X) then
        begin
          Dec(CamX, Slots[I].Speed);
          if CamX < 0 then
            CamX := 0;
        end;
      end;
      if Slots[I].DirX = 1 then
        Slots[I].X := Slots[I].X + Slots[I].Speed
      else
        if Slots[I].DirX = -1 then
          Slots[I].X := Slots[I].X - Slots[I].Speed;
    end;
  end;
end;
{$F-}
