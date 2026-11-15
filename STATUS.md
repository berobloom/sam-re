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
- Source: 165 Pascal routines in `src/match/<SEG>_<OFF>.PAS`, the `.OBJ`
  blocks as NASM in `src/match/OBJ<SEG>.ASM` (`tools/tp/obj2asm.py`), the
  asm entry points in `.EXT`, the data in `<SEG>.VAR`. The largest routines
  (Touch, ActorAI, ActorFrame, the program body) are unedited output of
  `tools/tp/pasgen.py`, a pattern decompiler for TP 5.0 code.
- Names: SAM1RE notes (../SAM) and GUESS; many globals are still
  `W<addr>`/`B<addr>`, the slot fields `W0A`..`W1C`.
- Compiler: TP 5.0 / 5.5 / 6.0 compile headless (`tools/tp/tpc.sh`); 5.0 is
  SAM's (`tools/tp/pin_version.sh`).
- Harness: DOSBox-X + MCP built (`./setup.sh` says ready); not used here.

## Next

- Names: the `W`/`B` globals, the slot fields, the 29C3 and Genus asm
  routines; `match.py` must stay green after each rename.
- `gen_scaffold.py` still carries the stub, fill and keeper machinery that the
  finished source no longer uses.
