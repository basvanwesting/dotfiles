---
filed: 2026-10-12
learned: 2026-10-12
project: engage
model: claude-opus-5-5
---

# Don't Compensate for Human Races

Two people editing the same record at the same moment is a race that always exists, in every form of every app. Guarding one instance of it (a row lock, a version column, merge logic) buys nothing a user would notice and marks the unguarded siblings as bugs, so the next review asks for the same guard everywhere: an endless source of machinery. A plain read-change-write is the right shape for a human-speed edit. Races between processes are a different thing and are handled: a late background write, two inserts on one unique key, a timer firing after its state moved on.
Tell: a lock, transaction or version check whose stated reason is "two tabs", "two operators" or "two admins"; a review finding that says "lost update" where both writers are people clicking.

Example failure: engage, moving presenter-screen edits from a GenServer onto a `pin_leases` row. A fresh-eyes review flagged that two group pages on one PIN could drop each other's added screen, and I added `SELECT … FOR UPDATE` in a transaction around three edit functions. The owner: "Human race conditionals always exist, we are not compensating for that." The right response was to rebut the finding in the commit body and keep the read-change-write.
