---
name: copilot-update
description: Update the copilot-init, copilot-optimize, and copilot-update skills to their latest versions from the source repository. Use when the user says "update copilot skills", "get the latest copilot-init", "refresh copilot skills", or similar.
license: MIT
compatibility: Requires curl.
metadata:
  author: MichaelvanLaar
  version: "1.0"
  generatedBy: "1.0.0"
---

# Update Copilot Skills

Fetch the latest versions of the installed copilot-\* skills from `MichaelvanLaar/github-copilot-config-skills` and replace the local copies.

## Step 1: Check prerequisites

Verify `.github/skills/` exists in the current directory:

```bash
ls .github/skills/ 2>/dev/null || echo "NOT_FOUND"
```

If the directory is missing, abort and tell the user: "No `.github/skills/` directory found. Install the skills first — see the README at github.com/MichaelvanLaar/github-copilot-config-skills."

## Step 2: Detect installed skills

```bash
for skill in copilot-init copilot-optimize copilot-update; do
  [ -f ".github/skills/$skill/SKILL.md" ] && echo "$skill: installed" || echo "$skill: not installed"
done
```

Update rules:

- **`copilot-update`** — always update (enables self-update).
- **`copilot-init` and `copilot-optimize`** — only if already installed. Do not install skills the user has not chosen to install.

If none of the three skills are installed, abort: "No `copilot-*` skills found. Install the skills first — see github.com/MichaelvanLaar/github-copilot-config-skills."

## Step 3: Download and replace

For each installed skill, update both file locations if they exist:

1. `.github/skills/$skill/SKILL.md` — always update if the skill is installed (or is `copilot-update`)
2. `.github/prompts/$skill.prompt.md` — update only if the file already exists

```bash
BASE_URL="https://raw.githubusercontent.com/MichaelvanLaar/github-copilot-config-skills/main"

for skill in copilot-update copilot-init copilot-optimize; do
  github_skill=".github/skills/$skill/SKILL.md"
  github_prompt=".github/prompts/$skill.prompt.md"

  if [ "$skill" = "copilot-update" ] || [ -f "$github_skill" ]; then
    mkdir -p ".github/skills/$skill"
    if curl -fsSL "$BASE_URL/.github/skills/$skill/SKILL.md" -o "$github_skill"; then
      echo "✓ updated $github_skill"
    else
      echo "✗ failed to update $github_skill"
    fi

    if [ -f "$github_prompt" ]; then
      if curl -fsSL "$BASE_URL/.github/prompts/$skill.prompt.md" -o "$github_prompt"; then
        echo "✓ updated $github_prompt"
      else
        echo "✗ failed to update $github_prompt"
      fi
    fi
  else
    echo "— skipped $skill (not installed)"
  fi
done
```

## Step 4: Report and wrap up

After the downloads complete:

1. List each skill: updated files, skipped files, or failed files.
2. If `copilot-init` or `copilot-optimize` were skipped (not installed), mention: "They are available but not installed — see github.com/MichaelvanLaar/github-copilot-config-skills to add them."
3. Remind the user to commit the updated files:
   ```
   git add .github/skills/ .github/prompts/ && git commit
   ```

## What this skill cannot do

Unlike the Claude Code equivalent (`cc-update`), this skill cannot configure:

- **No permissions deny/allow** — Copilot has no file-level access control
- **No PostToolUse hooks** — no hook system for auto-formatting after edits
- **No autocompact control** — no equivalent to `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`
- **No `@`-import progressive disclosure** — `copilot-instructions.md` loads in full on every session; unlike Claude Code's `CLAUDE.md`, it cannot `@`-import `copilot-learnings.md` automatically
- **No MCP automation** — MCP servers are configured in GitHub repository settings UI, not via files

## What NOT to do

- Do not install `copilot-init` or `copilot-optimize` if they were not already present.
- Do not run any skill after updating.
- Do not modify any other project files.

---

Did this output meet your expectations? If not, describe what was off and Copilot will log the correction to `.github/copilot-learnings.md`.

> **Note:** Unlike the Claude Code equivalent (`cc-update`), corrections are not auto-loaded on every session — Copilot has no `@`-import support. Run `copilot-optimize` periodically to review accumulated learnings and promote them into your configuration.
