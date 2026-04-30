## ADDED Requirements

### Requirement: Detect installed copilot skills before updating

The skill SHALL check which `copilot-*` skills are currently installed before attempting any downloads. It SHALL update only skills that are already present and SHALL NOT install skills the user has not chosen to install.

#### Scenario: All three skills installed

- **WHEN** `.claude/skills/copilot-init/SKILL.md`, `.claude/skills/copilot-optimize/SKILL.md`, and `.claude/skills/copilot-update/SKILL.md` all exist
- **THEN** the skill SHALL update all three

#### Scenario: Only copilot-update installed

- **WHEN** only `.claude/skills/copilot-update/SKILL.md` exists
- **THEN** the skill SHALL update `copilot-update` only (self-update) and report the other two as skipped

#### Scenario: No copilot skills installed

- **WHEN** no `.claude/skills/copilot-*/SKILL.md` files are found
- **THEN** the skill SHALL abort and tell the user to install skills first via the repo's installation instructions

### Requirement: Update Claude Code skill files

The skill SHALL fetch the latest `SKILL.md` for each installed `copilot-*` Claude Code skill from `MichaelvanLaar/github-copilot-config-skills` via curl and replace the local copy.

#### Scenario: Download succeeds

- **WHEN** curl successfully fetches the latest SKILL.md
- **THEN** the local file is replaced and the skill reports `✓ updated <skill-name>`

#### Scenario: Download fails

- **WHEN** curl returns a non-zero exit code for a skill
- **THEN** the local file is left unchanged and the skill reports `✗ failed to update <skill-name>`

### Requirement: Update GitHub Copilot skill files

The skill SHALL also update the corresponding `.github/skills/copilot-*/SKILL.md` files if they exist, following the same install-only-if-present rule.

#### Scenario: Matching .github/skills file exists

- **WHEN** `.github/skills/copilot-init/SKILL.md` is present and Claude Code's `copilot-init` is being updated
- **THEN** the `.github/skills/copilot-init/SKILL.md` SHALL also be updated from the repo

#### Scenario: .github/skills file absent

- **WHEN** `.github/skills/copilot-init/SKILL.md` does not exist
- **THEN** the skill SHALL NOT create it; it reports the Claude Code skill as updated and notes the GitHub skill was not installed

### Requirement: Update GitHub Copilot prompt files

The skill SHALL also update the corresponding `.github/prompts/copilot-*.prompt.md` files if they exist, following the same install-only-if-present rule.

#### Scenario: Matching prompt file exists

- **WHEN** `.github/prompts/copilot-init.prompt.md` is present
- **THEN** it SHALL be updated alongside the SKILL.md files

#### Scenario: Prompt file absent

- **WHEN** `.github/prompts/copilot-init.prompt.md` does not exist
- **THEN** the skill SHALL NOT create it

### Requirement: Self-update is always applied

The skill SHALL always update itself (`copilot-update`) regardless of whether other skills are installed, to ensure the update mechanism stays current.

#### Scenario: copilot-update is the only installed skill

- **WHEN** only `copilot-update` is installed
- **THEN** the skill updates itself and reports the others as skipped (not missing)

### Requirement: Post-update commit reminder

After completing all updates, the skill SHALL remind the user to commit the updated files.

#### Scenario: One or more files were updated

- **WHEN** at least one file was successfully updated
- **THEN** the skill SHALL output the git command to stage and commit: `git add .claude/skills/ .github/skills/ .github/prompts/ && git commit`

### Requirement: Deliver in three formats

The `copilot-update` capability SHALL be delivered as a Claude Code SKILL.md (`.claude/skills/copilot-update/SKILL.md`), a GitHub Copilot SKILL.md (`.github/skills/copilot-update/SKILL.md`), and a GitHub Copilot prompt file (`.github/prompts/copilot-update.prompt.md`).

#### Scenario: User invokes from Claude Code

- **WHEN** a user runs `/copilot-update` in Claude Code
- **THEN** the `.claude/skills/copilot-update/SKILL.md` is executed

#### Scenario: User invokes from GitHub Copilot

- **WHEN** a user attaches the `.github/prompts/copilot-update.prompt.md` in Copilot Chat
- **THEN** Copilot executes the update workflow
