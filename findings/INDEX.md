# findings/ INDEX: read this first, then open ONE file

How to work: `../METHOD.md`. Status: **CLOSED** = confirmed and pinned by a
check, do not re-derive; **OPEN** = work remains (say what).

| Question | File | Status |
|---|---|---|
| Executables: format, size, sha256, entry, compiler, segments, libraries | `executables.md` | CLOSED (TP 5.0 CONFIRMED, every segment's unit named) |
| The matching process and the recipe | `../MATCHING.md`, `../recipe/units.json` | CLOSED (165 of 165 routines match) |
| File formats and archives on the disc | `formats.md` | not started (no file yet) |
| Globals of unit 2891 (DS:34D6..70FF): `src/match/2891.VAR` is the source of truth (pinned, matched) | `../src/match/2891.VAR` | OPEN (gaps are pads) |
| Memory map: segments / LE objects, globals, tables | `memory.md` | not started (no file yet) |
| Startup chain, main loop, frame timing | `game-loop.md` | not started (no file yet) |
| Input: keyboard handler, key table, mouse | `input.md` | not started (no file yet) |
| Video: mode, palette, blitter, back buffer, present | `video.md` | not started (no file yet) |
| Sound: banks, PlaySound priority gate (287F) | `sound.md` | OPEN (player in main, [bp-4] at run time) |
| Actors: walker kinds, spawns, pickups, doors, the fall counter | `actors.md` | OPEN (from the 2026-11-15 live A/B) |
| Menus and the title screen's timing | `menus.md` | OPEN (title timing only) |

Add a row per subsystem. Keep each file to what is true now; history lives in
git. Template: `_TEMPLATE.md`.
