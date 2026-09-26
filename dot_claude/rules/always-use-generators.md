---
filed: 2026-09-26
---

# Always Use Generators

When a framework generator exists for an artifact (Rails migrations/models/controllers, `cargo new`, `npm create`, etc.), run the generator first and rework its output with Edit. Generators carry the framework's current conventions (canonical timestamps, naming, placement, base classes); hand-written files carry invented ones. Example failure: hand-rounded Rails migration timestamps caused a silent master/feature version collision.
