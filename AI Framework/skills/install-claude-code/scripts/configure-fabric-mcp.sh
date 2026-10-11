#!/usr/bin/env bash
set -euo pipefail

mode=""
tenant_id=""
workspace_id=""
package="@microsoft/fabric-mcp@latest"

usage() {
  echo "Usage: $0 --preflight|--login|--configure|--verify --tenant-id UUID --workspace-id UUID"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --preflight|--login|--configure|--verify)
      [[ -z "$mode" ]] || { echo "Choose exactly one mode." >&2; exit 2; }
      mode="$1"
      ;;
    --tenant-id)
      shift
      [[ $# -gt 0 ]] || { echo "--tenant-id requires a value." >&2; exit 2; }
      tenant_id="$1"
      ;;
    --workspace-id)
      shift
      [[ $# -gt 0 ]] || { echo "--workspace-id requires a value." >&2; exit 2; }
      workspace_id="$1"
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

[[ -n "$mode" && -n "$tenant_id" && -n "$workspace_id" ]] || { usage >&2; exit 2; }

uuid_pattern='^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
[[ "$tenant_id" =~ $uuid_pattern ]] || { echo "Invalid tenant ID format: $tenant_id" >&2; exit 2; }
[[ "$workspace_id" =~ $uuid_pattern ]] || { echo "Invalid workspace ID format: $workspace_id" >&2; exit 2; }

for required_command in claude az node npm npx; do
  command -v "$required_command" >/dev/null 2>&1 || {
    echo "Missing required command: $required_command" >&2
    exit 1
  }
done

node_version="$(node --version)"
node_major="${node_version#v}"
node_major="${node_major%%.*}"
[[ "$node_major" =~ ^[0-9]+$ ]] && (( node_major >= 20 )) || {
  echo "Node.js 20 or later is required; found $node_version." >&2
  exit 1
}

echo "Claude Code: $(command -v claude)"
claude --version
echo "Node.js: $node_version"
echo "Expected Fabric tenant: $tenant_id"
echo "Read-only test workspace: $workspace_id"

active_tenant="$(az account show --query tenantId -o tsv 2>/dev/null || true)"
if [[ "$mode" == "--login" && "$(printf %s "$active_tenant" | tr '[:upper:]' '[:lower:]')" != "$(printf %s "$tenant_id" | tr '[:upper:]' '[:lower:]')" ]]; then
  echo "Launching interactive Azure login for tenant $tenant_id..."
  az login --tenant "$tenant_id"
  active_tenant="$(az account show --query tenantId -o tsv 2>/dev/null || true)"
fi

if [[ -z "$active_tenant" ]]; then
  echo "Azure CLI is not authenticated. Run this script with --login." >&2
  exit 3
fi

echo "Active Azure CLI tenant: $active_tenant"
[[ "$(printf %s "$active_tenant" | tr '[:upper:]' '[:lower:]')" == "$(printf %s "$tenant_id" | tr '[:upper:]' '[:lower:]')" ]] || {
  echo "Azure CLI tenant mismatch. Run this script with --login." >&2
  exit 3
}

if [[ "$mode" == "--preflight" || "$mode" == "--login" ]]; then
  echo "Preflight passed."
  exit 0
fi

# Capture existing configuration privately: arbitrary entries may contain secrets.
get_status=0
get_output="$(claude mcp get fabric 2>&1)" || get_status=$?

matches_expected() {
  grep -Eq '^Type: stdio[[:space:]]*$' <<<"$get_output" &&
  grep -Eq '^Command: npx[[:space:]]*$' <<<"$get_output" &&
  grep -Eq '^Args: -y @microsoft/fabric-mcp@latest server start --mode all[[:space:]]*$' <<<"$get_output" &&
  grep -Eq '^[[:space:]]*AZURE_TOKEN_CREDENTIALS([=:][[:space:]]*)AzureCliCredential[[:space:]]*$' <<<"$get_output"
}

if [[ "$mode" == "--configure" ]]; then
  if (( get_status == 0 )) && matches_expected; then
    echo "Expected local Fabric MCP configuration already exists; run --verify."
  elif (( get_status != 0 )) && grep -Eqi "No MCP server found with name: fabric|server.*fabric.*not found" <<<"$get_output"; then
    claude mcp add --scope local --transport stdio fabric \
      -e AZURE_TOKEN_CREDENTIALS=AzureCliCredential \
      -- npx -y "$package" server start --mode all
    echo "Local Fabric MCP definition added; run --verify."
  else
    echo "Fabric MCP entry differs or inspection failed. Inspect it privately; obtain approval before replacing it." >&2
    exit 4
  fi
  exit 0
fi

if (( get_status != 0 )) || ! matches_expected; then
  echo "Fabric MCP configuration could not be verified. Inspect it privately; do not paste credentials." >&2
  exit 4
fi
if ! grep -Eq '^Status:.*Connected[[:space:]]*$' <<<"$get_output"; then
  echo "Fabric MCP connection was not positively confirmed; inspect /mcp in Claude." >&2
  exit 5
fi
echo "Expected local Fabric MCP configuration and connected status verified."
echo "Use the read-only Claude prompt to confirm workspace $workspace_id is visible in tenant $tenant_id."
