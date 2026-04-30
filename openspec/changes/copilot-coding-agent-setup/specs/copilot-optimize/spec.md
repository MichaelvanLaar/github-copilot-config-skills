## ADDED Requirements

### Requirement: Full inventory before analysis

The skill SHALL read and catalog all existing Copilot configuration files before suggesting any changes: `.github/copilot-instructions.md`, all `.github/instructions/*.instructions.md` files, `AGENTS.md`, `.github/workflows/copilot-setup-steps.yml`, and any `CLAUDE.md` / `GEMINI.md` at the project root. It SHALL report a metrics snapshot before proposing changes.

#### Scenario: Config files exist

- **WHEN** the skill is invoked on a project with existing Copilot config
- **THEN** the skill SHALL report: line count of `copilot-instructions.md`, number of path-specific instruction files, presence/absence of `copilot-setup-steps.yml`, and presence/absence of `AGENTS.md`

#### Scenario: No Copilot config found

- **WHEN** `.github/copilot-instructions.md` does not exist
- **THEN** the skill SHALL stop and suggest running `copilot-init` instead

### Requirement: Instruction file length audit

The skill SHALL check that `.github/copilot-instructions.md` does not exceed the ~2 page / ~8 000 character limit. It SHALL flag the file as "must fix" if it is too long and suggest specific sections to trim or move to path-specific instruction files.

#### Scenario: File within limit

- **WHEN** `copilot-instructions.md` is under 8 000 characters
- **THEN** no length warning is shown

#### Scenario: File exceeds limit

- **WHEN** `copilot-instructions.md` exceeds 8 000 characters
- **THEN** the skill SHALL flag it as "must fix", report the character count, and suggest which sections to move to path-specific instruction files or remove

### Requirement: Instruction content quality audit

The skill SHALL check `copilot-instructions.md` for missing essential sections and known anti-patterns.

#### Scenario: Missing commands section

- **WHEN** `copilot-instructions.md` contains no build, test, or lint commands
- **THEN** the skill SHALL flag this as "should fix" with a note that the Coding Agent needs explicit command sequences to avoid CI failures

#### Scenario: Contains anti-patterns

- **WHEN** the file contains personality instructions ("act as a senior engineer"), file-by-file codebase descriptions, or rules the linter already enforces
- **THEN** the skill SHALL flag each instance as "should fix" with a specific removal suggestion

#### Scenario: No architecture overview

- **WHEN** the file has no description of directory structure or key architectural patterns
- **THEN** the skill SHALL flag this as "nice to have" with a suggestion to add a brief layout section

### Requirement: Path-specific instruction coverage check

The skill SHALL assess whether path-specific `.github/instructions/*.instructions.md` files would improve the setup for projects with distinct subsystems.

#### Scenario: Multi-language project with single instruction file

- **WHEN** the project has clearly distinct subsystems (e.g., TypeScript frontend and Python backend) and no path-specific instruction files exist
- **THEN** the skill SHALL flag this as "nice to have" and suggest which glob patterns would be useful

#### Scenario: Path-specific files have invalid applyTo patterns

- **WHEN** a `.github/instructions/*.instructions.md` file has a missing or malformed `applyTo` frontmatter field
- **THEN** the skill SHALL flag it as "must fix"

### Requirement: copilot-setup-steps.yml audit

The skill SHALL check for the presence and quality of `.github/workflows/copilot-setup-steps.yml` when the project has a build or dependency system.

#### Scenario: Build system present but no setup steps

- **WHEN** a package manager or build tool is detected and `copilot-setup-steps.yml` is absent
- **THEN** the skill SHALL flag this as "should fix" with a note that pre-installing dependencies reduces failed agent sessions and token waste

#### Scenario: Setup steps workflow exists

- **WHEN** `copilot-setup-steps.yml` exists
- **THEN** the skill SHALL verify it has the required `copilot-setup-steps` job name and report any structural issues as "must fix"

### Requirement: AGENTS.md consistency check

The skill SHALL verify that `AGENTS.md` (if present) is consistent with `copilot-instructions.md` — no contradictory rules, no duplicate content.

#### Scenario: Contradictory rules detected

- **WHEN** `AGENTS.md` and `copilot-instructions.md` contain contradictory coding rules
- **THEN** the skill SHALL flag the conflict as "must fix" and show both conflicting passages

### Requirement: Tiered findings with approval gate

The skill SHALL present all findings grouped as "must fix / should fix / nice to have" and SHALL wait for user approval before modifying any file.

#### Scenario: User approves all changes

- **WHEN** the user approves the full list of proposed changes
- **THEN** the skill SHALL apply every change and report before/after metrics

#### Scenario: User approves selectively

- **WHEN** the user approves only a subset of proposed changes
- **THEN** the skill SHALL apply only the approved changes and leave the rest untouched

### Requirement: Deliver in three formats

The `copilot-optimize` capability SHALL be delivered as a Claude Code SKILL.md (`.claude/skills/copilot-optimize/SKILL.md`), a GitHub Copilot SKILL.md (`.github/skills/copilot-optimize/SKILL.md`), and a GitHub Copilot prompt file (`.github/prompts/copilot-optimize.prompt.md`).

#### Scenario: User invokes from Claude Code

- **WHEN** a user runs `/copilot-optimize` in Claude Code
- **THEN** the `.claude/skills/copilot-optimize/SKILL.md` is executed with full multi-step audit flow

#### Scenario: User invokes from GitHub Copilot

- **WHEN** a user attaches the `.github/prompts/copilot-optimize.prompt.md` in Copilot Chat
- **THEN** Copilot executes a simplified version of the audit workflow
