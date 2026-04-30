---
description: Audit and optimize an existing GitHub Copilot Coding Agent configuration. Lighter alternative to the full copilot-optimize skill.
---

Audit and improve the GitHub Copilot Coding Agent configuration in this project.

**If `.github/copilot-instructions.md` does not exist**, stop and suggest running `copilot-init` instead.

**Step 1 — Inventory and metrics snapshot**

Read all Copilot config files and report:

- `copilot-instructions.md` character count (limit: ~8 000)
- Number of files in `.github/instructions/`
- Whether `.github/workflows/copilot-setup-steps.yml` exists
- Whether `AGENTS.md` exists

**Step 2 — Audit findings** (group as must fix / should fix / nice to have)

Check for:

- **Length**: over 8 000 characters → must fix; suggest which sections to extract
- **Anti-patterns**: personality instructions, file-by-file descriptions, linter-enforced rules → should fix
- **Missing Commands section** or only vague commands → should fix
- **Invalid `applyTo`** in any `.github/instructions/*.instructions.md` file → must fix
- **Missing `copilot-setup-steps.yml`** when a build system is detected → should fix
- **Wrong job name** in `copilot-setup-steps.yml` (must be `copilot-setup-steps`) → must fix
- **Contradictions** between `AGENTS.md` and `copilot-instructions.md` → must fix
- **No architecture overview** → nice to have
- **No path-specific instruction files** for a multi-subsystem project → nice to have

**Step 3 — Wait for approval**, then apply only approved changes.

**Step 4 — Report** before/after metrics and list every file modified.

**Limitations vs. Claude Code's cc-optimize:** No permissions deny/allow, no PostToolUse hooks, no autocompact control, no `@`-import progressive disclosure, no MCP automation via files.
