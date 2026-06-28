#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

log_section "Installing Microsoft Fabric Skills"

require_git
require_rsync

VENDOR_ROOT="$HOME/.ai-framework/vendors"
FABRIC_REPO_DIR="$VENDOR_ROOT/skills-for-fabric"
FABRIC_REPO_URL="https://github.com/microsoft/skills-for-fabric.git"
FABRIC_SKILLS_SOURCE="$FABRIC_REPO_DIR/skills"
CODEX_SKILLS_TARGET="$HOME/.codex/skills"

mkdir -p "$VENDOR_ROOT"

if [ ! -d "$FABRIC_REPO_DIR/.git" ]; then
  git clone "$FABRIC_REPO_URL" "$FABRIC_REPO_DIR"
else
  git -C "$FABRIC_REPO_DIR" pull --ff-only
fi

mkdir -p "$CODEX_SKILLS_TARGET"
rsync -av "$FABRIC_SKILLS_SOURCE/" "$CODEX_SKILLS_TARGET/"

echo "Fabric skills installed to $CODEX_SKILLS_TARGET"
