# STATUS

Short: where the project stands, and what is next. History is in git; do not
keep a session diary here.

## State

- Executable: `SAM1.EXE` (MZ, LZEXE 0.91, **Turbo Pascal 5.0**, CONFIRMED);
  `findings/executables.md`.
- Recipe: `recipe/units.json` first pass, 238 routines in 13 code segments,
  0 matched.
- Compiler: TP 5.0 / 5.5 / 6.0 compile headless (`tools/tp/tpc.sh`); 5.0 is
  SAM's (`tools/tp/pin_version.sh`).
- Units mapped (Q3): 3 Borland, Genus `2643`, 9 game (incl. Jungck's
  graphics unit `29C3`). Q4: `.OBJ` code cannot interleave with Pascal, so
  the scaffold is size-exact Pascal stubs (MATCHING.md section 4).
- Scaffold (Q5): `tools/tp/gen_scaffold.py` writes `src/` (stubs, keepers,
  data blocks), builds and fits it; `tools/tp/match.py` passes: layout,
  System/Crt/Dos byte-identical, data identical but Genus's constants.
- Q1-Q5 READY FOR REVIEW.
- Harness: DOSBox-X + MCP built (`./setup.sh` says ready); not used here yet.
- Build: none yet.

## Next

Q6: the first game routine in Pascal. The generator needs a way to take a
hand-written routine instead of a stub (src/match/, pasted into the unit, with
a keeper call that passes dummy arguments), then match a small leaf routine.
