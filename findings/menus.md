# Menus and the title screen

## Summary

Run-time timing of the title screen, from the 2026-11-15 port audit (chat history).

## Findings

- **Title: the still picture shows ~1.0 s, then the view slides without stopping, and it holds
  3.1 s at each end.** The clock gates only the start of a sweep (`1802:352E`/`1802:3600`);
  201 steps take ~3 s, paced by the retrace wait. The timer runs at 140.06 Hz (PIT divisor
  0x2147, `OBJ0000.ASM` line 60, FastTimer `0000:5261`). CONFIRMED (bytes; first sweep
  measured at 1035 ms).

## Traps

- A test that pins the pan order (0..200..0) does not pin its timing: the old port's first
  slide waited 3 s instead of 1 with that test green.
