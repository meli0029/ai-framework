#!/usr/bin/env bash
set -euo pipefail

FABRIC_REPO_DIR="$HOME/projects/skills-for-fabric"
FABRIC_REPO_URL="https://github.com/microsoft/skills-for-fabric.git"
FABRIC_SKILLS_SOURCE="$FABRIC_REPO_DIR/skills"
CODEX_SKILLS_TARGET="$HOME/.codex/skills"

echo "Installing Microsoft Fabric skills..."

if [ ! -d "$FABRIC_REPO_DIR/.git" ]; then
  mkdir -p "$HOME/projects"
  git clone "$FABRIC_REPO_URL" "$FABRIC_REPO_DIR"
else
  git -C "$FABRIC_REPO_DIR" pull --ff-only
fi

mkdir -p "$CODEX_SKILLS_TARGET"
rsync -av "$FABRIC_SKILLS_SOURCE/" "$CODEX_SKILLS_TARGET/"

echo "Fabric skills installed to $CODEX_SKILLS_TARGET"
