---
name: memory-review
description: Review this project's auto-memory against CLAUDE.md. Promote durable learnings into CLAUDE.md, delete duplicates and shipped transient notes, keep live state. Run at end of a feature or before a PR.
disable-model-invocation: true
---

# Memory review

Memory is a staging area, CLAUDE.md is the committed team knowledge. Move durable learnings across, then remove them from memory. Duplication is a pipeline stage, not a steady state.

## 1. Inventory

- Memory dir: the path named in the system prompt ("persistent file-based memory at ..."). Read every `*.md` in it, including `MEMORY.md`.
- Instruction files: `CLAUDE.md`, every `@import` it references, `.claude/rules/*.md`, `AGENTS.md` if present. Read them all.
- If no CLAUDE.md exists, say so and propose creating one from the durable memories (section 3 still applies).

## 2. Classify every memory file

Grep the instruction files for each memory's key terms before deciding. One verdict per file:

| verdict | meaning | action |
|---|---|---|
| dup | already in an instruction file | delete memory |
| promote | durable rule, decision, or gotcha the team must know, missing from instruction files | add to CLAUDE.md (or the import that owns the topic), then delete memory |
| live | transient state still true: in-progress plan, pending prod work, status as of a date | keep; refresh the date if verified |
| stale | transient state whose work has shipped or been abandoned | verify against code/git first, then delete |
| global | personal working style, not project-specific | do NOT edit `~/.claude/CLAUDE.md` (chezmoi-managed); list as candidate for the user |
| ref | pointer to URL, bucket, dashboard, recipe | promote if team-relevant and secret-free, else keep |

Rules for promoted text:
- Rewrite as instruction or fact, not narrative. Drop "user said", session context, dates unless the date is the fact.
- Put it under the existing section that owns the topic. Create a section only if none fits.
- No secret values, only `op://` refs or variable names.
- `Why` and `How to apply` lines from feedback memories usually carry the real content; keep that, drop the frame.

## 3. Prune CLAUDE.md while there

Flag clauses that read as changelog ("removed 2026-09-11", "since 2026-09-17", "now shipped"). Instruction files state the current truth; git history holds the past. Propose removing the date or the whole clause.

## 4. Propose, then apply

Show one table: file, verdict, target section, one-line gist. Plus the CLAUDE.md prune list and the global candidates. Wait for approval. Deleting memories and editing committed team files is not reversible without git, so no edits before the user confirms.

After approval:
1. Edit instruction files.
2. Delete memory files, rewrite `MEMORY.md` index to match what remains.
3. Verify: `rg` each promoted key phrase in the instruction files; `ls` the memory dir matches the index; no dangling `[[links]]` in remaining memories.
4. Do not commit. Report changed files and suggest a commit message.
