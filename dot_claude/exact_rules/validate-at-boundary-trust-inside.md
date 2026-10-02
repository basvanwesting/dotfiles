---
filed: 2026-10-01
project: engage
model: claude-opus-5-5
---

# Validate at the Boundary, Trust Inside

Requiredness and defaults belong to the boundary where data enters: the changeset, form, API and import. Once that boundary guarantees a field, the runtime assumes it is there. It gets no `|| default`, no `nil` branch, no `[]` struct default, no `:if={@x.field}` guard. Each such fallback is a second definition of the rule, untested by real data. It hides a broken boundary instead of failing loudly. And it signals to the next reader that the field may legitimately be missing. When a field becomes mandatory, the same change removes every runtime fallback for it: struct defaults and `| nil` types become enforced keys, and view guards and fallback branches are deleted. Hand-built fixtures and storybooks fill the field in rather than the struct defaulting it.
Tell: a `|| 0`, `|| []`, `if x, do:`, `:if={@item.field}` or `nil ->` clause in runtime/view code for a field the boundary validates; a struct default that exists only so test or storybook literals compile; a "nil = …" sentence in a doc comment for data that can't be nil.

Example failure: TimelineProgram, after the AssetPoolItem changeset made sing-window edges (with lyrics), artist and both letter lists required. The runtime still had `lyrics_start_at || 0` and a nil-end "no clock, director-closed" branch in `Card.sing_length/1`. `Card` still had `correct_title_letters: []` defaults and `artist: String.t() | nil`. Six views kept `:if={@card.artist}`. Every one of these compensated for data the boundary already guaranteed. The fix was `@enforce_keys` on `Card`, deleting the branches and guards, and spelling the fields out in the storybook and test cards.
