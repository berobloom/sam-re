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
{ keep: if OnScreen(0, 1) then; }
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
{ keep: if ShotOnScreen(0, 1) then; }
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
{ src: SAM1RE 0529:011A (../SAM input.md: B6A19 is the GOD mode toggle; without it the player dies: B6EEE) }
{ interface }
{ keep: KillPlayer; }
procedure KillPlayer;
begin
  if B6A19 = 0 then
    B6EEE := 1;
end;
{ src: GUESS 0529:012D (counts W6844 up and derives W6846 from it: a ramp to W69CA + 4, halved when B69D6 is set) }
{$F+}
procedure Ramp;
begin
  Inc(W6844);
  if B69D6 = 0 then
    case W6844 of
      1..2: W6846 := 1;
      3: W6846 := 2;
      4..6: W6846 := 4;
      7..1000: W6846 := W69CA + 4;
    end
  else
    case W6844 of
      1..4: W6846 := 1;
      5..6: W6846 := 2;
      7..1000: W6846 := (W69CA + 4) shr 1;
    end;
end;
{$F-}
{ src: GUESS 0529:01C4 (a hit on the player when X, Y overlaps slot 1 (10 x 16): unless B6A1B or GOD mode, a
  life goes (B6A67 a short guard, sound 7), or with the last life sound $16 and the death arc starts) }
{ keep: - }
{$F+}
procedure HitPlayer(X, Y: Integer);
begin
  if (((Slots[1].X >= X) and (X + 9 >= Slots[1].X)) or ((Slots[1].X + 9 >= X) and (Slots[1].X <= X)))
    and (((Slots[1].Y >= Y) and (Y + 15 >= Slots[1].Y)) or ((Slots[1].Y + 15 >= Y) and (Slots[1].Y <= Y)))
    and (B6A1B = 0) and (B6A19 = 0) then
    if Lives > 1 then
    begin
      if B6A67 = 0 then
      begin
        B6A67 := 1;
        B6A68 := 30;
        Dec(Lives);
        W6858 := -1;
        Slots[1].W00 := 5;
        PlaySound(7);
      end;
    end
    else if B6A67 = 0 then
    begin
      PlaySound($16);
      B6A1B := 1;
      ArcLen := $23;
    end;
end;
{$F-}
{ src: GUESS 0529:027C (does a live shot overlap X, Y? the first one that does is marked spent (B1F) and the
  cells under it repainted, with the neighbours when X is not on a 16-pixel column) }
{ keep: - }
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
      Shots[I].B1F := 1;
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
{ keep: - }
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
      Slots[I].W00 := 0;
      Slots[I].X := X;
      Slots[I].Y := Y;
      Slots[I].W06 := X;
      Slots[I].W08 := Y;
      Slots[I].W18 := 0;
      Slots[I].W1A := 0;
      Slots[I].W0C := 0;
      Slots[I].W0E := $10;
      Slots[I].Free := 0;
      Slots[I].B1F := 0;
      Slots[I].W1C := 5001;
      Slots[I].W14 := T + 150;
      Slots[I].W0A := 1;
      Slots[I].W1A := 0;
      Slots[I].W16 := 1;
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
{ keep: - }
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
      Slots[I].W16 := Dir;
      if Slots[I].W16 = -1 then
        Slots[I].W0A := $15
      else
        Slots[I].W0A := 1;
      Slots[I].W18 := 0;
      Slots[I].W00 := 0;
      if T <> $89 then
        Slots[I].X := X and $FFF8
      else
        Slots[I].X := X;
      Slots[I].Y := Y;
      Slots[I].W06 := X;
      Slots[I].W08 := Y;
      Slots[I].W1A := A;
      Slots[I].W0C := 0;
      Slots[I].W0E := 0;
      Slots[I].Free := 0;
      Slots[I].B1F := 0;
      if T = 0 then
      begin
        Slots[I].W14 := $27;
        Slots[I].W1C := 7;
        Slots[I].W0A := 1;
      end
      else
      begin
        Slots[I].W14 := T;
        if (Slots[I].W14 = $1D6) or (Slots[I].W14 = $7D) or (Slots[I].W14 = $7E) then
        begin
          Slots[I].W1C := 7;
          Slots[I].W0A := 1;
        end
        else if (Slots[I].W14 = $339) or (Slots[I].W14 = $33B) then
        begin
          Slots[I].W1C := $13;
          Slots[I].W0A := 1;
        end
        else if Slots[I].W14 = $72 then
        begin
          Slots[I].W1C := $25;
          Slots[I].W0A := 1;
          Slots[I].W18 := Dir;
        end
        else if Slots[I].W14 = $C7 then
        begin
          Slots[I].W14 := $72;
          Slots[I].W1C := $89;
          Slots[I].W0A := 1;
          Slots[I].W18 := Dir;
        end
        else if Slots[I].W14 = $89 then
        begin
          Slots[I].W1C := $28;
          Slots[I].W0A := 1;
          Slots[I].W0E := $1E;
        end
        else
          Slots[I].W1C := $E;
      end;
      Done := True;
    end;
  until Done or (I = 25);
end;
{$F-}
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
{ src: GUESS 0529:65D9 (may the player move by DX, DY? the cells under the corners of slot 1's 16x16 box,
  inset 3 pixels left and right, must all be clear (Solid = 0); when blocked and Level > 1, W6844 := 0) }
{ keep: - }
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
      W6844 := 0;
  end
  else
    CanMove := True;
end;
{$F-}
{ src: GUESS 0529:66B3 (the player falls one step: JumpUpTop counts up to 19 and picks the step from JumpUp;
  a solid cell under the feet, or past step 10 a FlagB ledge, lands him on the 16-pixel row; the camera
  follows down to $B8; then the falling or standing pose by facing) }
{ keep: - }
{$F+}
procedure Fall;
begin
  Inc(JumpUpTop);
  if JumpUpTop > 19 then
    JumpUpTop := 19;
  B6EE6 := 1;
  Inc(Slots[1].Y, JumpUp[JumpUpTop]);
  if (Map[(Slots[1].X + 3) shr 4 + 1, Slots[1].Y shr 4 + 2].Solid <> 0)
    or (Map[(Slots[1].X + 12) shr 4 + 1, Slots[1].Y shr 4 + 2].Solid <> 0) then
  begin
    Inc(W683E);
    Slots[1].Y := Slots[1].Y and $FFF0;
    B6EE6 := 0;
  end;
  if JumpUpTop > 10 then
    if (Map[(Slots[1].X + 3) shr 4 + 1, (Slots[1].Y + 16) shr 4 + 1].FlagB <> 0)
      or (Map[(Slots[1].X + 12) shr 4 + 1, (Slots[1].Y + 16) shr 4 + 1].FlagB <> 0) then
      if Slots[1].Y < 5 then
      begin
        Inc(W683E);
        Slots[1].Y := Slots[1].Y and $FFF0;
        B6EE6 := 0;
      end
      else if (Map[(Slots[1].X + 3) shr 4 + 1, (Slots[1].Y + 7) shr 4 + 1].FlagB = 0)
        and (Map[(Slots[1].X + 12) shr 4 + 1, (Slots[1].Y + 7) shr 4 + 1].FlagB = 0) then
      begin
        Inc(W683E);
        Slots[1].Y := Slots[1].Y and $FFF0;
        B6EE6 := 0;
      end;
  if CamY + $78 < Slots[1].Y then
    if JumpUp[JumpUpTop] + CamY < $B8 then
      Inc(CamY, JumpUp[JumpUpTop])
    else
      CamY := $B8;
  if B6EE6 <> 0 then
  begin
    if (Slots[1].W14 = 1) or (Slots[1].W14 = 9) or (Slots[1].W14 = $B) or (Slots[1].W14 = $D) then
      Slots[1].W14 := $D
    else
      Slots[1].W14 := $E;
  end
  else if Slots[1].W14 = $D then
  begin
    if B6EF1 <> 0 then
      Slots[1].W14 := 1
    else
      Slots[1].W14 := 9;
  end
  else if Slots[1].W14 = $E then
  begin
    if B6EF0 <> 0 then
      Slots[1].W14 := 5
    else
      Slots[1].W14 := $A;
  end;
end;
{$F-}
{ src: GUESS 0529:68F5 (moves the player by the held directions: right/left (B6EF1/B6EF0) W6846 pixels after
  Ramp, down/up (B6EEA/B6EE9) 4 pixels, each only when CanMove allows it; the camera follows, clamped to
  0..$140 and 0..$B8; W06/W08 keep the old position) }
{ interface }
{ keep: MovePlayer; }
{$F+}
procedure MovePlayer;
begin
  Slots[1].W06 := Slots[1].X;
  Slots[1].W08 := Slots[1].Y;
  if B6EF1 <> 0 then
  begin
    Ramp;
    if CanMove(W6846, 0) then
    begin
      if (CamX < $140) and (CamX + $AA < Slots[1].X) then
      begin
        Inc(CamX, W6846);
        if CamX > $140 then
          CamX := $140;
      end;
      Inc(Slots[1].X, W6846);
    end;
  end;
  if B6EF0 <> 0 then
  begin
    Ramp;
    if CanMove(-W6846, 0) then
    begin
      if (CamX > 0) and (CamX + $96 > Slots[1].X) then
      begin
        Dec(CamX, W6846);
        if CamX < 0 then
          CamX := 0;
      end;
      Dec(Slots[1].X, W6846);
    end;
  end;
  if B6EEA <> 0 then
    if CanMove(0, 4) then
    begin
      if (CamY < $B8) and (CamY + $50 < Slots[1].Y) then
        Inc(CamY, 4);
      Inc(Slots[1].Y, 4);
    end;
  if B6EE9 <> 0 then
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
{ src: GUESS 0529:6A0E (the player's jump step: falls unless jumping or B6EE8; a jump starts on the jump key
  (B6EF3) or the joystick's jump button, when the two cells above the head are clear: pose, sound 1;
  JumpUpTop then climbs to 10 through JumpUp, the camera following up to 0, a blocked step ends it) }
{ to: 6B8E }
{ interface }
{ keep: Jump; }
{$F+}
procedure Jump;
begin
  if (B6EE7 = 0) and (B6EE8 = 0) then
    Fall;
  if (B69DA = 0) and (B6EE7 = 0) and (B6EE6 = 0) and ((B6EF3 <> 0) or (JumpButton and JoyOn))
    and (Map[(Slots[1].X + 3) shr 4 + 1, (Slots[1].Y - 3) shr 4 + 1].Solid = 0)
    and (Map[(Slots[1].X + 12) shr 4 + 1, (Slots[1].Y - 3) shr 4 + 1].Solid = 0) then
  begin
    if (Slots[1].W14 = 1) or (Slots[1].W14 = 9) or (Slots[1].W14 = $B) or (Slots[1].W14 = $D) then
      Slots[1].W14 := $D
    else
      Slots[1].W14 := $E;
    PlaySound(1);
    B6EE7 := 1;
    B6EE8 := 0;
    JumpUpTop := 0;
  end;
  if B6EE7 <> 0 then
  begin
    Inc(JumpUpTop);
    if JumpUpTop = 10 then
    begin
      B6EE7 := 0;
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
        B6EE7 := 0;
      end;
  end;
end;
{$F-}
{ src: SAM1RE 0529:6D0E (../SAM level-load.md: the tile touch effects of the cell at pixel X, Y: pickups
  (score, ammo, keys, gun), doors, the radar dish, laser fields, teleports, map exits) }
{ from: 6B8E }
{ keep: - }
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
          B6A0F := 1;
        $1A7:
          B6A10 := 1;
        $1A9:
          B6A11 := 1;
      end;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(5);
      W6858 := -1;
    end;
    $1A6, $1A8, $1AA:
    begin
      I := 0;
      case Map[X shr 4 + 1, Y shr 4 + 1].Front of
        $1A6:
          if B6A0F = 1 then
          begin
            I := 1;
            B6A0F := 0;
          end;
        $1A8:
          if B6A10 = 1 then
          begin
            I := 1;
            B6A10 := 0;
          end;
        $1AA:
          if B6A11 = 1 then
          begin
            I := 1;
            B6A11 := 0;
          end;
      end;
      if I = 1 then
      begin
        Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
        Map[X shr 4 + 1, Y shr 4 + 1].Solid := 0;
        PlaySound(6);
        W6858 := -1;
      end;
    end;
    $12D:
    begin
      Ammo := Ammo + 5;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      if Ammo > $63 then
        Ammo := $63;
      W6858 := -1;
      PlaySound(5);
    end;
    $13C:
    begin
      Score := Score + $3E8;
      Spawn(X and $FFF0, Y and $FFF0, $14);
      W6858 := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $26A:
    begin
      Score := Score + $FA;
      Spawn(X and $FFF0, Y and $FFF0, $12);
      W6858 := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $26B:
    begin
      Score := Score + $3E8;
      Spawn(X and $FFF0, Y and $FFF0, $14);
      W6858 := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $26C:
    begin
      Score := Score + $1F4;
      Spawn(X and $FFF0, Y and $FFF0, $13);
      W6858 := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $275:
    begin
      Score := Score + $64;
      Spawn(X and $FFF0, Y and $FFF0, $11);
      W6858 := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $276:
    begin
      Score := Score + $3E8;
      Spawn(X and $FFF0, Y and $FFF0, $14);
      W6858 := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $277:
    begin
      Score := Score + $1F4;
      Spawn(X and $FFF0, Y and $FFF0, $13);
      W6858 := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $278:
    begin
      Score := Score + $64;
      Spawn(X and $FFF0, Y and $FFF0, $11);
      W6858 := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $2C:
    begin
      Score := Score + $1F4;
      Spawn(X and $FFF0, Y and $FFF0, $13);
      W6858 := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
    end;
    $26D..$26F:
    begin
      case Map[X shr 4 + 1, Y shr 4 + 1].Front of
        $26D:
        begin
          B6A16 := 1;
          Score := Score + $64;
          Spawn(X and $FFF0, Y and $FFF0, $11);
          W6858 := -1;
          PlaySound(4);
        end;
        $26E:
          if (B6A18 <> 0) and (B6A16 <> 0) then
          begin
            B6A17 := 1;
            Score := Score + $64;
            Spawn(X and $FFF0, Y and $FFF0, $11);
            W6858 := -1;
            PlaySound(4);
          end
          else
          begin
            B6A17 := 1;
            B6A18 := 0;
            Score := Score + $64;
            Spawn(X and $FFF0, Y and $FFF0, $11);
            W6858 := -1;
            PlaySound(4);
          end;
        $26F:
          if (B6A18 <> 0) and (B6A16 <> 0) and (B6A17 <> 0) then
          begin
            Score := Score + $2710;
            Spawn(X and $FFF0, Y and $FFF0, $17);
            W6858 := -1;
            PlaySound($C);
          end
          else
          begin
            Score := Score + $64;
            Spawn(X and $FFF0, Y and $FFF0, $11);
            W6858 := -1;
            B6A18 := 0;
            PlaySound(4);
          end;
      end;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
    end;
    $25E:
    begin
      Score := Score + $1F4;
      Spawn(X and $FFF0, Y and $FFF0, $13);
      W6858 := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(4);
      W6858 := -1;
    end;
    $130:
    begin
      Bullets[Level] := 1;
      Score := Score + $7D0;
      Spawn(X and $FFF0, Y and $FFF0, $15);
      W6858 := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(5);
      B6D8C := 1;
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
            W6866 := $1B0 - W6866;
            DrawBack((X - 1) shl 4, (Y - 1) shl 4);
            DrawFront((X - 1) shl 4, (Y - 1) shl 4);
            W6866 := $1B0 - W6866;
            PlaySound(7);
            Delay($64);
          end;
    end;
    $201..$204:
    begin
      if not Playing then
        PlaySound($1C);
      if B6A19 = 0 then
        B69DA := 1;
      W69DC := $33;
      W6D88 := Slots[1].X;
      W6D8A := Slots[1].Y;
      case Map[X shr 4 + 1, Y shr 4 + 1].Front of
        $113..$122:
        begin
          MapSite := Map[X shr 4 + 1, Y shr 4 + 1].Front - $111;
          Map[X shr 4 + 1, Y shr 4 + 1].Front := $10C;
        end;
        $10C:
          if W69DC > $F then
            Inc(Map[X shr 4 + 1, Y shr 4 + 1].Front);
        $10D:
          if W69DC > $1E then
            Inc(Map[X shr 4 + 1, Y shr 4 + 1].Front);
      end;
      if W69DC > $32 then
      begin
        MapSite := Map[X shr 4 + 1, Y shr 4 + 1].Back;
        W69DC := 0;
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
        B6EEA := 0;
        B6EE9 := 0;
      end;
    end;
    $27B:
    begin
      B6A1A := 1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(5);
      W6858 := -1;
      Spawn(X and $FFF0, Y and $FFF0, $13);
      Score := Score + $1F4;
    end;
    $27D:
      if B6A1A = 1 then
      begin
        B6A1A := 0;
        PlaySound($B);
        W6858 := -1;
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
        Slots[I].W00 := 0;
        Slots[I].W14 := $27B;
        Slots[I].X := PX;
        Slots[I].Y := PY;
        Slots[I].W06 := PX;
        Slots[I].W08 := PY;
        Slots[I].W16 := 1;
        Slots[I].W18 := 0;
        Slots[I].W0A := 1;
        Slots[I].W1A := 0;
        Slots[I].W0C := $28;
        Slots[I].W0E := 0;
        Slots[I].W1C := $16;
        Slots[I].Free := 0;
        Slots[I].B1F := 0;
        B6A14 := 1;
      end
      else
        if B6A14 = 0 then
        begin
          B6A14 := 1;
          ClearText;
          TextLines[1] := 'You have no way to open';
          TextLines[2] := 'this door right now.   ';
          TextLines[3] := '';
          TextLines[4] := 'Press ESCAPE  ';
          TextLines[5] := 'END OF WINDOW';
          B6820[1] := 1;
          W683A := Ord(TextWindow(False));
          B6EEB := 0;
          B683C := 0;
        end;
    $27E:
      if B69F4 <> 0 then
      begin
        if B6D8C <> 0 then
          B6EEC := 1;
        B6A64 := 1;
        SiteDone[Level] := 1;
        if Lives = 3 then
        begin
          HealthBonus;
          Score := Score + $61A8;
          W6858 := -1;
        end;
        if (X shr 4 = 0) or (Map[X shr 4 + 1 - 1, Y shr 4 + 1].Solid = 1) then
        begin
          Slots[1].W06 := Slots[1].X;
          Slots[1].W08 := Slots[1].Y;
          Slots[1].X := X and $FFF0 + $10;
          Slots[1].Y := Y and $FFF0;
          Slots[1].W16 := -1;
          Slots[1].W14 := 5;
          B6EE7 := 0;
          B6EE6 := 0;
          B6EF0 := 1;
          B6EF1 := 0;
        end
        else
        begin
          Slots[1].W06 := Slots[1].X;
          Slots[1].W08 := Slots[1].Y;
          Slots[1].X := X and $FFF0 - $10;
          Slots[1].Y := Y and $FFF0;
          Slots[1].W16 := 1;
          Slots[1].W14 := 1;
          B6EE7 := 0;
          B6EE6 := 0;
          B6EF0 := 0;
          B6EF1 := 1;
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
          B6820[1] := 1;
          W683A := Ord(TextWindow(False));
          B6EEB := 0;
          B683C := 0;
          if (X shr 4 = 0) or (Map[X shr 4 + 1 - 1, Y shr 4 + 1].Solid = 1) then
          begin
            Slots[1].W06 := Slots[1].X;
            Slots[1].W08 := Slots[1].Y;
            Slots[1].X := X and $FFF0 + $10;
            Slots[1].Y := Y and $FFF0;
            Slots[1].W14 := $A;
            B6EE7 := 0;
            B6EE6 := 0;
            B6EF0 := 0;
            B6EF1 := 0;
          end
          else
          begin
            Slots[1].W06 := Slots[1].X;
            Slots[1].W08 := Slots[1].Y;
            Slots[1].X := X and $FFF0 - $10;
            Slots[1].Y := Y and $FFF0;
            Slots[1].W14 := 9;
            B6EE7 := 0;
            B6EE6 := 0;
            B6EF0 := 0;
            B6EF1 := 0;
          end;
        end;
    $270:
    begin
      I := 1;
      repeat
        Inc(I);
      until (Slots[I].Free = 1) or (I = $19);
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      Slots[I].W00 := 0;
      Slots[I].W14 := $271;
      Slots[I].X := X and $FFF0;
      Slots[I].Y := Y and $FFF0;
      Slots[I].W06 := X and $FFF0;
      Slots[I].W08 := Y and $FFF0;
      Slots[I].W16 := 1;
      Slots[I].W18 := 0;
      Slots[I].W0A := 1;
      Slots[I].W1A := 0;
      Slots[I].W0C := $28;
      Slots[I].W0E := 0;
      Slots[I].W1C := $17;
      Slots[I].Free := 0;
      Slots[I].B1F := 0;
      if B6A19 = 0 then
        B69DA := 1;
      if (B6A1B = 0) and (B6A19 = 0) then
      begin
        B6A1B := 1;
        ArcLen := $23;
      end;
      B6EE9 := 0;
      B6EEA := 0;
      B6EF0 := 0;
      B6EF1 := 0;
      B6EE7 := 0;
    end;
    $1F3, $25B, $265, $267, $268:
      if B6A19 = 0 then
      begin
        B6A1B := 1;
        ArcLen := $23;
        PlaySound($16);
      end;
    $25C:
      if B6A12 = 1 then
      begin
        B6A12 := 0;
        B6A13 := 1;
        Map[X shr 4 + 1, Y shr 4 + 1].Solid := 0;
        PlaySound($18);
        for Y := 1 to $18 do
          for X := 1 to $28 do
            if Map[X, Y].Front = $25B then
            begin
              Map[X, Y].Front := 0;
              DrawBack((X - 1) shl 4, (Y - 1) shl 4);
              DrawFront((X - 1) shl 4, (Y - 1) shl 4);
              W6866 := $1B0 - W6866;
              DrawBack((X - 1) shl 4, (Y - 1) shl 4);
              DrawFront((X - 1) shl 4, (Y - 1) shl 4);
              W6866 := $1B0 - W6866;
            end;
        ShowMessage('Laser Field has been De-Activated.');
      end
      else
        if B6A13 = 0 then
        begin
          PlaySound($19);
          B6A13 := 1;
          ClearText;
          TextLines[1] := 'The computer needs a floppy';
          TextLines[2] := 'disk to operate.';
          TextLines[3] := '';
          TextLines[4] := 'Press ESCAPE';
          TextLines[5] := 'END OF WINDOW';
          B6820[1] := 1;
          W683A := Ord(TextWindow(False));
          B6EEB := 0;
          B683C := 0;
        end;
    $25D:
    begin
      B6A12 := 1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(5);
      W6858 := -1;
      Spawn(X and $FFF0, Y and $FFF0, $13);
      Score := Score + $1F4;
    end;
    $B7:
    begin
      X := X and $FFF0;
      if ((Slots[1].X > X) and (Slots[1].X - X <= 2) or (Slots[1].X < X) and (X - Slots[1].X <= 2)) and (B6A06 = 0) then
      begin
        W6858 := -1;
        PlaySound($17);
        for PY := 1 to $18 do
          for PX := 1 to $28 do
            if (Map[PX, PY].Front = $B7) and ((X shr 4 + 1 <> PX) or (Y shr 4 + 1 <> PY)) then
            begin
              W6A0A := (PX - 1) shl 4;
              W6A0C := (PY - 1) shl 4;
              if Map[W6A0A shr 4, W6A0C shr 4 + 1].Solid <> 0 then
                W6A0A := W6A0A + 3
              else
                W6A0A := W6A0A - 3;
              PX := $28;
              PY := $18;
            end;
        B6A06 := 1;
        W6A08 := $13;
        B69DA := 1;
        if (B6EF1 = 1) or (Slots[1].W14 = 1) then
          Slots[1].W14 := 9
        else
          Slots[1].W14 := $A;
        B6EE9 := 0;
        B6EEA := 0;
        B6EF0 := 0;
        B6EF1 := 0;
        B6EE7 := 0;
      end;
    end;
    $139:
    begin
      Score := Score + $FA;
      Spawn(X and $FFF0, Y and $FFF0, $12);
      W6858 := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(5);
      W69CA := 4;
      W69CC := $D8;
    end;
    $143..$145:
    begin
      Score := Score + $64;
      W6858 := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      Map[X shr 4 + 1, Y shr 4 + 1].FlagB := 0;
      PlaySound(4);
    end;
    $142:
    begin
      Score := Score + $3E8;
      W6858 := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(5);
      B685C := 2;
      W69CE := $1B0;
    end;
    $31:
    begin
      Score := Score + $64;
      W6858 := -1;
      Inc(W69C6);
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(5);
    end;
    $13A:
    begin
      Score := Score + $1388;
      W6858 := -1;
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
      B69D3 := 1;
      B6EF0 := 0;
      B6EF1 := 0;
      W69D0 := $D8;
      ShowMessage('YOU FEEL A BIT CONFUSED!');
    end;
    $1D4:
    begin
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound($1B);
      B69D6 := 1;
      W69D4 := $D8;
    end;
    $269:
    begin
      W6858 := -1;
      Map[X shr 4 + 1, Y shr 4 + 1].Front := 0;
      PlaySound(5);
      Inc(W69C4);
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
