#!/usr/bin/env bash
set -euo pipefail

echo "Installing PostgreSQL AI tooling..."

if ! command -v npx >/dev/null 2>&1; then
  echo "npx is required. Install Node.js/npm first."
  exit 1
fi

npx skills add timescale/pg-aiguide --skill postgres

if command -v codex >/dev/null 2>&1; then
  codex mcp add --url "https://mcp.tigerdata.com/docs" pg-aiguide || true
else
  echo "Codex CLI not found. Skipping MCP registration."
fi

echo "PostgreSQL AI tooling installed."
