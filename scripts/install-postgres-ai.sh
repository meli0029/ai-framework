#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

log_section "Installing PostgreSQL AI Tooling"

require_node

echo ""
echo "This installer uses the official Timescale pg-aiguide installer."
echo ""
echo "Recommended agent selections:"
echo "  - Codex"
echo "  - Claude Code"
echo "  - Cursor"
echo "  - GitHub Copilot"
echo ""
echo "The vendor installer may also select universal/default agent targets."
echo "That is expected."
echo ""
echo "Launching official installer..."
echo ""

npx skills add timescale/pg-aiguide --skill postgres

echo ""
echo "Registering PostgreSQL documentation MCP with Codex, if available..."

if has_codex; then
  codex mcp add --url "https://mcp.tigerdata.com/docs" pg-aiguide || true
else
  echo "Codex CLI not found. Skipping Codex MCP registration."
fi

echo ""
echo "PostgreSQL AI tooling installed."
