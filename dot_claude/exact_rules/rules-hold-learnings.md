---
filed: 2026-10-14
project: engage
model: claude-opus-5-5
---

# Rules Hold Learnings, Code Docs Hold Facts

A rule file records a learning: a decision with its why, or a mistake with its tell. What the code does (callback names, data keys, which module answers what, the behaviour of a feature) belongs in the moduledoc or @doc beside the code, where it changes with the code and is read by whoever touches it. When a change leaves a rule's description stale, fix the code docs and trim the rule; extend a rule only when a learning changed. A rule that enumerates implementation goes stale with every new case, and each stale line narrows the review with a fact that is no longer true.
Tell: a proposed rule edit naming functions, struct fields, map keys or per-feature lists ("the duel's `duel:`, the wheel's `wheel:`, the tug's `tug:`"); a rule change whose only trigger is "the code now does X".

Example failure: after adding tug of war to both programs, the agent proposed extending `director-console.md` with the tug's `tug: :left | :right` roster note and `media-control.md` with `renders_media?` answering for a scene type's own elements. Bas: "this is more like implementation code than a rule", "rules should be about learnings". The facts went into the View/Scene docs instead; neither rule changed.
