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
