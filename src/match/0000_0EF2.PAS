{ src: GUESS 0000:0EF2 (writes SAM1.CFG: the sound switch and keys go into Config, then the record) }
{ from: 0EE9 }
{ to: 0F6C }
{$I-}
{$F+}
procedure SaveConfig;
var
  F: file of TConfig;
begin
  Config.Sound := SoundOn;
  Config.KUp := KeyUp;
  Config.KDown := KeyDown;
  Config.KLeft := KeyLeft;
  Config.KRight := KeyRight;
  Config.KJump := KeyJump;
  Config.KFire := KeyFire;
  Config.K70EC := W70EC;
  Config.K70EE := W70EE;
  Assign(F, 'SAM1.CFG');
  Rewrite(F);
  Write(F, Config);
  Close(F);
end;
{$F-}
{$I+}
