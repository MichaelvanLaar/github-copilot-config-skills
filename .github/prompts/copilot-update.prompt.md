---
description: Update installed copilot-init, copilot-optimize, and copilot-update skills to their latest versions from the source repository. Lighter alternative to the full copilot-update skill.
---

Update the installed copilot-\* skills from `MichaelvanLaar/github-copilot-config-skills`.

**Step 1 — Check prerequisites**

Verify `.github/skills/` exists. If not, abort and tell the user to install the skills first from github.com/MichaelvanLaar/github-copilot-config-skills.

**Step 2 — Detect installed skills**

```bash
for skill in copilot-init copilot-optimize copilot-update; do
  [ -f ".github/skills/$skill/SKILL.md" ] && echo "$skill: installed" || echo "$skill: not installed"
done
```

**Step 3 — Download and replace**

```bash
BASE_URL="https://raw.githubusercontent.com/MichaelvanLaar/github-copilot-config-skills/main"

for skill in copilot-update copilot-init copilot-optimize; do
  github_skill=".github/skills/$skill/SKILL.md"
  github_prompt=".github/prompts/$skill.prompt.md"

  if [ "$skill" = "copilot-update" ] || [ -f "$github_skill" ]; then
    mkdir -p ".github/skills/$skill"
    curl -fsSL "$BASE_URL/.github/skills/$skill/SKILL.md" -o "$github_skill" \
      && echo "✓ updated $github_skill" || echo "✗ failed $github_skill"
    [ -f "$github_prompt" ] && { curl -fsSL "$BASE_URL/.github/prompts/$skill.prompt.md" -o "$github_prompt" \
      && echo "✓ updated $github_prompt" || echo "✗ failed $github_prompt"; }
  else
    echo "— skipped $skill (not installed)"
  fi
done
```

Rules: `copilot-update` is always updated (self-update). `copilot-init` and `copilot-optimize` are updated only if already installed — never install skills the user has not chosen.

**Step 4 — Report and commit reminder**

List each result (updated / skipped / failed), then remind the user:

```
git add .github/skills/ .github/prompts/ && git commit
```

---

Did this output meet your expectations? If not, describe what was off and Copilot will log the correction to `.github/copilot-learnings.md`.

> **Note:** Corrections are not auto-loaded on every session. Run `copilot-optimize` periodically to review and incorporate them.
