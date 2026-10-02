---
filed: 2026-09-26
project: engage
---

# Challenge Weak Requirements; Count Supporting Machinery

A feature's cost is itself PLUS every piece of supporting machinery it drags in (state fields, widened signatures, generic UI components, config/API surface). A human hand-writing that plumbing feels friction that acts as a design signal — AI doesn't, so:

- When a request is weakly specified or weakly motivated, question the requirement FIRST (what need? who uses it? does an existing mechanism serve it better?) instead of implementing it well.
- When proposing a feature, enumerate its supporting machinery as part of the price. Machinery only one feature needs is a red flag — prefer deriving from existing state.
- Before extending a mechanism, check whether it's used at all (grep / DB query). Prefer removing unused mechanics over building on top.

Example failure: a vague "reward fast answers" idea (`speed_bonus_values`) dragged in an order-tracking state field on two structs, a widened scoring signature, a generic UI component, and config/API surface — never used by any stored design; removal touched 12+ files.
