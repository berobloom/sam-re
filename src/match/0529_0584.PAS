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
