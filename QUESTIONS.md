# Open questions and hypotheses

Numbered; never renumber. When one is answered, mark it **RESOLVED** with a
pointer to the finding, and leave it here so the number stays valid.

## Questions

1. <question>: what would settle it: <experiment>

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
