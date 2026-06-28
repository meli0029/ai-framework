#!/usr/bin/env bash
set -euo pipefail

show_help() {
  echo "AI Framework Installer"
  echo ""
  echo "Usage:"
  echo "  ./scripts/install-framework.sh [options]"
  echo ""
  echo "Options:"
  echo "  --fabric        Install Microsoft Fabric Skills"
  echo "  --help, -h      Show this help"
}

if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fabric)
      "$SCRIPT_DIR/install-fabric-skills.sh"
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
