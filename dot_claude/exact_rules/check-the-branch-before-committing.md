---
filed: 2026-11-20
kind: patch
learned: 2026-10-17
project: engage
---

# Check the Branch Before Committing

Where HEAD points is the user's working state, not the agent's: during a live incident the user may sit on the commit production runs (a detached HEAD or a hotfix branch), ready for a hotfix. The commit loop says "commit on `main`", but that assumes `main` is what is checked out. A commit made without looking lands on the wrong line of history, and repairing it by switching branches takes the user off the checkout they chose, which costs more than the stray commit. So look at the branch before committing; when HEAD is detached or not the branch the work belongs on, ask where the commit goes, and never switch, cherry-pick or reset the user's checkout to fix it unasked.
Tell: a commit with no `git status` or `git branch --show-current` before it in the session; "HEAD detached at" in a status the agent read past; a `git switch`, `checkout` or `cherry-pick` the user did not ask for.

Example failure: engage, 2026-10-17, mid-incident. The user had detached HEAD at 321c30eb, prod's version, with `main` one commit ahead. The agent committed a plan doc there without noticing, then "restored" it by cherry-picking onto `main`, which moved the user off the prod-aligned checkout. The right response was to ask where the commit belonged before making it, and to suggest a named branch (`git switch -c hotfix/prod <prod commit>`) over a detached HEAD.
