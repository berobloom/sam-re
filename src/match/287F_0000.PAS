{ src: SAM1RE 287F:0000 (../SAM formats.md SND: priority-gated sound request). Both priority lookups
  store into NewPri; CurPri is never set (the bytes: both write [bp-2], the compare reads [bp-4]) }
{ interface }
{ keep: PlaySound(1); }
procedure PlaySound(Id: Integer);
var
  NewPri, CurPri: Integer;
begin
  if Playing then
  begin
    case Id of
      1..12: NewPri := Bank1^[Id].Priority;
      13..24: NewPri := Bank2^[Id - 12].Priority;
      25..36: NewPri := Bank3^[Id - 24].Priority;
    end;
    case CurSound of
      1..12: NewPri := Bank1^[CurSound].Priority;
      13..24: NewPri := Bank2^[CurSound - 12].Priority;
      25..36: NewPri := Bank3^[CurSound - 24].Priority;
    end;
    if NewPri >= CurPri then
    begin
      NoteIdx := 1;
      Playing := True;
      CurSound := Id;
    end;
  end
  else
  begin
    NoteIdx := 1;
    Playing := True;
    CurSound := Id;
  end;
end;
