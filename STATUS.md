# STATUS

Short: where the project stands, and what is next. History is in git; do not
keep a session diary here.

## State

- Executable: `SAM1.EXE` (MZ, LZEXE 0.91, **Turbo Pascal 5.0**, CONFIRMED);
  `findings/executables.md`.
- Recipe: `recipe/units.json`, 241 routines in 13 code segments; matched:
  units 286F (joystick) and 287F (sound) whole, 2891's Pascal part
  (StartupInit, NewGame, LevelReset; its asm decrypt 0C14 open), 3 empty
  inits: 3205 of 185368 routine bytes (1.73%, `tools/tp/match.py`).
- Data: per-unit ranges in the recipe; a unit's hand-written variables go in
  `src/match/<SEG>.VAR` (287F's is the first).
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

The asm blocks (`{$L}` OBJ code: 286F:007F, 2891:0C14, then Genus and 29C3)
via NASM, so whole units match; then unit 25E6, then 1802/0D9C/0529 and main,
growing 2891.VAR as their routines name more globals.
