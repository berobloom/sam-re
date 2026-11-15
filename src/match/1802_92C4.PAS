{ src: SAM1RE 1802:92C4 (../SAM menus.md: the title menu; N, Space and Enter start a game ('B'); a failed
  restore returns ' '; Escape returns ' ' too) }
{ from: 91F2 }
{ to: 963C }
{ keep: if MainMenu = ' ' then; }
{$F+}
function MainMenu: Char;
var
  I: Integer;
begin
  I := 0;
  ClearText;
  Inc(I);
  TextLines[I] := '     MAIN MENU';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := ' N)ew Game';
  Inc(I);
  TextLines[I] := ' R)estore Old Game';
  Inc(I);
  TextLines[I] := ' S)tory';
  Inc(I);
  TextLines[I] := ' I)nstructions';
  Inc(I);
  TextLines[I] := ' H)igh Scores';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := ' O)rdering Info.';
  Inc(I);
  TextLines[I] := ' F)oreign Orders';
  Inc(I);
  TextLines[I] := ' C)all Our BBS';
  Inc(I);
  TextLines[I] := ' V)ideo Support';
  Inc(I);
  TextLines[I] := ' A)bout Apogee';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := ' Q)uit to DOS';
  Inc(I);
  TextLines[I] := '';
  Inc(I);
  TextLines[I] := 'Make a selection: ^';
  Inc(I);
  TextLines[I] := 'END OF WINDOW';
  B6820[1] := $31;
  B6820[2] := $17;
  B6820[3] := $23;
  B6820[4] := $13;
  B6820[5] := $1F;
  B6820[6] := $18;
  B6820[7] := $10;
  B6820[8] := $01;
  B6820[9] := $39;
  B6820[10] := $1C;
  B6820[11] := $21;
  B6820[12] := $1E;
  B6820[13] := $2E;
  B6820[14] := $2F;
  W683A := Ord(TextWindow(False));
  case W683A of
    $31, $39, $1C:
      begin
        MainMenu := 'B';
        B6EED := 0;
        W69C4 := 1;
      end;
    $17:
      begin
        ShowHelp;
        MainMenu := 'I';
      end;
    $21:
      begin
        ForeignOrders;
        MainMenu := 'F';
      end;
    $2E:
      begin
        ApogeeBBS;
        MainMenu := 'A';
      end;
    $23:
      begin
        MainMenu := 'H';
        HallOfFame;
      end;
    $1E:
      begin
        MainMenu := 'A';
        AboutApogee;
      end;
    $2F:
      begin
        MainMenu := 'V';
        AskAltVideo;
      end;
    $13:
      begin
        MainMenu := 'R';
        W69C4 := 1;
        W6D86 := RestoreMenu;
        if W6D86 = $1C then
        begin
          W6D86 := 0;
          MainMenu := ' ';
        end
        else
          B6EED := 0;
      end;
    $1F:
      begin
        MainMenu := 'S';
        Story;
      end;
    $18:
      begin
        MainMenu := 'O';
        OrderSeries;
      end;
    $10:
      begin
        AskQuit;
        if B6EEC <> 0 then
          MainMenu := 'Q'
        else
          MainMenu := ' ';
      end;
    1:
      begin
        B6EEB := 0;
        MainMenu := ' ';
      end;
  end;
end;
{$F-}
