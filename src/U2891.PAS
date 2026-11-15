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
    W00, X, Y, W06, W08, W0A: Integer;  { +02/+04: position (SAM1RE) }
    W0C, W0E, W10, W12, W14, W16, W18, W1A, W1C: Integer;  { +14: T+150 at spawn (0529:03F0) }
    Free: Byte;                    { +1E }
    B1F: Byte;
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
  P_3838: array[1..6] of Byte;
  TextLines: array[1..299] of String[40]; { @3838 }
  P681C: Pointer; { @681C; TextWindow's save-under buffer (30000 bytes) }
  B6820: array[1..20] of Byte; { @6820 }
  P_683A: array[1..6] of Byte;
  W683A: Integer; { @683A }
  B683C: Byte; { @683C }
  W683E: Integer; { @683E; counts the player's landings (0529:66B3), GUESS }
  W6840: Integer; { @6840; the number in a level's header record (0D9C:A1AE) }
  Level: Integer; { @6842 }
  W6844, W6846: Integer; { @6844 }
  P_684A: array[1..2] of Byte;
  W684A: Integer; { @684A }
  W684C, W684E, W6850: Integer; { @684C; loop variables of the text windows }
  W6852: Integer; { @6852 }
  W6854: Integer; { @6854 }
  W6856: Integer; { @6856 }
  W6858: Integer; { @6858 }
  W685A: Integer; { @685A }
  B685C: Byte; { @685C }
  CamX: Integer; { @685E }
  CamY: Integer; { @6860 }
  W6862: Integer; { @6862 }
  W6864: Integer; { @6864 }
  W6866: Integer; { @6866 }
  B6868: Byte; { @6868; 1 when exactly 15 of the 16 sites are done (0D9C:2E88; SAM1RE level-load.md) }
  Bullets: array[1..20] of Byte; { @686A }
  Ammo: Integer; { @687E }
  Shots: array[1..10] of TSlot; { @6880; a second slot table (0529:008D tests it like Slots), GUESS name }
  Score: LongInt; { @69C0 }
  W69C4: Integer; { @69C4 }
  W69C6: Integer; { @69C6 }
  Gun: Integer; { @69C8 }
  W69CA: Integer; { @69CA }
  W69CC: Integer; { @69CC }
  W69CE: Integer; { @69CE }
  W69D0: Integer; { @69D0 }
  B69D2: Byte; { @69D2 }
  B69D3: Byte; { @69D3 }
  W69D4: Integer; { @69D4 }
  B69D6: Byte; { @69D6 }
  W69D8: Integer; { @69D8 }
  B69DA: Byte; { @69DA }
  W69DC: Integer; { @69DC }
  MapSite: Integer; { @69DE }
  SiteDone: array[1..20] of Byte; { @69E0 }
  B69F4, B69F5, B69F6, B69F7, B69F8, B69F9, B69FA, B69FB, B69FC, B69FD, B69FE, B69FF: Byte; { @69F4 }
  B6A00, B6A01, B6A02, B6A03, B6A04, B6A05, B6A06: Byte; { @6A00 }
  W6A08, W6A0A, W6A0C: Integer; { @6A08 }
  B6A0E, B6A0F, B6A10, B6A11, B6A12, B6A13, B6A14, B6A15, B6A16, B6A17, B6A18, B6A19, B6A1A, B6A1B: Byte; { @6A0E }
  ArcLen: Byte; { @6A1C }
  Arc: array[0..34] of Integer; { @6A1E }
  B6A64: Byte; { @6A64 }
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
  W6D86, W6D88, W6D8A: Integer; { @6D86 }
  B6D8C: Byte; { @6D8C }
  JoyCenterX, JoyCenterY: Integer; { @6D8E; signed compares in main 0000:08A2 }
  JoyX, JoyY: Integer; { @6D92 }
  JoyMovedX, JoyMovedY: Boolean; { @6D96 }
  Gfx: array[1..16] of PGfx; { @6D98 }
  GfxFile: file of TGfx; { @6DD8 }
  GfxSmall: array[1..3] of PGfxSmall; { @6E58 }
  GfxSmallFile: file of TGfxSmall; { @6E64 }
  P_6EE5: array[1..1] of Byte;
  B6EE5, B6EE6, B6EE7, B6EE8, B6EE9, B6EEA, B6EEB, B6EEC, B6EED, B6EEE, B6EEF, B6EF0, B6EF1: Byte; { @6EE5 }
  B6EF2, B6EF3: Byte; { @6EF2 }
  NameUp, NameDown, NameFire, NameRight, NameJump, NameLeft: String[80]; { @6EF4; key names (redefine menu) }
  KeyUp, KeyDown, KeyLeft, KeyRight, KeyFire, KeyJump: Integer; { @70E0; SAM1RE menus.md: 70E8 fire }
  W70EC: Integer; { @70EC }
  W70EE: Integer; { @70EE }
  OldExit: Pointer; { @70F0; main 0000:0E67 hooks ExitProc, int $1C and int 9 }
  OldInt1C: Pointer; { @70F4 }
  OldInt9: Pointer; { @70F8 }
var P_2891_END: array[1..4] of Byte;
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
{ keep: StartupInit; }
procedure StartupInit;
var
  I: Integer;
  L: LongInt;
begin
  for I := 1 to 25 do
    Slots[I].Free := 1;
  CamX := 0;
  CopyPage;
  W6858 := -1;
  CamY := 0;
  W6852 := 0;
  W70EC := 0;
  W70EE := 0;
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
  B6EE5 := 0;
  B6EF0 := 0;
  B6EF1 := 0;
  B6EE9 := 0;
  B6EEA := 0;
  B6EEB := 0;
  B6EEC := 0;
  B6EED := 0;
  B6EEE := 0;
  B6EEF := 0;
  B6EE8 := 0;
  B6EE7 := 0;
  B6EF3 := 0;
  B6EE6 := 0;
  Level := 1;
  W6856 := 0;
  W6866 := $10;
  W6864 := 0;
  W6862 := 0;
  W6846 := 0;
  B685C := 1;
  Score := 0;
  W69C4 := 1;
  Ammo := 5;
  Gun := 1;
  W69C6 := 0;
  for I := 1 to 15 do
    Bullets[I] := 0;
  W69CA := 0;
  W69CC := 0;
  W69CE := 0;
  B69D3 := 0;
  W69D0 := 0;
  B69D2 := 0;
  B69D6 := 0;
  W69D4 := 0;
  W69D8 := 0;
  B6A15 := 0;
  B6A12 := 0;
  B6A13 := 0;
  B6A0E := 0;
  B6A0F := 0;
  B6A10 := 0;
  B6A11 := 0;
  B6A19 := 0;
  B6A1A := 0;
  B6A14 := 0;
  B69DA := 0;
  W69DC := 0;
  MapSite := 1;
  B6A16 := 0;
  B6A17 := 0;
  B6A18 := 1;
  for I := 1 to 20 do
    SiteDone[I] := 0;
  B6A1B := 0;
  ArcLen := $23;
  B6A64 := 0;
  RespawnDelay := 8;
  Lives := 3;
  B6A67 := 0;
  B6A68 := 0;
  B69F4 := 0;
  B683C := 0;
  B69FA := 0;
  B69FB := 0;
  B69FC := 0;
  B69FF := 0;
  B6A00 := 0;
  B6A01 := 0;
  B6A02 := 0;
  B6A03 := 0;
  B6A04 := 0;
  B6A05 := 0;
  B69F5 := 0;
  B69F6 := 0;
  B69F7 := 0;
  B69F8 := 0;
  B69F9 := 0;
  B69FD := 0;
  B69FE := 0;
  B6A06 := 0;
  W6A08 := 0;
  W6A0A := 0;
  W6A0C := 0;
  State.X := 0;
  State.Y := 0;
  State.Score := Score;
  State.W08 := W69C4;
  State.Ammo := Ammo;
  for I := 1 to 20 do
    State.Bullets[I] := Bullets[I];
  State.W22 := W69CA;
  State.W24 := W69CC;
  State.B26 := B69D3;
  State.W27 := W69D0;
  State.B29 := B69D2;
  State.B2A := B69D6;
  State.W2B := W69D4;
  State.W2D := W69D8;
  State.W2F := W69DC;
  State.MapSite := MapSite;
  for I := 1 to 20 do
    State.SiteDone[I] := SiteDone[I];
  W6D86 := 0;
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
  Arc[0] := -8;
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
  Arc[15] := -6;
  Arc[16] := -6;
  Arc[17] := -6;
  Arc[18] := -6;
  Arc[19] := -6;
  Arc[20] := -6;
  Arc[21] := -4;
  Arc[22] := -4;
  Arc[23] := -4;
  Arc[24] := -4;
  Arc[25] := 0;
  Arc[26] := 0;
  Arc[27] := 0;
  Arc[28] := 4;
  Arc[29] := 4;
  Arc[30] := 8;
  Arc[31] := 8;
  Arc[32] := 8;
  Arc[33] := 8;
  Arc[34] := 8;
  B6D8C := 0;
end;
{ src: SAM1RE 2891:07D5 (../SAM code-map.md: new game) }
{ interface }
{ keep: NewGame; }
procedure NewGame;
var
  I: Integer;
begin
  B6D8C := 0;
  for I := 1 to 25 do
    Slots[I].Free := 1;
  CamX := 0;
  CopyPage;
  W6858 := -1;
  CamY := 0;
  W6852 := 0;
  B6EE5 := 0;
  B6EF0 := 0;
  B6EF1 := 0;
  B6EE9 := 0;
  B6EEA := 0;
  B6EEB := 0;
  B6EEC := 0;
  B6EED := 0;
  B6EEE := 0;
  B6EEF := 0;
  B6EE8 := 0;
  B6EE7 := 0;
  B6EF3 := 0;
  B6EE6 := 0;
  Level := 1;
  W6856 := 0;
  W6866 := $10;
  W6864 := 0;
  W6862 := 0;
  W6846 := 0;
  B685C := 1;
  Score := 0;
  W69C4 := 1;
  Ammo := 5;
  Gun := 1;
  W69C6 := 0;
  for I := 1 to 15 do
    Bullets[I] := 0;
  W69CA := 0;
  W69CC := 0;
  W69CE := 0;
  B69D3 := 0;
  W69D0 := 0;
  B69D2 := 0;
  B69D6 := 0;
  W69D4 := 0;
  W69D8 := 0;
  B6A15 := 0;
  B6A12 := 0;
  B6A13 := 0;
  B6A0E := 0;
  B6A0F := 0;
  B6A10 := 0;
  B6A11 := 0;
  B6A19 := 0;
  B6A1A := 0;
  B6A14 := 0;
  B69DA := 0;
  W69DC := 0;
  MapSite := 1;
  B6A16 := 0;
  B6A17 := 0;
  B6A18 := 1;
  for I := 1 to 20 do
    SiteDone[I] := 0;
  B6A1B := 0;
  ArcLen := $23;
  B69F4 := 0;
  B6A64 := 0;
  RespawnDelay := 8;
  Lives := 3;
  B6A67 := 0;
  B6A68 := 0;
  B683C := 0;
  B69FA := 0;
  B69FB := 0;
  B69FC := 0;
  B69FF := 0;
  B6A00 := 0;
  B6A01 := 0;
  B6A02 := 0;
  B6A03 := 0;
  B6A04 := 0;
  B6A05 := 0;
  B69F5 := 0;
  B69F6 := 0;
  B69F7 := 0;
  B69F8 := 0;
  B69F9 := 0;
  B69FD := 0;
  B69FE := 0;
  B6A06 := 0;
  W6A08 := 0;
  W6A0A := 0;
  W6A0C := 0;
  State.X := 0;
  State.Y := 0;
  State.Score := Score;
  State.W08 := W69C4;
  State.Ammo := Ammo;
  for I := 1 to 20 do
    State.Bullets[I] := Bullets[I];
  State.W22 := W69CA;
  State.W24 := W69CC;
  State.B26 := B69D3;
  State.W27 := W69D0;
  State.B29 := B69D2;
  State.B2A := B69D6;
  State.W2B := W69D4;
  State.W2D := W69D8;
  State.W2F := W69DC;
  State.MapSite := MapSite;
  for I := 1 to 20 do
    State.SiteDone[I] := SiteDone[I];
  State.B47 := B6A02;
end;
{ src: SAM1RE 2891:0A89 (../SAM code-map.md: level entry / respawn). I is never used (sub sp,2) }
{ interface }
{ keep: LevelReset; }
procedure LevelReset;
var
  I: Integer;
begin
  B6D8C := 0;
  SetColor(0);
  ClearRows(0, $50, 0, 8);
  CopyPage;
  W6858 := -1;
  B6EE5 := 0;
  B6EF0 := 0;
  B6EF1 := 0;
  B6EE9 := 0;
  B6EEA := 0;
  B6EEB := 0;
  B6EEC := 0;
  B6EED := 0;
  B6EEE := 0;
  B6EEF := 0;
  B6EE8 := 0;
  B6EE7 := 0;
  B6EF3 := 0;
  B6EE6 := 0;
  W6856 := 0;
  W6846 := 0;
  B6A15 := 0;
  B6A12 := 0;
  B6A13 := 0;
  B6A0E := 0;
  B6A0F := 0;
  B6A10 := 0;
  B6A11 := 0;
  B6A1A := 0;
  B6A14 := 0;
  B69DA := 0;
  B6A16 := 0;
  B6A17 := 0;
  B6A18 := 1;
  W69CA := 0;
  W69CC := 0;
  W69CE := 0;
  B69D3 := 0;
  W69D0 := 0;
  B69D2 := 0;
  B69D6 := 0;
  W69D4 := 0;
  B683C := 0;
  B6A64 := 0;
  RespawnDelay := 8;
  Lives := 3;
  B6A67 := 0;
  B6A68 := 0;
  B6A1B := 0;
  ArcLen := $23;
  B69F4 := 0;
  B69FA := 0;
  B69FB := 0;
  B69FC := 0;
  B69FF := 0;
  B6A00 := 0;
  B6A01 := 0;
  B6A02 := 0;
  B6A03 := 0;
  B6A04 := 0;
  B6A05 := 0;
  B69F5 := 0;
  B69F6 := 0;
  B69F7 := 0;
  B69F8 := 0;
  B69F9 := 0;
  B69FD := 0;
  B69FE := 0;
  B6A06 := 0;
  W6A08 := 0;
  W6A0A := 0;
  W6A0C := 0;
end;
begin
{ init }
{ src: EXE 2891:0C0D: the unit has no initialization statements; TP emits an empty frame }
end.
