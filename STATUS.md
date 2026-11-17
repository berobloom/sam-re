# STATUS

Short: where the project stands, and what is next. History is in git; do not
keep a session diary here.

## State

- Executable: `SAM1.EXE` (MZ, LZEXE 0.91, **Turbo Pascal 5.0**, CONFIRMED);
  `findings/executables.md`.
- **The matching decompilation is complete** (`SOURCE.md`: what the source
  is and where the game lives). `src/` (written by
  `tools/tp/gen_scaffold.py` from `src/match/`) compiles with TP 5.0 to a
  `SAM1.EXE` whose load image equals the unpacked original in all 188768
  bytes, and `tools/tp/pack.py` (LZEXE 0.91 after setting the header's
  min/max alloc to 3248/44208, which the original's linker output did not
  have: MATCHING.md section 8) turns it into the shipped `original/SAM1.EXE`
  byte for byte, SHA-256 included. All 10 game
  units are byte-identical: main, 0529 (actors), 0D9C (map), 1802 (menus,
  windows, save/load), 25E6 (text), 2643 (Genus PCX Toolkit, asm), 286F
  (joystick), 287F (sound), 2891 (start-up, data), 29C3 (graphics, asm).
  System, Dos and Crt come from TURBO.TPL byte for byte (`match.py`
  `library` lines). The data segment is identical.
- Build: `tools/tp/gen_scaffold.py` assembles `src/match/` into `src/`,
  builds, checks every routine's offset and size and fits the data pads
  (the stub/keeper scaffold that led here is in git up to `36f8b8f`).
- Source: 165 Pascal routines in `src/match/<SEG>_<OFF>_<Name>.PAS`, the `.OBJ`
  blocks as NASM in `src/match/OBJ<SEG>.ASM` (`tools/tp/obj2asm.py`), the
  asm entry points in `.EXT`, the data in `<SEG>.VAR`. The largest routines
  (Touch, ActorAI, ActorFrame, the program body) are unedited output of
  `tools/tp/pasgen.py`, a pattern decompiler for TP 5.0 code.
- Names: SAM1RE notes (../SAM) and GUESS, each with its source in the
  `.VAR` comment; `tools/tp/rename.py` renames (code only, refuses a clash).
  9 globals keep `W<addr>`/`B<addr>` names because the code only clears them
  (`3832..3836`, `6856`, `6A0E`, `6EEF`, `6EF2`) or only saves them (`69D8`),
  as their `.VAR` notes say. Every slot field is named.
- Compiler: TP 5.0 / 5.5 / 6.0 compile headless (`tools/tp/tpc.sh`); 5.0 is
  SAM's (`tools/tp/pin_version.sh`).
- Harness: DOSBox-X + MCP built (`./setup.sh` says ready); used only for the
  README's captures (`docs/media/`).
- Progress: `tools/progress.py` rebuilds, compares and writes `PROGRESS.md`,
  `docs/SAMPROGRESS.HTML` (every routine with its source) and the README badge.

## Next

- Names are done but for the 9 write-only globals; the asm blocks' internal
  routines are named (`<SEG>.LABELS`), their jump targets stay `L<offset>`.
  Open: checking the LIKELY slot fields (Limit/Count/Health/Wait) kind by
  kind; the 286F block entry (`OBJ286F`, reads four game-port axes, no
  Pascal caller) keeps the generator's name. `match.py` must stay green
  after each rename.
