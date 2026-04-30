## Context

The `cc-init`, `cc-optimize`, and `cc-update` skills rely on Claude Code–specific mechanisms: `.claude/settings.json` (permissions and hooks), PostToolUse hooks (auto-formatting), `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (cost control), and `@`-import progressive disclosure. GitHub Copilot Coding Agent has none of these. Its configuration surface is:

- `.github/copilot-instructions.md` — global repository instructions (~2 pages / ~8 000 chars max); loaded automatically on every agent session.
- `.github/instructions/*.instructions.md` — path-specific instructions injected when the agent opens matching files (via `applyTo` glob in frontmatter).
- `.github/workflows/copilot-setup-steps.yml` — pre-install dependencies and tools before each agent session (GitHub Actions syntax, `copilot-setup-steps` job only, max 59 min).
- MCP servers — configured via GitHub repository settings UI (not a checked-in file).
- `AGENTS.md` / `CLAUDE.md` / `GEMINI.md` — vendor-neutral or vendor-specific instruction files read by multiple agents.

The existing repo already ships `.github/skills/` (GitHub Copilot skills with SKILL.md frontmatter) and `.github/prompts/` (simpler prompt files). The new skills follow the same patterns.

## Goals / Non-Goals

**Goals:**

- Give Copilot users the best achievable equivalent of `cc-init`, `cc-optimize`, and `cc-update` within the platform's constraints.
- Deliver each skill in all three formats already established in this repo: Claude Code skill, GitHub Copilot skill, GitHub Copilot prompt file.
- Document feature gaps clearly and concisely so users don't waste time looking for non-existent equivalents.
- Keep instruction files lean — every sentence in `copilot-instructions.md` is loaded on every agent session.

**Non-Goals:**

- Replicating hooks, autocompact, or `@`-import progressive disclosure — these have no Copilot equivalent.
- Modifying `install.sh` — Copilot skill installation is out of scope for this change.
- Configuring MCP servers — these are set in the GitHub UI per-repository, not in checked-in files; the skills can reference documentation but cannot automate this.
- Supporting GitHub Copilot in VS Code Chat vs. Coding Agent distinctions beyond what affects configuration files.

## Decisions

### D1: Three-file delivery per capability

**Decision:** Each of the three capabilities (`copilot-init`, `copilot-optimize`, `copilot-update`) ships as three files: a Claude Code SKILL.md, a GitHub Copilot SKILL.md, and a `.github/prompts/*.prompt.md`.

**Rationale:** This mirrors the existing pattern established by the `openspec-*` skills in this repo. Claude Code users can run Copilot setup from inside Claude Code; native Copilot users get the same logic through Copilot skills or prompts. The prompt file is a simplified subset of the full skill — useful for quick invocations without the full skill runner.

**Alternative considered:** A single "universal" skill file. Rejected because the tool-use APIs differ enough that trying to unify them produces a worse experience for both platforms.

### D2: copilot-init creates four outputs maximum

**Decision:** `copilot-init` creates: `.github/copilot-instructions.md`, optionally one or more `.github/instructions/*.instructions.md` files, optionally `.github/workflows/copilot-setup-steps.yml`, and optionally `AGENTS.md`. It does NOT create `settings.json`, hooks, or sync scripts.

**Rationale:** There are no Copilot equivalents. Creating stub files that do nothing would mislead users. Instead, the skill explicitly calls out what it cannot create and explains why.

### D3: Feature gap documentation is inline, not a separate file

**Decision:** Feature gaps are documented in a brief "What this skill cannot do" section within each skill, not in a separate README or doc file.

**Rationale:** Users invoking `copilot-init` should immediately see the constraints, not search for a separate document. Inline is more durable — the gap note stays next to the code it describes.

### D4: copilot-optimize audits a different surface than cc-optimize

**Decision:** `copilot-optimize` checks: instruction file length (< 2 pages), structure quality (missing commands section, missing architecture overview), use of path-specific instructions, presence of `copilot-setup-steps.yml` if the project has a build/test system, and `AGENTS.md` consistency if present.

**Rationale:** The Copilot equivalent of "permissions are too loose" is "instruction file is too long and will get truncated" or "no setup steps, so the agent trial-and-errors on tool installation." These are the highest-leverage checks given the platform constraints.

### D5: copilot-update uses curl, mirrors cc-update

**Decision:** `copilot-update` fetches the latest `SKILL.md` files from `MichaelvanLaar/github-copilot-config-skills` via `curl` for installed skills only, and updates the matching `.github/prompts/*.prompt.md` files.

**Rationale:** Exact same pattern as `cc-update`. Self-contained, no external dependencies beyond `curl`.

## Risks / Trade-offs

- **GitHub Copilot docs change frequently** → The "~2 pages / ~8 000 chars" limit and the `applyTo` frontmatter format have changed in past releases. Skills should cite the exact behavior they depend on, and `copilot-optimize` should note if limits seem outdated.
- **`copilot-setup-steps.yml` is advanced** → Many users won't have a build system, making this step optional. `copilot-init` should ask before creating it; `copilot-optimize` should only flag its absence if the project clearly has a build/test system.
- **Prompt files are less powerful than skills** → The `.github/prompts/*.prompt.md` format does not support `allowed-tools` or structured multi-step flows the way SKILL.md does. The prompt versions are intentionally simplified and should note they are a lighter alternative.
- **MCP configuration is UI-only** → The skills can explain MCP concepts but cannot automate configuration. This is a hard gap — document it clearly.

## Open Questions

- Should `copilot-update` also update the `.github/prompts/` files, or only the SKILL.md files? (Current decision: both, since prompts are the Copilot-native alternative.)
- Should `copilot-init` support a `$ARGUMENTS` hint the same way `cc-init` does? (Current decision: yes, same pattern.)
