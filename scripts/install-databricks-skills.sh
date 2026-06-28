#!/usr/bin/env bash
set -euo pipefail

echo "Installing Databricks agent skills..."

if command -v databricks >/dev/null 2>&1; then
  databricks aitools install
elif command -v npx >/dev/null 2>&1; then
  npx skills add databricks/databricks-agent-skills
else
  echo "Install either Databricks CLI or Node.js/npm first."
  exit 1
fi

echo "Databricks skills installed."
