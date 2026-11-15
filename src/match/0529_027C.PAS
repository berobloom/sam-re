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
