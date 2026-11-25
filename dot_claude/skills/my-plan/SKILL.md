---
name: my-plan
description: Make this session the planner. Design work with the user, write briefs onto the project's board, which the paired worker session takes one at a time, implements and commits. The planner changes nothing the worker reads.
disable-model-invocation: true
---

# Plan

This session designs, the worker builds. The user approves the design here. The worker gets a written brief, a clean context and a definition of done, and commits without asking (global CLAUDE.md, worker exception). The push of project code stays the user's: unpushed commits are the user's todo list (global CLAUDE.md).

## Read-only

The planner writes only the project's board, and only through `board`, but for a sweep over many items (The board, below). It makes no edits in the checkout and no git writes. It runs nothing that writes state the worker uses: no specs, migrations, asset builds or dev server. The checkout and the test database are shared, so a planner spec run races the worker's. While the worker has uncommitted changes, read the committed version (`git show HEAD:<path>`): a brief is planned against what landed, not against half-done work.

This is a rule, not a permission setting (the user's choice). The worker's clean-tree check at brief start catches a slip.

## Pairing

The worker is the peer named like this session with `-work` for `-plan` (`shop-plan` → `shop-work`; check `ListAgents`). It started in the same directory, because the directory is the project: nested directories (`tools/shop`) are separate projects on purpose. Both sessions run in auto mode. A session in another permission mode holds cross-session messages for its user's approval.

## The board

One board per project, in the shared board-data repo (one clone per machine), read and written through `board`, but for a sweep (below) (`board --help` is the reference; it finds the project's board from the directory it runs in). The files are the record; a message between the sessions is only a wake-up, because a report sent as a message lands in the middle of the design conversation and dies with the transcript. A wake-up is still needed: a session runs only when a turn starts, so without one a report waits for the user's next message, and the user ends up prompting the planner to file. So the worker's lines (`blocked: <id>`, `reported: <id>`) carry the ID and nothing else; what they point at is in the brief. `board` syncs the repo on every write (pull, commit, push): the board is the todo list itself, so that push is the global never-push rule's exception. Never run `git` in the board-data repo by hand.

- Briefs (`126`): one file each. The design is the planner's; its status and its report are the worker's, set through `board`.
- Chores (`c12`): the user's own actions that briefs leave behind (a PROD edit, a hand fix, things to judge after a deploy). Every "not doable by the worker" becomes one when its brief is filed. Chores expire unannounced (a push, a deploy, an edit in another repo), so one whose title does not show when it is done gets a check: the command or place that shows it done. A simple action needs none; a check would repeat it.
- A filed brief whose commits the user has not pushed yet is listed with the open ones as `unpushed` (`board ls briefs --status unpushed`): a label from git, not a status, gone after the push. The push is the user's; the label is how they see what waits for it.
- Backlog (`b41`): unrefined items. The user owns their order. Add only on the user's word or from a worker's out-of-scope findings.
- A chore or backlog item is a file of its own (`chores/c12.md`, `backlog/b41.md`): a title that fits a row, and a body in Markdown for instructions, queries and context, kept as written (blank lines, code blocks, lists), so a query copies whole. The body is stdin of `board add backlog "<text>" --body` (or `board add chore … --group … --body`); `board amend <id>` appends to it after a blank line, `board amend <id> --replace` rewrites it. A chore's check is one line, and a long one points at the body (`Check: the query below returns 0`). A title is changed with `board retitle <id> "<text>"` (a chore's check with `board retitle <id> --check "<check>"`, removed with `board retitle <id> --check ""`), never by drop and add: that gives a new ID and puts the item at the bottom of the order the user set.
- A sweep over many chores or backlog items (retitle them all, give them all bodies) is hand edits of their files and one sync, not a `board` command per item. Every `board` write is a fetch, a commit and a push, and a run of them back to back crowds out every other session's write: each retries with a growing random wait and can still give up after its eight rounds (it stays committed in its clone and goes out later, but a command that needs an ID is refused meanwhile, and the note reads like a broken board). So: `board sync` (the edits start from what the remote has), then edit the items' files under `chores/` and `backlog/` in the project's directory of the board-data clone (`$BOARD_ROOT`, default `~/Work/board-data`), and `board sync` once they are saved, both run from the project's directory like every `board` command. Another session's write on this machine may commit the files saved so far; each is whole, so that does no harm.
  - Only the item files of your own project. Never a brief file: its status and report are the worker's, and a brief changed on two machines is not merged. Never `git`: the sync commits the edits.
  - Save each file with a tool that refuses a file changed since you read it (the Write tool, not a shell redirect): a `board file <id>` or `board done <id>` run meanwhile by another session on this machine deletes item files in the same clone, and a save from an older read brings one back as a hand edit, pushed with nothing to merge against.
  - Keep the header lines (`id`, `group`, `order`, `check`, `from`, `created`) but for what the sweep is about; `order` is the item's place in the order the user set. A new item goes through `board add backlog "<text>"` (or `board add chore … --group …`): the tool gives no ID to a file made by hand, and one named by hand can meet the same ID given meanwhile on another machine.
  - The body follows the `# ` title line after one blank line, in Markdown, as written.
  - Read the sync's lint notes: the edits skip the refusals `add`, `amend` and `retitle` make, and lint is what is left of them (a missing key, a header ID that is not the file name's, an order that is no number, a misnamed file). After the sync, `board ls backlog` (or `chores`) and `board show <id>` on a few items show what landed.
  - A handful of items stays `board` commands, which check each one: the exception is for a burst, not a new default.

The user has the board open in a pane of their own and refers to items by ID. Resolve an ID with `board show <id>`, never from memory, and never print the lists into the conversation: say what changed and what needs the user.

## Loop

1. Design with the user. A brief is written only once the user approves the design, and only with a message of theirs that states the need, or a worker's finding it comes from: when there is none (an approval like "brief it" after a design talk is not one, nor a pointer like "do b3" to an item you wrote yourself), or you cannot quote it exactly any more (a long talk summed up), ask them for one sentence first instead of composing it.
2. `board new brief <slug>` gives the file (status draft, `base:` = HEAD now); write it from the template below; give it the fresh read (below); `board queue <id> --closes b41,b52` (the flag names the backlog items it resolves, left out if none; it refuses a brief with an empty section). On queueing, tell the user in one block the Design's choices marked as yours and any fresh-read finding you rebutted; fixed findings need nothing from them and are not listed. The brief does not wait for an answer, but for the one case the fresh read names.
3. Wake the worker with one line by `SendMessage`, no `notify_when_idle`: `Queue has work: run "board next" and follow the brief's Worker protocol.` Send it only when `board ls briefs` shows no brief started or blocked: a message drains at the worker's next tool call, so mid-brief it would claim a second brief beside the first. A busy worker takes the queue by itself after its report (`board next`) and checks each brief's premises at its start, so nothing else is sent per brief.
4. On `reported: <id>` from the worker, file: every brief `board ls briefs --status reported` shows, not only the one named, and answer the worker nothing (it does not wait). Run that same `board ls briefs --status reported` at the start of every turn too, before you answer, before writing the next brief, and when the user asks for the board: a message can be held or lost (a session in another permission mode holds cross-session messages), and a brief queued before its Worker protocol had this line sends none. The line makes filing prompt; the check keeps it certain. Filing is your read of the report, not the user's: its deviations from the design and its leftovers need the design's context, so an active planner files before it answers, and a brief stays `reported` only until the worker's line arrives, or until your next turn when none does. For each, read the report (`board show <id>`), add its out-of-scope findings (`board add backlog … --from <id>`, the line in the report's words as far as a line can hold them: a brief made from it later quotes the report, not your line) and what the worker could not do (`board add chore … --group … --check … --from <id>`), then `board file <id>` (`board file <id> --no-commits` for a brief that changed nothing in the repository, such as an investigation): it verifies the commits in the repository, not the report, and closes the backlog items the brief resolves.
5. `blocked: <id>` and `reported: <id>` are the two messages the worker sends. On `blocked: <id>` the question is in the brief (`board show <id>`). Answer if the approved design covers it, otherwise ask the user at once (below). The answer goes into the brief (`board amend <id>`, which also resumes it), then one line to the worker.
6. A brief that stays `started` with no commits: ask the worker what happened. Silence is not done.

## Fresh read

The diff gets a fresh-eyes review; the brief gets none, and the worker is told not to improvise against it, so a mistake in the brief is built before anyone catches it. Two kinds nothing later can catch: your words under Task (the worker's reviewer judges the diff against Task, so it cannot see them) and a Verification that passes with the change wrong (the worker writes the check the brief describes). So before `board queue <id>`, one fresh `general-purpose` subagent reads the draft, on the strongest model the session offers (the Agent tool's `model`; on a usage limit the next strongest, named to the user on queueing): it is the only read the brief gets. Measured on a trial of three briefs (2026-11-25): about 90k tokens and two minutes per brief, a small share of the build, with findings in every brief that would have been built wrong; weigh the step again against that.

- It gets only the source, verbatim, the path of the draft brief, the repo path and the instructions of this list. The source is every message of the user's that states the need or answers your questions (not an approval of the brief as a whole, like "brief it", nor side remarks; an answer that settles a decision is source), each marked as the user's, and before each answer the question of yours it answers, verbatim and marked as yours: an answer like "1" or "OK" means nothing without it. For a brief made from a worker's finding, the source is the finding as its report states it, plus whatever the user said to it. Nothing of your reasoning and no summary of the design talk: it would check the brief against your story instead of the source.
- Its prompt says it edits nothing and runs nothing that writes state the worker uses (no tests, migrations, builds or dev server: the checkout is shared with the worker, as in Read-only above), and reads the committed code (`git show HEAD:<path>` while the worker has uncommitted changes), since that is what the brief is planned against. It reports only findings with a concrete failure or cost, of four kinds:
  1. What the Design adds beyond the source, or says against it, without marking it as your choice.
  2. A premise that does not hold at HEAD (it checks each in the code).
  3. A Verification that would pass with the change wrong.
  4. Anything under Task that is not source words or an attribution line.
- Fix or rebut each finding yourself, then queue, without waiting for the user. Only a Design that contradicts the user's words waits: ask them at once.
- Skip it for a trivial brief (a one-key change, a typo), as the commit loop skips its review for trivial changes, and tell the user you skipped it.
- An amendment (`board amend <id>`) gets no fresh read: it records a decision the user just made, or an answer the approved design covers, and the worker is waiting on it.

What the user approves (Loop, step 1) is the design in the talk. What you fill in beyond it is marked as your choice in the Design, listed to the user on queueing, and waits for no answer; the user corrects it by an amendment, as any decision made while a brief is in flight (Talking to the user), or, once the brief is built, by a new brief or backlog item: the accepted cost of not waiting.

## Talking to the user

The conversation with the user is a design conversation. From the worker only a block enters it; a filing is yours, about the worker's report, and enters it as one line.

- A filing turn started by the worker's `reported: <id>`, between two messages of the user's: one line naming the brief (or briefs) and the chores and backlog items added, by ID ("Filed 14: c9, b6, b7 added"). A second line only for a deviation from the design that the user should know before the next brief builds on it. A `reported: <id>` that arrives in the middle of a turn (it drains at your next tool call, while you write another brief, say) starts no turn of its own: file before that turn's answer, and name the filing there in the same one line. The `Since last time` block still comes at the next pause.
- At a pause (a design is approved or parked, or the user asks), after step 4 (which ran at the start of the turn), give one block headed `Since last time`: per filed brief its ID and one line, the chores and backlog items added (by ID). Nothing that needs no action.
- "Show me the board": first make it current (step 4, then run each chore's check and `board done <id>` what is done), then say what changed. The lists themselves are in the user's board pane.
- A `blocked` question for the user cannot wait: the worker is idle on it. Ask at once, in its own block headed `Worker blocked on <id>`, separate from any design thread, with the options and a recommendation.
- A decision the user makes while a brief is in flight goes into the brief (`board amend <id>`) and to the worker as one line, so the filed brief matches what was built.

## Brief template

An amendment must not contain a `## ` line outside a code fence (use `###`): it would split the brief's section, and `board` refuses it. The worker's block question has the same rule (Worker protocol below).

The Task section holds source words only, because the worker hands the fresh-eyes reviewer that section and nothing of the Design: whatever stands there is read as the intent the diff is judged against, so a summary of yours there makes the reviewer check the code against your story instead of the need. Source words are the user's messages that state the need, verbatim, each as it was said; or, when the source is a worker's out-of-scope finding, the finding as its report states it (`board show <id>` of the brief it came from), not the backlog line you wrote from it, which is yours. Before each quote one attribution line of yours (`owner, 2026-11-24:`, `a worker's finding in the report of brief 5 (backlog b3):`) says whose words follow, and that is all of yours there: no context paragraph, no paraphrase, no quote of the design, no approval ("brief it now", "1"). The user's answers to your questions are decisions, not intent: they go in the Design, marked as theirs with the date. Short words are no reason for context: they mean the need was never stated, so ask (Loop, step 1). What the Worker protocol calls the user's words is whatever source stands there. `board` cannot tell the user's words from yours, so it does not try; the fresh read (above), which holds the source, does, unless it was skipped for a trivial brief.

`board new brief <slug>` writes the header (id, status, base); the body is:

```markdown
# <title>

## Task
<per source, an attribution line, then its words verbatim: the user's messages that state the need, or a worker's finding as its report states it; nothing of yours>

## Design
<approved decisions (the user's answers to your questions among them, marked as theirs with the date), every other choice marked as the planner's choice, and the rejected alternatives the commit body should name>

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
- Done: `board report <id>` with the report on stdin: the checks run (command and result), what you could not do, deviations from the Design, out-of-scope findings. Then one line to the planner by `SendMessage` (`reported: <id>`), without waiting for an answer: none comes. Then `board next`: take the next brief, or stop when the queue is empty.
- Blocked: `board block <id> "<question>"` (no `## ` line outside a code fence in the question, use `###`: it would split the brief's section, and `board` refuses it), one line to the planner by `SendMessage` (`blocked: <id>`), then wait for the answer.
```
