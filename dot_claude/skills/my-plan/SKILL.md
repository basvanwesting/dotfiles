---
name: my-plan
description: Make this session the planner. Design work with the user, write briefs, hand them one at a time to the paired worker session, which implements and commits. The planner changes nothing the worker reads.
disable-model-invocation: true
---

# Plan

This session designs, the worker builds. The user approves the design here. The worker gets a written brief, a clean context and a definition of done, and commits without asking (global CLAUDE.md, worker exception). The push stays the user's review.

## Read-only

The planner writes only its briefs directory. It makes no edits in the checkout and no git writes. It runs nothing that writes state the worker uses: no specs, migrations, asset builds or dev server. The checkout and the test database are shared, so a planner spec run races the worker's. While the worker has uncommitted changes, read the committed version (`git show HEAD:<path>`): a brief is planned against what landed, not against half-done work.

This is a rule, not a permission setting (the user's choice). The worker's clean-tree check at brief start catches a slip.

## Pairing

The worker is the peer named like this session with `-work` for `-plan` (`cu-plan` → `cu-work`; check `ListAgents`). It started in the same directory, because the directory is the project: nested directories (`data_analysis/engage`) are separate projects on purpose. Both sessions run in auto mode. A session in another permission mode holds cross-session messages for its user's approval.

## Layout

`~/.claude/projects/<slug>/briefs/`. `<slug>` is this session's start directory with every non-alphanumeric character replaced by `-` (the same slug as the memory directory). The planner is the only writer.

- `backlog.md`: unrefined items. The user owns their order. Append only on the user's word or from a worker's out-of-scope findings.
- `queue/NN-<slug>.md`: approved briefs, NN = send order (the user's priority, then dependencies).
- `sent/`: the brief in flight, at most one. The worker's inbox is not a queue: a message drains at its next tool call, so a second brief would land in the middle of the first.
- `done/`: briefs whose commits are verified.

## Loop

1. Design with the user. A brief is written only once the user approves the design.
2. Write it to `queue/` (template below), `base:` = HEAD now.
3. Send automatically when `sent/` is empty. First re-check the brief's premises against HEAD: the previous brief may have moved them. Fix the brief, or ask the user if the design changes. Move it to `sent/`, then `SendMessage` to the worker with `notify_when_idle: true`. First line: `Brief NN-<slug>: <absolute path>. Read it and follow its Worker protocol.`
4. Report `done`: verify each SHA with `git log` (the repository, not the report), move the brief to `done/`, tell the user in one line, plus anything the worker could not do (PROD checks). Then step 3 for the next brief.
5. Report `blocked`: answer if the approved design covers the question, otherwise ask the user. Reply to the worker (`to` = the message's `from`). It waits meanwhile, and nothing else is sent.
6. Idle notice without a report: check `git log`, then ask the worker what happened. Silence is not done.

## Brief template

```markdown
# <title>

base: <sha>

## Task
<the user's words, verbatim>

## Design
<approved decisions and the rejected alternatives the commit body should name>

## Premises
<what must still hold at HEAD; entry points, files>

## Out of scope
<what not to touch>

## Verification
<focused specs, lint>

## Not doable by the worker
<PROD checks and the like; these go in the report and the commit body>

## Worker protocol
- Start: `git status` is clean and the premises hold at HEAD. Otherwise report `blocked` and don't improvise: the design was approved against those premises.
- Implement under the commit loop of the global CLAUDE.md. Non-trivial Design decisions get a decision comment in the code.
- Fresh-eyes review: give the reviewer only the Task section verbatim, the diff and the repo path, not the Design. The decisions are in the code; the reviewer judges the code against the user's words.
- Commit when green, without asking. One brief may be several commits.
- Out-of-scope findings: don't fix them, list them in the report.
- Report to the planner by `SendMessage` (reply to the brief's sender): `done: <sha> …` with the checks run (command and result), what you could not do, and out-of-scope findings. Or `blocked: <question>`, then wait for the answer.
```
