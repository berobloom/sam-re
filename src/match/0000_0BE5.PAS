{ src: GUESS 0000:0BE5 (the int $1C handler: W6852 counts ticks; every 20th tick the timers W69CC, W69D4 and
  W69D0 run down (each end forces a status repaint, W6858 := -1); then the sound playing (287F) steps one
  note: Sound(note), NoSound every Period notes, and at the -1 end Playing stops) }
{ keep: - }
procedure TimerISR; interrupt;
begin
  Inline($FA);
  Inc(W6852);
  Inc(Tick);
  if Tick = 20 then
  begin
    Tick := 0;
    if W69CC > 0 then
    begin
      Dec(W69CC);
      if W69CC = 0 then
      begin
        W69CA := 0;
        StatusCamX := -1;
      end;
    end;
    if W69D4 > 0 then
    begin
      Dec(W69D4, 2);
      if W69D4 = 0 then
      begin
        B69D6 := 0;
        StatusCamX := -1;
      end;
    end;
    if W69D0 > 0 then
    begin
      Dec(W69D0, 2);
      if W69D0 = 0 then
      begin
        B69D2 := 1;
        B69D3 := 0;
        StatusCamX := -1;
      end;
    end;
  end;
  if Playing and SoundOn then
    case CurSound of
    1..12:
      begin
        Sound(Bank1^[CurSound].Notes[NoteIdx]);
        Inc(NoteIdx);
        if NoteIdx mod Bank1^[CurSound].Period = 0 then
          NoSound;
        if Bank1^[CurSound].Notes[NoteIdx] = -1 then
        begin
          Playing := False;
          NoteIdx := 1;
          NoSound;
        end;
      end;
    13..24:
      begin
        Sound(Bank2^[CurSound - 12].Notes[NoteIdx]);
        Inc(NoteIdx);
        if NoteIdx mod Bank2^[CurSound - 12].Period = 0 then
          NoSound;
        if Bank2^[CurSound - 12].Notes[NoteIdx] = -1 then
        begin
          Playing := False;
          NoteIdx := 1;
          NoSound;
        end;
      end;
    25..36:
      begin
        Sound(Bank3^[CurSound - 24].Notes[NoteIdx]);
        Inc(NoteIdx);
        if NoteIdx mod Bank3^[CurSound - 24].Period = 0 then
          NoSound;
        if Bank3^[CurSound - 24].Notes[NoteIdx] = -1 then
        begin
          Playing := False;
          NoteIdx := 1;
          NoSound;
        end;
      end;
    end;
  Inline($FB);
end;
