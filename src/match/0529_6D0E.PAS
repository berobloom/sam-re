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
