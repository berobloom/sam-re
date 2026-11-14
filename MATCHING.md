# MATCHING: rebuilding SAM1.EXE byte for byte

The pattern is the one fnv_decomp (github.com/momusdigital/fnv_decomp) used for
a 2010 MSVC game, adapted to a 1992 Turbo Pascal one:

1. pin one exact binary;
2. recover the exact toolchain;
3. match the libraries first (they are free matches);
4. list every routine in a recipe, the plan and the progress meter;
5. a build whose layout matches **from day one** (unmatched routines as
   size-exact stubs), and every change keeps it matching;
6. rewrite routines one at a time in Pascal until each compiles to the same
   bytes;
7. name things only after they match, and mark where each name came from.

What makes it work: one complete list of work, and one check nobody can argue
with. A routine is either byte-identical or it is not.

## 0. The target (CONFIRMED)

| | |
|---|---|
| `original/SAM1.EXE` | sha256 `d8d0569b2ebf43314f92ba808bc0504f17fd69b84da1186aa065eea9ab4e24fc`, LZEXE 0.91 |
| unpacked image | 0x2E160 bytes, 2555 relocations, entry `0000:11C3`, stack `352B:4000` (`tools/real/unlzexe.py`; image and relocation set identical to `../SAM/build/SAM1_unp.exe`) |
| segments | 13 code segments + DS `2DEB` (data 0x2B0 initialised bytes, then BSS), derived from the relocated words by `tools/tp/inventory.py` |

The match is judged on the **unpacked load image plus its relocation set**,
not on the MZ header (header fields depend on the unpacker). The last step
(section 8) is the packed file.

## 1. The toolchain (CONFIRMED: TP 5.0)

Known from `../SAM` (notes, re-check before relying on them):

- **Turbo Pascal 5.0** (CONFIRMED 2026-11-14, `tools/tp/pin_version.sh`,
  `findings/executables.md` §Compiler version); 5.5 and 6.0 differ in their
  heap code. `../SAM/PLAN.md`'s "6.0 likely" is WRONG. For the source: TP 5.0
  has no objects (5.5) and no `asm` blocks (6.0), so hand-written code in the
  game is `inline(...)`, `{$L}` .OBJ externals, or `interrupt` procedures.
- Libraries: the System unit (`2CD1`, last code segment, as TP links it);
  `2CC7` (160 bytes) holds `Intr` (int86) = the **Dos** unit (LIKELY);
  `2961` holds `Delay` with a calibration loop = the **Crt** unit (LIKELY);
  **Genus PCX Programmer's Toolkit 3.56** (string "Copyright (c) Genus
  Microprogramming, Inc. 1988-89"; `../SAM/findings/formats.md` line 8;
  which segment(s) is OPEN, `29C3` is the candidate).

How to pin the version (the experiment): compile an empty program with each
candidate TPC and compare its System segment routines with `2CD1`. TP's linker
drops unused routines ("smart linking"), so compare routine by routine
(`Random` at `2CD1:0980`, the `RandSeed` LCG at `2CD1:09CF`, the runtime-error
exit), not whole segments. The candidate whose routines are byte-identical is
the compiler; one byte differing in a shared routine rules it out.

Then the compiler directives. TP code generation is deterministic and has
no optimiser, so the remaining switches show in the bytes, per unit or
per routine:

| Switch | What it leaves in the code |
|---|---|
| `{$S+}` stack check | a call to the System stack-check routine at every routine entry |
| `{$R+}` range check, `{$Q+}` overflow (TP7) | calls to System check routines after index/arith |
| `{$I+}` I/O check | a call to the System I/O-check after every file op |
| `{$F+}` far calls | `retf` and far calls for routines that would otherwise be near |
| `{$G+}` 286 code (TP6+) | `enter`/`leave`, `push imm`, shifts by immediate |
| `{$A+}` word alignment, `{$B-}` short-circuit booleans, `{$N+}/{$E+}` 8087 | data layout, boolean branch shape, float calls |

Record each unit's switches in `recipe/units.json` (`compiler`).

Running TPC: `tools/tp/tpc.sh TPDIR SRCDIR FILE.PAS` (stock `dosbox`, dummy
video driver, nothing on screen; works with TP 6.0). Alternatively
[emu2](https://github.com/dmsc/emu2), which runs DOS command-line tools
straight from a Linux shell and is the better fit for a build script
(not installed). Borland's files and the Genus toolkit are not committed;
point to them with `SAM2_TP` / `SAM2_GENUS` (paths outside the repo).

## 2. Libraries first

Like fnv's `HAVOK_LIB` / `CRT_LIB`: once the compiler is pinned, System, Dos
and Crt match by compiling with that compiler's own `TURBO.TPL`, and the
Genus segment by linking the Genus 3.56 unit. That is roughly 20 KB of the
121 KB of code, and their routine names come with them (tags `TP_RTL`,
`GENUS_LIB`). If the Genus 3.56 unit cannot be found, its routines become
reassembled asm (section 4) and are matched by hand like game code.

## 3. The recipe: `recipe/units.json`

Written first by `tools/tp/inventory.py` (re-run it; never hand-edit the
sizes it computes). One entry per code segment (= one TP unit, the main
program first, System last), each with its routines: `addr` (`SSSS:OOOO`),
`size` (entry to next entry, as fnv's `function_spans.py`; string literals
TP stores in front of a routine land in the routine above it), `reached`
(bytes the recursive descent decoded), `status`, `name`, `src`.

First pass (2026-11-14): 238 routines; 5 `frame_only` starts (a
`push bp / mov bp,sp` no seed reached: `0000:0008` is the keyboard ISR,
`0000:11FA` the main body; check each by hand). Status values:

- `unmatched`: the build carries it as reassembled asm;
- `matched`: Pascal source compiles to its bytes and the check proves it;
- `library`: matched by linking the library (section 2).

The progress measure is matched bytes / code bytes, as fnv reports it.

Unit-level facts the recipe must also hold, because the linker decides them
and they show in the image: the unit order (the `uses` order decides where
each unit lands), each unit's directive set, and the data segment layout
(typed constants in the initialised 0x2B0 bytes, then the variables of each
unit in link order). A routine that matches byte for byte at the wrong
address does not count.

## 4. The scaffold: the layout matches before any Pascal is written

What TP 5.0 does (CONFIRMED, `.work/q4/` experiment 2026-11-14, see
`findings/executables.md` §Toolchain facts): a unit's segment holds its
Pascal routines in source order (nested ones before their parent), then the
unit's init, then **all** `{$L}` `.OBJ` code. So asm stubs cannot sit between
Pascal routines; the routine-by-routine `.OBJ` scaffold is impossible.
SAM's own units show the same shape (Crt, Genus, `29C3`, `25E6`: Pascal
first, asm after the init).

Instead the scaffold is **size-exact Pascal stubs**. Code and DS offsets in
TP code are plain immediates (`mov di,0x1545`, `mov ax,[0x6a0f]`), not
relocations, so a matched routine can only be byte-identical when everything
in front of it in its segment, and the whole data segment, has the original
size and order. Hence:

- every unmatched routine is a Pascal stub at its place in the unit, with a
  body `Inline(...)` of filler bytes so the stub compiles to exactly the
  original span (the frame `55 89 E5` + filler + `89 EC 5D CB` = 7 bytes of
  compiler code around the filler; string literals TP puts in front of the
  next routine count against the stub's span); the generator takes spans
  from the recipe, never image bytes, so stubs can be committed;
- every unit declares its variables and typed constants in the original
  order and sizes from day one (unknown ones as `array[..] of Byte` blocks,
  split and named as routines get matched);
- the units are listed in the `uses` order that reproduces the init order
  (`recipe/units.json` `init_order`) and so the segment order;
- smart linking (CONFIRMED, §Toolchain facts) drops whatever nothing calls
  or names, in game units and in System/Crt/Dos alike. So each unit gets a
  **keeper**: its largest stub's filler starts with calls to every other
  stub of the unit and `Inline(>Var)` for every variable block and typed
  constant (2 bytes each, counted as filler), and the init calls the keeper.
  The runtime needs the same: statements in the keepers that use exactly
  the 54 System, 23 Crt and 3 Dos routines SAM links, no more (a missing or
  extra one moves everything after it); `tools/tp/rtlcmp.py` on the build
  shows which;
- the variables: program-level variables are never dropped, and the program
  comes first in DS, so the scaffold can declare the whole region of the
  program and units `0529`..`25E6` (DS:02A2 up to Genus's first variable) in
  the program, and split it into units as they are matched;
- the switches: `{$S-}` everywhere (CONFIRMED: no call to the stack check
  `2CD1:0244` anywhere); the rest are set per unit as matching shows them.

With that the build has every routine at its original address, so section
5 can compare at fixed addresses. Libraries (System, Dos, Crt) come from TP
5.0's TURBO.TPL; Genus (`2643`) needs its 3.56 TPU or becomes Pascal + an
`.OBJ` reassembled from the image (NASM `-f obj` works with TP 5.0 if the
segment is `CODE` with **no class**, and public names are upper case).

## 5. The check: `tools/tp/match.py` (to write)

Build with `TPC /GD` and `{$D+,L+}` in every unit: the `.MAP` then gives each
unit's segment and, for every source line, its code address. Every
routine's `begin` line carries its original address as a marker
(`begin { @0529:0837 }`), so the check pairs each source routine with its
recipe entry through the map, private and nested routines included (the
map's public list alone misses those).

For every routine marked `matched` it compares, at the original address:

1. the bytes of the routine's span (CS/DS immediates included: a layout
   slip anywhere earlier shows up here);
2. its relocations (same positions, same target segments);

and for the whole build: every segment's start and size, and the
initialised data (DS `0..0x2AF`). Unmatched stubs are only checked for size.

It reports per routine `match` or the first differing offset and the count;
it never prints image bytes, so its output can go in commits. Exit 0 only
when every `matched` routine and every size holds. A change that breaks any
of them is rejected, without exception. The end state is the whole image
and relocation table identical (section 8).

Prove the check can fail (METHOD.md section 6): change one byte of a matched
routine's source output and see it named.

## 6. Matching one routine

1. Pick the next routine from the recipe: smallest first within a unit, or
   the one a matched caller needs.
2. Read its disassembly (`tools/real/disasm16.py`, or `ndisasm -b16`: see
   `../SAM/GOTCHAS.md` iter 160, capstone decoded parts of CODE_1 wrong).
   Ghidra's decompile is a draft only.
3. Write Pascal. Recurring TP shapes (from `../SAM/GOTCHAS.md`): params
   pushed left to right (the first argument is the highest `[bp+n]`); `case`
   compiles to compare chains with three link shapes, not jump tables; a
   same-segment far call is `push cs` + near call; small routines can be
   inlined into several copies; arrays are reached through `shl`/`mul` index
   math on the element size.
4. Compile, run the check, adjust until byte-identical. Typical misses:
   `Integer` vs `Word` (signed vs unsigned jumps), `Byte` vs `Integer` locals
   (byte ops), `with` blocks (they keep a pointer in a temp), the order of
   local declarations (frame offsets), `if` vs `case`, `Inc(x)` vs `x := x+1`
   (different code in TP).
5. Set `status: matched` in the recipe, commit (`Match: SSSS:OOOO name`).

### Where a matched routine lives

`src/match/<SEG>_<OFF>.PAS` holds the routine as written, plus directive
comments: `{ interface }` (declare it in the interface, i.e. far; a routine
that ends in `retf` and is called from other units), `{ keep: STATEMENT }`
(how the unit's keeper uses it so the smart linker keeps it, e.g. `if
JumpButton then`). Its `begin` stands alone on a line (the fit and the check
find it through the map's line numbers). `tools/tp/gen_scaffold.py` pastes it
into the unit in place of the stub; `tools/tp/match.py --update` sets the
recipe status. `{ from: XXXX }`: the routine's string literals start at XXXX
(TP puts a routine's literals in front of its code). `tools/tp/rdiff.py
SEG:OFF` shows target and build side by side from the first difference.

Other files in `src/match/`: `<SEG>_<OFF>.EXT` an asm entry of the unit's
`{$L}` block (`{ interface }` exports it); `<SEG>.USES` the unit's uses
clause; `<SEG>.VAR` the unit's types and variables in place of its byte
block. In a .VAR, `{ @XXXX }` after a declaration pins its DS address: the
fit puts a pad before it (`P_XXXX`, sizes in `src/FILL.JSON` under `data`),
so unknown variables between known ones need no declaration yet.

### Data traps (CONFIRMED by builds)

- TP 5.0 **word-aligns** a variable of 2+ bytes (Integer at an odd address
  moved up one). A word at an odd DS address is therefore a field of a
  packed record (e.g. the state store DS:6D3E, `TState` in `2891.VAR`).
- `array[1..N]` at BASE is indexed as `[di + BASE - size]`: read the base
  from the displacement plus one element size.
- A nonzero LongInt constant is stored as two `mov word [x], imm`; an
  Integer/Word one as one, and zero as `xor ax,ax` + `mov` (25E6 init).

### Code traps (CONFIRMED by builds)

- Source lines over 127 characters: "Error 11: Line too long" (comments too).
- A private `{$F+}` routine's `forward` declaration must be `{$F+}` as well
  (the forward decides near/far; the generator does it).
- Operand order: target loads `Fg` before `Bg shl 4`; `(Bg shl 4) or Fg`
  matches, `Fg or (Bg shl 4)` does not (25E6:0000). TP evaluates the right
  operand of `or` first here; try the swap when only the order differs.
- A function returning String gets the result address at the highest
  `[bp+n]` and does not pop it (`retf` counts the parameters only).
- `{ keep: - }` on a private routine reached through exported ones: no keeper
  call (it may need arguments).

## 7. Names, after the match, with their source

Every name in `src/` carries a marker on the line before the declaration:

```pascal
{ src: TP_RTL 2CD1:0980 }
{ src: SAM1RE 0529:0837 (CONFIRMED) }
{ src: GUESS 0D9C:2C6E (confidence: medium) }
```

| Tag | Source |
|---|---|
| `EXE` | the binary itself: a string that names the routine, the Turbo Pascal runtime-error map |
| `TP_RTL` | a byte-identical routine of the Borland System / Dos / Crt units |
| `GENUS_LIB` | a byte-identical routine of the Genus PCX Toolkit 3.56 |
| `SAM1RE` | `../SAM` findings; carry that note's evidence level |
| `GUESS` | a best guess from what the code does; confidence high / medium / low as fnv defines them |

One tag per name, the most reliable source first. Renaming never changes the
bytes, so renames always pass the check (TP routine names are not in the
image; only order and size matter).

## 8. Last: the shipped file

Pack the matched build with LZEXE 0.91 (`../cosmore/src/LZEXE91/LZEXE.EXE`)
and compare with `original/SAM1.EXE`. LZEXE is deterministic as far as known
(LIKELY; untested), so a matching image should pack to the shipped file.
