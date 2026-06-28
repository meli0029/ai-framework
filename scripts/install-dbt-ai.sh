#!/usr/bin/env bash
set -euo pipefail

echo "Installing dbt AI tooling..."

if ! command -v npx >/dev/null 2>&1; then
  echo "npx is required. Install Node.js/npm first."
  exit 1
fi

npx skills add dbt-labs/dbt-agent-skills

echo "dbt agent skills installed."
echo "Note: dbt MCP setup may require project-specific credentials and should be configured inside the client repo."
