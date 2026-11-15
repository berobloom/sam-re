{ src: GUESS 0000:0BE5 (the int $1C handler: W6852 counts ticks; every 20th tick the timers W69CC, W69D4 and
  W69D0 run down (each end forces a status repaint, W6858 := -1); then the sound playing (287F) steps one
  note: Sound(note), NoSound every Period notes, and at the -1 end Playing stops) }
{ keep: - }
procedure TimerISR; interrupt;
begin
  Inline($FA);
  Inc(Ticks);
  Inc(Tick);
  if Tick = 20 then
  begin
    Tick := 0;
    if SpeedTimer > 0 then
    begin
      Dec(SpeedTimer);
      if SpeedTimer = 0 then
      begin
        SpeedBonus := 0;
        StatusCamX := -1;
      end;
    end;
    if SlowTimer > 0 then
    begin
      Dec(SlowTimer, 2);
      if SlowTimer = 0 then
      begin
        SlowWalk := 0;
        StatusCamX := -1;
      end;
    end;
    if ConfuseTimer > 0 then
    begin
      Dec(ConfuseTimer, 2);
      if ConfuseTimer = 0 then
      begin
        UnconfuseMsg := 1;
        Confused := 0;
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
