{ src: SAM1RE 1802:DB46 (../SAM menus.md: the text-mode order screen of episodes 2 and 3; 20 columns of
  shade bars, a framed title, a framed body, the cursor left on row 24; locals J..L are never used) }
{ from: D8B1 }
{ to: DD4D }
{ interface }
{ keep: OrderScreen; }
procedure OrderScreen;
var
  I, J, K, L: Integer;
begin
  TextMode(3);
  ClrScr;
  GotoXY(1, 1);
  for I := 0 to 19 do
  begin
    WriteVert((I shl 2) + 1, 1, 8, 0, '°°°°°°°°°°°°°°°°°°°°°°°');
    WriteVert((I shl 2) + 2, 1, 7, 0, '°°°°°°°°°°°°°°°°°°°°°°°');
    WriteVert((I shl 2) + 3, 1, 15, 0, '°°°°°°°°°°°°°°°°°°°°°°°');
    WriteVert((I shl 2) + 4, 1, 7, 0, '°°°°°°°°°°°°°°°°°°°°°°°');
  end;
  Window(9, 2, 72, 4, 15, 4, 3);
  WriteCenter(3, 15, 4, ' HOW TO ORDER THE FINAL TWO AMAZING EPISODES OF SECRET AGENT');
  Window(5, 7, 76, 21, 3, 4, 3);
  WriteCenter(8, 14, 4, ' The final two episodes of SECRET AGENT continue your adventure');
  WriteCenter(9, 14, 4, ' as the heroic super spy 006«.  You''ll encounter fun and danger');
  WriteCenter(10, 14, 4, ' on two all-new islands, packed with new graphics and challenges.');
  WriteCenter(12, 14, 4, ' By ordering the final two episodes of SECRET AGENT you''ll get:');
  WriteCenter(13, 14, 4, ' The hints and tricks sheet, the cheat password, and an all-new');
  WriteCenter(14, 14, 4, ' bonus game from Apogee Software for you to try out.');
  WriteCenter(16, 15, 4, ' Apogee Software             CALL TOLL FREE!  ');
  WriteCenter(17, 15, 4, ' P.O. Box 476389              1-800-GAME123   ');
  WriteCenter(18, 15, 4, ' Garland, TX 75047          Visa or MasterCard ');
  WriteCenter(20, 14, 4, ' Or mail $34 (check or money order) to order SECRET AGENT.');
  TextColor(3);
  TextBackground(0);
  GotoXY(1, 24);
end;
