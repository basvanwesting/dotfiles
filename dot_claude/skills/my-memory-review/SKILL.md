---
name: my-memory-review
description: Review this project's auto-memory against CLAUDE.md. Promote durable learnings into CLAUDE.md, delete duplicates and shipped transient notes, keep live state. Run at end of a feature or before a PR.
disable-model-invocation: true
---

# Memory review

Memory is a staging area, CLAUDE.md is the committed team knowledge. Move durable learnings across, then remove them from memory. Duplication is a pipeline stage, not a steady state.

## 1. Inventory

- Memory dir: the path named in the system prompt ("persistent file-based memory at ..."). Read every `*.md` in it, including `MEMORY.md`.
- Instruction files: `CLAUDE.md`, every `@import` it references, `.claude/rules/*.md`, `AGENTS.md` if present. Read them all. Project rules (`.claude/rules/*.md` in the repo) are an inbox, not a home (`knowledge-lives-in-the-codebase`): section 3a sweeps them into the codebase.
- Size: `wc -c` all of the above plus `~/.claude/CLAUDE.md` and `~/.claude/rules/*.md` (path-scoped project rules excluded). Claude Code warns past 150k chars; report the total, and the root CLAUDE.md plus its imports in lines (budget ~300).
- User rules: `~/.claude/rules/*.md` (chezmoi source `~/.local/share/chezmoi/dot_claude/exact_rules/`) and the unloaded `~/.claude/rules-probation/*.md`. Read them too; section 3c reviews them.
- If no CLAUDE.md exists, say so and propose creating one from the durable memories (section 3 still applies).

## 2. Classify every memory file

Grep the instruction files for each memory's key terms before deciding. One verdict per file:

| verdict | meaning | action |
|---|---|---|
| dup | already in an instruction file | delete memory |
| promote | durable decision, gotcha or outside fact the team must know, missing from the codebase, and passing the 3b test | put it at the narrowest scope containing every site it constrains (class doc for a fact, domain CLAUDE.md for a domain decision, root for cross-cutting), then delete memory |
| live | transient state still true: in-progress plan, pending prod work, status as of a date | keep; refresh the date if verified |
| stale | transient state whose work has shipped or been abandoned | verify against code/git first, then delete |
| global | lesson that holds in every project, not just this one | do not edit `~/.claude/` directly (chezmoi-managed); list as a `/my-learn` candidate with a one-line draft |
| ref | pointer to URL, bucket, dashboard, recipe | promote if team-relevant and secret-free, else keep |

Rules for promoted text:
- Rewrite as instruction or fact, not narrative. Drop "user said", session context, dates unless the date is the fact.
- Put it under the existing section that owns the topic. Create a section only if none fits. Never a new project rule: an area decision goes to that domain's CLAUDE.md (decisions only), an area fact to the class doc, with a one-line pointer from an auto-loaded file.
- No secret values, only `op://` refs or variable names.
- `Why` and `How to apply` lines from feedback memories usually carry the real content; keep that, drop the frame.

## 3. Prune CLAUDE.md and project rules while there

Flag clauses that read as changelog ("removed 2026-09-11", "since 2026-09-17", "now shipped"). Instruction files state the current truth; git history holds the past. Propose removing the date or the whole clause.

## 3a. Sweep project rules into the codebase

Each project rule whose last edit (`git log -1`) is older than ~4 weeks and that is not under open discussion: propose its target per `knowledge-lives-in-the-codebase`, per paragraph (class doc, extension point, domain CLAUDE.md, root block, or delete when the code already says it), checking the root's size before adding a block to it. A generator-written AGENTS.md is swept the same way. The user approves per rule; then the rule file is deleted.

## 3b. Sanity-check CLAUDE.md and project rules: let go of what a capable agent does anyway

Instruction files decay the other way too: advice a better model follows unprompted is noise that dilutes the lines that matter. For each guidance line (patterns, conventions, notes; not domain facts) ask: would a capable agent get this wrong without it? Keep only:
- facts the code can't show (external contracts, environment, why-not-X)
- decisions with a rejected alternative ("never propose ...")
- preferences that contradict the default (explicit in-lists over between, a banned term)
- gotchas with a burn behind them (a silent skip, a prod incident)

Propose removal for generic best practice (efficient SQL, naming, error handling), anything readable straight from the code (file tables, pattern descriptions), and duplicates of global rules. Age comes from `git blame`, not inline dates: an old guidance line whose failure hasn't recurred is a candidate. Apply the same test before promoting a memory in section 2: a memory that fails it is deleted, not promoted.

Also flag root CLAUDE.md sections that concern one area only (a CSS look, one designer, one program): propose moving their decisions to that area's CLAUDE.md and their facts to class docs (or deleting what the code says), leaving a one-line pointer in the root. Mandatory when the root outgrows its budget.

## 3c. Move user rules toward retirement

User rules only; project rules are swept into the codebase by 3a, never probated. Rules in `~/.claude/rules/` record mistakes a past agent made; agents change, so a rule is a hypothesis with a date. A loaded rule that never recurs proves nothing (the rule may be what prevents it), so rules leave through probation: unloaded, and only absence there counts. Evidence of recurrence: memories in this project, the git log of the rule's `project:`, `Restore rule:` commits in the chezmoi log, the current diff.
- Probation at a model release: every loaded `kind: patch` rule, regardless of age.
- Probation candidate: a loaded rule, two months or more since `filed:`/`learned:`/`restored:`, no recurrence, whose failure shows in a diff, so the fresh-eyes review can catch it. Rules that act before code exists (process, requirements) stay.
- Retirement candidate: a probation rule two months or more since `probation:`, no recurrence.

List each with its dates and the evidence checked. Move nothing here: `/my-learn` section 3 does the chezmoi moves.

## 4. Propose, then apply

Show one table: file, verdict, target section, one-line gist. Plus the instruction-size total, the prune and move-to-rule list (sections 3 and 3b), the `/my-learn` candidates, and the rule probation and retirement candidates. Wait for approval. Deleting memories and editing committed team files is not reversible without git, so no edits before the user confirms.

After approval:
1. Edit instruction files.
2. Delete memory files, rewrite `MEMORY.md` index to match what remains.
3. Verify: `rg` each promoted key phrase in the instruction files; `ls` the memory dir matches the index; no dangling `[[links]]` in remaining memories.
4. Do not commit. Report changed files and suggest a commit message.
