#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

log_section "Installing dbt AI Tooling"

require_node

npx skills add dbt-labs/dbt-agent-skills

echo "dbt AI tooling installed."
echo "Note: dbt MCP may require client/project-specific configuration."
