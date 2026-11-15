{ src: GUESS 0000:0F75 (reads SAM1.CFG into Config and takes the sound switch and keys from it, the joystick
  when K70EE = 1 and one is present; without the file: sound on, the arrow keys, Ctrl ($1D) jumps, Alt ($38) fires) }
{ from: 0F6C }
{$I-}
{$F+}
procedure LoadConfig;
var
  F: file of TConfig;
  Ok: Boolean;
begin
  Assign(F, 'SAM1.CFG');
  Reset(F);
  Ok := IOResult = 0;
  Reset(F);
  Ok := IOResult = 0;
  if Ok then
  begin
    Read(F, Config);
    Close(F);
    SoundOn := Config.Sound;
    KeyUp := Config.KUp;
    KeyDown := Config.KDown;
    KeyLeft := Config.KLeft;
    KeyRight := Config.KRight;
    KeyJump := Config.KJump;
    KeyFire := Config.KFire;
    AltVideo := Config.K70EC;
    UseJoystick := Config.K70EE;
    if UseJoystick = 1 then
      JoyOn := JoyPresent
    else
      JoyOn := False;
  end
  else
  begin
    SoundOn := True;
    KeyUp := $48;
    KeyDown := $50;
    KeyLeft := $4B;
    KeyRight := $4D;
    KeyJump := $1D;
    KeyFire := $38;
    AltVideo := 0;
    UseJoystick := 0;
    JoyOn := False;
  end;
end;
{$F-}
{$I+}
