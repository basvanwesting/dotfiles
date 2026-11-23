---
name: my-plan
description: Make this session the planner. Design work with the user, write briefs onto the project's board, which the paired worker session takes one at a time, implements and commits. The planner changes nothing the worker reads.
disable-model-invocation: true
---

# Plan

This session designs, the worker builds. The user approves the design here. The worker gets a written brief, a clean context and a definition of done, and commits without asking (global CLAUDE.md, worker exception). The push of project code stays the user's: unpushed commits are the user's todo list (global CLAUDE.md).

## Read-only

The planner writes only the project's board, and only through `board`. It makes no edits in the checkout and no git writes. It runs nothing that writes state the worker uses: no specs, migrations, asset builds or dev server. The checkout and the test database are shared, so a planner spec run races the worker's. While the worker has uncommitted changes, read the committed version (`git show HEAD:<path>`): a brief is planned against what landed, not against half-done work.

This is a rule, not a permission setting (the user's choice). The worker's clean-tree check at brief start catches a slip.

## Pairing

The worker is the peer named like this session with `-work` for `-plan` (`shop-plan` → `shop-work`; check `ListAgents`). It started in the same directory, because the directory is the project: nested directories (`tools/shop`) are separate projects on purpose. Both sessions run in auto mode. A session in another permission mode holds cross-session messages for its user's approval.

## The board

One board per project, in the shared board-data repo (one clone per machine), read and written through `board` (`board --help` is the reference; it finds the project's board from the directory it runs in). The files are the record; a message between the sessions is only a wake-up, because a report sent as a message lands in the middle of the design conversation and dies with the transcript. `board` syncs the repo on every write (pull, commit, push): the board is the todo list itself, so that push is the global never-push rule's exception. Never run `git` in the board-data repo by hand.

- Briefs (`126`): one file each. The design is the planner's; its status and its report are the worker's, set through `board`.
- Chores (`c12`): the user's own actions that briefs leave behind (a PROD edit, a hand fix, things to judge after a deploy). Every "not doable by the worker" becomes one when its brief is filed. Chores expire unannounced (a push, a deploy, an edit in another repo), so each names its check: the command or place that shows it done.
- Backlog (`b41`): unrefined items. The user owns their order. Add only on the user's word or from a worker's out-of-scope findings.

The user has the board open in a pane of their own and refers to items by ID. Resolve an ID with `board show <id>`, never from memory, and never print the lists into the conversation: say what changed and what needs the user.

## Loop

1. Design with the user. A brief is written only once the user approves the design.
2. `board new brief <slug>` gives the file (status draft, `base:` = HEAD now); write it from the template below; `board queue <id> --closes b41,b52` (the flag names the backlog items it resolves, left out if none; it refuses a brief with an empty section).
3. Wake the worker with one line by `SendMessage`, no `notify_when_idle`: `Queue has work: run "board next" and follow the brief's Worker protocol.` Send it only when `board ls briefs` shows no brief started or blocked: a message drains at the worker's next tool call, so mid-brief it would claim a second brief beside the first. A busy worker takes the queue by itself after its report (`board next`) and checks each brief's premises at its start, so nothing else is sent per brief.
4. No done message arrives. At every pause, before writing the next brief, and when the user asks for the board: `board ls briefs --status reported`. For each, read the report (`board show <id>`), add its out-of-scope findings (`board add backlog … --from <id>`) and what the worker could not do (`board add chore … --group … --check … --from <id>`), then `board file <id>` (`board file <id> --no-commits` for a brief that changed nothing in the repository, such as an investigation): it verifies the commits in the repository, not the report, and closes the backlog items the brief resolves.
5. `blocked: <id>` is the one message the worker sends; the question is in the brief (`board show <id>`). Answer if the approved design covers it, otherwise ask the user at once (below). The answer goes into the brief (`board amend <id>`, which also resumes it), then one line to the worker.
6. A brief that stays `started` with no commits: ask the worker what happened. Silence is not done.

## Talking to the user

The conversation with the user is a design conversation, and nothing from the worker enters it except a block.

- At a pause (a design is approved or parked, or the user asks), after step 4, give one block headed `Since last time`: per filed brief its ID and one line, the chores and backlog items added (by ID). Nothing that needs no action.
- "Show me the board": first make it current (step 4, then run each chore's check and `board done <id>` what is done), then say what changed. The lists themselves are in the user's board pane.
- A `blocked` question for the user cannot wait: the worker is idle on it. Ask at once, in its own block headed `Worker blocked on <id>`, separate from any design thread, with the options and a recommendation.
- A decision the user makes while a brief is in flight goes into the brief (`board amend <id>`) and to the worker as one line, so the filed brief matches what was built.

## Brief template

An amendment must not contain a `## ` line outside a code fence (use `###`): it would split the brief's section, and `board` refuses it. The worker's block question has the same rule (Worker protocol below).

`board new brief <slug>` writes the header (id, status, base); the body is:

```markdown
# <title>

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
- Start: `board next` gave you this brief. `git status` is clean and the premises hold at HEAD. Otherwise `board block <id> "<question>"` and don't improvise: the design was approved against those premises.
- Implement under the commit loop of the global CLAUDE.md. Non-trivial Design decisions get a decision comment in the code.
- Fresh-eyes review: give the reviewer only the Task section verbatim, the diff and the repo path, not the Design. The decisions are in the code; the reviewer judges the code against the user's words. Spawn the reviewer on the strongest model the session offers (the Agent tool's `model`), also when you run on a lesser one; if that one is unavailable (a usage limit), the next strongest, and the report and the commit body name the model the review ran on: the planner verifies the commit, not the diff, so this review is the only read the diff gets, and it costs a small share of the brief's tokens.
- Commit when green, without asking. One brief may be several commits, each with the trailer `Brief: <id>`. Never commit red, even when the cause predates the brief: block instead.
- A check that needs the dev server (visual checks through Playwright with the machine's installed Chrome or Chromium, Tidewave's runtime tools, probes) is not skipped because none runs: check its port, otherwise start `bin/dev` in the background and stop it after (global CLAUDE.md).
- Out-of-scope findings: don't fix them, list them in the report.
- Done: `board report <id>` with the report on stdin: the checks run (command and result), what you could not do, deviations from the Design, out-of-scope findings. Send the planner nothing. Then `board next`: take the next brief, or stop when the queue is empty.
- Blocked: `board block <id> "<question>"` (no `## ` line outside a code fence in the question, use `###`: it would split the brief's section, and `board` refuses it), one line to the planner by `SendMessage` (`blocked: <id>`), then wait for the answer.
```
