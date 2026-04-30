## 1. copilot-init

- [ ] 1.1 Create `.claude/skills/copilot-init/SKILL.md` — full multi-step Claude Code skill: context gathering (scan for existing config, detect toolchain, handle `$ARGUMENTS`), create `.github/copilot-instructions.md`, offer path-specific instruction files with `applyTo` patterns, offer `copilot-setup-steps.yml` when build system detected, create `AGENTS.md` when multi-tool environment found, inline "What this skill cannot do" section, and post-creation summary
- [ ] 1.2 Create `.github/skills/copilot-init/SKILL.md` — GitHub Copilot native skill with SKILL.md frontmatter, same workflow adapted for Copilot's tool surface
- [ ] 1.3 Create `.github/prompts/copilot-init.prompt.md` — simplified one-page prompt version noting it is a lighter alternative to the full skill

## 2. copilot-optimize

- [ ] 2.1 Create `.claude/skills/copilot-optimize/SKILL.md` — full audit Claude Code skill: full inventory and metrics snapshot, length audit (8 000-char limit), content quality audit (missing commands section, anti-patterns, missing architecture overview), path-specific instruction coverage check, `copilot-setup-steps.yml` audit, `AGENTS.md` consistency check, tiered findings (must fix / should fix / nice to have) with approval gate, apply only approved changes with before/after metrics
- [ ] 2.2 Create `.github/skills/copilot-optimize/SKILL.md` — GitHub Copilot native skill with SKILL.md frontmatter, same audit workflow adapted for Copilot's tool surface
- [ ] 2.3 Create `.github/prompts/copilot-optimize.prompt.md` — simplified prompt version of the audit workflow noting it is a lighter alternative

## 3. copilot-update

- [ ] 3.1 Create `.claude/skills/copilot-update/SKILL.md` — curl-based update Claude Code skill: detect installed `copilot-*` skills, update `.claude/skills/copilot-*/SKILL.md` for present skills only, update `.github/skills/copilot-*/SKILL.md` if present, update `.github/prompts/copilot-*.prompt.md` if present, always self-update `copilot-update`, report per-file success/failure, output commit reminder with exact git command
- [ ] 3.2 Create `.github/skills/copilot-update/SKILL.md` — GitHub Copilot native skill with SKILL.md frontmatter, same update logic adapted for Copilot's tool surface
- [ ] 3.3 Create `.github/prompts/copilot-update.prompt.md` — simplified prompt version of the update workflow
