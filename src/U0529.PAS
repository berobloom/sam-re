unit U0529;
{$S-,D+,L+}
interface
uses Crt, U29C3, U2891, U287F, U286F, GENUS, U25E6, U1802, U0D9C;

function OnScreen(Margin, N: Integer): Boolean;
function ShotOnScreen(Margin, N: Integer): Boolean;
procedure KillPlayer;
procedure ActorFrame;
procedure MovePlayer;
procedure Jump;
procedure TouchPlayer;
implementation
{$F+} procedure Ramp; forward; {$F-}
{$F+} procedure HitPlayer(X, Y: Integer); forward; {$F-}
{$F+} function ShotHit(X, Y: Integer): Boolean; forward; {$F-}
{$F+} procedure Spawn(X, Y, T: Integer); forward; {$F-}
{$F+} procedure SpawnObject(X, Y, Dir, A, T: Integer); forward; {$F-}
{$F+} procedure ActorAI(NewX, NewY, I, CX, CY: Integer); forward; {$F-}
{$F+} function CanMove(DX, DY: Integer): Boolean; forward; {$F-}
{$F+} procedure Fall; forward; {$F-}
{$F+} procedure Touch(X, Y: Integer); forward; {$F-}
{ src: GUESS 0529:0000 (slot N within the view (320 x 184 from CamX, CamY) widened by Margin on each side) }
{ interface }
function OnScreen(Margin, N: Integer): Boolean;
begin
  if Slots[N].X < CamX - Margin then
    OnScreen := False
  else if Slots[N].X > CamX + $140 + Margin then
    OnScreen := False
  else if Slots[N].Y < CamY - Margin then
    OnScreen := False
  else if Slots[N].Y > CamY + $B8 + Margin then
    OnScreen := False
  else
    OnScreen := True;
end;
{ src: GUESS 0529:008D (OnScreen for the second slot table, Shots) }
{ interface }
function ShotOnScreen(Margin, N: Integer): Boolean;
begin
  if Shots[N].X < CamX - Margin then
    ShotOnScreen := False
  else if Shots[N].X > CamX + $140 + Margin then
    ShotOnScreen := False
  else if Shots[N].Y < CamY - Margin then
    ShotOnScreen := False
  else if Shots[N].Y > CamY + $B8 + Margin then
    ShotOnScreen := False
  else
    ShotOnScreen := True;
end;
{ src: SAM1RE 0529:011A (../SAM input.md: Invulnerable is the GOD mode toggle; without it the player dies: QuitMap) }
{ interface }
procedure KillPlayer;
begin
  if Invulnerable = 0 then
    QuitMap := 1;
end;
{ src: GUESS 0529:012D (counts WalkHeld up and derives WalkSpeed from it: a ramp to SpeedBonus + 4,
  halved when SlowWalk is set) }
{$F+}
procedure Ramp;
begin
  Inc(WalkHeld);
  if SlowWalk = 0 then
    case WalkHeld of
      1..2: WalkSpeed := 1;
      3: WalkSpeed := 2;
      4..6: WalkSpeed := 4;
      7..1000: WalkSpeed := SpeedBonus + 4;
    end
  else
    case WalkHeld of
      1..4: WalkSpeed := 1;
      5..6: WalkSpeed := 2;
      7..1000: WalkSpeed := (SpeedBonus + 4) shr 1;
    end;
end;
{$F-}
{ src: GUESS 0529:01C4 (a hit on the player when X, Y overlaps slot 1 (10 x 16): unless HitLock or GOD mode, a
  life goes (HitRecover a short guard, sound 7), or with the last life sound $16 and the death arc starts) }
{$F+}
procedure HitPlayer(X, Y: Integer);
begin
  if (((Slots[1].X >= X) and (X + 9 >= Slots[1].X)) or ((Slots[1].X + 9 >= X) and (Slots[1].X <= X)))
    and (((Slots[1].Y >= Y) and (Y + 15 >= Slots[1].Y)) or ((Slots[1].Y + 15 >= Y) and (Slots[1].Y <= Y)))
    and (HitLock = 0) and (Invulnerable = 0) then
    if Lives > 1 then
    begin
      if HitRecover = 0 then
      begin
        HitRecover := 1;
        HitTimer := 30;
        Dec(Lives);
        StatusCamX := -1;
        Slots[1].MaskFrames := 5;
        PlaySound(7);
      end;
    end
    else if HitRecover = 0 then
    begin
      PlaySound($16);
      HitLock := 1;
      ArcLen := $23;
    end;
end;
{$F-}
{ src: GUESS 0529:027C (does a live shot overlap X, Y? the first one that does is marked spent (B1F) and the
  cells under it repainted, with the neighbours when X is not on a 16-pixel column) }
{$F+}
function ShotHit(X, Y: Integer): Boolean;
var
  I: Integer;
begin
  ShotHit := False;
  for I := 1 to Gun do
    if (Shots[I].Free = 0) and (Shots[I].X + 7 >= X) and (Shots[I].X <= X + 6) and (Shots[I].Y + 8 >= Y)
      and (Shots[I].Y <= Y + 8) then
    begin
      ShotHit := True;
      Shots[I].Remove := 1;
      DrawBack(Shots[I].X, Shots[I].Y);
      DrawFront(Shots[I].X, Shots[I].Y);
      if X and $F > 0 then
      begin
        DrawBack(Shots[I].X - 16, Shots[I].Y);
        DrawBack(Shots[I].X + 16, Shots[I].Y);
        DrawFront(Shots[I].X - 16, Shots[I].Y);
        DrawFront(Shots[I].X + 16, Shots[I].Y);
      end;
    end;
end;
{$F-}
{ src: GUESS 0529:03F0 (spawns an actor of type T at X, Y into the first free slot of Slots (Free = 1):
  W14 := T + 150, and draws tile T of Gfx[10] at the row under it and 26 rows lower) }
{$F+}
procedure Spawn(X, Y, T: Integer);
var
  I: Integer;
  L: LongInt;
  Done: Boolean;
begin
  I := 0;
  Done := False;
  repeat
    Inc(I);
    if Slots[I].Free = 1 then
    begin
      Slots[I].MaskFrames := 0;
      Slots[I].X := X;
      Slots[I].Y := Y;
      Slots[I].PrevX := X;
      Slots[I].PrevY := Y;
      Slots[I].DirY := 0;
      Slots[I].Speed := 0;
      Slots[I].Limit := 0;
      Slots[I].Count := $10;
      Slots[I].Free := 0;
      Slots[I].Remove := 0;
      Slots[I].Kind := 5001;
      Slots[I].Sprite := T + 150;
      Slots[I].Anim := 1;
      Slots[I].Speed := 0;
      Slots[I].DirX := 1;
      DrawTileB(Gfx[10]^.Tile[T], Slots[I].X, ((Slots[I].Y + 8) and $FFF0) + 16);
      DrawTileB(Gfx[10]^.Tile[T], Slots[I].X, ((Slots[I].Y + 8) and $FFF0) + $1A0);
      Done := True;
    end;
  until Done or (I = 25);
end;
{$F-}
{ src: GUESS 0529:0584 (plays sound 3 and puts an object of kind T at X, Y into the first free slot of
  Slots, facing Dir (-1 or 1; W0A 21 or 1); X snaps to 8 pixels except for kind $89. W1C is set by kind:
  0 (becomes $27) and $1D6/$7D/$7E 7, $339/$33B $13, $72 $25, $C7 (becomes $72) $89, $89 $28, else $E) }
{$F+}
procedure SpawnObject(X, Y, Dir, A, T: Integer);
var
  I: Integer;
  L: LongInt;
  Done: Boolean;
begin
  I := 0;
  Done := False;
  repeat
    Inc(I);
    if Slots[I].Free = 1 then
    begin
      PlaySound(3);
      Slots[I].DirX := Dir;
      if Slots[I].DirX = -1 then
        Slots[I].Anim := $15
      else
        Slots[I].Anim := 1;
      Slots[I].DirY := 0;
      Slots[I].MaskFrames := 0;
      if T <> $89 then
        Slots[I].X := X and $FFF8
      else
        Slots[I].X := X;
      Slots[I].Y := Y;
      Slots[I].PrevX := X;
      Slots[I].PrevY := Y;
      Slots[I].Speed := A;
      Slots[I].Limit := 0;
      Slots[I].Count := 0;
      Slots[I].Free := 0;
      Slots[I].Remove := 0;
      if T = 0 then
      begin
        Slots[I].Sprite := $27;
        Slots[I].Kind := 7;
        Slots[I].Anim := 1;
      end
      else
      begin
        Slots[I].Sprite := T;
        if (Slots[I].Sprite = $1D6) or (Slots[I].Sprite = $7D) or (Slots[I].Sprite = $7E) then
        begin
          Slots[I].Kind := 7;
          Slots[I].Anim := 1;
        end
        else if (Slots[I].Sprite = $339) or (Slots[I].Sprite = $33B) then
        begin
          Slots[I].Kind := $13;
          Slots[I].Anim := 1;
        end
        else if Slots[I].Sprite = $72 then
        begin
          Slots[I].Kind := $25;
          Slots[I].Anim := 1;
          Slots[I].DirY := Dir;
        end
        else if Slots[I].Sprite = $C7 then
        begin
          Slots[I].Sprite := $72;
          Slots[I].Kind := $89;
          Slots[I].Anim := 1;
          Slots[I].DirY := Dir;
        end
        else if Slots[I].Sprite = $89 then
        begin
          Slots[I].Kind := $28;
          Slots[I].Anim := 1;
          Slots[I].Count := $1E;
        end
        else
          Slots[I].Kind := $E;
      end;
      Done := True;
    end;
  until Done or (I = 25);
end;
{$F-}
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
{ src: SAM1RE 0529:2F6B (../SAM objects.md: the actor update pass, once a frame from main 0000:1BDF: slots 2..25
  that are live and on screen (or one of the gate-exempt kinds) get their proposed position from the
  direction and speed fields, then their behaviour: ActorAI for kinds below $1E, the inline chain for the
  rest and the 5000/5001 score puffs; then the player's shots move and stop at solid cells) }
{ interface }
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
              Slots[I].Count := $10;
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
                Slots[I].Count := $10;
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
            Dec(Slots[I].Count);
            if Slots[I].Count <= 0 then
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
              Slots[I].MaskFrames := 3;
              Dec(Slots[I].Health);
              if Slots[I].Health = 0 then
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
            if Slots[I].Count > 0 then
              Dec(Slots[I].Count);
            if (Slots[I].Count = 0) and (Slots[I].Y shr 4 = (Slots[1].Y + 8) shr 4)
                and ((Slots[I].X < Slots[1].X) and (Slots[I].DirX = 1) or (Slots[I].X > Slots[1].X)
                and (Slots[I].DirX = -1)) then
            begin
              Slots[I].Count := $46;
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
              Slots[I].MaskFrames := 3;
              Dec(Slots[I].Health);
              if Slots[I].Health = 0 then
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
            Inc(Slots[I].Count);
            if Slots[I].Count >= Slots[I].Limit then
            begin
              Slots[I].Count := 0;
              if (Slots[I].Y shr 4 = (Slots[1].Y + 8) shr 4) and ((Slots[I].X < Slots[1].X)
                  and (Slots[I].DirX = 1) or (Slots[I].X > Slots[1].X) and (Slots[I].DirX = -1)) then
                SpawnObject(Slots[I].X, Slots[I].Y, Slots[I].DirX, 4, $33B);
            end;
            if Slots[I].Wait > 0 then
              Dec(Slots[I].Wait);
            if Slots[I].Wait = 1 then
              Slots[I].Health := $1E
            else
              if Slots[I].Wait = 0 then
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
                Dec(Slots[I].Health);
                if Slots[I].Health = 0 then
                  Slots[I].Wait := $50;
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
                if Slots[I].Wait = 0 then
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
              Dec(Slots[I].Limit);
              Slots[I].MaskFrames := 3;
              if Slots[I].Limit <= 0 then
              begin
                for Col1 := 0 to $F do
                  SetPalReg(Col1, $C);
                Playing := False;
                PlaySound($A);
                ExitArmed := 1;
                Score := Score + $1388;
                StatusCamX := -1;
                Slots[I].Kind := $1389;
                Slots[I].Count := $10;
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
            Inc(Slots[I].Count);
            if Slots[I].Count = Slots[I].Limit then
              if (Slots[I].X - $10 < Slots[1].X) and (Slots[I].X + $10 > Slots[1].X)
                  and (Slots[I].Y < Slots[1].Y) then
              begin
                Slots[I].Count := 0;
                SpawnObject(NewX, Slots[I].Y + 8, 1, 8, $C7);
              end
              else
                Dec(Slots[I].Count);
            Slots[I].X := NewX;
            HitPlayer(Slots[I].X, Slots[I].Y);
            if ShotHit(Slots[I].X, Slots[I].Y) then
            begin
              Slots[I].MaskFrames := 3;
              Dec(Slots[I].Health);
              if Slots[I].Health <= 0 then
              begin
                PlaySound($13);
                Score := Score + $1F4;
                StatusCamX := -1;
                DrawBack(Slots[I].X, Slots[I].Y);
                DrawBack(Slots[I].X - $10, Slots[I].Y);
                DrawBack(Slots[I].X + $10, Slots[I].Y);
                Slots[I].Kind := $1389;
                Slots[I].Count := $10;
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
              Slots[I].MaskFrames := 3;
              Dec(Slots[I].Health);
              if Slots[I].Health <= 0 then
              begin
                PlaySound($13);
                Score := Score + $3E8;
                StatusCamX := -1;
                DrawBack(Slots[I].X, Slots[I].Y);
                DrawBack(Slots[I].X - $10, Slots[I].Y);
                DrawBack(Slots[I].X + $10, Slots[I].Y);
                Slots[I].Kind := $1389;
                Slots[I].Count := $10;
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
              Slots[I].MaskFrames := 3;
              Dec(Slots[I].Health);
              if Slots[I].Health <= 0 then
              begin
                PlaySound($13);
                Score := Score + $3E8;
                StatusCamX := -1;
                Slots[I].Kind := $1389;
                Slots[I].Count := $10;
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
            Inc(Slots[I].Count);
            if Slots[I].Count >= Slots[I].Health then
            begin
              Slots[I].Count := Slots[I].Health;
              if (Slots[1].X + 8 >= Slots[I].X - 4) and (Slots[1].X + 8 <= Slots[I].X + 4)
                  and (Slots[I].Y >= Slots[1].Y) and (VGunOff = 0) then
              begin
                SpawnObject(Slots[I].X, Slots[I].Y + 8, -1, 8, $72);
                Slots[I].Count := 0;
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
            if Slots[I].Wait > 0 then
              Dec(Slots[I].Wait);
            if Slots[I].Wait = 0 then
            begin
              if Slots[I].Count = 0 then
                SpawnObject(Slots[I].X, Slots[I].Y + $10, 1, 0, $89);
              Inc(Slots[I].Count);
              if Slots[I].Count = Slots[I].Limit then
              begin
                Slots[I].Count := 0;
                Slots[I].Wait := $6E;
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
            Inc(Slots[I].Count);
            if Slots[I].Count >= Slots[I].Limit then
            begin
              Slots[I].Count := 0;
              if (Slots[I].Y shr 4 = (Slots[1].Y + 8) shr 4) and ((Slots[I].X < Slots[1].X)
                  and (Slots[I].DirX = 1) or (Slots[I].X > Slots[1].X) and (Slots[I].DirX = -1)) then
                SpawnObject(Slots[I].X, Slots[I].Y, Slots[I].DirX, 4, $33B);
            end;
            if Slots[I].Wait > 0 then
              Dec(Slots[I].Wait);
            if Slots[I].Wait = 1 then
              Slots[I].Health := $1E
            else
              if Slots[I].Wait = 0 then
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
                Dec(Slots[I].Health);
                if Slots[I].Health = 0 then
                  Slots[I].Wait := $50;
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
                if Slots[I].Wait = 0 then
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
            Dec(Slots[I].Count);
            if Slots[I].Count = 0 then
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
                Slots[I].Count := $10;
                Slots[I].Sprite := $AC;
                Slots[I].Anim := 1;
                Slots[I].Speed := 0;
                DrawTileB(Gfx[10]^.Tile[21], Slots[I].X, Slots[I].Y + $10);
                DrawTileB(Gfx[10]^.Tile[21], Slots[I].X, Slots[I].Y + $1A0);
              end;
            end;
          $2B:
          begin
            Inc(Slots[I].Limit);
            if Slots[I].Limit = Slots[I].Count then
            begin
              Inc(Slots[I].Anim);
              if Slots[I].Anim > $13 then
                Slots[I].Anim := Random(5) + 1;
              Slots[I].Limit := 0;
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
        Shots[I].Count := 7;
      end;
      Shots[I].X := NewX;
    end;
end;
{$F-}
{ src: GUESS 0529:65D9 (may the player move by DX, DY? the cells under the corners of slot 1's 16x16 box,
  inset 3 pixels left and right, must all be clear (Solid = 0); when blocked and Level > 1, WalkHeld := 0) }
{$F+}
function CanMove(DX, DY: Integer): Boolean;
var
  X1, Y1, X2, Y2: Integer;
begin
  X1 := (Slots[1].X + DX + 3) shr 4 + 1;
  X2 := (Slots[1].X + DX + 12) shr 4 + 1;
  Y1 := (Slots[1].Y + DY) shr 4 + 1;
  Y2 := (Slots[1].Y + DY + 15) shr 4 + 1;
  if (Map[X1, Y1].Solid <> 0) or (Map[X2, Y1].Solid <> 0) or (Map[X1, Y2].Solid <> 0)
    or (Map[X2, Y2].Solid <> 0) then
  begin
    CanMove := False;
    if Level > 1 then
      WalkHeld := 0;
  end
  else
    CanMove := True;
end;
{$F-}
{ src: GUESS 0529:66B3 (the player falls one step: JumpUpTop counts up to 19 and picks the step from JumpUp;
  a solid cell under the feet, or past step 10 a FlagB ledge, lands him on the 16-pixel row; the camera
  follows down to $B8; then the falling or standing pose by facing) }
{$F+}
procedure Fall;
begin
  Inc(JumpUpTop);
  if JumpUpTop > 19 then
    JumpUpTop := 19;
  Falling := 1;
  Inc(Slots[1].Y, JumpUp[JumpUpTop]);
  if (Map[(Slots[1].X + 3) shr 4 + 1, Slots[1].Y shr 4 + 2].Solid <> 0)
    or (Map[(Slots[1].X + 12) shr 4 + 1, Slots[1].Y shr 4 + 2].Solid <> 0) then
  begin
    Inc(Landings);
    Slots[1].Y := Slots[1].Y and $FFF0;
    Falling := 0;
  end;
  if JumpUpTop > 10 then
    if (Map[(Slots[1].X + 3) shr 4 + 1, (Slots[1].Y + 16) shr 4 + 1].FlagB <> 0)
      or (Map[(Slots[1].X + 12) shr 4 + 1, (Slots[1].Y + 16) shr 4 + 1].FlagB <> 0) then
      if Slots[1].Y < 5 then
      begin
        Inc(Landings);
        Slots[1].Y := Slots[1].Y and $FFF0;
        Falling := 0;
      end
      else if (Map[(Slots[1].X + 3) shr 4 + 1, (Slots[1].Y + 7) shr 4 + 1].FlagB = 0)
        and (Map[(Slots[1].X + 12) shr 4 + 1, (Slots[1].Y + 7) shr 4 + 1].FlagB = 0) then
      begin
        Inc(Landings);
        Slots[1].Y := Slots[1].Y and $FFF0;
        Falling := 0;
      end;
  if CamY + $78 < Slots[1].Y then
    if JumpUp[JumpUpTop] + CamY < $B8 then
      Inc(CamY, JumpUp[JumpUpTop])
    else
      CamY := $B8;
  if Falling <> 0 then
  begin
    if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) or (Slots[1].Sprite = $D) then
      Slots[1].Sprite := $D
    else
      Slots[1].Sprite := $E;
  end
  else if Slots[1].Sprite = $D then
  begin
    if RightHeld <> 0 then
      Slots[1].Sprite := 1
    else
      Slots[1].Sprite := 9;
  end
  else if Slots[1].Sprite = $E then
  begin
    if LeftHeld <> 0 then
      Slots[1].Sprite := 5
    else
      Slots[1].Sprite := $A;
  end;
end;
{$F-}
{ src: GUESS 0529:68F5 (moves the player by the held directions: right/left (RightHeld/LeftHeld) WalkSpeed pixels after
  Ramp, down/up (DownHeld/UpHeld) 4 pixels, each only when CanMove allows it; the camera follows, clamped to
  0..$140 and 0..$B8; W06/W08 keep the old position) }
{ interface }
{$F+}
procedure MovePlayer;
begin
  Slots[1].PrevX := Slots[1].X;
  Slots[1].PrevY := Slots[1].Y;
  if RightHeld <> 0 then
  begin
    Ramp;
    if CanMove(WalkSpeed, 0) then
    begin
      if (CamX < $140) and (CamX + $AA < Slots[1].X) then
      begin
        Inc(CamX, WalkSpeed);
        if CamX > $140 then
          CamX := $140;
      end;
      Inc(Slots[1].X, WalkSpeed);
    end;
  end;
  if LeftHeld <> 0 then
  begin
    Ramp;
    if CanMove(-WalkSpeed, 0) then
    begin
      if (CamX > 0) and (CamX + $96 > Slots[1].X) then
      begin
        Dec(CamX, WalkSpeed);
        if CamX < 0 then
          CamX := 0;
      end;
      Dec(Slots[1].X, WalkSpeed);
    end;
  end;
  if DownHeld <> 0 then
    if CanMove(0, 4) then
    begin
      if (CamY < $B8) and (CamY + $50 < Slots[1].Y) then
        Inc(CamY, 4);
      Inc(Slots[1].Y, 4);
    end;
  if UpHeld <> 0 then
    if CanMove(0, -4) then
    begin
      if (CamY > 0) and (CamY + $50 > Slots[1].Y) then
      begin
        Dec(CamY, 4);
        if CamY < 0 then
          CamY := 0;
      end;
      Dec(Slots[1].Y, 4);
    end;
end;
{$F-}
{ src: GUESS 0529:6A0E (the player's jump step: falls unless jumping or Riding; a jump starts on the jump key
  (JumpHeld) or the joystick's jump button, when the two cells above the head are clear: pose, sound 1;
  JumpUpTop then climbs to 10 through JumpUp, the camera following up to 0, a blocked step ends it) }
{ to: 6B8E }
{ interface }
{$F+}
procedure Jump;
begin
  if (Jumping = 0) and (Riding = 0) then
    Fall;
  if (KeysOff = 0) and (Jumping = 0) and (Falling = 0) and ((JumpHeld <> 0) or (JumpButton and JoyOn))
    and (Map[(Slots[1].X + 3) shr 4 + 1, (Slots[1].Y - 3) shr 4 + 1].Solid = 0)
    and (Map[(Slots[1].X + 12) shr 4 + 1, (Slots[1].Y - 3) shr 4 + 1].Solid = 0) then
  begin
    if (Slots[1].Sprite = 1) or (Slots[1].Sprite = 9) or (Slots[1].Sprite = $B) or (Slots[1].Sprite = $D) then
      Slots[1].Sprite := $D
    else
      Slots[1].Sprite := $E;
    PlaySound(1);
    Jumping := 1;
    Riding := 0;
    JumpUpTop := 0;
  end;
  if Jumping <> 0 then
  begin
    Inc(JumpUpTop);
    if JumpUpTop = 10 then
    begin
      Jumping := 0;
      JumpUpTop := 9;
    end;
    if JumpUpTop < 17 then
      if CanMove(0, -JumpUp[JumpUpTop]) then
      begin
        if (CamY > 0) and (CamY + $50 > Slots[1].Y) then
        begin
          Dec(CamY, JumpUp[JumpUpTop]);
          if CamY < 0 then
            CamY := 0;
        end;
        Dec(Slots[1].Y, JumpUp[JumpUpTop]);
      end
      else
      begin
        JumpUpTop := 9;
        Jumping := 0;
      end;
  end;
end;
{$F-}
{ src: SAM1RE 0529:6D0E (../SAM level-load.md: the tile touch effects of the cell at pixel X, Y: pickups
  (score, ammo, keys, gun), doors, the radar dish, laser fields, teleports, map exits) }
{ from: 6B8E }
{$F+}
procedure Touch(X, Y: Integer);
var
  I, PX, PY: Integer;
begin
  case Map[X shr 4 + 1, Y shr 4 + 1].Front of
    0:
      ;
    $1A5, $1A7, $1A9:
    begin
      case Map[X shr 4 + 1, Y shr 4 + 1].Front of
        $1A5:
          KeyA := 1;
        $1A7:
          KeyB := 1;
        $1A9:
          KeyC := 1;
      end;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(5);
      StatusCamX := -1;
    end;
    $1A6, $1A8, $1AA:
    begin
      I := 0;
      case Map[X shr 4 + 1, Y shr 4 + 1].Front of
        $1A6:
          if KeyA = 1 then
          begin
            I := 1;
            KeyA := 0;
          end;
        $1A8:
          if KeyB = 1 then
          begin
            I := 1;
            KeyB := 0;
          end;
        $1AA:
          if KeyC = 1 then
          begin
            I := 1;
            KeyC := 0;
          end;
      end;
      if I = 1 then
      begin
        Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
        Map[X shr 4 + 1, Y shr 4 + 1].Solid := 0;
        PlaySound(6);
        StatusCamX := -1;
      end;
    end;
    $12D:
    begin
      Ammo := Ammo + 5;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      if Ammo > $63 then
        Ammo := $63;
      StatusCamX := -1;
      PlaySound(5);
    end;
    $13C:
    begin
      Score := Score + $3E8;
      Spawn(X and $FFF0, Y and $FFF0, $14);
      StatusCamX := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $26A:
    begin
      Score := Score + $FA;
      Spawn(X and $FFF0, Y and $FFF0, $12);
      StatusCamX := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $26B:
    begin
      Score := Score + $3E8;
      Spawn(X and $FFF0, Y and $FFF0, $14);
      StatusCamX := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $26C:
    begin
      Score := Score + $1F4;
      Spawn(X and $FFF0, Y and $FFF0, $13);
      StatusCamX := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $275:
    begin
      Score := Score + $64;
      Spawn(X and $FFF0, Y and $FFF0, $11);
      StatusCamX := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $276:
    begin
      Score := Score + $3E8;
      Spawn(X and $FFF0, Y and $FFF0, $14);
      StatusCamX := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $277:
    begin
      Score := Score + $1F4;
      Spawn(X and $FFF0, Y and $FFF0, $13);
      StatusCamX := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $278:
    begin
      Score := Score + $64;
      Spawn(X and $FFF0, Y and $FFF0, $11);
      StatusCamX := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $2C:
    begin
      Score := Score + $1F4;
      Spawn(X and $FFF0, Y and $FFF0, $13);
      StatusCamX := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $26D..$26F:
    begin
      case Map[X shr 4 + 1, Y shr 4 + 1].Front of
        $26D:
        begin
          Bonus1 := 1;
          Score := Score + $64;
          Spawn(X and $FFF0, Y and $FFF0, $11);
          StatusCamX := -1;
          PlaySound(4);
        end;
        $26E:
          if (Bonus3 <> 0) and (Bonus1 <> 0) then
          begin
            Bonus2 := 1;
            Score := Score + $64;
            Spawn(X and $FFF0, Y and $FFF0, $11);
            StatusCamX := -1;
            PlaySound(4);
          end
          else
          begin
            Bonus2 := 1;
            Bonus3 := 0;
            Score := Score + $64;
            Spawn(X and $FFF0, Y and $FFF0, $11);
            StatusCamX := -1;
            PlaySound(4);
          end;
        $26F:
          if (Bonus3 <> 0) and (Bonus1 <> 0) and (Bonus2 <> 0) then
          begin
            Score := Score + $2710;
            Spawn(X and $FFF0, Y and $FFF0, $17);
            StatusCamX := -1;
            PlaySound($C);
          end
          else
          begin
            Score := Score + $64;
            Spawn(X and $FFF0, Y and $FFF0, $11);
            StatusCamX := -1;
            Bonus3 := 0;
            PlaySound(4);
          end;
      end;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
    end;
    $25E:
    begin
      Score := Score + $1F4;
      Spawn(X and $FFF0, Y and $FFF0, $13);
      StatusCamX := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
      StatusCamX := -1;
    end;
    $130:
    begin
      Bullets[Level] := 1;
      Score := Score + $7D0;
      Spawn(X and $FFF0, Y and $FFF0, $15);
      StatusCamX := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(5);
      HasPix := 1;
    end;
    $25F:
    begin
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
      ShowMessage('You can see invisible platforms.');
      for Y := 1 to $18 do
        for X := 1 to $28 do
          if Map[X, Y].Front = -1 then
          begin
            Map[X, Y].Mid := $260;
            Map[X, Y].FlagB := 1;
            DrawBack((X - 1) shl 4, (Y - 1) shl 4);
            DrawFront((X - 1) shl 4, (Y - 1) shl 4);
            PageY := $1B0 - PageY;
            DrawBack((X - 1) shl 4, (Y - 1) shl 4);
            DrawFront((X - 1) shl 4, (Y - 1) shl 4);
            PageY := $1B0 - PageY;
            PlaySound(7);
            Delay($64);
          end;
    end;
    $201..$204:
    begin
      if not Playing then
        PlaySound($1C);
      if Invulnerable = 0 then
        KeysOff := 1;
      MarkerTimer := $33;
      MarkerX := Slots[1].X;
      MarkerY := Slots[1].Y;
      case Map[X shr 4 + 1, Y shr 4 + 1].Front of
        $113..$122:
        begin
          MapSite := Map[X shr 4 + 1, Y shr 4 + 1].Front - $111;
          Map[X shr 4 + 1, Y shr 4 + 1].Front := $10C;
        end;
        $10C:
          if MarkerTimer > $F then
            Inc(Map[X shr 4 + 1, Y shr 4 + 1].Front);
        $10D:
          if MarkerTimer > $1E then
            Inc(Map[X shr 4 + 1, Y shr 4 + 1].Front);
      end;
      if MarkerTimer > $32 then
      begin
        MapSite := Map[X shr 4 + 1, Y shr 4 + 1].Back;
        MarkerTimer := 0;
        FadeOut($14);
        Level := MapSite;
        SaveState;
        if State.X > X and $FFF0 + 8 then
          State.X := State.X and $FFF0 + $10
        else
          State.X := (State.X + 8) and $FFF0;
        if State.Y > Y and $FFF0 + 8 then
          State.Y := State.Y and $FFF0 + $10
        else
          State.Y := (State.Y + 8) and $FFF0;
        LoadLevel(MapSite);
        LevelReset;
        SiteDone[MapSite] := 1;
        DownHeld := 0;
        UpHeld := 0;
      end;
    end;
    $27B:
    begin
      DoorKey := 1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(5);
      StatusCamX := -1;
      Spawn(X and $FFF0, Y and $FFF0, $13);
      Score := Score + $1F4;
    end;
    $27D:
      if DoorKey = 1 then
      begin
        DoorKey := 0;
        PlaySound($B);
        StatusCamX := -1;
        if Slots[1].X + 5 > X then
        begin
          PX := (X shr 4 + 1) shl 4;
          PY := Y and $FFF0;
        end
        else
        begin
          PX := (X shr 4 - 1) shl 4;
          PY := Y and $FFF0;
        end;
        DrawTileB(Gfx[6]^.Tile[35], PX, PY + $10);
        DrawTileB(Gfx[6]^.Tile[35], PX, PY + $1A0);
        I := 1;
        repeat
          Inc(I);
        until (Slots[I].Free = 1) or (I = $19);
        Slots[I].MaskFrames := 0;
        Slots[I].Sprite := $27B;
        Slots[I].X := PX;
        Slots[I].Y := PY;
        Slots[I].PrevX := PX;
        Slots[I].PrevY := PY;
        Slots[I].DirX := 1;
        Slots[I].DirY := 0;
        Slots[I].Anim := 1;
        Slots[I].Speed := 0;
        Slots[I].Limit := $28;
        Slots[I].Count := 0;
        Slots[I].Kind := $16;
        Slots[I].Free := 0;
        Slots[I].Remove := 0;
        DoorMsgShown := 1;
      end
      else
        if DoorMsgShown = 0 then
        begin
          DoorMsgShown := 1;
          ClearText;
          TextLines[1] := 'You have no way to open';
          TextLines[2] := 'this door right now.   ';
          TextLines[3] := '';
          TextLines[4] := 'Press ESCAPE  ';
          TextLines[5] := 'END OF WINDOW';
          KeyFilter[1] := 1;
          WinKey := Ord(TextWindow(False));
          EscHeld := 0;
          MenuReq := 0;
        end;
    $27E:
      if ExitArmed <> 0 then
      begin
        if HasPix <> 0 then
          QuitDos := 1;
        ExitLock := 1;
        SiteDone[Level] := 1;
        if Lives = 3 then
        begin
          HealthBonus;
          Score := Score + $61A8;
          StatusCamX := -1;
        end;
        if (X shr 4 = 0) or (Map[X shr 4 + 1 - 1, Y shr 4 + 1].Solid = 1) then
        begin
          Slots[1].PrevX := Slots[1].X;
          Slots[1].PrevY := Slots[1].Y;
          Slots[1].X := X and $FFF0 + $10;
          Slots[1].Y := Y and $FFF0;
          Slots[1].DirX := -1;
          Slots[1].Sprite := 5;
          Jumping := 0;
          Falling := 0;
          LeftHeld := 1;
          RightHeld := 0;
        end
        else
        begin
          Slots[1].PrevX := Slots[1].X;
          Slots[1].PrevY := Slots[1].Y;
          Slots[1].X := X and $FFF0 - $10;
          Slots[1].Y := Y and $FFF0;
          Slots[1].DirX := 1;
          Slots[1].Sprite := 1;
          Jumping := 0;
          Falling := 0;
          LeftHeld := 0;
          RightHeld := 1;
        end;
      end
      else
        if Level > 1 then
        begin
          PlaySound($F);
          ClearText;
          TextLines[1] := '     MISSION ALERT!    ';
          TextLines[2] := '                       ';
          TextLines[3] := 'You failed to destroy a';
          TextLines[4] := 'vital radar dish. Find ';
          TextLines[5] := 'and destroy! ';
          TextLines[6] := '                       ';
          TextLines[7] := 'Press ESCAPE!          ';
          TextLines[8] := 'END OF WINDOW';
          KeyFilter[1] := 1;
          WinKey := Ord(TextWindow(False));
          EscHeld := 0;
          MenuReq := 0;
          if (X shr 4 = 0) or (Map[X shr 4 + 1 - 1, Y shr 4 + 1].Solid = 1) then
          begin
            Slots[1].PrevX := Slots[1].X;
            Slots[1].PrevY := Slots[1].Y;
            Slots[1].X := X and $FFF0 + $10;
            Slots[1].Y := Y and $FFF0;
            Slots[1].Sprite := $A;
            Jumping := 0;
            Falling := 0;
            LeftHeld := 0;
            RightHeld := 0;
          end
          else
          begin
            Slots[1].PrevX := Slots[1].X;
            Slots[1].PrevY := Slots[1].Y;
            Slots[1].X := X and $FFF0 - $10;
            Slots[1].Y := Y and $FFF0;
            Slots[1].Sprite := 9;
            Jumping := 0;
            Falling := 0;
            LeftHeld := 0;
            RightHeld := 0;
          end;
        end;
    $270:
    begin
      I := 1;
      repeat
        Inc(I);
      until (Slots[I].Free = 1) or (I = $19);
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      Slots[I].MaskFrames := 0;
      Slots[I].Sprite := $271;
      Slots[I].X := X and $FFF0;
      Slots[I].Y := Y and $FFF0;
      Slots[I].PrevX := X and $FFF0;
      Slots[I].PrevY := Y and $FFF0;
      Slots[I].DirX := 1;
      Slots[I].DirY := 0;
      Slots[I].Anim := 1;
      Slots[I].Speed := 0;
      Slots[I].Limit := $28;
      Slots[I].Count := 0;
      Slots[I].Kind := $17;
      Slots[I].Free := 0;
      Slots[I].Remove := 0;
      if Invulnerable = 0 then
        KeysOff := 1;
      if (HitLock = 0) and (Invulnerable = 0) then
      begin
        HitLock := 1;
        ArcLen := $23;
      end;
      UpHeld := 0;
      DownHeld := 0;
      LeftHeld := 0;
      RightHeld := 0;
      Jumping := 0;
    end;
    $1F3, $25B, $265, $267, $268:
      if Invulnerable = 0 then
      begin
        HitLock := 1;
        ArcLen := $23;
        PlaySound($16);
      end;
    $25C:
      if Floppy = 1 then
      begin
        Floppy := 0;
        LaserDown := 1;
        Map[X shr 4 + 1, Y shr 4 + 1].Solid := 0;
        PlaySound($18);
        for Y := 1 to $18 do
          for X := 1 to $28 do
            if Map[X, Y].Front = $25B then
            begin
              Map[X, Y].Front := 0;
              DrawBack((X - 1) shl 4, (Y - 1) shl 4);
              DrawFront((X - 1) shl 4, (Y - 1) shl 4);
              PageY := $1B0 - PageY;
              DrawBack((X - 1) shl 4, (Y - 1) shl 4);
              DrawFront((X - 1) shl 4, (Y - 1) shl 4);
              PageY := $1B0 - PageY;
            end;
        ShowMessage('Laser Field has been De-Activated.');
      end
      else
        if LaserDown = 0 then
        begin
          PlaySound($19);
          LaserDown := 1;
          ClearText;
          TextLines[1] := 'The computer needs a floppy';
          TextLines[2] := 'disk to operate.';
          TextLines[3] := '';
          TextLines[4] := 'Press ESCAPE';
          TextLines[5] := 'END OF WINDOW';
          KeyFilter[1] := 1;
          WinKey := Ord(TextWindow(False));
          EscHeld := 0;
          MenuReq := 0;
        end;
    $25D:
    begin
      Floppy := 1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(5);
      StatusCamX := -1;
      Spawn(X and $FFF0, Y and $FFF0, $13);
      Score := Score + $1F4;
    end;
    $B7:
    begin
      X := X and $FFF0;
      if ((Slots[1].X > X) and (Slots[1].X - X <= 2) or (Slots[1].X < X) and (X - Slots[1].X <= 2)) and (WarpArmed = 0) then
      begin
        StatusCamX := -1;
        PlaySound($17);
        for PY := 1 to $18 do
          for PX := 1 to $28 do
            if (Map[PX, PY].Front = $B7) and ((X shr 4 + 1 <> PX) or (Y shr 4 + 1 <> PY)) then
            begin
              WarpX := (PX - 1) shl 4;
              WarpY := (PY - 1) shl 4;
              if Map[WarpX shr 4, WarpY shr 4 + 1].Solid <> 0 then
                WarpX := WarpX + 3
              else
                WarpX := WarpX - 3;
              PX := $28;
              PY := $18;
            end;
        WarpArmed := 1;
        WarpTimer := $13;
        KeysOff := 1;
        if (RightHeld = 1) or (Slots[1].Sprite = 1) then
          Slots[1].Sprite := 9
        else
          Slots[1].Sprite := $A;
        UpHeld := 0;
        DownHeld := 0;
        LeftHeld := 0;
        RightHeld := 0;
        Jumping := 0;
      end;
    end;
    $139:
    begin
      Score := Score + $FA;
      Spawn(X and $FFF0, Y and $FFF0, $12);
      StatusCamX := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(5);
      SpeedBonus := 4;
      SpeedTimer := $D8;
    end;
    $143..$145:
    begin
      Score := Score + $64;
      StatusCamX := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      Map[X shr 4 + 1, Y shr 4 + 1].FlagB := 0;
      PlaySound(4);
    end;
    $142:
    begin
      Score := Score + $3E8;
      StatusCamX := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(5);
      Tile142Flag := 2;
      Tile142Val := $1B0;
    end;
    $31:
    begin
      Score := Score + $64;
      StatusCamX := -1;
      Inc(Tile31Count);
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(5);
    end;
    $13A:
    begin
      Score := Score + $1388;
      StatusCamX := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(5);
      Inc(Gun);
      if Gun > 2 then
        Gun := 2;
      ShowMessage('Increased Shot Power!');
    end;
    $1D2:
    begin
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound($1A);
      Confused := 1;
      LeftHeld := 0;
      RightHeld := 0;
      ConfuseTimer := $D8;
      ShowMessage('YOU FEEL A BIT CONFUSED!');
    end;
    $1D4:
    begin
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound($1B);
      SlowWalk := 1;
      SlowTimer := $D8;
    end;
    $269:
    begin
      StatusCamX := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(5);
      Inc(Tile269Count);
    end;
  end;
end;
{$F-}
{ src: GUESS 0529:86DF (the main loop's touch pass: Touch at the four corners of the player's box, inset one
  pixel left and right) }
{ interface }
procedure TouchPlayer;
begin
  Touch(Slots[1].X + 1, Slots[1].Y);
  Touch(Slots[1].X + 14, Slots[1].Y);
  Touch(Slots[1].X + 1, Slots[1].Y + 15);
  Touch(Slots[1].X + 14, Slots[1].Y + 15);
end;
begin
{ init }
{ src: EXE 0529:8724: the unit has no initialization statements; TP emits an empty frame }
end.
