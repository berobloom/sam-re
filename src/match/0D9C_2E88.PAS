{ src: SAM1RE 0D9C:2E88 (../SAM level-load.md: the world-map cell of row char S at cell X, Y. B6868 := exactly
  15 of the 16 site counters done; on the world map (Level 1) each char gives its SetCell; the site markers
  M N O P show done or undone by SiteDone[W685A + 2], and 'l' by B6868) }
{ from: 2E20 }
{ to: 3A59 }
{ keep: - }
{$F+}
procedure WorldCell(X, Y: Integer; S: String);
var
  I, N: Integer;
  FO: Boolean;
begin
  AllDone := 0;
  FO := False;
  N := 0;
  for I := 2 to $11 do
    if SiteDone[I] = 1 then
      Inc(N);
  if N = 15 then
    AllDone := 1;
  if Level = 1 then
  begin
    if S = 'A' then
      SetCell(X, Y, $1F5, 0, 0, 0, 0, FO);
    if S = 'B' then
      SetCell(X, Y, $1F6, 0, 0, 1, 0, FO);
    if S = 'C' then
      SetCell(X, Y, $1F7, 0, 0, 1, 0, FO);
    if S = 'D' then
      SetCell(X, Y, $1F8, 0, 0, 1, 0, FO);
    if S = 'E' then
      SetCell(X, Y, $1F9, 0, 0, 1, 0, FO);
    if S = 'F' then
      SetCell(X, Y, $1FA, 0, 0, 1, 0, FO);
    if S = 'G' then
      SetCell(X, Y, $1FB, 0, 0, 1, 0, FO);
    if S = 'H' then
      SetCell(X, Y, BackTile, 0, 0, 0, 0, FO);
    if S = 'I' then
      SetCell(X, Y, BackTile, 0, 0, 0, 0, FO);
    if S = 'J' then
      SetCell(X, Y, $295, 0, 0, 0, 0, FO);
    if S = 'K' then
      SetCell(X, Y, BackTile, 0, 0, 0, 0, FO);
    if S = 'L' then
      SetCell(X, Y, BackTile, 0, 0, 0, 0, FO);
    if S = 'M' then
      if SiteDone[SiteCounter + 2] <> 0 then
        SetCell(X, Y, SiteCounter + 2, 0, $205, 0, 0, FO)
      else
        SetCell(X, Y, SiteCounter + 2, 0, $201, 0, 0, FO);
    if S = 'N' then
    begin
      if SiteDone[SiteCounter + 2] <> 0 then
        SetCell(X, Y, SiteCounter + 2, 0, $206, 0, 0, FO)
      else
        SetCell(X, Y, SiteCounter + 2, 0, $202, 0, 0, FO);
      Inc(SiteCounter);
    end;
    if S = 'O' then
    begin
      if SiteDone[SiteCounter + 2] <> 0 then
        SetCell(X, Y, SiteCounter + 2, 0, $207, 0, 0, FO)
      else
        SetCell(X, Y, SiteCounter + 2, 0, $203, 0, 0, FO);
      Inc(SiteCounter);
    end;
    if S = 'P' then
    begin
      if SiteDone[SiteCounter + 2] <> 0 then
        SetCell(X, Y, SiteCounter + 2, 0, $208, 0, 0, FO)
      else
        SetCell(X, Y, SiteCounter + 2, 0, $204, 0, 0, FO);
      Inc(SiteCounter);
    end;
    if S = 'Q' then
      SetCell(X, Y, $205, 0, 0, 0, 0, FO);
    if S = 'R' then
      SetCell(X, Y, $206, 0, 0, 0, 0, FO);
    if S = 'S' then
      SetCell(X, Y, $207, 0, 0, 0, 0, FO);
    if S = 'T' then
      SetCell(X, Y, $208, 0, 0, 0, 0, FO);
    if S = 'U' then
      SetCell(X, Y, $209, 0, 0, 1, 0, FO);
    if S = 'V' then
      SetCell(X, Y, $20A, 0, 0, 0, 0, FO);
    if S = 'W' then
      SetCell(X, Y, $20B, 0, 0, 0, 0, FO);
    if S = 'X' then
      SetCell(X, Y, $20C, 0, 0, 0, 0, FO);
    if S = '0' then
      SetCell(X, Y, $20D, 0, 0, 0, 0, FO);
    if S = 'Z' then
      SetCell(X, Y, $20E, 0, 0, 0, 0, FO);
    if S = 'a' then
      SetCell(X, Y, $20F, 0, 0, 1, 0, FO);
    if S = 'b' then
      SetCell(X, Y, $210, 0, 0, 0, 0, FO);
    if S = 'c' then
      SetCell(X, Y, $211, 0, 0, 0, 0, FO);
    if S = 'd' then
      SetCell(X, Y, $212, 0, 0, 0, 0, FO);
    if S = 'e' then
      SetCell(X, Y, $213, 0, 0, 0, 0, FO);
    if S = 'f' then
      SetCell(X, Y, $214, 0, 0, 1, 0, FO);
    if S = 'g' then
      SetCell(X, Y, $215, 0, 0, 1, 0, FO);
    if S = 'h' then
      SetCell(X, Y, $216, 0, 0, 0, 0, FO);
    if S = 'i' then
      SetCell(X, Y, $217, 0, 0, 0, 0, FO);
    if S = 'j' then
      SetCell(X, Y, $218, 0, 0, 0, 0, FO);
    if S = 'k' then
      SetCell(X, Y, $219, 0, 0, 0, 0, FO);
    if S = 'l' then
      if AllDone = 0 then
        SetCell(X, Y, $1FC, 0, 0, 1, 0, FO)
      else
        SetCell(X, Y, BackTile, 0, 0, 0, 0, FO);
    if S = 'm' then
      SetCell(X, Y, BackTile, 0, $299, 0, 0, FO);
    if S = 'n' then
      SetCell(X, Y, BackTile, 0, $29A, 0, 0, FO);
    if S = 'o' then
      SetCell(X, Y, BackTile, $29F, 0, 0, 1, FO);
    if S = 'p' then
      SetCell(X, Y, BackTile, $2A0, 0, 0, 1, FO);
    if S = 'q' then
      SetCell(X, Y, BackTile, $2A1, 0, 0, 1, FO);
    if S = 'r' then
      SetCell(X, Y, BackTile, $2A2, 0, 0, 1, FO);
    if S = 's' then
      SetCell(X, Y, $2AB, 0, 0, 0, 0, FO);
    if S = 't' then
      SetCell(X, Y, BackTile, 0, $2AC, 0, 0, FO);
    if S = 'u' then
      SetCell(X, Y, BackTile, 0, $2AD, 0, 0, FO);
    if S = 'v' then
      SetCell(X, Y, BackTile, 0, $2AE, 0, 0, FO);
    if S = 'x' then
      SetCell(X, Y, BackTile, 0, $2B0, 0, 0, FO);
    if S = 'y' then
      SetCell(X, Y, BackTile, 0, $2B1, 0, 0, FO);
    if S = 'z' then
      SetCell(X, Y, $2B2, 0, 0, 0, 0, FO);
    if S = 'w' then
      SetCell(X, Y, BackTile, 0, $2AF, 0, 0, FO);
    if S = 'w' then
    begin
      SetCell(X, Y - 1, 2, 0, $B3, 1, 0, FO);
      SetCell(X, Y, 2, 0, $B7, 0, 0, FO);
    end;
  end;
end;
{$F-}
