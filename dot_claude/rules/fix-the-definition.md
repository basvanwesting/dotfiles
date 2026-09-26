---
filed: 2026-09-26
learned: 2026-09-26
project: genetic-algorithm
---

# Fix the Definition, Not the Consumer

When a fix compensates at the point of use (an offset, a `+1`/`-1`, a filter, a clamp, a `< 2` special case), the error is usually in the definition of the data being consumed. Fix it there, once, so every consumer gets it right and no call site carries special knowledge. Tell: the same compensation repeated at several sites; a sibling that already does it right by construction. Applies to reviewing PRs as much as to writing code — accept the diagnosis, redirect the fix.

Example failure: point crossover could pick point 0 (swaps whole parents). The PR sampled from `1..n` with a `.map(|i| i + 1)` and `n - 1` in three places plus a `genes_size < 2` guard; I asked only for a preloaded sampler. The right fix was MultiUnique's existing structure: derive a `crossover_points` array in `try_from` and sample its indices.
