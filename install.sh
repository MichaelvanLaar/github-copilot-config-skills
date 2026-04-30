#!/usr/bin/env bash
# Install copilot-* skills from MichaelvanLaar/github-copilot-config-skills
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/MichaelvanLaar/github-copilot-config-skills/main/install.sh | bash
#   curl -fsSL .../install.sh | bash -s path/to/project
#   curl -fsSL .../install.sh | REF=v1.0.0 bash              # pin to a specific tag

set -euo pipefail

REF="${REF:-main}"
BASE="https://raw.githubusercontent.com/MichaelvanLaar/github-copilot-config-skills/$REF"
SKILLS=(copilot-init copilot-optimize copilot-update)

TARGET="."
for arg in "$@"; do
  case "$arg" in
    -*) echo "Unknown flag: $arg" >&2; exit 1 ;;
    *) TARGET="$arg" ;;
  esac
done

echo "Installing copilot-* skills to: $TARGET"
echo ""

mkdir -p "$TARGET/.github/prompts"
for skill in "${SKILLS[@]}"; do
  skill_dir="$TARGET/.github/skills/$skill"
  mkdir -p "$skill_dir"
  if curl -fsSL "$BASE/.github/skills/$skill/SKILL.md" -o "$skill_dir/SKILL.md"; then
    echo "  ✓ .github/skills/$skill/SKILL.md"
  else
    echo "  ✗ failed: .github/skills/$skill/SKILL.md" >&2
  fi

  prompt="$TARGET/.github/prompts/$skill.prompt.md"
  if curl -fsSL "$BASE/.github/prompts/$skill.prompt.md" -o "$prompt"; then
    echo "  ✓ .github/prompts/$skill.prompt.md"
  else
    echo "  ✗ failed: .github/prompts/$skill.prompt.md" >&2
  fi
done

echo ""
echo "Done."
echo ""
echo "In Copilot Chat, attach a skill or prompt file and ask Copilot to:"
echo "  copilot-init     — Bootstrap GitHub Copilot config for a new project"
echo "  copilot-optimize — Audit and improve an existing config"
echo "  copilot-update   — Update skills to their latest versions"
