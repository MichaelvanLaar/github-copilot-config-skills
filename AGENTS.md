# AI Coding Assistant Skills

Repository of reusable skills and prompt configurations for Claude Code and GitHub Copilot.

## Setup

No build steps required. This is a content repository of Markdown and YAML files.

## Structure

- `.claude/skills/` — Claude Code skills (SKILL.md per skill)
- `.github/prompts/` — GitHub Copilot prompt files (mirror Claude Code skills)
- `openspec/` — Change workflow management (proposals, specs, tasks)

## Conventions

- Each skill lives in its own subdirectory with a `SKILL.md` file
- GitHub Copilot prompts in `.github/prompts/` mirror Claude Code skills in purpose and content
- When editing a skill, update the corresponding file in `.github/prompts/`
- `openspec/config.yaml` holds the project context shown to AI when creating artifacts — keep it current

## Safety

- Do not commit secrets or credentials
- Do not use `--force` git flags — fix the underlying issue instead
