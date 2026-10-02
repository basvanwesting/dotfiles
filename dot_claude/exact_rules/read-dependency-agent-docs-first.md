---
filed: 2026-09-30
project: cu
---

# Read a Dependency's Agent Docs Before Its Source

When a problem leads into a third-party library, first look for agent guidance its authors shipped with the package: `AGENTS.md` or `CLAUDE.md` at the root of the installed copy (cargo `~/.cargo/registry/src/*/<crate>-<version>/`, `bundle show <gem>`, `node_modules/<pkg>/`, mix `deps/<pkg>/`). Authors put the decision matrices, API intent and common mistakes there. Reverse-engineering the same answers from source is slower, and it can land on an internal API the authors warn against.
Tell: an investigation that greps or reads a package's source without first listing the root of its installed directory.
