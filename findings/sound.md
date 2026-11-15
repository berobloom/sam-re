# Sound (unit 287F + the tick handler in main)

## Data (CONFIRMED: `src/match/287F.VAR` builds at DS:3444..34D5, `match.py` data OK)

| DS | Name | Type |
|---|---|---|
| 3444/3448/344C | Bank1..3 | `^array[1..12] of TSound` (SAM101E/102E/103E.SND, ids 1-12/13-24/25-36) |
| 3450 | SndFile | `File` (start-up 0:1250..0:134B: Assign, Reset(F, $1C98), BlockRead, Close per bank) |
| 34D0 | CurSound | Integer |
| 34D2 | NoteIdx | Integer |
| 34D4 | Playing | Boolean |
| 34D5 | SoundOn | Boolean |

`TSound` = `Notes: array[1..300] of Integer` then 5 Integers (Priority at
+600 = `[di-0xA]` from the record end). Field names after Priority: SAM1RE.

## PlaySound (287F:0000), CONFIRMED by match

Source: `src/match/287F_0000_PlaySound.PAS`. If nothing plays, start the sound.
Otherwise two `case` lookups both assign **NewPri** (requested, then current
sound's priority), and `if NewPri >= CurPri` compares with **CurPri, a local
that is never assigned** (`[bp-4]`, stack garbage from the caller's frame).
So the gate is: current sound's priority >= garbage. This corrects SAM1RE's
reading ("requested >= current"). Run-time effect: OPEN (what [bp-4] holds at
the 87 call sites), SPECULATIVE that it usually lets the new sound start.

287F:0116 = the unit's empty init.
