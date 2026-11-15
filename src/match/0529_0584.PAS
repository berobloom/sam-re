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
      Slots[I].W00 := 0;
      if T <> $89 then
        Slots[I].X := X and $FFF8
      else
        Slots[I].X := X;
      Slots[I].Y := Y;
      Slots[I].PrevX := X;
      Slots[I].PrevY := Y;
      Slots[I].Speed := A;
      Slots[I].W0C := 0;
      Slots[I].W0E := 0;
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
          Slots[I].W0E := $1E;
        end
        else
          Slots[I].Kind := $E;
      end;
      Done := True;
    end;
  until Done or (I = 25);
end;
{$F-}
