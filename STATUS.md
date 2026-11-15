# STATUS

Short: where the project stands, and what is next. History is in git; do not
keep a session diary here.

## State

- Executable: `SAM1.EXE` (MZ, LZEXE 0.91, **Turbo Pascal 5.0**, CONFIRMED);
  `findings/executables.md`.
- Recipe: `recipe/units.json`, 241 routines in 13 code segments. Byte-
  identical units: 286F (joystick), 287F (sound), 2891 (start-up/resets),
  29C3 (Jungck's graphics: Pascal init + 12 KB asm block as NASM source),
  25E6 (text windows: MakeAttr, Replicate, ClearArea, Box, Window,
  WriteCenter, WriteVert over an asm FastWrite), 2643 (Genus PCX Toolkit:
  init + 8.9 KB asm with 106 segment fixups + its typed constants), 1802
  (menus, text windows, window font, save/load, status line; 52 routines incl.
  the nested ones of RedefineKeys). The data segment is identical. 93550 of
  187615 routine bytes (49.86%). In progress: main (KeyISR, ReadJoystick,
  TimerISR, the handlers, config, DetectVideo matched; the 16 KB main block
  left), 0529 (12 routines; Touch, 0837, 2F6B left), 0D9C (SetCell,
  LoadLevel; the draw routines, ParseRow, 2E88, 3A91 left).
- Data: per-unit ranges in the recipe (main 02A2..02BC + VideoTab at 0000,
  0D9C's Map 02BC..21FC); hand-written variables in `src/match/<SEG>.VAR`.
- Compiler: TP 5.0 / 5.5 / 6.0 compile headless (`tools/tp/tpc.sh`); 5.0 is
  SAM's (`tools/tp/pin_version.sh`).
- Units mapped (Q3): 3 Borland, Genus `2643`, 9 game (incl. Jungck's
  graphics unit `29C3`). Q4: `.OBJ` code cannot interleave with Pascal, so
  the scaffold is size-exact Pascal stubs (MATCHING.md section 4).
- Scaffold (Q5): `tools/tp/gen_scaffold.py` writes `src/` (stubs, keepers,
  data blocks), builds and fits it; `tools/tp/match.py` passes: layout,
  System/Crt/Dos byte-identical, data identical but Genus's constants.
- Q1-Q6 READY FOR REVIEW.
- Harness: DOSBox-X + MCP built (`./setup.sh` says ready); not used here yet.
- Build: none yet.

## Next

Units 0D9C (map/loader), 0529 (actors/AI) and main, growing 2891.VAR as their routines name more globals. OBJ29C3.ASM is mechanical (749 db lines where descent found no code);
naming its routines comes later.
