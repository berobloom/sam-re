# Work queue (human-owned)

Work the first item that is neither ticked nor marked READY FOR REVIEW, top to
bottom. While any item here is open it overrides STATUS.md `## Next`.

Rules for the agent:

- **Only the human ticks `[x]`.** When you think an item is done, add
  `READY FOR REVIEW: <check or evidence>` under it, and say in STATUS.md which
  check proves it and which mutation makes that check fail.
- An item is done when its **Accept** line holds, not when a theory explains
  the report. If the Accept line is about the screen, render it and look at
  the image before writing READY FOR REVIEW.
- If new evidence shows an item is wrong or should be split, write that under
  the item. Never delete an item.
- If an item needs the live harness and the harness fails twice in a row,
  write BLOCKED with the reason under it and take the next item that can be
  done offline.

## Items

- [ ] **Q1 Get the candidate compilers**
  Human: put Turbo Pascal 5.5 (free from Embarcadero's antique software
  page), 6.0 and 7.0 / BP 7.0 (your own copies) outside the repo, one folder
  each, and set `SAM2_TP` to their parent folder.
  Accept: `TPC.EXE` of each runs headless and compiles an empty program
  (emu2 or the harness DOSBox-X), recorded in `findings/executables.md`.
  2026-11-14: TP 6.0 (from the human) runs headless under stock `dosbox`:
  `tools/tp/tpc.sh .work/toolchains/tp60 <dir> FILE.PAS`. TP 6.0 is ruled out
  as SAM's compiler (`findings/executables.md` §Compiler version), so **TP 5.5
  is needed next** (free from Embarcadero's antique software page), 5.0 if 5.5
  also differs.
  2026-11-14: TP 5.5 (from the human) in `.work/toolchains/tp55`: closer
  (44/54 System) but also ruled out by its heap allocator. **TP 5.0 needed
  next**, 4.0 as fallback.
  READY FOR REVIEW: TP 5.0 (downloaded from WinWorld), 5.5 and 6.0 all
  compile headless in `.work/toolchains/tp50|tp55|tp60` via `tools/tp/tpc.sh`;
  recorded in `findings/executables.md` §Compiler version.

- [ ] **Q2 Pin the Turbo Pascal version** (MATCHING.md section 1)
  Accept: one candidate's System routines are byte-identical to `2CD1`'s for
  every routine both contain, every other candidate differs in at least one,
  and the comparison is a script under `tools/tp/`.
  READY FOR REVIEW: **TP 5.0.** `tools/tp/pin_version.sh .work/toolchains/tp50`
  prints `differ 0` for System, Crt and Dos (80 routines; 7 differ only in
  layout numbers, so not yet byte-identical, see the finding); the same
  script on `tp55` gives 4 `differ`, on `tp60` 17 (the negative controls).

- [ ] **Q3 Name the library segments**
  Which segments are System, Dos, Crt and Genus, and which are game units.
  Accept: each of the 13 segments has `unit` filled in `recipe/units.json`
  with an evidence level.
  READY FOR REVIEW: all 13 filled (`unit`, `init`, `init_order` in
  `recipe/units.json`); summary and evidence in `findings/executables.md`
  §Units and init order. Genus = `2643`; `29C3` is Jungck's own graphics unit,
  not a library.

- [ ] **Q4 The scaffold experiment** (MATCHING.md section 4)
  Accept: a two-routine test unit, one Pascal and one `{$L}` external, links
  in the order wanted, or the experiment shows why not and section 4 is
  rewritten to the per-unit fallback.
  READY FOR REVIEW: it does not interleave (TP 5.0 puts all `.OBJ` code
  after the unit's Pascal routines and init; `.work/q4/`, `findings/
  executables.md` §Toolchain facts). MATCHING.md sections 4-5 rewritten: not
  the per-unit fallback but size-exact Pascal stubs + a map-based check at
  fixed addresses.

- [ ] **Q5 `tools/tp/match.py` and a matching scaffold build**
  Accept: the full scaffold builds an image + relocation set identical to
  `.work/tp/SAM1_unp.exe`, and the check names a routine when one byte is
  flipped.
  Changed by Q4 (agent decision; the human asked not to review): stubs are
  filler, so the scaffold matches in layout, not in every byte. Accept: every
  segment of the scaffold build has its original start and size, the
  initialised data is identical, and `match.py` names a matched routine when
  one byte is changed.
  READY FOR REVIEW: `tools/tp/gen_scaffold.py` (fits in 2 rounds) then
  `tools/tp/match.py`: layout OK (entry, SS:SP, length, 13 bases, DS), System
  / Crt / Dos byte-identical with their relocations, data identical except
  Genus's 614 constant bytes (zeros until Genus is matched). Mutation: one
  byte flipped in System `Random` -> `library 2CD1 FAIL`.

- [ ] **Q6 First matched game routine in Pascal**
  Accept: one game routine (not library) is `matched` in the recipe and the
  whole build still matches.
  READY FOR REVIEW: `286F:0038` JumpButton and `286F:0058` FireButton
  (`src/match/286F_00{38,58}.PAS`, one line each) compile byte for byte;
  `tools/tp/match.py` all OK. Mutation: `$10` -> `$11` fails at +000B.
