# Actors: kinds, spawns, pickups, doors

## Summary

What the matched source's bytes mean at run time, from the 2026-11-15 live slot-by-slot A/B
of old SAM's port against the original (chat history; the old repo is gone). The matched
source in `src/match/` is the truth for the bytes. Kind numbers are slot `+1C` (`TSlot`).

## Findings

- **Walker kinds 1..6 move at speeds 1,1,2,2,2,2;** kinds 4/5 (`g`, `G`) shoot along the
  player's row when facing them; kind 6 (char `0x7F`) turns only at walls and its wreck
  (sprite 0x271) is removed after 11 frames. CONFIRMED (creator bytes; live slot dump of
  level 4).
- **Char `0xD1` creates kind `0x1A`, a +10000 pickup** (creator `0D9C:8FDA..9142`, body
  `0529:2828..29A1`: when |dx| <= 9 and |dy| <= 0xF, sound 5, +10000, a popup), on levels 7,
  13, 15, 16. CONFIRMED (bytes; live counts).
- **Levels 2..17 spawn 269 entities,** from both records of a row (the base row, then its `*`
  overlay row) and from the row-24 record (level 14 has a kind `0x2C` there). CONFIRMED
  (recount and live A/B of all 16 levels).
- **Per-kind spawn details:** kinds `0x0F` and `0x2B` spawn one row up, `0x10` one column
  left; kinds `0x29`/`0x2B`/`0x2C` start with direction 0 (all others 1); kinds `0x0F..0x12`
  each have their own base animation cell (`0x1AD`/`0x1B5`/`0x1D7`/`0x1DF`); shooter kind
  `0x0A` fires `0x1D6` at x+8, kind `0x0C` fires `0x1E8` at x+16, one shot per kind.
  CONFIRMED (live A/B, then bytes).
- **Char `0xD4` is harmless;** only its sibling `x` (sprite `0x103`) hurts, and it animates two
  steps per frame. CONFIRMED (bytes).
- **The fall counter `JumpUpTop` (DS:3510) is set to 18 once, in StartupInit `2891:0136`, never
  per level:** it carries over between levels; resetting it made the level-4 player fall
  through a platform. CONFIRMED (`2891_0136_StartupInit.PAS` line 165 is the only store
  outside Jump `0529:6A0E` and Fall `0529:66B3`; live A/B).
- **Kind `0x16` is the `q` exit door; opening it clears the cell one row above, (x, y-1):** the
  `dec ax` at `0529:22D3` acts on the y term. CONFIRMED (disassembly re-read 2026-10-30).
- **The game's Random stream is never reseeded** (no `Randomize` in `src/match/`; RandSeed at
  DS:029C), so a scripted run is deterministic, but the seed at level entry depends on what
  ran before (0xABCC6465 at the loader after title and world map in one run): read it live.
  STRONGLY SUPPORTED (grep; one live read).

## Traps

Old-SAM claims that were RETRACTED (keep them out of names and notes):
- "World stride 0x219 at `0529:23F4`" (overnight iter 18): a phantom, removed by iter 25.
- "Sound census 15/12/3" (iter 27): invented, replaced in the same pass.
- "Kind `0x1A` has no creator": its creator is `0D9C:8FDA`.
- "`0xD4` hurts on contact": it does not.
- "Up/down do not change the pose": they do (KeyISR sets the sprite on the world map).
- "Cell draws `0D9C:0000`/`0D9C:2530` have no callers": 169/121 callers; `callers.py` had
  been run at the wrong segment index.
- The door clearing (x-1, y) (old iter 32), and its off-by-3 address `0529:22D0`.
