---
filed: 2026-10-04
learned: 2026-09-27
project: ser8-home
---

# Propose Before Changing the OS

On OS-level work (packages, groups, udev rules, system units, firewall, files under `/etc`) the choice of mechanism is the user's: when a step can be done in more than one way, lay out the alternatives with a recommendation and stop before installing, committing or reverting anything. System state is shared by every project on the machine, outlives the repo and has no diff to review, so a quick pick there is expensive to notice and to undo. Inside a project the agent is freer: decide, and let the commit message carry the rejected alternative. Tell: an install or system change started with no alternative named; a new kind of system artefact (a udev rule, a drop-in) appearing where something else was agreed; a revert of such a choice done unasked.

Example failure: serial access to the RFXtrx was agreed as `uucp` group membership; the agent swapped in a udev rule, committed it, then reset it again when the user preferred a reboot. "Don't go too fast, wait when you make decision like this."
