# Open questions and hypotheses

Numbered; never renumber. When one is answered, mark it **RESOLVED** with a
pointer to the finding, and leave it here so the number stays valid.

## Questions

1. <question>: what would settle it: <experiment>

2. **What does the `0xD1` pickup draw at spawn?** Its creator blits `DS:6DD4+3` twice
   (`0D9C:9031`, `0D9C:9055`); unidentified. What would settle it: break there and dump the
   blit's source rows. (chat 2026-11-15)
3. **Do kinds `0x17` and `0x19` ever run ActorAI's default arm?** `0x19` looked dead, `0x17`
   is created only by touch. SPECULATIVE. What would settle it: a census of `+1C := 0x17/0x19`
   stores and a live break on each. (chat 2026-11-15)
4. **Why did DOSBox close while walking the world map** during the README captures
   (2026-11-17)? Not followed up; SPECULATIVE: a harness or key-timing fault, not the game.

## Hypotheses

- LIKELY: <claim>. For: <evidence>. Against / gap: <what is missing>.
  Test: <the experiment that decides it>.

- ANSWERED 2026-11-14 (`findings/executables.md` §Toolchain facts, data
  order): code-segment order, typed constants before variables.
  **How does TP 5.0 order the units' data in DS?** SAM's initialised data
  starts with Genus's typed constants (DS:0000) and ends with System's
  (RandSeed DS:029C), while the code order puts Genus sixth of 13. Test: two
  units with typed constants and variables, used in a known order, `/GD` map.
  The scaffold (MATCHING.md section 4) needs the answer. [SAM2 Q5]
