{ src: SAM1RE 1802:92C4 (../SAM menus.md: the title menu; N, Space and Enter start a game ('B'); a failed
  restore returns ' '; Escape returns ' ' too) }
{ from: 91F2 }
{ to: 963C }
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
  KeyFilter[1] := $31;
  KeyFilter[2] := $17;
  KeyFilter[3] := $23;
  KeyFilter[4] := $13;
  KeyFilter[5] := $1F;
  KeyFilter[6] := $18;
  KeyFilter[7] := $10;
  KeyFilter[8] := $01;
  KeyFilter[9] := $39;
  KeyFilter[10] := $1C;
  KeyFilter[11] := $21;
  KeyFilter[12] := $1E;
  KeyFilter[13] := $2E;
  KeyFilter[14] := $2F;
  WinKey := Ord(TextWindow(False));
  case WinKey of
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
        SaveSlot := RestoreMenu;
        if SaveSlot = $1C then
        begin
          SaveSlot := 0;
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
        EscHeld := 0;
        MainMenu := ' ';
      end;
  end;
end;
{$F-}
