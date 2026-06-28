#!/usr/bin/env bash
set -euo pipefail

FABRIC_SKILLS_SOURCE="$HOME/projects/skills-for-fabric/skills"
CODEX_SKILLS_TARGET="$HOME/.codex/skills"

if [ ! -d "$FABRIC_SKILLS_SOURCE" ]; then
  echo "Fabric skills source not found:"
  echo "$FABRIC_SKILLS_SOURCE"
  echo ""
  echo "Clone it first:"
  echo "cd ~/projects"
  echo "git clone https://github.com/microsoft/skills-for-fabric.git"
  exit 1
fi

mkdir -p "$CODEX_SKILLS_TARGET"

echo "Installing Fabric skills..."
rsync -av --delete "$FABRIC_SKILLS_SOURCE/" "$CODEX_SKILLS_TARGET/"

echo ""
echo "Done."
echo "Fabric skills installed to:"
echo "$CODEX_SKILLS_TARGET"