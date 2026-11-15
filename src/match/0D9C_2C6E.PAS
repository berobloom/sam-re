{ src: SAM1RE 0D9C:2C6E (../SAM level-load.md: SetCell, the cell X, Y (0-based) of Map gets its five fields
  and is repainted on both pages ($10 and $1A0, W6866); FrontOnly sets the front tile only. No bounds test) }
{ to: 2E20 }
{ keep: SetCell(0, 0, 0, 0, 0, 0, 0, False); }
{$F+}
procedure SetCell(X, Y, Back, Mid, Front: Integer; Solid, FlagB: Byte; FrontOnly: Boolean);
begin
  if FrontOnly then
  begin
    Map[X + 1, Y + 1].Front := Front;
    W6866 := $10;
    DrawFront(X shl 4, Y shl 4);
    W6866 := $1A0;
    DrawFront(X shl 4, Y shl 4);
    W6866 := $10;
  end
  else
  begin
    Map[X + 1, Y + 1].Back := Back;
    Map[X + 1, Y + 1].Mid := Mid;
    Map[X + 1, Y + 1].Front := Front;
    Map[X + 1, Y + 1].Solid := Solid;
    Map[X + 1, Y + 1].FlagB := FlagB;
    W6866 := $10;
    if Y = $18 then
      DrawSheet(X shl 4, Y shl 4)
    else
      DrawBack(X shl 4, Y shl 4);
    DrawFront(X shl 4, Y shl 4);
    W6866 := $1A0;
    if Y = $18 then
      DrawSheet(X shl 4, Y shl 4)
    else
      DrawBack(X shl 4, Y shl 4);
    DrawFront(X shl 4, Y shl 4);
    W6866 := $10;
  end;
end;
{$F-}
