# gc-config Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the `github-copilot-config-skills` repo into `gc-config`, a GitHub Copilot CLI plugin with two skills (`gc-config-init`, `gc-config-optimize`) distributed via the Copilot CLI plugin system.

**Architecture:** The repo becomes a single-plugin marketplace. A `.github/plugin/marketplace.json` at the repo root makes it discoverable. The plugin lives in `plugins/gc-config/` with a `plugin.json` manifest and two skills in `skills/*/SKILL.md`. The existing prompt files are removed; their content moves into the SKILL.md files with proper frontmatter.

**Tech Stack:** Markdown, JSON, Bash (shim only). No build toolchain required.

---

## File Map

| Action  | Path                                                                  |
| ------- | --------------------------------------------------------------------- |
| Create  | `.github/plugin/marketplace.json`                                     |
| Create  | `plugins/gc-config/plugin.json`                                       |
| Create  | `plugins/gc-config/skills/gc-config-init/SKILL.md`                    |
| Create  | `plugins/gc-config/skills/gc-config-optimize/SKILL.md`                |
| Rewrite | `AGENTS.md`                                                           |
| Rewrite | `install.sh`                                                          |
| Rewrite | `README.md`                                                           |
| Delete  | `.github/prompts/copilot-init.prompt.md`                              |
| Delete  | `.github/prompts/copilot-optimize.prompt.md`                          |
| Delete  | `.github/prompts/copilot-update.prompt.md`                            |
| Manual  | Rename GitHub repo from `github-copilot-config-skills` to `gc-config` |

---

## Task 1: Create plugin manifests

**Files:**

- Create: `.github/plugin/marketplace.json`
- Create: `plugins/gc-config/plugin.json`

- [ ] **Step 1: Create `.github/plugin/marketplace.json`**

Create the directory and write the file:

```json
{
  "name": "gc-config",
  "metadata": {
    "description": "GitHub Copilot CLI skills for setting up and maintaining best-practice GitHub Copilot configurations",
    "version": "1.0.0"
  },
  "owner": { "name": "Michael van Laar" },
  "plugins": [
    {
      "name": "gc-config",
      "source": "./plugins/gc-config",
      "description": "Bootstrap and audit GitHub Copilot configurations",
      "version": "1.0.0",
      "skills": ["./skills/gc-config-init", "./skills/gc-config-optimize"]
    }
  ]
}
```

- [ ] **Step 2: Create `plugins/gc-config/plugin.json`**

Create the directories and write the file:

```json
{
  "name": "gc-config",
  "description": "Bootstrap and audit a best-practice GitHub Copilot configuration",
  "version": "1.0.0",
  "author": { "name": "Michael van Laar" },
  "homepage": "https://github.com/MichaelvanLaar/gc-config",
  "repository": "https://github.com/MichaelvanLaar/gc-config",
  "license": "MIT"
}
```

- [ ] **Step 3: Validate both JSON files**

Run:

```bash
python3 -m json.tool .github/plugin/marketplace.json > /dev/null && echo "marketplace.json: OK"
python3 -m json.tool plugins/gc-config/plugin.json > /dev/null && echo "plugin.json: OK"
```

Expected output:

```
marketplace.json: OK
plugin.json: OK
```

- [ ] **Step 4: Commit**

```bash
git add .github/plugin/marketplace.json plugins/gc-config/plugin.json
git commit -m "feat: ✨ add GitHub Copilot CLI plugin manifests"
```

---

## Task 2: Create gc-config-init skill

**Files:**

- Create: `plugins/gc-config/skills/gc-config-init/SKILL.md`

- [ ] **Step 1: Create `plugins/gc-config/skills/gc-config-init/SKILL.md`**

```markdown
---
name: gc-config-init
description: Bootstrap a best-practice GitHub Copilot Coding Agent configuration for a new or unconfigured project. Use when a user asks to set up GitHub Copilot, create copilot-instructions.md, or configure GitHub Copilot for the first time. Also use when the user says things like "set up my Copilot config", "bootstrap Copilot", or "initialize GitHub Copilot". Grounded in official GitHub Copilot Coding Agent best practices.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: "[optional: brief project description]"
---

Set up a GitHub Copilot Coding Agent configuration for this project.

**Before creating any files:**

1. If `.github/copilot-instructions.md` already exists, stop and suggest running `/gc-config-optimize` instead.
2. Scan for toolchain clues: `package.json`, `Cargo.toml`, `go.mod`, `requirements.txt`, `Makefile`, `README.md`, and similar.
3. If the project description was not provided in `$ARGUMENTS` and the toolchain cannot be determined, ask what the project produces and what stack is involved.

**Create `.github/copilot-instructions.md`** with this structure (keep under ~8 000 characters):

```markdown
# <Project Name>

<One-line description and stack summary.>

## Commands

- Build: `<command or TODO>`
- Test: `<command or TODO>`
- Lint: `<command or TODO>`

## Architecture

<Key directories and patterns — only non-obvious parts. Omit if too new.>

## Conventions

<Concrete rules that deviate from defaults. Never standard language conventions.>

## Don't

- Don't commit secrets or credentials to git
- Don't use `--force` git flags — fix the underlying issue instead
```

**Optionally also create:**

- `.github/instructions/*.instructions.md` — if the project has distinct subsystems with different conventions; use `applyTo: "<glob>"` frontmatter to scope each file
- `.github/workflows/copilot-setup-steps.yml` — if a package manager or build tool is detected; job name must be `copilot-setup-steps`, runtime under 59 min; always include dependency caching (`actions/setup-node@v4` with `cache: 'npm'`, `actions/setup-python@v5` with `cache: 'pip'`, `actions/setup-go@v5` with `cache: true`, or `actions/cache@v4` for Cargo) — without caching every agent session reinstalls all dependencies from scratch
- `AGENTS.md` — if other AI tool directories (`.claude/`, `.gemini/`, `.codex/`) are present

**After creating files**, list what was created, note any TODO placeholders, and mention:

- Fill in TODO commands once they are known
- Run `/gc-config-optimize` once the project has more content
- Add MCP servers via GitHub repository settings (Settings → Copilot → MCP servers)
- When Copilot makes a mistake and the user corrects it, Copilot logs a one-line summary to `.github/copilot-learnings.md` instead of modifying config files directly. Run `/gc-config-optimize` periodically to incorporate accumulated learnings into the configuration.

**Limitations vs. Claude Code's `/cc-config-init`:** No permissions deny/allow, no PostToolUse hooks, no autocompact control, no `@`-import progressive disclosure (so `copilot-learnings.md` is not auto-loaded — `/gc-config-optimize` is required to apply it), no MCP automation via files.

---

Did this output meet your expectations? If not, describe what was off and Copilot will log the correction to `.github/copilot-learnings.md`.

> **Note:** Corrections are not auto-loaded on every session. Run `/gc-config-optimize` periodically to review and incorporate them.
```

- [ ] **Step 2: Verify the file has correct YAML frontmatter**

Check the frontmatter parses (Python's `yaml` is available in standard lib via `python3 -c`):

```bash
python3 -c "
import re, sys
content = open('plugins/gc-config/skills/gc-config-init/SKILL.md').read()
match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
if not match:
    print('ERROR: No frontmatter found'); sys.exit(1)
import yaml
data = yaml.safe_load(match.group(1))
required = ['name', 'description', 'allowed-tools']
missing = [k for k in required if k not in data]
if missing:
    print(f'ERROR: Missing fields: {missing}'); sys.exit(1)
print(f'OK: name={data[\"name\"]}, allowed-tools={data[\"allowed-tools\"]}')
"
```

Expected output:

```
OK: name=gc-config-init, allowed-tools=Read, Write, Edit, Bash, Glob, Grep
```

- [ ] **Step 3: Commit**

```bash
git add plugins/gc-config/skills/gc-config-init/SKILL.md
git commit -m "feat: ✨ add gc-config-init skill"
```

---

## Task 3: Create gc-config-optimize skill

**Files:**

- Create: `plugins/gc-config/skills/gc-config-optimize/SKILL.md`

- [ ] **Step 1: Create `plugins/gc-config/skills/gc-config-optimize/SKILL.md`**

```markdown
---
name: gc-config-optimize
description: Audit and improve an existing GitHub Copilot Coding Agent configuration. Checks the 8,000-character limit, anti-patterns, missing sections, invalid applyTo globs, missing dependency caching, and accumulated learnings. Use when a user asks to optimize, audit, or improve their Copilot configuration.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: "[optional: focus area, e.g. 'length' or 'caching']"
---

Audit and improve the GitHub Copilot Coding Agent configuration in this project.

**If `.github/copilot-instructions.md` does not exist**, stop and suggest running `/gc-config-init` instead.

**Step 1 — Inventory and metrics snapshot**

Read all Copilot config files and report:

- `copilot-instructions.md` character count (limit: ~8 000)
- Number of files in `.github/instructions/`
- Whether `.github/workflows/copilot-setup-steps.yml` exists
- Whether `AGENTS.md` exists

**Step 2 — Inventory** also reads `.github/copilot-learnings.md` if it exists.

**Step 3 — Audit findings** (group as must fix / should fix / nice to have)

Check for:

- **Length**: over 8 000 characters → must fix; suggest which sections to extract
- **Anti-patterns**: personality instructions, file-by-file descriptions, linter-enforced rules → should fix
- **Missing Commands section** or only vague commands → should fix
- **Invalid `applyTo`** in any `.github/instructions/*.instructions.md` file → must fix
- **Missing `copilot-setup-steps.yml`** when a build system is detected → should fix
- **Missing dependency caching** in `copilot-setup-steps.yml` (`actions/setup-node` without `cache:`, `actions/setup-python` without `cache:`, `actions/setup-go` without `cache: true`, raw Cargo commands without `actions/cache@v4`) → should fix; every agent session otherwise reinstalls all dependencies from scratch
- **Wrong job name** in `copilot-setup-steps.yml` (must be `copilot-setup-steps`) → must fix
- **Contradictions** between `AGENTS.md` and `copilot-instructions.md` → must fix
- **No architecture overview** → nice to have
- **No path-specific instruction files** for a multi-subsystem project → nice to have

**Step 4 — Learnings review** (if `.github/copilot-learnings.md` exists)

- Classify each entry: recurring pattern (promote to a config file) or one-off (delete).
- Include promoted entries in the findings report under the appropriate tier.
- When applying changes: add promoted content to config files and remove processed entries from `copilot-learnings.md`; delete the file entirely if all entries are resolved.

**Step 5 — Wait for approval**, then apply only approved changes (including any learnings changes).

**Step 6 — Report** before/after metrics, list every file modified, and note how many learnings entries were promoted, deleted, or remain.

**Limitations vs. Claude Code's `/cc-config-optimize`:** No permissions deny/allow, no PostToolUse hooks, no autocompact control, no `@`-import progressive disclosure (so `copilot-learnings.md` is not auto-loaded — this skill is required to apply it), no MCP automation via files.

---

Did this output meet your expectations? If not, describe what was off and Copilot will log the correction to `.github/copilot-learnings.md`.

> **Note:** Corrections are not auto-loaded on every session. Run `/gc-config-optimize` periodically to review and incorporate them.
```

- [ ] **Step 2: Verify frontmatter**

```bash
python3 -c "
import re, sys
content = open('plugins/gc-config/skills/gc-config-optimize/SKILL.md').read()
match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
if not match:
    print('ERROR: No frontmatter found'); sys.exit(1)
import yaml
data = yaml.safe_load(match.group(1))
required = ['name', 'description', 'allowed-tools']
missing = [k for k in required if k not in data]
if missing:
    print(f'ERROR: Missing fields: {missing}'); sys.exit(1)
print(f'OK: name={data[\"name\"]}, allowed-tools={data[\"allowed-tools\"]}')
"
```

Expected output:

```
OK: name=gc-config-optimize, allowed-tools=Read, Write, Edit, Bash, Glob, Grep
```

- [ ] **Step 3: Commit**

```bash
git add plugins/gc-config/skills/gc-config-optimize/SKILL.md
git commit -m "feat: ✨ add gc-config-optimize skill"
```

---

## Task 4: Remove deprecated prompt files

**Files:**

- Delete: `.github/prompts/copilot-init.prompt.md`
- Delete: `.github/prompts/copilot-optimize.prompt.md`
- Delete: `.github/prompts/copilot-update.prompt.md`

- [ ] **Step 1: Delete the prompt files and directory**

```bash
git rm .github/prompts/copilot-init.prompt.md \
       .github/prompts/copilot-optimize.prompt.md \
       .github/prompts/copilot-update.prompt.md
```

Expected output:

```
rm '.github/prompts/copilot-init.prompt.md'
rm '.github/prompts/copilot-optimize.prompt.md'
rm '.github/prompts/copilot-update.prompt.md'
```

- [ ] **Step 2: Verify the directory is gone**

```bash
ls .github/prompts/ 2>&1
```

Expected output:

```
ls: cannot access '.github/prompts/': No such file or directory
```

- [ ] **Step 3: Commit**

```bash
git commit -m "chore: 🔥 remove deprecated prompt files"
```

---

## Task 5: Update AGENTS.md

**Files:**

- Modify: `AGENTS.md`

- [ ] **Step 1: Rewrite `AGENTS.md`**

Replace the entire file content with:

```markdown
# gc-config

GitHub Copilot CLI plugin providing two skills for setting up and maintaining
best-practice GitHub Copilot Coding Agent configurations.

## Key Config Files

| File                                                   | Purpose                                    |
| ------------------------------------------------------ | ------------------------------------------ |
| `.github/plugin/marketplace.json`                      | Copilot CLI marketplace manifest           |
| `plugins/gc-config/plugin.json`                        | Plugin manifest                            |
| `plugins/gc-config/skills/gc-config-init/SKILL.md`     | Skill: bootstrap GitHub Copilot config     |
| `plugins/gc-config/skills/gc-config-optimize/SKILL.md` | Skill: audit GitHub Copilot config         |
| `install.sh`                                           | Deprecated shim pointing to plugin install |

## Setup

No build steps required. This is a content repository of Markdown and JSON files.

## Conventions

- Plugin manifest fields follow the Copilot CLI plugin reference spec.
- Skill SKILL.md files use YAML frontmatter (name, description, allowed-tools, argument-hint).
- Keep skill content aligned: both skills end with the learnings/feedback step.
- Internal skill cross-references use `/gc-config-init` and `/gc-config-optimize`.

## Don't

- Don't commit secrets or credentials.
- Don't use `--force` git flags — fix the underlying issue instead.
```

- [ ] **Step 2: Commit**

```bash
git add AGENTS.md
git commit -m "docs: 📝 update AGENTS.md for gc-config plugin repo"
```

---

## Task 6: Replace install.sh with a shim

**Files:**

- Modify: `install.sh`

- [ ] **Step 1: Rewrite `install.sh`**

Replace the entire file content with:

```bash
#!/usr/bin/env bash
# install.sh — DEPRECATED
#
# Skills are now distributed as a GitHub Copilot CLI plugin.
# Install via the Copilot CLI plugin system instead.

echo ""
echo "This install script is no longer used."
echo ""
echo "Install the gc-config skills via the GitHub Copilot CLI plugin system:"
echo ""
echo "  1. In GitHub Copilot CLI, run:"
echo "       /plugin marketplace add MichaelvanLaar/gc-config"
echo ""
echo "  2. Then install the plugin:"
echo "       /plugin install gc-config@gc-config"
echo ""
echo "  3. To enable auto-updates, go to /plugin → Marketplaces tab"
echo "     and turn on auto-update for MichaelvanLaar/gc-config."
echo ""

exit 1
```

- [ ] **Step 2: Verify the shim runs and exits with code 1**

```bash
bash install.sh; echo "Exit code: $?"
```

Expected output:

```

This install script is no longer used.

Install the gc-config skills via the GitHub Copilot CLI plugin system:

  1. In GitHub Copilot CLI, run:
       /plugin marketplace add MichaelvanLaar/gc-config

  2. Then install the plugin:
       /plugin install gc-config@gc-config

  3. To enable auto-updates, go to /plugin → Marketplaces tab
     and turn on auto-update for MichaelvanLaar/gc-config.

Exit code: 1
```

- [ ] **Step 3: Commit**

```bash
git add install.sh
git commit -m "chore: 🔧 replace install.sh with plugin system shim"
```

---

## Task 7: Rewrite README.md

**Files:**

- Modify: `README.md`

- [ ] **Step 1: Rewrite `README.md`**

Replace the entire file with:

```markdown
# gc-config

Two GitHub Copilot CLI skills for setting up and maintaining a best-practice GitHub Copilot Coding Agent configuration, distributed as a Copilot CLI plugin.

**`/gc-config-init`** bootstraps a lean configuration for a new or unconfigured project — creating `copilot-instructions.md`, path-specific instruction files, `copilot-setup-steps.yml`, and `AGENTS.md` where applicable.

**`/gc-config-optimize`** audits and improves an existing Copilot configuration against current best practices — checking for the 8,000-character limit, anti-patterns, missing sections, consistency between files, and accumulated learnings.

Both skills are grounded in the official GitHub Copilot Coding Agent documentation and research on agent instruction design.

## Table of Contents

- [gc-config](#gc-config)
  - [Table of Contents](#table-of-contents)
  - [What problem do these skills solve?](#what-problem-do-these-skills-solve)
  - [Installation](#installation)
    - [Keeping skills current](#keeping-skills-current)
    - [Uninstalling](#uninstalling)
  - [Usage](#usage)
    - [`/gc-config-init` — Bootstrap a new project](#gc-config-init--bootstrap-a-new-project)
    - [`/gc-config-optimize` — Audit and improve an existing setup](#gc-config-optimize--audit-and-improve-an-existing-setup)
    - [Recommended workflow](#recommended-workflow)
  - [What the skills create and check](#what-the-skills-create-and-check)
    - [Configuration files](#configuration-files)
    - [Key best practices applied](#key-best-practices-applied)
  - [What these skills cannot configure](#what-these-skills-cannot-configure)
  - [Compatibility](#compatibility)
  - [Contributing](#contributing)
  - [License](#license)

## What problem do these skills solve?

GitHub Copilot's Coding Agent reads configuration from several sources — a global instructions file, path-specific instruction files, a setup workflow, and `AGENTS.md`. Without guidance, these files tend to accumulate noise: personality instructions, file-by-file descriptions, rules that a linter already enforces, and content that blows past the 8,000-character limit without warning.

These skills take a different approach:

- **`/gc-config-init`** creates the minimum viable configuration that's correct from day one: a focused `copilot-instructions.md` (under the character limit), path-specific instruction files scoped with correct `applyTo` globs, and a properly structured `copilot-setup-steps.yml` if a build system is detected.

- **`/gc-config-optimize`** treats your existing configuration as a codebase to audit. It inventories every config file, measures character counts, checks for known anti-patterns, and presents findings in three tiers — must fix, should fix, nice to have — before touching anything.

## Installation

Open GitHub Copilot CLI in any project and run:
```

/plugin marketplace add MichaelvanLaar/gc-config
/plugin install gc-config@gc-config

```

That's it. GitHub Copilot CLI downloads the skills and makes `/gc-config-init` and `/gc-config-optimize` available immediately.

> **Note:** Auto-update for third-party marketplaces is off by default — see [Keeping skills current](#keeping-skills-current) to enable it.

### Keeping skills current

The plugin system checks for updates automatically on startup. For third-party marketplaces (like this one), auto-update is **off by default**. To enable it:

1. Run `/plugin` in GitHub Copilot CLI
2. Go to the **Marketplaces** tab
3. Turn on auto-update for `MichaelvanLaar/gc-config`

Once enabled, GitHub Copilot CLI updates the skills on startup whenever a new version is available.

### Uninstalling

To remove the plugin and the marketplace in one step:

```

/plugin marketplace remove gc-config

```

Removing the marketplace automatically uninstalls any plugins installed from it. To remove only the plugin while keeping the marketplace:

```

/plugin uninstall gc-config@gc-config

```

## Usage

### `/gc-config-init` — Bootstrap a new project

Start GitHub Copilot CLI in your project directory and invoke the skill:

```

/gc-config-init

```

Or with a brief project description to skip some questions:

```

/gc-config-init Next.js 14 e-commerce platform with Stripe and Postgres
/gc-config-init Rust CLI tool with clap, targeting Linux and macOS

```

The skill will:

1. **Scan** for existing Copilot config files and abort if `copilot-instructions.md` already exists (use `/gc-config-optimize` instead).
2. **Detect** the project's toolchain to propose relevant `copilot-setup-steps.yml` content and infer what path-specific instruction files might be useful.
3. **Create** up to four outputs:
   - `.github/copilot-instructions.md` — global agent instructions, kept under 8,000 characters
   - `.github/instructions/*.instructions.md` — path-specific instruction files with correct `applyTo` glob patterns (offered, not forced)
   - `.github/workflows/copilot-setup-steps.yml` — pre-install workflow when a build system is detected (job name is always `copilot-setup-steps`, runtime capped at 59 minutes)
   - `AGENTS.md` — only when evidence of a multi-tool AI environment is found
4. **Summarize** what was created, what was skipped, and why.

### `/gc-config-optimize` — Audit and improve an existing setup

Attach the skill in GitHub Copilot CLI. You can optionally focus on a specific area:

```

/gc-config-optimize
/gc-config-optimize length
/gc-config-optimize caching

```

The skill will:

1. **Inventory** all Copilot config files and take a metrics snapshot: character counts, number of path-specific instruction files, presence of `copilot-setup-steps.yml`, `AGENTS.md`, and `copilot-learnings.md`.
2. **Audit** against best practices, checking for:
   - **Must fix**: over the 8,000-character limit, invalid `applyTo` globs, wrong job name in `copilot-setup-steps.yml`, contradictions between `AGENTS.md` and `copilot-instructions.md`
   - **Should fix**: anti-patterns (personality instructions, file-by-file descriptions, linter-enforced rules), missing Commands section, missing `copilot-setup-steps.yml` when a build system is detected, missing dependency caching in `copilot-setup-steps.yml`
   - **Nice to have**: missing architecture overview, no path-specific files for a multi-subsystem project
3. **Review learnings**: if `.github/copilot-learnings.md` exists, classify each entry as a recurring pattern (promote into config) or a one-off (delete), and include findings in the report.
4. **Present** all findings grouped by severity tier before touching anything.
5. **Wait for your approval**, then apply only the changes you approve.
6. **Report** before/after metrics for every modified file, plus how many learnings entries were promoted, deleted, or remain.

### Recommended workflow

```

Day 1: /gc-config-init ← Bootstrap config for a new project
... start coding ...

Week 1: /gc-config-optimize ← First audit pass with real code context
... continue building ...

Ongoing: /gc-config-optimize ← Periodic hygiene checks; incorporates accumulated learnings
/gc-config-optimize length ← When copilot-instructions.md has grown

```

## What the skills create and check

### Configuration files

| File                                        | Created by                         | Purpose                                                                                                     |
| ------------------------------------------- | ---------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `.github/copilot-instructions.md`           | `/gc-config-init`                  | Global agent instructions, loaded every session (limit: ~8,000 characters)                                  |
| `.github/instructions/*.instructions.md`    | `/gc-config-init` (optional)       | Path-specific instructions, scoped via `applyTo` glob in frontmatter                                        |
| `.github/workflows/copilot-setup-steps.yml` | `/gc-config-init` (optional)       | Pre-install dependencies before Copilot runs; job must be named `copilot-setup-steps`; max 59 minutes       |
| `AGENTS.md`                                 | `/gc-config-init` (optional)       | Vendor-neutral agent instructions for multi-tool AI environments                                            |
| `.github/copilot-learnings.md`              | Created by Copilot on corrections  | Accumulates one-line corrections from skill feedback steps; reviewed and incorporated by `/gc-config-optimize` |

### Key best practices applied

- **Stay under 8,000 characters**: `copilot-instructions.md` is loaded on every agent session. Content past ~8,000 characters is silently truncated. The skills measure this and flag overruns.
- **Path-specific scoping**: use `.github/instructions/*.instructions.md` with `applyTo` glob patterns to deliver frontend, backend, or test-specific context only when relevant — avoids bloating the global file.
- **`applyTo` correctness**: invalid glob patterns silently fail. The skills check that every `applyTo` value is a valid glob.
- **`copilot-setup-steps.yml` constraints**: the workflow job must be named exactly `copilot-setup-steps` or Copilot ignores it. Runtime is capped at 59 minutes. The skills enforce both.
- **Dependency caching in setup steps**: without caching, every agent session reinstalls all dependencies from scratch. The skills generate and check for ecosystem-specific caching: `actions/setup-node@v4` with `cache: 'npm'`, `actions/setup-python@v5` with `cache: 'pip'`, `actions/setup-go@v5` with `cache: true`, and `actions/cache@v4` for Cargo.
- **Remove anti-patterns**: personality instructions ("be concise"), file-by-file descriptions, and rules that a linter already enforces all waste the character budget without adding value.
- **Commands section**: a `## Commands` section with the project's build, test, and lint commands gives Copilot the verification loop it needs to self-check its own work.
- **`AGENTS.md` consistency**: when both `AGENTS.md` and `copilot-instructions.md` exist, the skills check for contradictions between them.
- **Learning and improvement**: each skill ends with a feedback step. When Copilot makes a mistake, the correction is logged as a one-line entry in `.github/copilot-learnings.md`. Running `/gc-config-optimize` periodically reviews these entries, promotes recurring patterns into the configuration, and deletes one-offs — keeping the learnings file lean or removing it until the next correction cycle.

## What these skills cannot configure

Unlike the companion [cc-config](https://github.com/MichaelvanLaar/cc-config) for Claude Code, these skills target GitHub Copilot's configuration surface. Several Claude Code features have no Copilot equivalent:

| Claude Code feature                                     | Status in GitHub Copilot                                                                                                                                                     |
| ------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `permissions.deny` / `permissions.allow`                | No file-level access control                                                                                                                                                 |
| PostToolUse hooks (auto-formatter)                      | No hook system                                                                                                                                                               |
| Autocompact control (`CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`) | No equivalent                                                                                                                                                                |
| `@`-import progressive disclosure                       | `copilot-instructions.md` loads in full every session                                                                                                                        |
| Learnings auto-loading                                  | `CLAUDE.md` can reference `learnings.md` so corrections load automatically; `copilot-learnings.md` is passive — run `/gc-config-optimize` explicitly to incorporate corrections |
| MCP server automation via files                         | MCP servers are configured in GitHub repository settings UI only                                                                                                             |
| `.claude/context/` shared domain folder                 | No equivalent; content must live in `copilot-instructions.md` or path-specific files                                                                                         |
| Content exclusions (file patterns to hide from Copilot) | Configured in GitHub UI only — Organization or repository Settings → Copilot → Content exclusion                                                                             |
| Spending limits / budget caps                           | Configured in GitHub UI only — Organization Settings → Billing → GitHub Copilot                                                                                              |

## Compatibility

- Works with any programming language, framework, or build tool.
- Works with content projects (static sites, documentation sets, Markdown-driven workflows).
- Supports multi-tool AI environments (Claude Code, Cursor, Gemini) via `AGENTS.md`.
- Requires GitHub Copilot CLI.

## Contributing

Issues and pull requests are welcome. If you've found a best practice that isn't covered, or a pattern that the skills should detect, please open an issue.

## License

[MIT](LICENSE)
```

- [ ] **Step 2: Verify README has all required sections**

```bash
for section in "What problem" "Installation" "Keeping skills" "Uninstalling" "Usage" "gc-config-init" "gc-config-optimize" "Recommended workflow" "Configuration files" "Key best practices" "cannot configure" "Compatibility" "Contributing" "License"; do
  grep -q "$section" README.md && echo "✓ $section" || echo "✗ MISSING: $section"
done
```

Expected output: all lines showing `✓`.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: 📝 rewrite README for Copilot CLI plugin"
```

---

## Task 8: Rename GitHub repository (manual)

This step requires GitHub access and cannot be done by an automated agent.

- [ ] **Step 1: Rename the repository on GitHub**

Run in the terminal (requires `gh` CLI authenticated):

```bash
gh repo rename gc-config --yes
```

GitHub automatically sets up a redirect from the old URL (`github.com/MichaelvanLaar/github-copilot-config-skills`) to the new one (`github.com/MichaelvanLaar/gc-config`). Existing clones and links continue to work.

- [ ] **Step 2: Update the local git remote (if needed)**

```bash
git remote get-url origin
```

If the output still shows the old name, update it:

```bash
git remote set-url origin https://github.com/MichaelvanLaar/gc-config.git
```

- [ ] **Step 3: Verify the new URL resolves**

```bash
git ls-remote origin HEAD
```

Expected: a commit SHA printed without error.

- [ ] **Step 4: Push all commits**

```bash
git push
```

---

## Self-Review

**Spec coverage check:**

| Spec requirement                                       | Covered by                                      |
| ------------------------------------------------------ | ----------------------------------------------- |
| `.github/plugin/marketplace.json`                      | Task 1                                          |
| `plugins/gc-config/plugin.json`                        | Task 1                                          |
| `plugins/gc-config/skills/gc-config-init/SKILL.md`     | Task 2                                          |
| `plugins/gc-config/skills/gc-config-optimize/SKILL.md` | Task 3                                          |
| Remove `.github/prompts/`                              | Task 4                                          |
| Update `AGENTS.md`                                     | Task 5                                          |
| Replace `install.sh` with shim                         | Task 6                                          |
| Rewrite `README.md`                                    | Task 7                                          |
| GitHub repo rename                                     | Task 8                                          |
| Drop `copilot-update` skill                            | Covered: not created, prompts deleted in Task 4 |

All spec requirements covered. ✓
