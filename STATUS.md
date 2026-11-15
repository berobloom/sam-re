# STATUS

Short: where the project stands, and what is next. History is in git; do not
keep a session diary here.

## State

- Executable: `SAM1.EXE` (MZ, LZEXE 0.91, **Turbo Pascal 5.0**, CONFIRMED);
  `findings/executables.md`.
- **The matching decompilation is complete.** `src/` (written by
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
  (the stub/keeper scaffold that led here is in git before `36f8b8f`'s
  successor).
- Source: 165 Pascal routines in `src/match/<SEG>_<OFF>.PAS`, the `.OBJ`
  blocks as NASM in `src/match/OBJ<SEG>.ASM` (`tools/tp/obj2asm.py`), the
  asm entry points in `.EXT`, the data in `<SEG>.VAR`. The largest routines
  (Touch, ActorAI, ActorFrame, the program body) are unedited output of
  `tools/tp/pasgen.py`, a pattern decompiler for TP 5.0 code.
- Names: SAM1RE notes (../SAM) and GUESS, each with its source in the
  `.VAR` comment; `tools/tp/rename.py` renames (code only, refuses a clash).
  27 globals are still `W<addr>`/`B<addr>`: mostly no reader in the image or
  no SAM1RE meaning (`69C4`/`69C6`/`69CE`/`685C`/`6856`, `6A0E..6A11`,
  `6EE8`, `6EEC..6EEF`); slot fields `W00`, `W0C`..`W12`.
- Compiler: TP 5.0 / 5.5 / 6.0 compile headless (`tools/tp/tpc.sh`); 5.0 is
  SAM's (`tools/tp/pin_version.sh`).
- Harness: DOSBox-X + MCP built (`./setup.sh` says ready); not used here.

## Next

- Names: the 29C3 and Genus asm routines; the last 27 globals need an
  experiment or a closer read; `match.py` must stay green after each rename.
