# gc-config Skill Enhancement: Hooks, Permissions Equivalent, and MCP Clarification

**Date:** 2026-05-11
**Scope:** `gc-config-init`, `gc-config-optimize`, `README.md`
**Approach:** Full parity with cc-config — restructure both skills into named-step format and add all Copilot-equivalent capabilities.

## Context

The gc-config plugin previously disclaimed hooks, permissions, and MCP file configuration as unavailable in Copilot. Research confirmed this is outdated:

- `.github/hooks/hooks.json` provides `postToolUse` (formatter) and `preToolUse` (blocking) hooks
- Copilot CLI supports `~/.copilot/mcp-config.json` for file-based MCP configuration
- `preToolUse` blocking scripts are a partial equivalent to `permissions.deny`

Both skills currently have a "Limitations vs. Claude Code" footer that should be removed and replaced with correct feature coverage.

## Architecture

Two skill rewrites + one README update. No new files in the plugin except the skills themselves and `README.md`. The hooks infrastructure that the skills _create in target projects_ is `.github/hooks/hooks.json` + `.github/hooks/scripts/format.sh`.

### Hooks schema (Copilot `.github/hooks/hooks.json`)

```json
{
  "version": 1,
  "hooks": {
    "postToolUse": [
      {
        "type": "command",
        "bash": ".github/hooks/scripts/format.sh",
        "cwd": ".",
        "timeoutSec": 30
      }
    ],
    "preToolUse": [
      {
        "type": "command",
        "bash": ".github/hooks/scripts/guard.sh",
        "cwd": ".",
        "timeoutSec": 10
      }
    ]
  }
}
```

`postToolUse` scripts cannot deny — they must exit 0 / use `|| true`. `preToolUse` scripts block by exiting 1; they receive a JSON payload on stdin with `.toolName` and `.toolInput`.

**Open technical detail:** The exact field name for the edited file path in `postToolUse` stdin needs verification against current GitHub Docs before writing the formatter script example. Candidates: env var `$TOOL_INPUT_FILE_PATH`, or jq extraction from `.toolInput.path` / `.tool_input.file_path`. The implementation plan should include a verification step before finalizing the script template.

## Component Design

### gc-config-init (rewrite: ~150–200 lines, 7 named steps)

**Step 1 — Gather context**

- Abort if `copilot-instructions.md` already exists → suggest `/gc-config-optimize`
- Scan toolchain files (package.json, Cargo.toml, go.mod, pyproject.toml, Makefile, README.md)
- Check if `.github/hooks/hooks.json` already exists (skip Step 2 if so)
- Note which formatters are present (Prettier, ruff, rustfmt, gofmt, php-cs-fixer)
- If no toolchain clues and no `$ARGUMENTS`, ask: what does this project produce and what stack?

**Step 2 — Create `.github/hooks/hooks.json`** _(new)_

- If a formatter is detected: create hooks.json with `postToolUse` hook pointing to `.github/hooks/scripts/format.sh`
- Create `format.sh` with the ecosystem-appropriate formatter invocation; script must exit 0 / use `|| true`
- Formatter examples: Prettier (JS/TS/MD), ruff (Python), rustfmt (Rust), gofmt (Go)
- Offer optional `preToolUse` guard: block writes to `.env` and `secrets/` files; mention this is the Copilot equivalent of `permissions.deny`
- If no formatter detected: skip hook creation; note in summary

**Step 3 — Create `.github/copilot-instructions.md`**

- Same structure as today (project name, Commands, Architecture, Conventions, Don't)
- Keep under ~8,000 characters
- Include Commands section with exact command strings (or TODO placeholders)

**Step 4 — Create path-specific instruction files** _(optional)_

- `.github/instructions/*.instructions.md` with `applyTo: "<glob>"` frontmatter
- Offer when project has distinct subsystems (frontend/backend, tests, etc.)

**Step 5 — Create `copilot-setup-steps.yml`** _(optional)_

- Only when a package manager or build tool is detected
- Job name must be `copilot-setup-steps`; runtime capped at 59 minutes
- Always include ecosystem caching: `actions/setup-node@v4` with `cache: 'npm'`, `actions/setup-python@v5` with `cache: 'pip'`, `actions/setup-go@v5` with `cache: true`, `actions/cache@v4` for Cargo

**Step 6 — Create `AGENTS.md`** _(optional)_

- Only when evidence of other AI tool directories (`.claude/`, `.gemini/`, `.codex/`) is found

**Step 7 — Summary**

- List every file created, note TODO placeholders
- MCP note: "MCP servers for Copilot CLI can be added in `~/.copilot/mcp-config.json`; for the Coding Agent, use GitHub repository Settings → Copilot → MCP servers"
- Learnings note: run `/gc-config-optimize` periodically to incorporate corrections

**Removed:** The "Limitations vs. Claude Code" footer.

---

### gc-config-optimize (rewrite: ~200–250 lines, 5 steps with named sub-sections)

**Step 1 — Full inventory**

- Read all Copilot config files
- Read `.github/hooks/hooks.json` and referenced scripts _(new)_
- Scan toolchain for formatter/linter presence

**Metrics snapshot (report to user):**

- `copilot-instructions.md` character count
- Number of `.github/instructions/` files
- Whether `copilot-setup-steps.yml` exists
- Whether `AGENTS.md` exists
- Whether `.github/hooks/hooks.json` exists and which hooks are defined _(new)_
- Number of `copilot-learnings.md` entries (if present)

**Step 2 — Audit against best practices**

_2a: copilot-instructions.md_

- Over 8,000 characters → must fix
- Anti-patterns (personality instructions, file-by-file descriptions, linter-enforced rules) → should fix
- Missing Commands section or only vague commands → should fix
- No architecture overview → nice to have

_2b: AGENTS.md_

- Exists? Should it? (yes if multiple AI tools present)
- Tool-agnostic? No Claude-specific syntax inside AGENTS.md
- Contradictions with copilot-instructions.md → must fix

_2c: Path-specific instruction files_

- Invalid `applyTo` globs → must fix
- Missing files for multi-subsystem project → nice to have

_2d: copilot-setup-steps.yml_

- Wrong job name → must fix
- Missing caching → should fix
- Missing when build system detected → should fix

_2e: Hooks audit_ _(new)_

- No `hooks.json` but formatter detected → should fix
- Hooks present but `postToolUse` script missing or not exiting 0 → should fix
- No `preToolUse` blocking for sensitive files when `.env` / `secrets/` exist → nice to have
- Hook scripts not executable or missing shebang → should fix

**Step 3 — Learnings review**

- Read all entries in `copilot-learnings.md`
- Group: recurring patterns → promote to config; one-offs → delete
- Present grouped list with rationale; wait for approval before changing

**Step 4 — Findings report**
Three tiers:

- **Must fix:** length over limit, invalid `applyTo`, wrong job name, contradictions
- **Should fix:** anti-patterns, missing Commands, missing setup-steps, missing caching, missing `postToolUse` formatter hook, broken hook scripts
- **Nice to have:** architecture overview, path-specific files, `preToolUse` blocking, learnings promotion

**Step 5 — Apply approved changes and report**

- Apply only approved changes
- Report before/after metrics (character count, hook count, learnings count)
- List every file modified

**Removed:** The "Limitations vs. Claude Code" footer.

---

### README.md (targeted edits, no restructuring)

**Addition to "Configuration files" table:**

| `.github/hooks/hooks.json` | `/gc-config-init` (optional) | PostToolUse formatter and optional preToolUse blocking hooks |

**Addition to "Key best practices applied":**

New bullet: PostToolUse formatter hook — `.github/hooks/hooks.json` runs a formatter script after every file edit. Hook scripts must exit 0; use `|| true` for graceful degradation.

**"What these skills cannot configure" table — three row changes:**

| Row                                                                    | Change                                                                                                                        |
| ---------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `PostToolUse hooks (auto-formatter) \| No hook system`                 | Remove — Copilot now has `.github/hooks/hooks.json`                                                                           |
| `permissions.deny / permissions.allow \| No file-level access control` | Update: preToolUse hooks provide a partial equivalent — blocking scripts that reject tool calls before execution              |
| `MCP server automation via files \| UI only`                           | Update: Copilot CLI supports `~/.copilot/mcp-config.json` (file-based, per machine); Coding Agent requires GitHub Settings UI |

## Error Handling

- All `postToolUse` scripts must use `|| true` — hooks that exit non-zero after a tool completes can cause unexpected behavior
- `preToolUse` scripts intentionally exit 1 to block; must be clearly documented as the blocking mechanism
- Hook script templates include the shebang (`#!/usr/bin/env bash`) and are made executable (`chmod +x`)

## Testing / Verification

No automated tests (content repo). Verification steps:

1. Read both rewritten SKILL.md files and confirm all 7 (init) / 5 (optimize) steps are present
2. Confirm "Limitations" footer is absent from both files
3. Confirm README "What these skills cannot configure" table has the three updated rows
4. Confirm README "Configuration files" table includes `hooks.json` row
5. Verify hooks.json schema against current GitHub Docs before finalizing formatter script template
