#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

log_section "Installing PostgreSQL AI Tooling"

require_node

npx skills add timescale/pg-aiguide --skill postgres

if has_codex; then
  codex mcp add --url "https://mcp.tigerdata.com/docs" pg-aiguide || true
else
  echo "Codex CLI not found. Skipping MCP registration."
fi

echo "PostgreSQL AI tooling installed."
