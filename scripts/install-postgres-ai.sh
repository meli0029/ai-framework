#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

log_section "Installing PostgreSQL AI Tooling"

require_node

echo ""
echo "This installer uses the official Timescale pg-aiguide installer."
echo ""
echo "Recommended installation:"
echo "  - Universal (.agents/skills)"
echo "  - Global scope"
echo ""
echo "These skills are reusable across client repositories."
echo "Client-specific knowledge belongs in the client's AI Framework folder."
echo ""
echo "Launching official installer..."
echo ""

npx skills add timescale/pg-aiguide --skill postgres

echo ""
echo "PostgreSQL AI tooling installed successfully."
echo "Any additional agent configuration should follow the vendor's official documentation."
