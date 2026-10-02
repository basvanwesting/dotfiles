---
filed: 2026-09-26
project: engage
---

# Intent Beats Mechanical Rules

A lint/format rule is a proxy for readability; when the proxy and the goal conflict, the goal wins. Before enabling a style check, ask whether it can tell an intentional idiom from a mistake — if it can't (Credo `SinglePipe` judging "prepare `|>` execute" by arity), keep it as a documented convention plus review instead of machine enforcement, and say explicitly in the docs which rules are enforced and which are conventions. When a formatter or linter blocks a deliberate readability choice, surface the tradeoff rather than silently complying.
