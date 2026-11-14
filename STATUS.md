# STATUS

Short: where the project stands, and what is next. History is in git; do not
keep a session diary here.

## State

- Executable: `SAM1.EXE` (MZ, LZEXE 0.91, **Turbo Pascal 5.0**, CONFIRMED);
  `findings/executables.md`.
- Recipe: `recipe/units.json`, 241 routines in 13 code segments; matched:
  unit 286F (joystick) whole, 287F (sound request) whole, 3 empty inits:
  430 of 185368 routine bytes (`tools/tp/match.py`).
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

Unit 2891 (start-up, resets, high scores; DS:34D6..7100): its variables
first (.VAR, names from SAM1RE), then its leaf routines. The sound player in
main (0:0BED..0:0E26) is a candidate once main's own data is split.
