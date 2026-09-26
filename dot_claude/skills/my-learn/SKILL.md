---
name: my-learn
description: File a lesson from this session as a user-level rule in ~/.claude/rules/ through the chezmoi dotfiles (pull, write, apply, commit, push). Use after a review remark that generalises beyond the instance.
disable-model-invocation: true
---

# Learn

Turn a review remark into one rule file. Rules are considerations the agent weighs in every project, not gates; they record a mistake an agent made and how to recognise it, so they can be retired when the mistake stops recurring.

## 1. Draft

Source: the remark and the instance in this conversation, or the argument given. Write the rule in this shape, nothing more:

```markdown
---
filed: <today, ISO date>
learned: <ISO date of the incident, if different from today>
project: <repo name the incident happened in>
model: <model id of the session that made the mistake, if known>
---

# <Imperative title, e.g. "Name Siblings at the Same Level">

<Principle: one paragraph. What to do and why the wrong version is wrong.>
Tell: <how the mistake shows up in a diff, a name, a message; the thing a future agent can check for in its own work>.

Example failure: <the instance, concrete: names, numbers, what was asked, what the right fix was>.
```

- Only `paths` is read from the frontmatter by Claude Code; the other fields are for review tooling and are stripped before loading.
- Principle, tell, one example. No compliance instructions, no lists of situations: a long rule matches more than the failure it came from and starts hampering.
- Filename: kebab-case slug of the title, `dot_claude/rules/<slug>.md`.
- Check the existing rules first (`ls dot_claude/rules/`, grep key terms). If one already covers it, propose sharpening that file instead of adding a sibling.

Show the full file. Wait for approval.

## 2. Write through chezmoi

Source is `~/.local/share/chezmoi`; the target `~/.claude/rules/` is never edited directly.

1. `git -C ~/.local/share/chezmoi pull --rebase`. On conflict: stop, report, do not resolve (other agents on other machines push here too).
2. Write the file under `dot_claude/rules/`.
3. `chezmoi apply ~/.claude/rules/<slug>.md`, then `chezmoi diff ~/.claude/rules/<slug>.md` must be empty and the target must exist.
4. Commit only that file: summary `Add rule: <lowercased title>` (~60 chars), blank line, 3–6 line body with the lesson and the incident in one sentence each.
5. `git push`. This is the one place an agent pushes: the dotfiles repo has no CI or deploy to gate, the text was approved in step 1, and an unpushed rule is what turns the next machine's pull into a rebase. Other machines pick the rule up with `chezmoi update`, not a plain pull: the target under `~/.claude/rules/` only changes on apply.

Report the commit hash and the target path.

## 3. Retiring

Not this skill's job; `/my-memory-review` lists rules past their shelf life. When asked to retire a rule: same pull, `git rm`, apply, commit `Retire rule: <title>` with why (no recurrence since <date>, or superseded by <rule>), push.
