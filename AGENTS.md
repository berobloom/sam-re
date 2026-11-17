# sam-re: Secret Agent, rebuilt to its original source

## Project goal

Rebuild the Turbo Pascal source of the 1992 DOS game Secret Agent, episode 1
(Apogee, programmer Peder Jungck): source that compiles, with the compiler and
libraries the game was built with, to **exactly** the bytes of `SAM1.EXE`
(a matching decompilation, the fnv_decomp pattern). The process is
`MATCHING.md`; read it before METHOD.md. A C or SDL2 port is a later step that
starts from the matched source, not part of this project yet.

Sister project: `../SAM` (161 iterations of behavioural RE and a C port of the
same EXE). Its `findings/` are a name and meaning source (tag `SAM1RE`, see
MATCHING.md section 6); they are notes, not proof (METHOD.md section 1). Read
them by `grep -n`, never whole: several are over 100 KB.

## Session start (in this order)

1. `git status --short`: an interrupted run may have left work behind.
2. `QUEUE.md`: the human's work list. Its first open item is the task.
3. `MATCHING.md`: the process and the state of the recipe. Then `METHOD.md`
   (trust order, evidence levels, checks that can fail).
4. `findings/INDEX.md`, then only the one findings file the task needs.
5. `STATUS.md`, then `GOTCHAS.md` (17 traps; the rest is in
   `harness/TRAPS.md`: grep it when something looks impossible).

## Context budget

Written for small local models as much as for large ones:

- Grep before reading; read a range, not a file. Never read whole:
  decompiler output (`.work/ghidra/*.c`), call graphs, the port's main
  source, `harness/TRAPS.md`, the MCP server.
- Cap every command's output (`| head -80`); every scan loop advances its
  index and has a limit.
- Large tool results are written to files: parse the file, do not call the
  tool again to see it.
- If the same call fails twice with the same message, change the approach or
  mark the item BLOCKED and continue offline. If the harness fails twice in a
  row, stop using it for this item.

## Evidence rules

Never present an inference as fact. Every finding carries a level:
CONFIRMED, STRONGLY SUPPORTED, LIKELY or SPECULATIVE (METHOD.md section 2),
plus its evidence (addresses, capture files, the experiment). Prefer evidence
from the binary and runtime experiments over external documentation.

## Where things go

| What | Where |
|---|---|
| Facts about the game, by subsystem | `findings/<subsystem>.md` (index: `findings/INDEX.md`) |
| Open questions and hypotheses | `QUESTIONS.md` |
| The recipe: every routine, its unit, size, status, name and name source | `recipe/units.json` (MATCHING.md section 3) |
| Rebuilt source | `src/` (`SAM1.PAS` + one `.PAS` per unit) |
| Function / variable names | in `src/` with a `{ src: TAG SSSS:OOOO }` marker, and in `recipe/units.json` |
| Harness and tool traps | `GOTCHAS.md` "This project's traps" (game traps: the findings file's `## Traps`); tag ones that are not about this game `[generic]` |
| Captures, states, dumps the checks use | `captures/` + `captures/MANIFEST.md` |
| What was done, what is next | `STATUS.md` |
| The human's priorities | `QUEUE.md` (only the human ticks `[x]`) |

Do not duplicate a finding; link to it.

## Not DREA

sam-re (started as SAM2) is an experiment: its findings, tools and traps stay in this repo
(`GOTCHAS.md`, `findings/`). Do not write into `../DREA`.

## Working mode

The human reviews little. Work the queue iteration after iteration, take the
sensible default where a choice is needed and write it down under the queue
item; stop only for things only the human can provide (toolchains, files).
Commit after each finished deliverable (`Match:`, `Recipe:`, `Tools:`,
`Findings:`).

## Binaries and addresses

- `original/` holds the untouched game files (read-only; checksums in
  `original/SHA256SUMS`). Derived files go to `.work/` (not committed).
- Executable: `SAM1.EXE`, MZ 16-bit real mode, LZEXE 0.91 packed, Turbo
  Pascal; details in `findings/executables.md`. Unpack:
  `.work/venv/bin/python tools/real/unlzexe.py original/SAM1.EXE .work/tp/SAM1_unp.exe`.
- Address convention: `SSSS:OOOO` with `SSSS` the segment **relative to the
  load segment** (the value the relocated word holds in the unpacked image,
  e.g. `2CD1:0980` = System `Random`), which no boot changes. `../SAM` writes
  `n:OOOO` with `n` the CODE_n index; `recipe/units.json` maps one to the
  other (`index`, `seg`). A boot's own segment only with that boot's load
  segment named.

## Running the original

The patched DOSBox-X and MCP server live in `../dos-re-suite`
(`harness/README.md`). `harness/install.sh` installs the game into
`.work/dos/C`; `tools/dosrun.py` drives it on a hidden Xvfb display (type,
keys, screenshots, memory, save states). Through MCP: the `dosre` server
(`.mcp.json`, read by Claude Code and by pi-mcp-adapter). One client per
port: never run two agents on
one harness.

Debug switches of the game: none known (`AGENTCHT.COM` is a separate cheat TSR).

## Reverse engineering rules

- Preserve the original binaries.
- Record addresses for every important conclusion.
- Small experiments that distinguish hypotheses beat long traces.
- When you discover something important, update the findings file in the
  same commit as the code that uses it.

## Commits

Commit only when asked, or (unattended runs) after each finished deliverable,
with explicit paths. Short subjects in the project's style
(`Match: ...`, `Recipe: ...`, `Findings: ...`, `Tools: ...`).
