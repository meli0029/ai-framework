#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_DIR="$REPO_ROOT/AI Framework/skills"
TARGET_DIR="${CODEX_HOME:-$HOME/.codex}/skills"

if ! command -v rsync >/dev/null 2>&1; then
  echo "rsync is required. Run ./scripts/bootstrap-fabric-tools.sh --install first." >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -type d -print0 |
  while IFS= read -r -d '' skill_dir; do
    if [ ! -f "$skill_dir/SKILL.md" ]; then
      continue
    fi
    skill_name="$(basename "$skill_dir")"
    mkdir -p "$TARGET_DIR/$skill_name"
    rsync -a --delete "$skill_dir/" "$TARGET_DIR/$skill_name/"
    echo "Installed framework skill: $skill_name"
  done

echo "Framework skills installed to $TARGET_DIR"
