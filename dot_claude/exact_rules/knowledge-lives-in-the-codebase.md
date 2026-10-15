---
filed: 2026-10-15
kind: knowledge
project: dqs
model: claude-opus-5-5
---

# Knowledge Lives in the Codebase; Rules Are an Inbox

A learning that spans repos is a global rule. Everything else ends up in the codebase, at the narrowest scope that contains every site it constrains: the class doc for one class, the CLAUDE.md of the domain for a decision on that domain, the root CLAUDE.md for what spans every domain (a separate decisions doc only once the root outgrows ~300 lines with its imports). A decision about code not yet written lives at the extension point that code will start from. Anything not auto-loaded is named by one line, by class, in a file that is. Local rules (`.claude/rules`) are an inbox, never a home: a sweep generalizes each into the codebase or deletes it, checking the root's size before moving a block into it. CLAUDE.md is the agent file; AGENTS.md documents for external agents. A generator-written AGENTS.md is an inbox like a local rule: its project decisions move into the codebase, its framework patches carry the model they were written for and expire with it.

Write down only what the code cannot say: the why of a decision, the trade-off chosen, knowledge from outside the repo. A fact the code already states is deleted, not moved; a fact that is moved is checked against the code first. Nested CLAUDE.md files hold decisions, never facts. A decision names its premise, so it can be reopened when the premise changes. Write the reason, not the instruction: a reason lets a stronger model handle cases its author never saw, an instruction caps it at the author's foresight.

Learnings come in two kinds that age differently. Knowledge: a choice where capable experts could differ, or a fact from outside the code; a better model still needs it. Capability patch: what a strong engineer does unprompted, written because the model of the day did not; it carries the model it was learned on and goes to probation at every model release. It returns when the failure recurs, as noticed by the fresh-eyes review or the user, through /my-learn. The test: would a senior colleague, new to this codebase, need to be told?
Tell: a doc restating what the code shows (names, counts, enums, state machines); a nested CLAUDE.md holding facts; a fact moved out of CLAUDE.md with no pointer left behind; an imperative without its reason; a capability patch without a model; a local rule that survived a sweep.

Example failure: CU, 2026-10: the nested CLAUDE.md files were the most stale. One listed a crate that does not exist, counted 28 crates where 22 exist, and called an edition migration underway that had stalled (16 of 18 crates still on 2018); others named a wrapper class and a fitness.rs that do not exist.
