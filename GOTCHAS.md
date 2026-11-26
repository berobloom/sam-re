# GOTCHAS: read every session

The traps that cost the most time, in one screen. The full list, by topic, is
`harness/TRAPS.md`: grep it when something looks impossible.

Rules for this file: one line or two per trap; harness, tool and process traps
only (game traps go in the findings file's `## Traps`); delete an entry when it
stops being true. Mark an entry `[generic]` when it is not about this game, so
it can be copied back into DREA.

## The ones that waste whole sessions

1. **Address arithmetic.** Real-mode linear = seg × 16 + off (one hex digit,
   0x824 × 16 = 0x8240). Compute with `python3 -c`, never in your head. Above
   0xFFFFF is your error, not the emulator's.
2. **A breakpoint that never fires** is far more often a wrong address than
   code that never runs. Recompute before concluding anything.
3. **gdb `eip` is always linear** (the stub adds the CS base), after any
   stop: never add CS × 16; offset = eip − CS × 16. The old rule "an offset
   after an interrupt" was wrong (Dave: CS 0x824, eip 0xF87C = 0824:763C).
4. **Segments and LE deltas change per boot** (launch method, `.conf`,
   `memsize`). Derive them each boot; notes record image addresses or CS
   offsets, never absolute run-time addresses.
5. **`E8 rel16` is 3 bytes**: target = (site + 3 + rel16) & 0xFFFF.
6. **One client per port** (GDB 2159, QMP 4444). A failed tool can leak a gdb
   client: kill that gdb by its PID (`ss -tnp` on the port, or `/proc/PID/cwd` inside
   this repo), never by name - `pkill -x gdb` also kills another project's gdb; then
   re-attach. Ports not listening?
   `grep 0A /proc/net/tcp | grep -E ':086F|:115C'`.
7. **`gdb_command` answers one call behind**, and runs only the first line.
8. **Run vs halt.** QMP (screenshot, save/load state, restart) needs a
   running guest; memory reads need a halted one. Keys sent while halted are
   queued; screenshots of a halted guest are frozen. Interrupt → read →
   continue → save.
9. **QMP `send-key` releases too early** for games with their own INT 9
   handler: send real down/up events with a hold of 0.08–0.3 s
   (`tools/dosrun.py key`).
10. **`load_state`** only into a session where the game already runs in its
    video mode; afterwards the BIOS mode byte 0x449 may lie (write 0x13 back).
11. **A `.state` is a ZIP whose `Memory` member is linear RAM** after a
    136-byte header: read it offline (`tools/real/statedump.py`). The VGA
    framebuffer is not in it.
12. **Time in BIOS ticks** (0x46C, 54.9 ms), not wall time: `cycles=fixed`
    is not real time on a busy host, and `clock()` delays end on a tick.
13. **Ghidra drops Watcom register arguments** (`in_EAX`): read call sites in
    the disassembly. [generic] (from the DREA template; this game is TP 5.0)
14. **Notes are not proof, and a check that cannot fail proves nothing.**
    Re-check a claim against the code before building on it; put the bug back
    and watch the check fail.
15. **One agent per worktree and per harness.** Commit each deliverable with
    explicit paths as soon as it exists; never end with a dirty tree.
16. **What is on the screen may not come from the file you decoded.** Read
    the BIOS mode byte 0x449 first; then find the screen's bytes in RAM (see
    METHOD.md, "Finding assets from the screen"). [dave]
17. **The same call failed twice with the same message: stop repeating it.**
    Change the approach, or mark the item BLOCKED and work offline.

## This project's traps

- **`../SAM` is gone.** The old project's directory no longer exists, so every pointer into
  it (CLAUDE.md, MATCHING.md §6/§7, SOURCE.md, executables.md, the `{ src: SAM1RE ... }`
  comments) dangles; its GOTCHAS 172/173 and port audit survive only in the chat history
  (summarised in METHOD §7 and findings/actors.md). SAM1RE names cannot be re-checked
  against their old notes. (2026-11-26)
- **dos-re-suite's MCP server may still have the "one reply behind" gdb bug** fixed in
  re_cold `dceb197` (`set tcp connect-timeout 3`, kill gdb on a startup timeout,
  `_mark_dead()` kills the child, a QMP liveness check per call): dos-re-suite's
  `mcp/server.py` has no connect-timeout and `_mark_dead()` (~line 969) only drops the
  handle. LIKELY (code reading, not reproduced). Fix the tool, not this note. [generic]
- **The first QMP call after a DOSBox restart fails; retry once** (the cached client points at
  the killed process). "CANNOT READ THE VIDEO MODE" right after a restart is this. STRONGLY
  SUPPORTED (2026-11-14). [generic]
- **A hand-written QMP socket hangs while the MCP server is connected:** QMP takes one client
  and greets the next only after the first leaves (`qmp.cpp` `listen(fd, 1)`). Do not script
  QMP beside the MCP server. LIKELY [generic]
- **sam-re uses re_cold's ports (GDB 2159 / QMP 4444)** in `.mcp.json`, `harness/game.conf.in`
  and `tools/dosrun.py`; old SAM used 2160/4445 to run beside re_cold. Two such projects
  collide: give one its own pair, or check `/proc/net/tcp` first. STRONGLY SUPPORTED
- **Headless into a level:** the autoexec only mounts the drive: type `sam1` + Enter; space at
  the Apogee logo; `n` at the title; `n` at the main menu (world map, `Level` DS:6842 = 1);
  hold `O`+`N`+`D` and press `P`: "Warp to which level? (1-16)"; answer N gives
  `Level := N + 1` (`0000_11C3_Main.PAS` line 826). Verify each step: keys sent while the logo
  loads are eaten, a stray letter at the menu opens a document window (Escape). CONFIRMED
  (live 2026-11-15: DS:6842 read 4 after answering 3)
- **Under the old `sam.conf` the boot had CS 0x0824, DS 0x360F** (DS = 0x2DEB + 0x824). Per
  trap 4 that changes per launch: verify by bytes (`80 3e f9 69` at `0000:50D1`). CONFIRMED
  for that boot only
- **The DOSBox window title is `COMMAND` until the game runs:** a screenshot helper looking for
  `SAM1` fails before that. CONFIRMED (2026-11-15)

## Working with agents

From the chat history (2026-10-29..11-17) and the memory notes; most are about the overnight
local-model loop.

- **Never `pkill` by name (not `-x` either):** another project's emulator and gdb have the same
  name. Decide ownership by `/proc/PID/cwd` inside the repo. STRONGLY SUPPORTED [generic]
- **A local model invents precise claims:** overnight 20261028 iter 18 added "world stride
  0x219 at 1:23f4" (a phantom), iter 27 an invented "15/12/3" sound census; an init address
  sat a few bytes before the real store. Commits citing a disassembly range were the
  trustworthy ones: spot-check a claim against the dump before merging a night. CONFIRMED
  [generic]
- **pi's bash tool has no default timeout:** a non-advancing `while` hung a whole pass. The
  watchdog sets 600 s per call (cap 1800; longest normal call 476 s). CONFIRMED [generic]
- **Unattended-run logs blow up:** pi's `tool_execution_update` repeats the whole output on
  every update (GB-sized `.jsonl`), plus per-token lines and duplicated results. Store output
  once, kill a call past 300 updates, merge deltas (8.3 MB -> 1.6 MB). CONFIRMED [generic]
- **An overnight run that dies at start-up: compare the configured model with the served
  one** (config.json `"model"`, `pi --list-models`, the server's `/health`); always pass
  `--model`. CONFIRMED (2026-10-29, 2026-11-08) [generic]
- **Test an agent loop against a real model only in a throwaway clone:** a wrap-up steer once
  made a test run commit in the real repo. CONFIRMED [generic]
- **A manual `ctx.compact()` in a pi extension aborts a `-p` run;** rely on auto-compaction.
  LIKELY [generic]
- **A gate only the agent's prompt knows about trips on the human's edits** (STATUS.md at 37
  lines failed a 30-line gate): run the gate script before starting a loop. CONFIRMED [generic]
- **"Go over it with antislop" means a text pass only** here; the user stopped UI, mobile and
  accessibility edits: "Only text". CONFIRMED (2026-11-17)
- **Alt texts and captions say only what the capture shows** ("the first level", "above the
  shark tank" were not visible; removed in `c30fa26`). CONFIRMED [generic]
- **Do not copy another project's `.claude/settings.local.json`** (it auto-enables MCP servers;
  the permission check denied it): leave it to the human. CONFIRMED [generic]
- **After a directory rename, fix the venv and regenerate the harness config:** the venv's
  `pip`/`activate` keep the old absolute path, the harness config holds absolute paths.
  CONFIRMED (2026-11-17) [generic]
