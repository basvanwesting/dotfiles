---
filed: 2026-09-29
learned: 2026-09-29
project: engage
---

# Group by Cohesion When a Struct Outgrows Its Size Limit

A size lint on a struct (Credo `StructFieldAmount`, a max-params check) going off means the shape has outgrown a flat list. Neither silencing the check nor bending the data to fit fixes that. Group fields by real cohesion: fields that are nil together (one nilable sub-struct), fields several structs build identically (one shared sub-struct, built once), fields always read as a unit. Keep flat whatever is pattern-matched everywhere. When sibling structs exist, design the groups across all of them, so the grouping becomes system-wide vocabulary. Tell: dropping a field or re-deriving a value in a consumer "to stay under the cap", or a per-file disable with a "the struct IS the contract" comment.

Example failure: TimelineProgram's director view hit Credo's 31-field cap. Over five changes, one commit dropped `stats`, another kept `min_win_target` off the view (so the console re-derived it from `top_counts`, a second definition of one rule), and a third per-file-disabled the check. The fix: shared `Rules`/`Tally`/`Media`/`Introduction` groups across the presenter, director and participant views (35 fields down to 16), with the cap enforced again.
