## ADDED Requirements

### Requirement: Context gathering before any file creation

The skill SHALL scan the project directory for existing Copilot configuration, project toolchain clues, sensitive files, and quality tools before creating any files. It SHALL NOT create files until the scan is complete.

#### Scenario: Existing copilot-instructions.md detected

- **WHEN** `.github/copilot-instructions.md` already exists
- **THEN** the skill SHALL stop, inform the user this skill is for fresh setups, and suggest running `copilot-optimize` instead

#### Scenario: Project description provided as argument

- **WHEN** `$ARGUMENTS` contains a project description
- **THEN** the skill SHALL use that description to infer stack and toolchain without asking

#### Scenario: Empty or minimal project

- **WHEN** no package manager, build tool, or content-toolchain config is found
- **THEN** the skill SHALL ask the user what the project produces and what toolchain is involved before proceeding

### Requirement: Create .github/copilot-instructions.md

The skill SHALL create `.github/copilot-instructions.md` with a lean structure covering the repository summary, build/test/lint commands, architecture overview, and coding conventions. The file SHALL stay within the ~2 page / ~8 000 character limit imposed by GitHub Copilot.

#### Scenario: Commands are known

- **WHEN** the skill detects build/test/lint commands from package.json, Makefile, or similar
- **THEN** copilot-instructions.md SHALL include those exact commands with validated sequences

#### Scenario: Commands are unknown

- **WHEN** no build/test commands can be determined
- **THEN** the skill SHALL insert `TODO:` placeholders for the commands section rather than guessing

#### Scenario: Instruction file is generated

- **WHEN** copilot-instructions.md is created
- **THEN** it SHALL contain at minimum: a one-line project description, a Commands section, and a Conventions section

### Requirement: Create path-specific instruction files

The skill SHALL offer to create one or more `.github/instructions/*.instructions.md` files using `applyTo` glob patterns when the project has distinct subsystems with different conventions (e.g., separate frontend and backend, or test files with different rules).

#### Scenario: Monolithic project with uniform conventions

- **WHEN** no distinct subsystems are detected
- **THEN** the skill SHALL NOT create path-specific instruction files (global instructions are sufficient)

#### Scenario: Project with distinct file-type conventions

- **WHEN** the project has files with clearly different tooling conventions (e.g., TypeScript frontend and Python backend)
- **THEN** the skill SHALL create appropriately scoped `.github/instructions/*.instructions.md` files with matching `applyTo` patterns

### Requirement: Create copilot-setup-steps.yml when build system exists

The skill SHALL offer to create `.github/workflows/copilot-setup-steps.yml` when the project has a build system, package manager, or dependency manager. The file SHALL follow GitHub Actions syntax with a single `copilot-setup-steps` job that pre-installs dependencies.

#### Scenario: Project has package manager

- **WHEN** `package.json`, `requirements.txt`, `Cargo.toml`, `go.mod`, `composer.json`, or similar is detected
- **THEN** the skill SHALL generate a `copilot-setup-steps.yml` that installs dependencies and, if applicable, runs a build or type-check step

#### Scenario: Project has no build system

- **WHEN** no package manager or build tool config is found
- **THEN** the skill SHALL NOT create `copilot-setup-steps.yml` and SHALL note this in the summary

### Requirement: Create AGENTS.md when multi-tool environment is detected

The skill SHALL create `AGENTS.md` when it detects that other AI coding tools are in use alongside GitHub Copilot (e.g., `.claude/`, `.gemini/`, Cursor config), or when the user confirms a multi-tool setup.

#### Scenario: Only GitHub Copilot detected

- **WHEN** no other AI tool configuration directories are found
- **THEN** the skill SHALL NOT create `AGENTS.md`

#### Scenario: Claude Code also in use

- **WHEN** `.claude/` directory is detected
- **THEN** the skill SHALL create `AGENTS.md` with vendor-neutral shared instructions

### Requirement: Feature gap documentation

The skill SHALL include a concise "What this skill cannot do" note in its output summary, listing Copilot platform limitations: no permissions deny/allow, no PostToolUse hooks, no autocompact control, no `@`-import progressive disclosure.

#### Scenario: Skill completes successfully

- **WHEN** the skill finishes creating files
- **THEN** the summary SHALL include a brief "Limitations vs. Claude Code" section that lists the features not available in GitHub Copilot

### Requirement: Deliver in three formats

The `copilot-init` capability SHALL be delivered as a Claude Code SKILL.md (`.claude/skills/copilot-init/SKILL.md`), a GitHub Copilot SKILL.md (`.github/skills/copilot-init/SKILL.md`), and a GitHub Copilot prompt file (`.github/prompts/copilot-init.prompt.md`).

#### Scenario: User invokes from Claude Code

- **WHEN** a user runs `/copilot-init` in Claude Code
- **THEN** the `.claude/skills/copilot-init/SKILL.md` is executed with full multi-step flow

#### Scenario: User invokes from GitHub Copilot

- **WHEN** a user attaches the `.github/prompts/copilot-init.prompt.md` in Copilot Chat
- **THEN** Copilot executes a simplified version of the same workflow
