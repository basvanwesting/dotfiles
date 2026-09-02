---
name: complete-and-consistent
description: Deliver complete, consistent changes even if it takes longer. Partial or inconsistent work is a failure, not progress.
---

## Core Principle

**Complete and consistent changes only. Partial or inconsistent work is failure, not progress.**

Be concise in all interactions and commit messages. Sacrifice grammar for brevity.
End each plan with a list of unresolved questions (if any). Keep questions brief.

## Challenge Weak Requirements; Count Supporting Machinery

A feature's cost is itself PLUS every piece of supporting machinery it drags in (state fields, widened function signatures, generic UI components, config/API surface). A human hand-writing that plumbing feels friction that acts as a design signal — AI doesn't, so replace it with explicit habits:

- When a request is weakly specified or weakly motivated, question the requirement FIRST (what need? who uses it? does an existing mechanism serve it better?) instead of implementing it well.
- When proposing a feature, enumerate its supporting machinery as part of the price. Machinery only one feature needs is a red flag — prefer deriving from existing state.
- Before extending a mechanism, cheaply check whether it's used at all (grep / DB query). Prefer removing unused mechanics over building on top.

Example failure: a vague "reward fast answers" idea (`speed_bonus_values`) dragged in an order-tracking state field on two structs, a widened scoring signature, a generic UI component, and config/API surface — never used by any stored design; removal touched 12+ files.

## Always Use Generators

When a framework generator exists for an artifact (Rails migrations/models/controllers, `cargo new`, `npm create`, etc.), run the generator first and rework its output with Edit. Never hand-write files to skip the generator's startup time — generators carry the framework's current conventions (canonical timestamps, naming, placement, base classes); hand-written files carry invented ones. Example failure: hand-rounded Rails migration timestamps caused a silent master/feature version collision.

## User Habits

Vim user — reflexively hits Esc as a "reset to normal mode" gesture with no intent to cancel. Esc is unbound from `chat:cancel` in `~/.claude/keybindings.json` (Chat context). Ctrl-C is the interrupt key. Editor mode stays on `normal` (not vim mode), because vim mode makes slash commands trigger search.

## Environment: macOS with Modern Toolchain

**Primary tools (Claude Code + modern CLI):**
- `Grep` tool - content search across files
- `Glob` tool - pattern-based file discovery  
- `Read` tool - file content viewing
- `rg` (ripgrep) - fast grep alternative
- `fd` - fast find alternative
- `sd` - simple sed alternative

**macOS-specific considerations:**
- BSD sed requires: `sed -i '' 's/old/new/g' file`
- BSD grep lacks `-P` flag (no PCRE)
- Prefer modern tools (rg/fd/sd) - they're faster and cross-platform

## Workflow: Find Everything, Change Everything

### 1. Discovery (mandatory)

Search exhaustively before making any changes:

```bash
# Use Claude Code tools first
Grep tool: "ComponentName"
Glob tool: "**/component*.{ts,tsx,js}"

# Or use CLI
rg "ComponentName" --type-list  # see what file types exist
rg "ComponentName"
fd "component_name"
```

Document every file found. If you find 5 files, actively search for the 6th.

### 2. Planning (mandatory)

List all files before coding:

```
Files requiring update:
□ src/components/ComponentA.tsx
□ src/components/ComponentB.tsx
□ tests/components/ComponentA.test.tsx
□ tests/components/ComponentB.test.tsx
□ docs/components.md
```

### 3. Implementation

- Update files systematically (alphabetical or by directory)
- Use identical implementations - copy/paste, don't rewrite
- If `class="foo bar"` in one file, use exactly `class="foo bar"` everywhere
- Check off files as completed
- Add newly discovered files to the list immediately

### 4. Verification (mandatory)

```bash
# Verify old pattern is gone
rg "old_pattern"  # Should return nothing

# Verify new pattern exists everywhere
rg "new_pattern"  # Should show all updated files

# Check consistency between similar files
diff src/ComponentA.tsx src/ComponentB.tsx  # Similar sections should match
```

## Common Patterns to Check

When searching, look for:
- Component files + their test files
- Similar names with different prefixes/suffixes (Button/IconButton/LinkButton)
- Files in parallel directories (src/components + tests/components)
- Configuration mirroring code structure
- Template/view files matching components
- Documentation corresponding to code

## Failure Modes to Avoid

**Don't:**
- Update 3 of 8 similar files
- Write slightly different implementations in each file
- Assume your first search found everything
- Rush to implementation

**Do:**
- Find all 8 files first, then update all 8
- Copy/paste to ensure exact consistency
- Search multiple ways to confirm completeness
- Spend time upfront on discovery

## Quick Reference Commands

```bash
# Finding files
fd "pattern"                    # by filename
fd -e tsx -e ts                 # by extension
rg -l "pattern"                 # files containing pattern

# Finding content  
rg "exact pattern"              # basic search
rg "pattern" --type typescript  # by file type
rg "pattern" -A 3 -B 3         # with context

# Replacing (verify first!)
sd "old" "new" file.tsx         # single file
fd -e tsx -x sd "old" "new"     # all .tsx files

# Checking consistency
diff file1.tsx file2.tsx
rg "pattern" | wc -l            # count occurrences
```

## Checklist for Every Change

Before starting:
- [ ] Used Grep/Glob tools or rg/fd to search?
- [ ] Checked all subdirectories?
- [ ] Looked for variant spellings?
- [ ] Created complete file list?

During work:
- [ ] Using identical implementations?
- [ ] Copy/pasting rather than rewriting?
- [ ] Checking off completed files?

After completion:
- [ ] Re-ran searches to verify completeness?
- [ ] Confirmed no missed files?
- [ ] Verified implementations are identical?

## Why This Matters

- Inconsistent code = technical debt = future bugs
- Partial work = broken features = user frustration
- 5 minutes finding all files now > 5 hours debugging later
- Complete and slow > fast and partial

---

Remember: If you discover files mid-implementation that you missed, that's a process failure. Stop, update them immediately, and improve your search patterns for next time.
