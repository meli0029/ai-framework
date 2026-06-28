#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

log_section "Installing Power BI AI Tooling"

require_vscode

code --install-extension analysis-services.powerbi-modeling-mcp

echo "Power BI AI tooling installed."
echo "Note: Remote Power BI MCP is hosted by Microsoft and does not require local install."
