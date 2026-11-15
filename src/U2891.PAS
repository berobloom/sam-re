unit U2891;
{$S-,D+,L+}
interface
uses U29C3;
{ 2891 data, DS:34D6..70FF. An "@XXXX" comment pins a declaration's address (gen_scaffold.py fits a pad before it);
  names: SAM1RE (../SAM findings: physics.md, code-map.md) or the address. Grouped names share a line. }
type
  TTile = array[1..160] of Byte;   { a 16x16 four-plane tile plus mask (GUESS) }
  TGfx = record                    { one record of SAM101.GFX, $1F80 bytes; DrawText addresses Tile[N] }
    Head: array[1..3] of Byte;     { at 3 + (N-1)*160, as the cells of TGfxSmall (GUESS) }
    Tile: array[1..50] of TTile;
    Tail: array[1..61] of Byte;
  end;
  PGfx = ^TGfx;
  TCell = array[1..40] of Byte;    { an 8x8 four-plane cell plus mask (GUESS) }
  TGfxSmall = record               { one record of SAM102.GFX, $800 bytes; DrawStatus addresses Cell[N] }
    Head: array[1..3] of Byte;     { at 3 + (N-1)*40: the 3-byte head is inferred from that, GUESS }
    Cell: array[1..51] of TCell;
    Tail: array[1..5] of Byte;
  end;
  PGfxSmall = ^TGfxSmall;
  TConfig = record                 { SAM1.CFG, one record of $1D3 bytes (main 0000:0EF2 / 0F75) }
    HiName: array[1..10] of String[40];
    HiScore: array[1..10] of LongInt;
    Sound: Boolean;                { SoundOn }
    KUp, KDown, KLeft, KRight, KJump, KFire, K70EC, K70EE: Integer;
  end;
  TSlot = record                   { 32 bytes; slot n at DS:3512 + (n-1)*32 }
    W00, X, Y, PrevX, PrevY, Anim: Integer;  { src: SAM1RE objects.md: +02/+04 position, +06/+08 last
      frame's (the repaint), +0A animation counter (image = Sprite + Anim div 5) }
    W0C, W0E, W10, W12, Sprite, DirX, DirY, Speed, Kind: Integer;  { src: SAM1RE objects.md: +14 sprite base
      (T+150 at spawn, 0529:03F0), +16/+18 x/y direction -1/0/1, +1A speed, +1C behaviour kind }
    Free: Byte;                    { +1E }
    Remove: Byte;                  { src: SAM1RE objects.md: := 1 asks the frame pass to free the slot }
  end;
  TState = record                  { DS:6D3E..6D85, the game-state store; packed: words at odd offsets }
    X, Y: Integer;                 { slot 1's position }
    Score: LongInt;                { +04 }
    W08, Ammo, Gun: Integer;
    Bullets: array[1..20] of Byte; { +0E }
    W22, W24: Integer;
    B26: Byte;
    W27: Integer;
    B29, B2A: Byte;
    W2B, W2D, W2F, MapSite: Integer;
    SiteDone: array[1..20] of Byte; { +33 }
    B47: Byte;
  end;
var
  JumpUp: array[1..19] of Byte; { @34D6; indexed by JumpUpTop 1..19 (0529:66B3) }
  JumpDown: array[0..37] of Byte; { @34EA }
  JumpUpTop: Byte; { @3510 }
  JumpDownTop: Byte; { @3511 }
  Slots: array[1..25] of TSlot; { @3512 }
  W3832, W3834, W3836: Integer; { @3832 }
  TextLines: array[1..299] of String[40]; { @3838 }
  P681C: Pointer; { @681C; TextWindow's save-under buffer (30000 bytes) }
  KeyFilter: array[1..20] of Byte; { @6820; keys TextWindow accepts (SAM1RE text-windows.md) }
  P_683A: array[1..6] of Byte;
  WinKey: Integer; { @683A; scan code TextWindow returns (SAM1RE text-windows.md) }
  MenuReq: Byte; { @683C; menu/pause request (SAM1RE input.md) }
  Landings: Integer; { @683E; counts the player's landings (0529:66B3), GUESS }
  BackTile: Integer; { @6840; the number in a level's header record (0D9C:A1AE) }
  Level: Integer; { @6842 }
  WalkHeld, WalkSpeed, PageStride: Integer; { @6844;
    WalkHeld: frames a walk key is held (SAM1RE physics.md);
    WalkSpeed: no reader (SAM1RE physics.md);
    PageStride: := $50 at level entry (SAM1RE level-load.md) }
  ScanCode: Integer; { @684A; key ISR scan code, break = make + $80 (SAM1RE input.md) }
  SlotIdx, RowIdx, W6850: Integer; { @684C; loop variables of the text windows }
  Ticks: Integer; { @6852; timer ISR ticks, frame gate > 7 (SAM1RE input.md) }
  SlotCount: Integer; { @6854 }
  W6856: Integer; { @6856 }
  StatusCamX: Integer; { @6858 }
  SiteCounter: Integer; { @685A; world-map site counter (SAM1RE level-load.md) }
  B685C: Byte; { @685C }
  CamX: Integer; { @685E }
  CamY: Integer; { @6860 }
  ScanPage: Integer; { @6862; the page the CRTC scans (SAM1RE level-load.md) }
  W6864: Integer; { @6864 }
  PageY: Integer; { @6866 }
  AllDone: Byte; { @6868; 1 when exactly 15 of the 16 sites are done (0D9C:2E88; SAM1RE level-load.md) }
  Bullets: array[1..20] of Byte; { @686A }
  Ammo: Integer; { @687E }
  Shots: array[1..10] of TSlot; { @6880; a second slot table (0529:008D tests it like Slots), GUESS name }
  Score: LongInt; { @69C0 }
  W69C4: Integer; { @69C4 }
  W69C6: Integer; { @69C6 }
  Gun: Integer; { @69C8 }
  SpeedBonus: Integer; { @69CA; walk speed bonus, tile N (SAM1RE physics.md) }
  SpeedTimer: Integer; { @69CC; speed power-up, $D8, -1 per 20 ticks (SAM1RE physics.md) }
  W69CE: Integer; { @69CE }
  ConfuseTimer: Integer; { @69D0; confusion, $D8, -2 (SAM1RE physics.md) }
  UnconfuseMsg: Byte; { @69D2; 1: print YOU FEEL LESS CONFUSED (SAM1RE physics.md) }
  Confused: Byte; { @69D3; walk keys mirrored (SAM1RE input.md) }
  SlowTimer: Integer; { @69D4; slow-walk power-up, $D8, -2 (SAM1RE physics.md) }
  SlowWalk: Byte; { @69D6; tile H (SAM1RE physics.md) }
  W69D8: Integer; { @69D8 }
  KeysOff: Byte; { @69DA; <> 0: game keys skipped (SAM1RE input.md) }
  W69DC: Integer; { @69DC }
  MapSite: Integer; { @69DE }
  SiteDone: array[1..20] of Byte; { @69E0 }
  ExitArmed, ChordO, ChordN, ChordD, ChordPB, WarpCheat, ChordP, ChordJ, ChordX, PjxDone, B69FE, ChordU: Byte; { @69F4;
    ChordO: cheat chord O N D + P/B (SAM1RE input.md);
    ChordN: cheat chord (SAM1RE input.md);
    ChordD: cheat chord (SAM1RE input.md);
    ChordPB: cheat chord (SAM1RE input.md);
    WarpCheat: level-warp latch (SAM1RE input.md);
    ChordP: cheat chord P J X (SAM1RE input.md);
    ChordJ: cheat chord (SAM1RE input.md);
    ChordX: cheat chord (SAM1RE input.md);
    PjxDone: P J X latch (SAM1RE input.md);
    ChordU: cheat chord U V K, ammo +25 (SAM1RE input.md) }
  ChordV, ChordK, AmmoCheat, ChordZ, ChordG, ChordI, WarpArmed: Byte; { @6A00;
    ChordV: cheat chord (SAM1RE input.md);
    ChordK: cheat chord (SAM1RE input.md);
    AmmoCheat: U V K one-shot (SAM1RE input.md);
    ChordZ: cheat chord Z G I (SAM1RE input.md);
    ChordG: cheat chord (SAM1RE input.md);
    ChordI: cheat chord (SAM1RE input.md);
    WarpArmed: warp tile armed (SAM1RE level-load.md) }
  WarpTimer, WarpX, WarpY: Integer; { @6A08;
    WarpTimer: warp countdown, := $13 (SAM1RE level-load.md);
    WarpX: warp destination (SAM1RE level-load.md);
    WarpY: warp destination (SAM1RE level-load.md) }
  B6A0E, B6A0F, B6A10, B6A11, Floppy, LaserDown, B6A14, VGunOff: Byte; { @6A0E;
    Floppy: the floppy (SAM1RE level-load.md);
    LaserDown: laser field off (SAM1RE level-load.md) }
  Bonus1, Bonus2, Bonus3, Invulnerable, DoorKey, HitLock: Byte; { @6A16;
    Bonus1: ordered bonus chain (SAM1RE level-load.md);
    Bonus2: ordered bonus chain (SAM1RE level-load.md);
    Bonus3: ordered bonus chain (SAM1RE level-load.md);
    Invulnerable: P J X toggle, gates damage (SAM1RE input.md);
    DoorKey: the door key (SAM1RE level-load.md);
    HitLock: hit/death lock (SAM1RE physics.md) }
  ArcLen: Byte; { @6A1C }
  Arc: array[1..35] of Integer; { @6A1E; indexed by ArcLen (main 0000:1B35) }
  ExitLock: Byte; { @6A64; exit/cutscene lock (SAM1RE physics.md) }
  RespawnDelay: Byte; { @6A65 }
  Lives: Byte; { @6A66 }
  B6A67: Byte; { @6A67 }
  B6A68: Byte; { @6A68 }
  NameInput: String; { @6A6A }
  HiName: array[1..10] of String[40]; { @6B6A }
  HiScore: array[1..10] of LongInt; { @6D04 }
  Config: TConfig absolute HiName; { the high scores, sound switch and keys as SAM1.CFG holds them, GUESS }
  P_6D3E: array[1..18] of Byte;
  State: TState; { @6D3E }
  SaveSlot, MarkerX, MarkerY: Integer; { @6D86;
    SaveSlot: save slot = scan - 1 (SAM1RE menus.md);
    MarkerX: player x at a site marker (SAM1RE level-load.md);
    MarkerY: player y at a site marker (SAM1RE level-load.md) }
  HasPix: Byte; { @6D8C; the PIX pickup (SAM1RE level-load.md) }
  JoyCenterX, JoyCenterY: Integer; { @6D8E; signed compares in main 0000:08A2 }
  JoyX, JoyY: Integer; { @6D92 }
  JoyMovedX, JoyMovedY: Boolean; { @6D96 }
  Gfx: array[1..16] of PGfx; { @6D98 }
  GfxFile: file of TGfx; { @6DD8 }
  GfxSmall: array[1..3] of PGfxSmall; { @6E58 }
  GfxSmallFile: file of TGfxSmall; { @6E64 }
  EscKey: Char; { @6EE4; EscapeMenu's result (main 0000:5078) }
  Shot, Falling, Jumping, B6EE8, UpHeld, DownHeld, EscHeld, B6EEC, B6EED, B6EEE, B6EEF, LeftHeld, RightHeld: Byte; { @6EE5;
    Shot: shot fired (SAM1RE physics.md);
    Falling: (SAM1RE physics.md);
    Jumping: (SAM1RE physics.md);
    UpHeld: (SAM1RE input.md);
    DownHeld: (SAM1RE input.md);
    EscHeld: (SAM1RE input.md);
    LeftHeld: (SAM1RE input.md);
    RightHeld: (SAM1RE input.md) }
  B6EF2, JumpHeld: Byte; { @6EF2; JumpHeld: (SAM1RE input.md) }
  NameUp, NameDown, NameFire, NameRight, NameJump, NameLeft: String[80]; { @6EF4; key names (redefine menu) }
  KeyUp, KeyDown, KeyLeft, KeyRight, KeyFire, KeyJump: Integer; { @70E0; SAM1RE menus.md: 70E8 fire }
  AltVideo: Integer; { @70EC; Alternate video setting Y/N (SAM1RE menus.md) }
  UseJoystick: Integer; { @70EE; 1 when the joystick was chosen (SAM1RE input.md) }
  OldExit: Pointer; { @70F0; main 0000:0E67 hooks ExitProc, int $1C and int 9 }
  OldInt1C: Pointer; { @70F4 }
  OldInt9: Pointer; { @70F8 }
  P_2891_END: array[1..4] of Byte;
procedure StartupInit;
procedure NewGame;
procedure LevelReset;
procedure OBJ2891;
procedure Decrypt(var Buf; Size: Word);
implementation
{$L OBJ2891.OBJ}
procedure OBJ2891; external;
procedure Decrypt; external;
{ src: SAM1RE 2891:0136 (../SAM code-map.md: start-up init: key defaults, high-score table, jump and arc tables) }
{ from: 0000 }
{ interface }
procedure StartupInit;
var
  I: Integer;
  L: LongInt;
begin
  for I := 1 to 25 do
    Slots[I].Free := 1;
  CamX := 0;
  CopyPage;
  StatusCamX := -1;
  CamY := 0;
  Ticks := 0;
  AltVideo := 0;
  UseJoystick := 0;
  KeyUp := $48;
  KeyDown := $50;
  KeyLeft := $4B;
  KeyRight := $4D;
  KeyFire := $38;
  KeyJump := $1D;
  for I := 1 to 10 do
  begin
    case I of
      1: HiName[I] := 'James Bond              200000';
      2: HiName[I] := 'Matt Helm               190000';
      3: HiName[I] := 'Flint                   180000';
      4: HiName[I] := 'Jack Ryan               170000';
      5: HiName[I] := 'Jim Phelps              160000';
      6: HiName[I] := 'Columbo                 150000';
      7: HiName[I] := 'Maxwell Smart           140000';
      8: HiName[I] := 'Frank Drebin            130000';
      9: HiName[I] := 'Underdog                120000';
      10: HiName[I] := 'The A Team              110000';
    end;
    L := I;
    HiScore[I] := 200000 - (L - 1) * 10000;
  end;
  Shot := 0;
  LeftHeld := 0;
  RightHeld := 0;
  UpHeld := 0;
  DownHeld := 0;
  EscHeld := 0;
  B6EEC := 0;
  B6EED := 0;
  B6EEE := 0;
  B6EEF := 0;
  B6EE8 := 0;
  Jumping := 0;
  JumpHeld := 0;
  Falling := 0;
  Level := 1;
  W6856 := 0;
  PageY := $10;
  W6864 := 0;
  ScanPage := 0;
  WalkSpeed := 0;
  B685C := 1;
  Score := 0;
  W69C4 := 1;
  Ammo := 5;
  Gun := 1;
  W69C6 := 0;
  for I := 1 to 15 do
    Bullets[I] := 0;
  SpeedBonus := 0;
  SpeedTimer := 0;
  W69CE := 0;
  Confused := 0;
  ConfuseTimer := 0;
  UnconfuseMsg := 0;
  SlowWalk := 0;
  SlowTimer := 0;
  W69D8 := 0;
  VGunOff := 0;
  Floppy := 0;
  LaserDown := 0;
  B6A0E := 0;
  B6A0F := 0;
  B6A10 := 0;
  B6A11 := 0;
  Invulnerable := 0;
  DoorKey := 0;
  B6A14 := 0;
  KeysOff := 0;
  W69DC := 0;
  MapSite := 1;
  Bonus1 := 0;
  Bonus2 := 0;
  Bonus3 := 1;
  for I := 1 to 20 do
    SiteDone[I] := 0;
  HitLock := 0;
  ArcLen := $23;
  ExitLock := 0;
  RespawnDelay := 8;
  Lives := 3;
  B6A67 := 0;
  B6A68 := 0;
  ExitArmed := 0;
  MenuReq := 0;
  ChordP := 0;
  ChordJ := 0;
  ChordX := 0;
  ChordU := 0;
  ChordV := 0;
  ChordK := 0;
  AmmoCheat := 0;
  ChordZ := 0;
  ChordG := 0;
  ChordI := 0;
  ChordO := 0;
  ChordN := 0;
  ChordD := 0;
  ChordPB := 0;
  WarpCheat := 0;
  PjxDone := 0;
  B69FE := 0;
  WarpArmed := 0;
  WarpTimer := 0;
  WarpX := 0;
  WarpY := 0;
  State.X := 0;
  State.Y := 0;
  State.Score := Score;
  State.W08 := W69C4;
  State.Ammo := Ammo;
  for I := 1 to 20 do
    State.Bullets[I] := Bullets[I];
  State.W22 := SpeedBonus;
  State.W24 := SpeedTimer;
  State.B26 := Confused;
  State.W27 := ConfuseTimer;
  State.B29 := UnconfuseMsg;
  State.B2A := SlowWalk;
  State.W2B := SlowTimer;
  State.W2D := W69D8;
  State.W2F := W69DC;
  State.MapSite := MapSite;
  for I := 1 to 20 do
    State.SiteDone[I] := SiteDone[I];
  SaveSlot := 0;
  JumpUp[1] := 0;
  JumpUp[2] := 8;
  JumpUp[3] := 8;
  JumpUp[4] := 8;
  JumpUp[5] := 4;
  JumpUp[6] := 4;
  JumpUp[7] := 2;
  JumpUp[8] := 2;
  JumpUp[9] := 2;
  JumpUp[10] := 1;
  JumpUp[11] := 1;
  JumpUp[12] := 2;
  JumpUp[13] := 2;
  JumpUp[14] := 2;
  JumpUp[15] := 4;
  JumpUp[16] := 4;
  JumpUp[17] := 8;
  JumpUp[18] := 8;
  JumpUp[19] := 8;
  JumpUpTop := 18;
  JumpDown[0] := 0;
  JumpDown[1] := 8;
  JumpDown[2] := 8;
  JumpDown[3] := 6;
  JumpDown[4] := 6;
  JumpDown[5] := 4;
  JumpDown[6] := 4;
  JumpDown[7] := 4;
  JumpDown[8] := 4;
  JumpDown[9] := 4;
  JumpDown[10] := 4;
  JumpDown[11] := 2;
  JumpDown[12] := 2;
  JumpDown[13] := 2;
  JumpDown[14] := 2;
  JumpDown[15] := 2;
  JumpDown[16] := 1;
  JumpDown[17] := 1;
  JumpDown[18] := 1;
  JumpDown[19] := 1;
  JumpDown[20] := 0;
  JumpDown[21] := 0;
  JumpDown[22] := 0;
  JumpDown[23] := 2;
  JumpDown[24] := 2;
  JumpDown[25] := 2;
  JumpDown[26] := 2;
  JumpDown[27] := 4;
  JumpDown[28] := 4;
  JumpDown[29] := 4;
  JumpDown[30] := 4;
  JumpDown[31] := 4;
  JumpDown[32] := 4;
  JumpDown[33] := 4;
  JumpDown[34] := 6;
  JumpDown[35] := 6;
  JumpDown[36] := 8;
  JumpDown[37] := 8;
  JumpDownTop := 37;
  Arc[1] := -8;
  Arc[2] := -8;
  Arc[3] := -8;
  Arc[4] := -8;
  Arc[5] := -8;
  Arc[6] := -8;
  Arc[7] := -8;
  Arc[8] := -8;
  Arc[9] := -8;
  Arc[10] := -8;
  Arc[11] := -8;
  Arc[12] := -8;
  Arc[13] := -8;
  Arc[14] := -8;
  Arc[15] := -8;
  Arc[16] := -6;
  Arc[17] := -6;
  Arc[18] := -6;
  Arc[19] := -6;
  Arc[20] := -6;
  Arc[21] := -6;
  Arc[22] := -4;
  Arc[23] := -4;
  Arc[24] := -4;
  Arc[25] := -4;
  Arc[26] := 0;
  Arc[27] := 0;
  Arc[28] := 0;
  Arc[29] := 4;
  Arc[30] := 4;
  Arc[31] := 8;
  Arc[32] := 8;
  Arc[33] := 8;
  Arc[34] := 8;
  Arc[35] := 8;
  HasPix := 0;
end;
{ src: SAM1RE 2891:07D5 (../SAM code-map.md: new game) }
{ interface }
procedure NewGame;
var
  I: Integer;
begin
  HasPix := 0;
  for I := 1 to 25 do
    Slots[I].Free := 1;
  CamX := 0;
  CopyPage;
  StatusCamX := -1;
  CamY := 0;
  Ticks := 0;
  Shot := 0;
  LeftHeld := 0;
  RightHeld := 0;
  UpHeld := 0;
  DownHeld := 0;
  EscHeld := 0;
  B6EEC := 0;
  B6EED := 0;
  B6EEE := 0;
  B6EEF := 0;
  B6EE8 := 0;
  Jumping := 0;
  JumpHeld := 0;
  Falling := 0;
  Level := 1;
  W6856 := 0;
  PageY := $10;
  W6864 := 0;
  ScanPage := 0;
  WalkSpeed := 0;
  B685C := 1;
  Score := 0;
  W69C4 := 1;
  Ammo := 5;
  Gun := 1;
  W69C6 := 0;
  for I := 1 to 15 do
    Bullets[I] := 0;
  SpeedBonus := 0;
  SpeedTimer := 0;
  W69CE := 0;
  Confused := 0;
  ConfuseTimer := 0;
  UnconfuseMsg := 0;
  SlowWalk := 0;
  SlowTimer := 0;
  W69D8 := 0;
  VGunOff := 0;
  Floppy := 0;
  LaserDown := 0;
  B6A0E := 0;
  B6A0F := 0;
  B6A10 := 0;
  B6A11 := 0;
  Invulnerable := 0;
  DoorKey := 0;
  B6A14 := 0;
  KeysOff := 0;
  W69DC := 0;
  MapSite := 1;
  Bonus1 := 0;
  Bonus2 := 0;
  Bonus3 := 1;
  for I := 1 to 20 do
    SiteDone[I] := 0;
  HitLock := 0;
  ArcLen := $23;
  ExitArmed := 0;
  ExitLock := 0;
  RespawnDelay := 8;
  Lives := 3;
  B6A67 := 0;
  B6A68 := 0;
  MenuReq := 0;
  ChordP := 0;
  ChordJ := 0;
  ChordX := 0;
  ChordU := 0;
  ChordV := 0;
  ChordK := 0;
  AmmoCheat := 0;
  ChordZ := 0;
  ChordG := 0;
  ChordI := 0;
  ChordO := 0;
  ChordN := 0;
  ChordD := 0;
  ChordPB := 0;
  WarpCheat := 0;
  PjxDone := 0;
  B69FE := 0;
  WarpArmed := 0;
  WarpTimer := 0;
  WarpX := 0;
  WarpY := 0;
  State.X := 0;
  State.Y := 0;
  State.Score := Score;
  State.W08 := W69C4;
  State.Ammo := Ammo;
  for I := 1 to 20 do
    State.Bullets[I] := Bullets[I];
  State.W22 := SpeedBonus;
  State.W24 := SpeedTimer;
  State.B26 := Confused;
  State.W27 := ConfuseTimer;
  State.B29 := UnconfuseMsg;
  State.B2A := SlowWalk;
  State.W2B := SlowTimer;
  State.W2D := W69D8;
  State.W2F := W69DC;
  State.MapSite := MapSite;
  for I := 1 to 20 do
    State.SiteDone[I] := SiteDone[I];
  State.B47 := AmmoCheat;
end;
{ src: SAM1RE 2891:0A89 (../SAM code-map.md: level entry / respawn). I is never used (sub sp,2) }
{ interface }
procedure LevelReset;
var
  I: Integer;
begin
  HasPix := 0;
  SetColor(0);
  ClearRows(0, $50, 0, 8);
  CopyPage;
  StatusCamX := -1;
  Shot := 0;
  LeftHeld := 0;
  RightHeld := 0;
  UpHeld := 0;
  DownHeld := 0;
  EscHeld := 0;
  B6EEC := 0;
  B6EED := 0;
  B6EEE := 0;
  B6EEF := 0;
  B6EE8 := 0;
  Jumping := 0;
  JumpHeld := 0;
  Falling := 0;
  W6856 := 0;
  WalkSpeed := 0;
  VGunOff := 0;
  Floppy := 0;
  LaserDown := 0;
  B6A0E := 0;
  B6A0F := 0;
  B6A10 := 0;
  B6A11 := 0;
  DoorKey := 0;
  B6A14 := 0;
  KeysOff := 0;
  Bonus1 := 0;
  Bonus2 := 0;
  Bonus3 := 1;
  SpeedBonus := 0;
  SpeedTimer := 0;
  W69CE := 0;
  Confused := 0;
  ConfuseTimer := 0;
  UnconfuseMsg := 0;
  SlowWalk := 0;
  SlowTimer := 0;
  MenuReq := 0;
  ExitLock := 0;
  RespawnDelay := 8;
  Lives := 3;
  B6A67 := 0;
  B6A68 := 0;
  HitLock := 0;
  ArcLen := $23;
  ExitArmed := 0;
  ChordP := 0;
  ChordJ := 0;
  ChordX := 0;
  ChordU := 0;
  ChordV := 0;
  ChordK := 0;
  AmmoCheat := 0;
  ChordZ := 0;
  ChordG := 0;
  ChordI := 0;
  ChordO := 0;
  ChordN := 0;
  ChordD := 0;
  ChordPB := 0;
  WarpCheat := 0;
  PjxDone := 0;
  B69FE := 0;
  WarpArmed := 0;
  WarpTimer := 0;
  WarpX := 0;
  WarpY := 0;
end;
begin
{ init }
{ src: EXE 2891:0C0D: the unit has no initialization statements; TP emits an empty frame }
end.
