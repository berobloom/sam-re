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
- Q1-Q4 READY FOR REVIEW.
- Harness: DOSBox-X + MCP built (`./setup.sh` says ready); not used here yet.
- Build: none yet.

## Next

QUEUE.md Q5: the human decides its changed Accept (QUEUE note). Then the
work is (MATCHING.md section 4): (1) the DS anchors: Genus's first and last
variable, Crt's block, 29C3's block (from each unit's DS operands); (2) which
runtime routine each of SAM's 54 System / 3 Dos entry points is, and a
Pascal statement that links it; (3) `tools/tp/gen_scaffold.py` (stubs +
keepers + a fit loop that compiles with `/GD`, reads each stub's address
from the line-number map and corrects its filler); (4) `match.py`. After Q6: match routines unit by unit, libraries
first, smallest routines first (MATCHING.md section 6).
