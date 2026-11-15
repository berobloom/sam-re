unit U287F;
{$S-,D+,L+}
interface
{ 287F data, DS:3444..34D5 (src: SAM1RE formats.md SND; the start-up code 0:1250..0:134b loads the
  three .SND files through SndFile, one TSoundBank record each, 0x1C98 bytes = 12 slots) }
type
  TSound = record
    Notes: array[1..300] of Integer;
    Priority: Integer;
    Unk1: Integer;
    Period: Integer;
    Unk2: Integer;
    Unk3: Integer;
  end;
  TSoundBank = array[1..12] of TSound;
var
  Bank1, Bank2, Bank3: ^TSoundBank;
  SndFile: file of TSoundBank;  { Reset passes $1C98; Read is the typed-file Read (main 0000:1250) }
  CurSound: Integer;
  NoteIdx: Integer;
  Playing: Boolean;
  SoundOn: Boolean;
procedure PlaySound(Id: Integer);
implementation
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
begin
{ init }
end.
