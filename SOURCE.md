# The rebuilt source of SAM1.EXE

Secret Agent (Apogee, 1992), rebuilt as Turbo Pascal 5.0 source that compiles
to the shipped `SAM1.EXE` byte for byte (after LZEXE 0.91, SHA-256 included).
This page says what the source is, how it turns into the executable, and
where each part of the game lives. The method is in `MATCHING.md`, the state
in `STATUS.md`.

## What the source is

The source is `src/match/` plus two layout files. Everything else is either
generated from it or comes from outside.

| Files | What they are | Written by |
|---|---|---|
| `src/match/<SEG>_<OFF>.PAS` (107 files, 10 800 lines) | The Pascal routines, one region of the original segment `SEG` at offset `OFF` per file (165 routines; nested ones live in their parent), plus each unit's init and the program body (`{ init }`) | by hand, or `tools/tp/pasgen.py` output kept as is (Touch, ActorAI, ActorFrame, the program body) |
| `src/match/<SEG>.VAR` (8) | Each unit's types, variables and typed constants, with `{ @XXXX }` pins to their DS addresses and a note on where each name comes from | by hand |
| `src/match/<SEG>_<OFF>.EXT` (38) | The Pascal `external` declarations of the assembly routines | by hand |
| `src/match/OBJ<SEG>.ASM` (6, 4 700 lines) | Each unit's `{$L}` assembly block as NASM source | **generated from the original binary** by `tools/tp/obj2asm.py`, names from `.EXT`/`.LABELS` |
| `src/match/<SEG>.USES`, `<SEG>.LABELS` | A unit's uses clause; names of internal asm routines | by hand |
| `recipe/units.json` | The layout: each unit's segment, size, base, init offset, routine offsets, data ranges | derived from the binary (`tools/tp/inventory.py`) |
| `src/FILL.JSON` | Padding between pinned variables nobody has declared yet | fitted by `gen_scaffold.py` |

Not source:

- `src/SAM1.PAS`, `src/U*.PAS`, `src/GENUS.PAS`, `src/OBJ*.ASM`: the
  compilable units, assembled from `src/match/` by `tools/tp/gen_scaffold.py`
  on every build (committed so the build can be read without running it).
- System, Dos and Crt: Borland's units from `TURBO.TPL` of TP 5.0, linked
  unchanged; they are byte-identical to the game's copies.
- The packing step: `tools/tp/pack.py` sets the header's min/max alloc to
  3248/44208 paragraphs (TP 5.0 cannot produce that maximum, so the shipped
  header was LIKELY edited after linking) and runs LZEXE 0.91.

### How much of it is real source

- **The game's Pascal (8 of 10 units, and parts of the other two):** real
  Pascal. Every statement compiles, TP 5.0 produces the original bytes from
  it, and it reads like a program: `if`, `case`, `for`, records, strings,
  file I/O. Four `Inline` statements remain, all where the original did
  something Pascal cannot write: `cli`/`sti` around the timer setup
  (`0000_0BE5`), and in the keyboard ISR (`0000_0000`) the chain to the old
  handler and the keyboard acknowledge on ports 61h/20h.
- **The assembly blocks:** a disassembly, not recovered source. NASM
  re-assembles most instructions to the same bytes; where its encoding
  differs, or where the code was not reached, the line is a `db` with the
  instruction in a comment (1 248 such lines). The two biggest blocks are
  the Genus PCX Toolkit (2643, a third-party library) and the graphics
  routines (29C3).
- **The data:** declared variables with names and types, except the Genus
  unit's, which stays one byte array of constants (`T_2643`, the bytes as
  in SAM1.EXE) and one untyped variable block.
- **Names** carry their source next to them: `SAM1RE` (the behavioural
  reverse engineering in `../SAM`), `EXE` (read from the code), `GUESS`.
  Nine variables keep address names (`W3832`, `B6EF2`, ...) because the code
  only clears them or only saves them.

## How it builds

```
src/match/*  +  recipe/units.json  +  src/FILL.JSON
      |  tools/tp/gen_scaffold.py   (assemble units, check layout, fit data pads)
      v
src/SAM1.PAS, src/U*.PAS, src/GENUS.PAS, src/OBJ*.ASM
      |  NASM -f obj,  TPC /GD /B  (TP 5.0, headless in DOSBox: tools/tp/tpc.sh)
      v
.work/scaffold/SAM1.EXE   == the unpacked original, 188 768 bytes (tools/tp/match.py)
      |  tools/tp/pack.py   (header min/max alloc, LZEXE 0.91)
      v
SAM1.EXE                  == original/SAM1.EXE, 63 630 bytes
```

`match.py` checks every routine's bytes and relocations, the segment bases
and the initialised data; `gen_scaffold.py` checks that every routine starts
at its original offset with its original size.

## Where the game lives

Units in link order. `SEG` is the segment relative to the load segment, as
in the file names.

| Unit | What it does | Routines |
|---|---|---|
| `SAM1` (0000) | Program body: start-up, title loop, the game loop (input, actors, drawing, page flip, status line); keyboard and timer ISRs; config file | `KeyISR`, `TimerISR`, `InstallHandlers`, `RestoreInts`, `ExitHandler`, `ReadJoystick`, `LoadConfig`, `SaveConfig`, `DetectVideo`; asm `FastTimer`, `NormalTimer`, `ReadCMOSClock` |
| `U0529` | Actors and the player: movement, jump and fall, actor behaviour per kind, hits, shots, tile touch effects | `MovePlayer`, `Jump`, `Fall`, `ActorAI`, `ActorFrame`, `Touch`, `HitPlayer`, `ShotHit`, `Spawn`, `SpawnObject`, `KillPlayer`, ... |
| `U0D9C` | Levels: loading, the row parser (map characters to cells), spawning actors from the map, drawing the map layers | `LoadLevel`, `ParseRow`, `SetCell`, `SpawnActor`, `DrawBack`, `DrawFront`, `DrawSheet`, `WorldCell` |
| `U1802` | Screens and menus: title, main and escape menus, text windows, status line, save/restore, high scores, ordering info, the story and the ending, joystick and key setup | `TitleLoop`, `MainMenu`, `EscapeMenu`, `TextWindow`, `DrawStatus`, `SaveGame`, `LoadGame`, `HallOfFame`, `ShowEnding`, `RedefineKeys`, ... (48) |
| `U25E6` | A text-mode screen library (windows, boxes, centred and vertical writes, fast video writes). The game calls none of it; only the init (`InitVideo`, the video segment and the CGA snow check) runs | `Window`, `Box`, `WriteCenter`, `InitVideo`; asm `FastWrite`, `DetectAdapter`, `GetVideoMode` |
| `GENUS` (2643) | Genus PCX Toolkit 3.56: shows the PCX title pictures | asm `ShowPicture`, `PcxSetDisplay`, `PcxSetMode`, two init entries |
| `U286F` | Joystick | `JoyPresent`, `FireButton`, `JumpButton`; asm `ReadAxis` |
| `U287F` | Sound effects (PC speaker, sound banks) | `PlaySound` |
| `U2891` | Start-up, new game and level reset; holds most global variables | `StartupInit`, `NewGame`, `LevelReset`; asm `Decrypt` |
| `U29C3` | EGA/VGA graphics: modes, page start and split screen, tile, cell and sprite blits, palette, fonts | all asm: `DrawTile`, `DrawSprite`, `DrawCell`, `SetViewStart`, `SetSplit`, `SetPalReg`, `CopyPage`, ... (25) |

The central data, all in `src/match/2891.VAR`:

- `Slots: array[1..25] of TSlot`: the player (slot 1) and the actors, with
  position, previous position, animation, direction, speed, kind and the
  per-kind fields `Limit`, `Count`, `Health`, `Wait` (LIKELY names).
- `Map: array[1..40, 1..25] of TCell`: the cells of the current level
  (back, mid, front tile and the solid/flag bytes), 40 x 24 visible plus a
  25th row, in `0D9C.VAR`.
- The game state: `Level`, `Score`, `Lives`, `Ammo`, the item flags (`KeyA`
  .. `KeyC`, `DoorKey`, `Floppy`, `HasPix`), the power-up timers, the cheat
  chords, the warp state and the quit requests.

## Reading it

Start at the program body, `src/match/0000_11C3.PAS`: it runs the title
loop and then the game loop, and every frame calls into `U0529` (movement,
actors), `U0D9C` (map drawing) and `U1802` (status line, menus). A routine's
file name is its address in the original, so `tools/tp/rdiff.py SEG:OFF`
compares it with the original's bytes.
