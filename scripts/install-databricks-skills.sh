#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

log_section "Installing Databricks Skills"

require_node

if command -v databricks >/dev/null 2>&1; then
  databricks aitools install
else
  npx skills add databricks/databricks-agent-skills
fi

echo "Databricks skills installed."
