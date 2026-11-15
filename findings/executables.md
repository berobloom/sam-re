# Executables

## SAM1.EXE

| | | Level |
|---|---|---|
| sha256 | `d8d0569b2ebf43314f92ba808bc0504f17fd69b84da1186aa065eea9ab4e24fc` | CONFIRMED |
| Packer | LZEXE 0.91; `tools/real/unlzexe.py` unpacks it | CONFIRMED (the image equals `../SAM/build/SAM1_unp.exe`, which `../SAM` checked against RAM) |
| Unpacked image | 0x2E160 bytes, 2555 relocations, entry `0000:11C3`, SS:SP `352B:4000` | CONFIRMED (unlzexe output) |
| Compiler | **Turbo Pascal 5.0** (TPC.EXE sha256 `095e26dd...`, 1988-08-29) | CONFIRMED: all 80 System/Crt/Dos routines have TP 5.0's code (73 byte-identical up to layout bytes, 7 differ only in numbers); 5.5 differs in 4, 6.0 in 17. `tools/tp/pin_version.sh`, §Compiler version |
| Libraries | Genus PCX Programmer's Toolkit 3.56 | LIKELY: the image string "Copyright (c) Genus Microprogramming, Inc. 1988-89"; the version number comes from `../SAM/findings/formats.md` line 8, not re-checked |
| Strings | "Copyright 1991 Peder Jungck", "Runtime error " | CONFIRMED (`strings`) |

## Segments (from the relocated words, `tools/tp/inventory.py`)

All CONFIRMED as segment bases (each is the value of at least 9 relocated
words). Roles are from `../SAM` notes unless stated.

| CODE_n | Seg | Size | Routines | Role |
|---|---|---|---|---|
| 0 | 0000 | 21136 | 11 | main program; entry `0000:11C3` (CONFIRMED, MZ header) |
| 1 | 0529 | 34608 | 17 | actors, physics, AI |
| 2 | 0D9C | 42592 | 9 | map, cells, level loader |
| 3 | 1802 | 56896 | 52 | menus, text windows, status line, sprites |
| 4 | 25E6 | 1488 | 13 | ? (ending film per `../SAM`) |
| 5 | 2643 | 8896 | 17 | ? (ending film per `../SAM`) |
| 6 | 286F | 256 | 5 | joystick |
| 7 | 287F | 288 | 2 | sound request |
| 8 | 2891 | 3328 | 5 | init / resets / decrypt |
| 9 | 2961 | 1568 | 23 | `Delay`: Crt unit (LIKELY) |
| 10 | 29C3 | 12352 | 27 | graphics: Genus toolkit candidate |
| 11 | 2CC7 | 160 | 3 | `Intr`: Dos unit (LIKELY) |
| 12 | 2CD1 | 4512 | 54 | System unit |
| DS | 2DEB | 0x2B0 initialised + BSS | | data |

Routine counts are the first-pass recursive descent and will grow (routines
reached only through pointers the inventory does not see).

## Compiler version

Experiment (2026-11-14): `.work/tpbuild/T2.PAS`, a program that calls ~60
System, Dos and Crt routines, compiled with TP 6.0 (TPC.EXE sha256
`2feaeb1b...`, TURBO.TPL `65079b04...`, from the 10-23-1990 floppies) by
`tools/tp/tpc.sh`, then `tools/tp/rtlcmp.py .work/tp/SAM1_unp.exe
.work/tpbuild/T2.EXE 2CD1 2CC7 2961`. Relocated words, call operands and
absolute memory operands are wildcards (they depend on layout, not on the
compiler).

- **Same code in 6.0:** Dos `Intr` and both other `2CC7` routines; `Random`
  `2CD1:0980` and the `RandSeed` LCG `2CD1:09CF` instruction for instruction
  (only the RandSeed DS offset differs: `0x29C` in SAM, `0x3E` in T2); Crt's
  `Delay` calibration `2961:0030` up to a CS-offset immediate.
- **Different code, so not 6.0 (CONFIRMED):**
  - System start-up `2CD1:002B`: SAM `mov ax,es:[2] / sub ax,0x1000 / mov
    [0x284],ax`, TP 6.0 `mov dx,es:[2] / mov [0x20],dx`, and SAM stores one
    heap variable fewer at `2CD1:0022..0x0028`.
  - `GetMem` `2CD1:0329`: after the shared `call` SAM has `jae` + a test of
    two words (`[0x288]|[0x28a]`), TP 6.0 `pop bp / jb`.
  - The string compare at `2CD1:06ED` loads the other operand first.
- **Why 5.x (LIKELY):** `Seg(top of memory) - $1000` is TP 5.x's free list
  pointer (the free list grows down from 64 KB below the heap's top); TP 6.0
  replaced that heap manager, and the two divergent routines are exactly the
  heap ones. Genus's 1988-89 copyright fits the TP 5.x years too.

TP 5.5 (2026-11-14, TPC.EXE sha256 `3155758683fc...`, TURBO.TPL
`98d24b53817...`, the 5.25" winworld set dated 1989-05-02; same T2 in
`.work/tpbuild55/`): **44/54 System, 22/23 Crt, 3/3 Dos.** The heap start-up
`2CD1:002B` now matches (`sub ax,0x1000` is in 5.5 too). Most remaining
misses differ only in immediates that hold DS or CS offsets (`mov di,0x73b8`
vs `0x68c` in `2CD1:0000`, `mov si,0xa66` vs `0xc53` in `2CD1:0A14`,
`mov ax,0xcb7` vs `0xea4` in `2CD1:0BA2`, `2961:0000`): layout, not compiler.
**Not 5.5 (CONFIRMED):** the free-list allocator `2CD1:0446` is the same up
to its heap-top arm; there SAM ends `clc / ret` (`2CD1:049D`), while 5.5 goes
on into a `HeapError` retry loop (`pop ax / mov cx,[HeapError] / or cx,[..+2]
/ je / lcall [HeapError] / ... / jne` back to the top). SAM tests `HeapError`
in `GetMem` itself instead (`2CD1:0329`: `call 0x446 / jae / mov
ax,[0x288] / or ax,[0x28a] / je`). So SAM's compiler predates 5.5's heap
code.

**TP 5.0: CONFIRMED** (2026-11-14). WinWorld "Borland Turbo Pascal 5.0
(5.25-360k)", files dated 1988-08-29: TPC.EXE sha256
`095e26ddb83386eb8d90509faf1e9a3d63a2f81fffb43fb2ff7968b228936c34`, TURBO.TPL
`b3b699c6736c00b4075f8fc39871a9eab5a8b933b1696dff3e1572cf7ca3b5ae`.
`tools/tp/pin_version.sh TPDIR` builds `tools/tp/rtltest/T2.PAS` + `T3.PAS`
(T3 adds the two helpers T2 never linked: `2CD1:025D` = copy a structured
value parameter into the frame, e.g. `0D9C:68BE` copies 0x2A bytes; `2CD1:08D4`
= set membership against a set constant) and classifies each routine
(`tools/tp/rtlcmp.py`: `same`, `layout` = only numbers differ, `differ`):

| Compiler | System 2CD1 (54) | Crt 2961 (23) | Dos 2CC7 (3) |
|---|---|---|---|
| 5.0 | same 48, layout 6, **differ 0** | same 22, layout 1, **differ 0** | same 3 |
| 5.5 | same 46, layout 4, differ 4 (`0329 0364 0446 06ED`) | same 22, layout 1 | same 3 |
| 6.0 | same 36, layout 3, differ 15 | same 19, layout 2, differ 2 | same 3 |

The 5.0 `layout` routines (`2CD1:0000 00D8 0329 0364 0A14 0BA2`, `2961:0000`)
differ only in immediates holding DS/CS offsets (`mov di,0x73b8` = the
`Input`/`Output` records) and in jumps to the shared runtime-error exit; they
should become byte-identical once the program's own data and code are laid
out like SAM's (LIKELY until the scaffold build shows it). The 5.5 and 6.0
rows are the negative control: the classifier does tell compilers apart.

## Units and init order (Q3)

The program entry `0000:11C3` far-calls the unit inits in this order
(CONFIRMED, disassembly): System `2CD1:0000`, `29C3:0070`, Crt `2961:0000`,
`2891:0C0D`, `287F:0116`, `286F:0078`, `2643:0000`, `25E6:048C`,
`1802:DE33`, `0D9C:A658`, `0529:8724`, then the main body at `0000:11FA`.
That is exactly the reverse of the code-segment order, with Dos (no init)
between `29C3` and System, so `29C3` is Dos's first user. Each segment's unit,
kind and evidence is in `recipe/units.json` (`unit`); in short:

- Borland TP 5.0 libraries: System `2CD1`, Dos `2CC7`, Crt `2961` (CONFIRMED).
- **Genus PCX Programmer's Toolkit 3.56 = `2643`** (STRONGLY SUPPORTED): Pascal
  init at `2643:0000` (15 bytes) then asm; `2643:0241` loads DS:0098, the
  head of a 22-entry video-mode name table ("CGA 320x200x4" .. "Video7
  800x600x256", 21-byte entries); DS:000E holds "PCX Programmer's Toolkit
  3.56", the Genus copyright and "Christopher A. Howard", DS:0090 "EMMXXXX".
  Called from `0000` (1 site) and `1802` (10).
- **`29C3` = Peder Jungck's own graphics unit** (CONFIRMED author): its code
  segment opens with four 28-byte string literals ("Copyright 1991 Peder
  Jungck", his address); its Pascal init `29C3:0070` sets the video mode
  (`1A3`, `1C5`, `27E2`, `2981`, `625`) and copies those literals to DS:7166
  (`System 064E` = string store, 0x50); the rest is asm.
- The other seven (`0000` main, `0529`, `0D9C`, `1802`, `25E6`, `286F`,
  `287F`, `2891`) are game Pascal units; `25E6` ends with 0x144 bytes after its
  init (asm), role OPEN.

DS order: answered below (§Toolchain facts, data order). For SAM it gives
(STRONGLY SUPPORTED): the main program and `0529`..`25E6` have **no typed
constants**; Genus's typed constants are DS:0000..0x0265 (its mode table
ends exactly there); System's 0x3C-byte block is DS:0266..0x02A1, which puts
RandSeed at 0x266+0x36 = **0x029C, where SAM has it** (`2CD1:09CF`). The
variables start at DS:02A2 (TP does not align the start), main program
first; System's `Input` is at DS:71B8 (`2961:0006` `mov di,0x71b8` is Crt's
`AssignCrt(Input)`), `Output` at 0x72B8 (`2CD1:0138`). 29C3's init writes a
0x50-char string at DS:7166, so 29C3's variables end at or just below
0x71B8, with Crt's before them.

## Toolchain facts (TP 5.0, experiments in `.work/q4/`)

- **Unit layout** (CONFIRMED, `.work/q4/U.PAS` + `Q4.MAP`): Pascal routines in
  source order (a nested routine before its parent), then the init, then all
  `{$L}` `.OBJ` code. Routines and externals declared interleaved still come
  out Pascal-first.
- **Map file** (`TPC /GD`): segments per unit, publics (interface routines,
  interface and System variables), and with `{$D+,L+}` a line-number table
  for every unit. Implementation-only routines and variables are NOT in the
  publics.
- **NASM** `-f obj` makes `.OBJ` files TP 5.0 links, if the segment is
  `segment CODE public align=1` with **no class** (with `class=CODE` TPC says
  "Error 51: Invalid PUBLIC definition") and public names are upper case.
- **Switches**: SAM has no call to the stack check `2CD1:0244` (it is linked,
  0 callers), so `{$S-}` (CONFIRMED). TP 5.0's default is `{$S+}`: a stub
  without `{$S-}` grows by `xor ax,ax / lcall System:0244`.
- **Data order** (CONFIRMED, `.work/q5/D.PAS`, units UA/UB/UC): two blocks,
  typed constants first, then variables; each block in **code-segment
  order** (program, units in code order, System last). Example: code D, UB,
  UC, UA, System; constants TCD 0, TCB 2, TCC 4, TCA 6, System's 0x08..0x43;
  variables VD 0x44, VB, VC, VA, then System's `Input`.
- **Smart linking drops unused data in units** (CONFIRMED, `.work/q5/F.PAS`):
  a unit's unused routine, typed constant and variables (public or private)
  are left out; the main program keeps its unused variables (`E.PAS`).
  `Inline(>Var)` counts as a use and keeps a variable (`G.PAS`: +8 bytes for
  VY1+VY2); `Inline` cannot name a routine ("Error 143: Invalid procedure or
  function reference", `H.PAS`), so a routine stays only if linked code calls
  it. System, Crt and Dos are smart-linked the same way: the build links only
  the runtime routines its code uses.
- **Crt's variables in TP 5.0** are 0x14 bytes (CheckBreak .. WindMax and
  private ones), just before the next unit's (`.work/q5/T2.MAP`); `DosError`
  is dropped when unused.

## Runtime set and heap (Q5)

- **The runtime SAM links** (CONFIRMED, `tools/tp/rtlmap.py` against
  `tools/tp/rtltest/T4.PAS` / `T2.PAS`): the 31 System entry points called
  from game code map to: string store `064E` (x695), compare `0724`, `Random`
  `0980`, typed-file `Read` `108C`, `GetMem` `0329`, char->string `074F`,
  concat `06C1`/`0634`, `Assign` `0FA9`, `Close` `1058`, `Reset(f)` `0FD7`,
  `IOResult` `0207`, set `in` `08D4`, `Copy` `0680`, `Str` `0B26`, LongInt
  multiply `0279`, `Pos` `06ED`, `FreeMem` `0364`, `Val` `0B71`, `Write(t,s)`
  `0F6B`, `Writeln(t)` `0EEE`, `Delete` `07D0`, `Rewrite(f)` `0FE0`,
  `Write(f)` `1093`, `Halt` `00D8`, value-parameter copy `025D`, `MemAvail`
  `03B5`, `Reset(t)` `0C12`, `Rewrite(t)` `0C17`, `FillChar` `117D`, start-up
  `0000`. Dos: `Intr` (with `MsDos` at `2CC7:0000`), `GetIntVec`,
  `SetIntVec`. Crt links whole (one `.OBJ`). One use of each, in
  `src/RTLKEEP.INC`, makes TP 5.0 emit SAM's System, Dos and Crt **byte for
  byte** (`tools/tp/match.py`, `library` lines).
- **Heap and header** (CONFIRMED, `tools/tp/pack.py`): the stack is 16384
  (SS:SP as TP writes it); the file LZEXE packed had min/max alloc
  3248/44208 paragraphs. LZEXE maps them one to one (packed min = input +
  8234, packed max = input + 8645; measured with inputs 2837/43797 and
  3248/43797), and the matched build with exactly these two words set packs
  to the shipped SAM1.EXE byte for byte. TP 5.0 cannot write that pair here:
  the default `{$M 16384,0,655360}` gives 2837/43797, heapmin 6576 gives the
  minimum, and the maximum would need heapmax 661936, which TP rejects. So the
  two words were edited after linking (LIKELY an EXEMOD-style tool). This
  corrects the earlier reading that the unpacked header's values are
  LZEXE's own.
