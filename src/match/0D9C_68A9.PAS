{ src: SAM1RE 0D9C:68A9 (../SAM level-load.md: the row parser. Row Y of the map from Row's 40 chars: a row
  that starts with '*' keeps its cells (FO), else they are cleared first. For each column: a space is the
  background tile 2; on levels > 1 the char chain sets cells (SetCell) and spawns actors inline (slot
  W6854) or through SpawnActor; then WorldCell, and 'Y' is the player's start: slot 1 there (on the world
  map at the stored State position), the camera centred on it and clamped) }
{ from: 66F9 }
{ keep: - }
{$F+}
procedure ParseRow(Y: Integer; Row: TRow);
var
  I: Integer;
  S: String;
  SI, SY: Integer;
  FO: Boolean;
begin
  if Row[1] <> '*' then
  begin
    FO := False;
    for I := 1 to 40 do
    begin
      Map[I, Y + 1].Back := 0;
      Map[I, Y + 1].Mid := 0;
      Map[I, Y + 1].Front := 0;
      Map[I, Y + 1].Solid := 0;
      Map[I, Y + 1].FlagB := 0;
    end;
  end
  else
    FO := True;
  for I := 0 to $27 do
  begin
    MemW[0:$41C] := MemW[0:$41A];
    S := Row[I + 1];
    if (S = ' ') and not FO then
      SetCell(I, Y, 2, 0, 0, 0, 0, FO);
    if Level > 1 then
    begin
      if S = '1' then
        SetCell(I, Y, 1, 0, 0, 1, 0, FO);
      if S = '2' then
        SetCell(I, Y, 3, 0, 0, 1, 0, FO);
      if S = '3' then
        SetCell(I, Y, 4, 0, 0, 1, 0, FO);
      if S = '5' then
        SetCell(I, Y, 5, 0, 0, 0, 0, FO);
      if S = '6' then
        SetCell(I, Y, 6, 0, 0, 0, 0, FO);
      if S = '7' then
        SetCell(I, Y, 7, 0, 0, 0, 0, FO);
      if S = #30 then
        SetCell(I, Y, 8, 0, 0, 0, 0, FO);
      if S = 'w' then
      begin
        SetCell(I, Y - 1, 2, 0, $B3, 1, 0, FO);
        SetCell(I, Y, 2, 0, $B7, 0, 0, FO);
      end;
      if S = #1 then
        SetCell(I, Y, 2, 0, $26B, 0, 0, FO);
      if S = #2 then
        SetCell(I, Y, 2, $A1, 0, 0, 0, FO);
      if S = #3 then
        SetCell(I, Y, 2, $A2, 0, 0, 0, FO);
      if S = #4 then
        SetCell(I, Y, 2, $9B, 0, 0, 0, FO);
      if S = #6 then
        SetCell(I, Y, 2, $9E, 0, 0, 0, FO);
      if S = #5 then
      begin
        SetCell(I - 1, Y, $9C, 0, 0, 0, 1, FO);
        SetCell(I, Y, $9D, 0, 0, 0, 1, FO);
      end;
      if S = #7 then
        SetCell(I, Y, 2, $AE, 0, 0, 0, FO);
      if S = #8 then
      begin
        SetCell(I - 1, Y, 2, $B5, 0, 0, 1, FO);
        SetCell(I, Y, 2, $B6, 0, 0, 1, FO);
      end;
      if S = #12 then
      begin
        SetCell(I - 1, Y, 2, $B9, 0, 0, 1, FO);
        SetCell(I, Y, 2, $BA, 0, 0, 1, FO);
      end;
      if S = #11 then
        SetCell(I, Y, 2, $B2, 0, 0, 1, FO);
      if S = #14 then
        SetCell(I, Y, 2, $2DD, 0, 0, 0, FO);
      if S = #15 then
        SetCell(I, Y, 2, $2DE, 0, 0, 0, FO);
      if S = #16 then
        SetCell(I, Y, 2, $2DF, 0, 0, 0, FO);
      if S = #17 then
        SetCell(I, Y, 2, $2E1, 0, 0, 0, FO);
      if S = #18 then
        SetCell(I, Y, 2, $2E5, 0, 0, 0, FO);
      if S = #19 then
        SetCell(I, Y, 2, $2E7, 0, 0, 0, FO);
      if S = #20 then
      begin
        SetCell(I, Y - 1, 2, $2E9, 0, 0, 0, FO);
        SetCell(I, Y, 2, $2ED, 0, 0, 0, FO);
      end;
      if S = #21 then
        SetCell(I, Y, 2, $2EA, 0, 0, 0, FO);
      if S = #22 then
        SetCell(I, Y, 2, $2EE, 0, 0, 0, FO);
      if S = #23 then
        SetCell(I, Y, 2, $2A5, 0, 0, 0, FO);
      if S = #24 then
        SetCell(I, Y, 2, $2A6, 0, 0, 0, FO);
      if S = #25 then
      begin
        SetCell(I, Y - 1, 2, $FB, 0, 0, 1, FO);
        SetCell(I, Y, 2, $FF, 0, 0, 0, FO);
      end;
      if S = #27 then
      begin
        SetCell(I - 1, Y - 1, 2, $FC, 0, 0, 1, FO);
        SetCell(I, Y - 1, 2, $FD, 0, 0, 1, FO);
        SetCell(I - 1, Y, 2, $100, 0, 0, 0, FO);
        SetCell(I, Y, 2, $101, 0, 0, 0, FO);
      end;
      if S = #28 then
      begin
        SetCell(I, Y - 1, 2, $FE, 0, 0, 1, FO);
        SetCell(I, Y, 2, $102, 0, 0, 0, FO);
      end;
      if S = '^' then
        SetCell(I, Y, 2, 0, $13A, 0, 0, FO);
      if S = 'K' then
        SetCell(I, Y, 2, 0, $25E, 0, 0, FO);
      if S = 'I' then
        SetCell(I, Y, BackTile, 0, 0, 0, 1, FO);
      if S = #211 then
        SetCell(I, Y, BackTile, 0, -1, 0, 0, FO);
      if S = 'r' then
        SetCell(I, Y, 2, 0, $25F, 0, 0, FO);
      if S = 's' then
        SetCell(I, Y, 2, 0, $12D, 0, 0, FO);
      if S = 'N' then
        SetCell(I, Y, 2, 0, $139, 0, 0, FO);
      if S = 'T' then
        SetCell(I, Y, 2, 0, $13C, 0, 0, FO);
      if S = 'W' then
        SetCell(I, Y, 2, 0, $26A, 0, 0, FO);
      if S = '\' then
        SetCell(I, Y, 2, 0, $26C, 0, 0, FO);
      if S = ']' then
        SetCell(I, Y, 2, 0, $275, 0, 0, FO);
      if S = 'd' then
        SetCell(I, Y, 2, 0, $276, 0, 0, FO);
      if S = 'f' then
        SetCell(I, Y, 2, 0, $277, 0, 0, FO);
      if S = 'h' then
        SetCell(I, Y, 2, 0, $278, 0, 0, FO);
      if S = ':' then
        SetCell(I, Y, 2, 0, $1D2, 0, 0, FO);
      if S = 'H' then
        SetCell(I, Y, 2, 0, $1D4, 0, 0, FO);
      if S = 'M' then
        SetCell(I, Y, 2, 0, $270, 0, 0, FO);
      if S = 'P' then
        SetCell(I, Y, 2, 0, $130, 0, 0, FO);
      if S = 'p' then
      begin
        SetCell(I - 1, Y, 2, $9F, 0, 0, 0, FO);
        SetCell(I, Y, 2, $A0, 0, 0, 0, FO);
      end;
      if S = #139 then
      begin
        SetCell(I - 1, Y, BackTile, $A3, 0, 1, 0, FO);
        SetCell(I, Y, BackTile, $A4, 0, 1, 0, FO);
      end;
      if S = #154 then
      begin
        SetCell(I - 1, Y, BackTile, $A6, 0, 1, 0, FO);
        SetCell(I, Y, BackTile, $A5, 0, 1, 0, FO);
      end;
      if S = #31 then
        SetCell(I, Y, BackTile, $A6, 0, 1, 0, FO);
      if S = #168 then
        SetCell(I, Y, 2, 0, $AF, 0, 0, FO);
      if S = #169 then
        SetCell(I, Y, 2, 0, $B0, 0, 0, FO);
      if S = #170 then
        SetCell(I, Y, 2, 0, $B1, 0, 0, FO);
      if S = #171 then
      begin
        SetCell(I, Y - 1, $C2, 0, 0, 0, 1, FO);
        SetCell(I, Y, $C6, 0, 0, 0, 0, FO);
      end;
      if S = #172 then
        SetCell(I, Y, 2, $C5, 0, 0, 0, FO);
      if S = #173 then
        SetCell(I, Y, $C1, 0, 0, 0, 1, FO);
      if S = #133 then
      begin
        SetCell(I - 3, Y, 2, 0, $DD, 0, 0, FO);
        SetCell(I - 2, Y, 2, 0, $DE, 0, 1, FO);
        SetCell(I - 1, Y, 2, 0, $DF, 0, 0, FO);
        SetCell(I, Y, 2, 0, $E0, 0, 0, FO);
      end;
      if S = #134 then
      begin
        SetCell(I - 2, Y, 2, 0, $E5, 0, 0, FO);
        SetCell(I - 1, Y, 2, 0, $E6, 0, 1, FO);
        SetCell(I, Y, 2, 0, $E7, 0, 0, FO);
      end;
      if S = '+' then
        SetCell(I, Y, 2, 0, $1A5, 0, 0, FO);
      if S = ',' then
        SetCell(I, Y, 2, 0, $1A6, 1, 0, FO);
      if S = '-' then
        SetCell(I, Y, 2, 0, $1A7, 0, 0, FO);
      if S = '.' then
        SetCell(I, Y, 2, 0, $1A8, 1, 0, FO);
      if S = '/' then
        SetCell(I, Y, 2, 0, $1A9, 0, 0, FO);
      if S = '4' then
        SetCell(I, Y, 2, 0, $1AA, 1, 0, FO);
      if S = 'o' then
        SetCell(I, Y, BackTile, $1A1, 0, 1, 0, FO);
      if S = 'i' then
        SetCell(I, Y, $1B9, 0, 0, 0, 0, FO);
      if S = 'j' then
        SetCell(I, Y, BackTile, $1BA, 0, 0, 1, FO);
      if S = 'k' then
        SetCell(I, Y, BackTile, $1BB, 0, 1, 0, FO);
      if S = 'l' then
        SetCell(I, Y, BackTile, $1BC, 0, 0, 1, FO);
      if S = #149 then
        SetCell(I, Y, 2, $1C1, 0, 0, 0, FO);
      if S = '|' then
        SetCell(I, Y, 2, $1A3, 0, 0, 0, FO);
      if S = '~' then
        SetCell(I, Y, 2, $1A4, 0, 0, 0, FO);
      if S = 'm' then
      begin
        SetCell(I, Y, 2, 0, 0, 0, 0, FO);
        Inc(SlotCount);
        DrawTileB(Gfx[4]^.Tile[45], I shl 4, (Y shl 4) + $10);
        DrawTileB(Gfx[4]^.Tile[45], I shl 4, (Y shl 4) + $1A0);
        Slots[SlotCount].W00 := 0;
        Slots[SlotCount].Sprite := $1BD;
        Slots[SlotCount].X := I shl 4;
        Slots[SlotCount].Y := Y shl 4;
        Slots[SlotCount].PrevX := I shl 4;
        Slots[SlotCount].PrevY := Y shl 4;
        if Random(2) > 0 then
          Slots[SlotCount].DirX := 1
        else
          Slots[SlotCount].DirX := -1;
        Slots[SlotCount].DirY := 0;
        Slots[SlotCount].Anim := 1;
        Slots[SlotCount].Speed := 1;
        Slots[SlotCount].W0C := 0;
        Slots[SlotCount].W0E := 0;
        Slots[SlotCount].Kind := $14;
        Slots[SlotCount].Free := 0;
        Slots[SlotCount].Remove := 0;
      end;
      if S = 'a' then
        SetCell(I, Y, $1F4, 0, 0, 1, 0, FO);
      if S = '`' then
        SetCell(I, Y, 2, 0, $1F3, 0, 0, FO);
      if S = '_' then
      begin
        SetCell(I, Y, 2, 0, 0, 0, 0, FO);
        Inc(SlotCount);
        DrawTileB(Gfx[5]^.Tile[45], I shl 4, (Y shl 4) + $10);
        DrawTileB(Gfx[5]^.Tile[45], I shl 4, (Y shl 4) + $1A0);
        Slots[SlotCount].W00 := 0;
        Slots[SlotCount].X := I shl 4;
        Slots[SlotCount].Y := Y shl 4;
        Slots[SlotCount].PrevX := I shl 4;
        Slots[SlotCount].PrevY := Y shl 4;
        if Random(2) > 0 then
          Slots[SlotCount].DirX := 1
        else
          Slots[SlotCount].DirX := -1;
        if Slots[SlotCount].DirX = 1 then
          Slots[SlotCount].Sprite := $1F1
        else
          Slots[SlotCount].Sprite := $1EF;
        Slots[SlotCount].DirY := 0;
        Slots[SlotCount].Anim := 1;
        Slots[SlotCount].Speed := 1;
        Slots[SlotCount].W0C := 0;
        Slots[SlotCount].W0E := 0;
        Slots[SlotCount].Kind := $15;
        Slots[SlotCount].Free := 0;
        Slots[SlotCount].Remove := 0;
      end;
      if S = 'D' then
        SetCell(I, Y, 2, 0, $265, 0, 0, FO);
      if S = 'E' then
        SetCell(I, Y, BackTile, 0, $266, 0, 1, FO);
      if S = 'O' then
        SetCell(I, Y, 2, 0, $267, 0, 0, FO);
      if S = 'U' then
        SetCell(I, Y, 2, 0, $268, 0, 0, FO);
      if S = #128 then
        SetCell(I, Y, 2, 0, $259, 0, 0, FO);
      if S = #129 then
        SetCell(I, Y, 2, 0, $25A, 0, 0, FO);
      if S = #130 then
        SetCell(I, Y, 2, 0, $25B, 0, 0, FO);
      if S = #131 then
        SetCell(I, Y, 2, 0, $25C, 0, 0, FO);
      if S = #132 then
        SetCell(I, Y, 2, 0, $25D, 0, 0, FO);
      if S = #140 then
        SetCell(I, Y, 2, 0, $26D, 0, 0, FO);
      if S = #141 then
        SetCell(I, Y, 2, 0, $26E, 0, 0, FO);
      if S = #142 then
        SetCell(I, Y, 2, 0, $26F, 0, 0, FO);
      if S = '%' then
      begin
        SetCell(I - 1, Y, 2, 0, $1C4, 0, 0, FO);
        SetCell(I, Y, 2, 0, $1C5, 0, 0, FO);
      end;
      if S = '&' then
      begin
        SetCell(I - 1, Y - 1, $1C7, 0, 0, 1, 0, FO);
        SetCell(I, Y - 1, $1C8, 0, 0, 1, 0, FO);
        SetCell(I - 1, Y, $1CB, 0, 0, 1, 0, FO);
        SetCell(I, Y, $1CC, 0, 0, 1, 0, FO);
      end;
      if S = '(' then
      begin
        SetCell(I - 1, Y - 1, $1C9, 0, 0, 1, 0, FO);
        SetCell(I, Y - 1, $1CA, 0, 0, 1, 0, FO);
        SetCell(I - 1, Y, $1CD, 0, 0, 1, 0, FO);
        SetCell(I, Y, $1CE, 0, 0, 1, 0, FO);
      end;
      if S = ')' then
        SetCell(I, Y, 2, 0, $1CF, 0, 0, FO);
      if S = '*' then
        if I > 0 then
          SetCell(I, Y, 2, 0, $1D3, 0, 0, FO);
      if S = 'q' then
      begin
        SetCell(I, Y - 1, 2, 0, $279, 1, 0, FO);
        SetCell(I, Y, 2, 0, $27D, 1, 0, FO);
      end;
      if S = 't' then
        SetCell(I, Y, 2, 0, $27B, 0, 0, FO);
      SpawnActor(I, Y, S, FO);
      if S = #175 then
        SetCell(I, Y, $15D, 0, 0, 0, 0, FO);
      if S = #143 then
        SetCell(I, Y, BackTile, $28B, 0, 1, 0, FO);
      if S = #144 then
        SetCell(I, Y, $28C, 0, 0, 1, 0, FO);
      if S = #145 then
        SetCell(I, Y, BackTile, $28D, 0, 1, 0, FO);
      if S = #146 then
        SetCell(I, Y, BackTile, $28E, 0, 0, 1, FO);
      if S = #147 then
        SetCell(I, Y, $28F, 0, 0, 1, 0, FO);
      if S = #148 then
        SetCell(I, Y, $290, 0, 0, 1, 0, FO);
      if S = #150 then
        SetCell(I, Y, 2, 0, $292, 0, 0, FO);
      if S = #151 then
        SetCell(I, Y, 2, 0, $293, 0, 0, FO);
      if S = #152 then
        SetCell(I, Y, 2, 0, $294, 0, 0, FO);
      if S = #153 then
        SetCell(I, Y, $295, 0, 0, 0, 0, FO);
      if S = #155 then
        SetCell(I, Y, 2, 0, $297, 0, 0, FO);
      if S = #156 then
        SetCell(I, Y, 2, 0, $298, 0, 0, FO);
      if S = #157 then
        SetCell(I, Y, 2, $299, 0, 0, 0, FO);
      if S = #158 then
        SetCell(I, Y, 2, $29A, 0, 0, 0, FO);
      if S = #163 then
        SetCell(I, Y, BackTile, $29F, 0, 0, 1, FO);
      if S = #164 then
        SetCell(I, Y, BackTile, $2A0, 0, 0, 1, FO);
      if S = #165 then
        SetCell(I, Y, BackTile, $2A1, 0, 0, 1, FO);
      if S = #166 then
        SetCell(I, Y, BackTile, $2A2, 0, 0, 1, FO);
      if S = #176 then
        SetCell(I, Y, 2, 0, $2AC, 0, 0, FO);
      if S = #177 then
        SetCell(I, Y, 2, 0, $2AD, 0, 0, FO);
      if S = #178 then
        SetCell(I, Y, 2, 0, $2AE, 0, 0, FO);
      if S = #179 then
        SetCell(I, Y, 2, 0, $2AF, 0, 0, FO);
      if S = #180 then
        SetCell(I, Y, 2, 0, $2B0, 0, 0, FO);
      if S = #181 then
        SetCell(I, Y, 2, 0, $2B1, 0, 0, FO);
      if S = #183 then
        SetCell(I, Y, 2, 0, $2B3, 0, 0, FO);
      if S = #184 then
        SetCell(I, Y, 2, 0, $2B4, 0, 0, FO);
      if S = #185 then
        SetCell(I, Y, 2, 0, $2B5, 0, 0, FO);
      if S = #186 then
      begin
        SetCell(I - 1, Y, $2B2, 0, 0, 0, 1, FO);
        SetCell(I, Y, $2B6, 0, 0, 0, 1, FO);
      end;
      if S = #187 then
        SetCell(I, Y, $2B7, 0, 0, 0, 0, FO);
      if S = #188 then
        SetCell(I, Y, $2BA, 0, 0, 0, 0, FO);
      if S = #189 then
        SetCell(I, Y, $2B8, 0, 0, 0, 0, FO);
      if S = #190 then
        SetCell(I, Y, $2B9, 0, 0, 0, 0, FO);
      if S = #191 then
      begin
        SetCell(I - 1, Y, $2A7, 0, 0, 0, 1, FO);
        SetCell(I, Y, $2A8, 0, 0, 0, 1, FO);
      end;
      if S = 'y' then
      begin
        SetCell(I - 1, Y, $13E, 0, 0, 0, 1, FO);
        SetCell(I, Y, $13F, 0, 0, 0, 1, FO);
      end;
      if S = 'z' then
        SetCell(I, Y, 2, $13D, 0, 0, 0, FO);
      if S = #135 then
      begin
        SetCell(I - 1, Y, $143, 0, 0, 0, 1, FO);
        SetCell(I, Y, $144, 0, 0, 0, 1, FO);
      end;
      if S = #182 then
        SetCell(I, Y, 2, $2A9, 0, 0, 0, FO);
      if S = #192 then
      begin
        SetCell(I - 1, Y, $2BB, 0, 0, 0, 1, FO);
        SetCell(I, Y, $2BC, 0, 0, 0, 1, FO);
      end;
      if S = #136 then
        SetCell(I, Y, 2, $159, 0, 0, 0, FO);
      if S = #137 then
        SetCell(I, Y, 2, $15A, 0, 0, 0, FO);
      if S = #138 then
        SetCell(I, Y, 2, $15B, 0, 0, 0, FO);
      if S = #162 then
        SetCell(I, Y, 2, $15C, 0, 0, 1, FO);
      if S = #193 then
        SetCell(I, Y, $2BD, 0, 0, 1, 0, FO);
      if S = #194 then
        SetCell(I, Y, $2BE, 0, 0, 1, 0, FO);
      if S = #195 then
        SetCell(I, Y, $2BF, 0, 0, 1, 0, FO);
      if S = #196 then
        SetCell(I, Y, $2C0, 0, 0, 1, 0, FO);
      if S = #197 then
        SetCell(I, Y, $2C1, 0, 0, 1, 0, FO);
      if S = #198 then
        SetCell(I, Y, $2C2, 0, 0, 1, 0, FO);
      if S = #199 then
        SetCell(I, Y, $2C3, 0, 0, 1, 0, FO);
      if S = #200 then
        SetCell(I, Y, $2C4, 0, 0, 1, 0, FO);
      if S = #201 then
        SetCell(I, Y, $2C5, 0, 0, 1, 0, FO);
      if S = #202 then
        SetCell(I, Y, 2, 0, $2C6, 0, 0, FO);
      if S = #203 then
        SetCell(I, Y, BackTile, 0, $2C7, 0, 1, FO);
      if S = #204 then
        SetCell(I, Y, BackTile, 0, $2C8, 0, 1, FO);
      if S = #205 then
        SetCell(I, Y, BackTile, 0, $2C9, 0, 1, FO);
      if S = #206 then
        SetCell(I, Y, 2, 0, $2CA, 0, 0, FO);
      if S = #207 then
        SetCell(I, Y, 2, 0, $2CB, 0, 0, FO);
      if S = #208 then
        SetCell(I, Y, 2, 0, $2CC, 0, 0, FO);
      if S = #209 then
      begin
        SetCell(I, Y, 2, 0, 0, 0, 0, FO);
        Inc(SlotCount);
        DrawTileB(Gfx[16]^.Tile[1], I shl 4, (Y shl 4) + $10);
        DrawTileB(Gfx[16]^.Tile[1], I shl 4, (Y shl 4) + $1A0);
        Slots[SlotCount].W00 := 0;
        Slots[SlotCount].Sprite := $2CD;
        Slots[SlotCount].X := I shl 4;
        Slots[SlotCount].Y := Y shl 4;
        Slots[SlotCount].PrevX := I shl 4;
        Slots[SlotCount].PrevY := Y shl 4;
        Slots[SlotCount].DirX := 1;
        Slots[SlotCount].DirY := 0;
        Slots[SlotCount].Anim := 1;
        Slots[SlotCount].Speed := 0;
        Slots[SlotCount].W0C := 0;
        Slots[SlotCount].W0E := 0;
        Slots[SlotCount].Kind := $1A;
        Slots[SlotCount].Free := 0;
        Slots[SlotCount].Remove := 0;
      end;
      if S = #210 then
      begin
        SetCell(I - 1, Y - 1, $BF, 0, 0, 0, 1, FO);
        SetCell(I, Y - 1, $C0, 0, 0, 0, 1, FO);
        SetCell(I - 1, Y, $C3, 0, 0, 0, 0, FO);
        SetCell(I, Y, $C4, 0, 0, 0, 0, FO);
      end;
      if S = #213 then
        SetCell(I, Y, BackTile, $2D1, 0, 0, 1, FO);
      if S = #214 then
        SetCell(I, Y, BackTile, $2D2, 0, 0, 1, FO);
      if S = #215 then
        SetCell(I, Y, BackTile, $2D3, 0, 0, 1, FO);
      if S = #217 then
        SetCell(I, Y, 2, $2D5, 0, 0, 0, FO);
      if S = #218 then
        SetCell(I, Y, BackTile, $2D6, 0, 0, 1, FO);
      if S = #219 then
        SetCell(I, Y, BackTile, $2D7, 0, 0, 1, FO);
      if S = #220 then
        SetCell(I, Y, BackTile, $2D8, 0, 0, 1, FO);
      if S = #221 then
        SetCell(I, Y, 2, $2D9, 0, 0, 0, FO);
      if S = #222 then
        SetCell(I, Y, BackTile, $2DA, 0, 0, 1, FO);
      if S = #223 then
        SetCell(I, Y, $C9, 0, 0, 0, 1, FO);
      if S = #224 then
        SetCell(I, Y, $CA, 0, 0, 0, 1, FO);
      if S = #225 then
        SetCell(I, Y, $CB, 0, 0, 0, 1, FO);
      if S = #226 then
        SetCell(I, Y, $CD, 0, 0, 0, 0, FO);
      if S = #227 then
        SetCell(I, Y, $CE, 0, 0, 0, 0, FO);
      if S = #228 then
        SetCell(I, Y, $CF, 0, 0, 0, 0, FO);
      if S = '!' then
        SetCell(I, Y, $2EF, 0, 0, 0, 0, FO);
      if S = 'B' then
        SetCell(I, Y, BackTile, $2F1, 0, 0, 1, FO);
      if S = 'C' then
        SetCell(I, Y, $2F3, 0, 0, 1, 0, FO);
      if S = 'F' then
        SetCell(I, Y, BackTile, $2F4, 0, 1, 0, FO);
      if S = 'J' then
        SetCell(I, Y, BackTile, $2F5, 0, 1, 0, FO);
      if S = #229 then
        SetCell(I, Y, $2F6, 0, 0, 1, 0, FO);
      if S = #230 then
        SetCell(I, Y, 2, 0, $2F7, 0, 0, FO);
      if S = #231 then
        SetCell(I, Y, 2, 0, $2F8, 0, 0, FO);
      if S = #232 then
        SetCell(I, Y, 2, 0, $2F9, 0, 0, FO);
      if S = #233 then
        SetCell(I, Y, 2, 0, $2FA, 0, 0, FO);
      if S = #234 then
        SetCell(I, Y, 2, 0, $2FB, 0, 0, FO);
      if S = #235 then
        SetCell(I, Y, 2, 0, $2FC, 0, 0, FO);
      if S = #236 then
        SetCell(I, Y, 2, 0, $2FD, 0, 0, FO);
      if S = #237 then
      begin
        SetCell(I - 1, Y, $C7, 0, 0, 0, 1, FO);
        SetCell(I, Y, $C8, 0, 0, 0, 1, FO);
      end;
      if S = #216 then
      begin
        SetCell(I - 1, Y, $10C, 0, 0, 0, 1, FO);
        SetCell(I, Y, $10D, 0, 0, 0, 1, FO);
      end;
      if S = #238 then
      begin
        SetCell(I - 2, Y, 2, $108, 0, 0, 1, FO);
        SetCell(I - 1, Y, 2, $109, 0, 0, 1, FO);
        SetCell(I, Y, 2, $10A, 0, 0, 1, FO);
      end;
      if S = #239 then
      begin
        SetCell(I, Y - 1, 2, $107, 0, 0, 1, FO);
        SetCell(I, Y, 2, $10B, 0, 0, 0, FO);
      end;
      if S = #241 then
        SetCell(I, Y, $307, 0, 0, 1, 0, FO);
      if S = #242 then
        SetCell(I, Y, $308, 0, 0, 1, 0, FO);
      if S = #243 then
        SetCell(I, Y, $309, 0, 0, 1, 0, FO);
      if S = #244 then
        SetCell(I, Y, $30A, 0, 0, 1, 0, FO);
      if S = #245 then
        SetCell(I, Y, $30B, 0, 0, 1, 0, FO);
      if S = #246 then
        SetCell(I, Y, $30C, 0, 0, 1, 0, FO);
      if S = #247 then
        SetCell(I, Y, $30D, 0, 0, 1, 0, FO);
      if S = #248 then
        SetCell(I, Y, $30E, 0, 0, 1, 0, FO);
      if S = #249 then
        SetCell(I, Y, $30F, 0, 0, 1, 0, FO);
      if S = #250 then
        SetCell(I, Y, $310, 0, 0, 1, 0, FO);
      if S = #251 then
        SetCell(I, Y, $311, 0, 0, 1, 0, FO);
      if S = #252 then
        SetCell(I, Y, $312, 0, 0, 1, 0, FO);
      if S = #253 then
        SetCell(I, Y, BackTile, $313, 0, 1, 0, FO);
      if S = #254 then
        SetCell(I, Y, $314, 0, 0, 1, 0, FO);
      if S = 'L' then
        SetCell(I, Y, BackTile, $315, 0, 1, 0, FO);
      if S = #159 then
        SetCell(I, Y, BackTile, $317, 0, 1, 0, FO);
      if S = #160 then
        SetCell(I, Y, $318, 0, 0, 1, 0, FO);
      if S = #161 then
        SetCell(I, Y, BackTile, $319, 0, 1, 0, FO);
      if S = 'S' then
        SetCell(I, Y, 2, 0, $316, 0, 0, FO);
      if S = 'Z' then
      begin
        SetCell(I - 1, Y - 1, 2, $31B, 0, 0, 1, FO);
        SetCell(I, Y - 1, 2, $31C, 0, 0, 1, FO);
        SetCell(I - 1, Y, 2, $31F, 0, 0, 0, FO);
        SetCell(I, Y, 2, $320, 0, 0, 0, FO);
      end;
      if S = #167 then
      begin
        SetCell(I, Y, 2, 0, 0, 0, 0, FO);
        Inc(SlotCount);
        DrawTileB(Gfx[7]^.Tile[25], I shl 4, (Y shl 4) + $10);
        DrawTileB(Gfx[7]^.Tile[25], I shl 4, (Y shl 4) + $1A0);
        Slots[SlotCount].W00 := 0;
        Slots[SlotCount].Sprite := $2A3;
        Slots[SlotCount].X := I shl 4;
        Slots[SlotCount].Y := Y shl 4;
        Slots[SlotCount].PrevX := I shl 4;
        Slots[SlotCount].PrevY := Y shl 4;
        Slots[SlotCount].DirX := 1;
        Slots[SlotCount].DirY := 0;
        Slots[SlotCount].Anim := 1;
        Slots[SlotCount].Speed := 0;
        Slots[SlotCount].W0C := 0;
        Slots[SlotCount].W0E := 0;
        Slots[SlotCount].Kind := $1B;
        Slots[SlotCount].Free := 0;
        Slots[SlotCount].Remove := 0;
      end;
      if S = 'b' then
      begin
        SetCell(I, Y, 2, 0, 0, 0, 0, FO);
        Inc(SlotCount);
        DrawTileB(Gfx[7]^.Tile[26], I shl 4, (Y shl 4) + $10);
        DrawTileB(Gfx[7]^.Tile[26], I shl 4, (Y shl 4) + $1A0);
        Slots[SlotCount].W00 := 0;
        Slots[SlotCount].Sprite := $2A4;
        Slots[SlotCount].X := I shl 4;
        Slots[SlotCount].Y := Y shl 4;
        Slots[SlotCount].PrevX := I shl 4;
        Slots[SlotCount].PrevY := Y shl 4;
        if Random(2) > 0 then
          Slots[SlotCount].DirX := 1
        else
          Slots[SlotCount].DirX := -1;
        Slots[SlotCount].DirY := 0;
        Slots[SlotCount].Anim := 1;
        Slots[SlotCount].Speed := 2;
        Slots[SlotCount].W0C := 0;
        Slots[SlotCount].W0E := 0;
        Slots[SlotCount].Kind := $1C;
        Slots[SlotCount].Free := 0;
        Slots[SlotCount].Remove := 0;
      end;
    end;
    WorldCell(I, Y, S);
    if S = 'Y' then
    begin
      SetCell(I, Y, 2, 0, 0, 0, 0, FO);
      SI := I;
      SY := Y;
      if (State.X <> 0) and (Level = 1) then
      begin
        I := State.X shr 4;
        Y := State.Y shr 4;
      end;
      DrawTileB(Gfx[3]^.Tile[1], I shl 4, (Y shl 4) + $10);
      DrawTileB(Gfx[3]^.Tile[1], I shl 4, (Y shl 4) + $1A0);
      Slots[1].W00 := 0;
      Slots[1].Sprite := 9;
      Slots[1].X := I shl 4;
      Slots[1].Y := Y shl 4;
      Slots[1].PrevX := I shl 4;
      Slots[1].PrevY := Y shl 4;
      Slots[1].DirX := 1;
      Slots[1].DirY := 0;
      Slots[1].Anim := 1;
      Slots[1].Speed := 2;
      Slots[1].W0C := 0;
      Slots[1].Kind := $63;
      Slots[1].Free := 0;
      Slots[1].Remove := 0;
      CamX := (I shl 4) - $A0;
      if CamX < 0 then
        CamX := 0;
      if CamX > $140 then
        CamX := $140;
      CamY := (Y shl 4) - $64;
      if CamY < 0 then
        CamY := 0;
      if CamY > $B8 then
        CamY := $B8;
      if AltVideo = 0 then
        SetViewStart(CamX, CamY + $10)
      else
        SetViewStartAlt(CamX, CamY + $10);
      I := SI;
      Y := SY;
    end;
  end;
end;
{$F-}
