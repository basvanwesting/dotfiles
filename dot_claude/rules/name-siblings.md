---
filed: 2026-09-26
learned: 2026-09-26
project: engage
---

# Name Siblings at the Same Level

When a second variant of something appears, the first one loses its generic name: siblings are named for what distinguishes them, and the generic word becomes the family (the module, the doc heading, the UI group label) — never one sibling's name. Adding a variant therefore includes renaming the existing one, with the data migration / snapshot bump that costs; leaving `foo` beside `foo_bar` to save that rename is the failure. Tell: a parenthetical or a suffix needed to explain the old name ("`:speed_duel` (year)"). Same rule for functions, fields, CSS classes and catalog atoms.

Example failure: title mode added as `:title_duel` beside the existing `:speed_duel`, so the family name stood in for the year variant; caught in review ("this naming sucks obviously") and renamed to `:year_duel` / `:title_duel` with `SpeedDuel` as the family module.
