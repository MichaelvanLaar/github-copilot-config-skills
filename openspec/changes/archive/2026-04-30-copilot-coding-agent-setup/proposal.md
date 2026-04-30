## Why

GitHub Copilot Coding Agent users lack the equivalent of `claude-code-config-skills`: there is no opinionated, ready-to-use tooling for bootstrapping and maintaining a lean, cost-efficient Copilot configuration. Setting up `.github/copilot-instructions.md`, path-specific instruction files, and `copilot-setup-steps.yml` by hand is error-prone and rarely reflects current best practices. This change ports the three core skills — init, optimize, update — to GitHub Copilot, adapting them to the platform's different (and more limited) configuration surface.

## What Changes

- **New Claude Code skills** (`.claude/skills/copilot-*/SKILL.md`): `copilot-init`, `copilot-optimize`, `copilot-update` — letting Claude Code users manage their Copilot configuration from within Claude Code.
- **New GitHub Copilot skills** (`.github/skills/copilot-*/SKILL.md`): native versions of the same three skills for direct invocation from GitHub Copilot.
- **New GitHub Copilot prompt files** (`.github/prompts/copilot-*.prompt.md`): simplified one-page prompt alternatives for users who prefer Copilot Chat over the full skill system.
- **Feature-gap documentation**: explicit notes in each skill on what the Claude Code originals do that Copilot cannot replicate (no `settings.json` deny/allow, no PostToolUse hooks, no autocompact control, no `@`-import progressive disclosure), so users understand the constraints without guessing.

No existing skills are modified. No breaking changes.

## Capabilities

### New Capabilities

- `copilot-init`: Bootstrap a best-practice GitHub Copilot Coding Agent configuration for a new or unconfigured project — creates `.github/copilot-instructions.md`, path-specific `.github/instructions/*.instructions.md` files, and `copilot-setup-steps.yml`; optionally creates `AGENTS.md`.
- `copilot-optimize`: Audit and improve an existing Copilot configuration against current best practices — reviews instruction file length/structure, missing setup steps, path-specific instruction coverage, and MCP configuration guidance.
- `copilot-update`: Update installed `copilot-*` skills and prompt files to their latest versions from this repository.

### Modified Capabilities

## Impact

- 9 new files: 3 Claude Code skills, 3 GitHub Copilot skills, 3 GitHub Copilot prompt files.
- `install.sh` is **not** modified — Copilot skills follow the existing manual-copy or future installer pattern.
- No changes to existing OpenSpec, `cc-*`, or `opsx` skills.
