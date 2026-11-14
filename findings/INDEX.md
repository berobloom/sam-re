# findings/ INDEX: read this first, then open ONE file

How to work: `../METHOD.md`. Status: **CLOSED** = confirmed and pinned by a
check, do not re-derive; **OPEN** = work remains (say what).

| Question | File | Status |
|---|---|---|
| Executables: format, size, sha256, entry, compiler, segments, libraries | `executables.md` | OPEN (TP version, segment roles) |
| The matching process and the recipe | `../MATCHING.md`, `../recipe/units.json` | OPEN |
| File formats and archives on the disc | `formats.md` | OPEN |
| Memory map: segments / LE objects, globals, tables | `memory.md` | OPEN |
| Startup chain, main loop, frame timing | `game-loop.md` | OPEN |
| Input: keyboard handler, key table, mouse | `input.md` | OPEN |
| Video: mode, palette, blitter, back buffer, present | `video.md` | OPEN |
| Sound: banks, PlaySound priority gate (287F) | `sound.md` | OPEN (player in main, [bp-4] at run time) |

Add a row per subsystem. Keep each file to what is true now; history lives in
git. Template: `_TEMPLATE.md`.
