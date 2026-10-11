#!/usr/bin/env bash
set -euo pipefail

show_help() {
  echo "AI Framework Installer"
  echo ""
  echo "Usage:"
  echo "  ./scripts/install-framework.sh [options]"
  echo ""
  echo "Options:"
  echo "  --framework-skills  Install this repository's reusable Codex skills"
  echo "  --fabric        Install Microsoft Fabric Skills"
  echo "  --fabric-tools  Check/install Fabric CLI workstation prerequisites"
  echo "  --help, -h      Show this help"
}

if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --framework-skills)
      "$SCRIPT_DIR/install-framework-skills.sh"
      ;;
    --fabric)
      "$SCRIPT_DIR/install-fabric-skills.sh"
      ;;
    --fabric-tools)
      "$SCRIPT_DIR/bootstrap-fabric-tools.sh" --install
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo ""
      show_help
      exit 1
      ;;
  esac
  shift
done

echo ""
echo "AI Framework installation complete."
