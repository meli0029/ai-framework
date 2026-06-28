#!/usr/bin/env bash
set -euo pipefail

log_section() {
  echo ""
  echo "=========================================="
  echo " $1"
  echo "=========================================="
}

require_command() {
  local cmd="$1"
  local install_hint="$2"

  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd"
    echo "$install_hint"
    exit 1
  fi
}

require_git() {
  require_command "git" "Install Git, then rerun this script."
}

require_rsync() {
  if ! command -v rsync >/dev/null 2>&1; then
    echo "rsync not found. Attempting install..."
    if command -v sudo >/dev/null 2>&1 && command -v apt >/dev/null 2>&1; then
      sudo apt update
      sudo apt install -y rsync
    else
      echo "Install rsync manually, then rerun this script."
      exit 1
    fi
  fi
}

require_node() {
  if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1 && command -v npx >/dev/null 2>&1; then
    return
  fi

  echo "Node.js/npm/npx not found. Attempting install..."

  if command -v sudo >/dev/null 2>&1 && command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y nodejs npm
  else
    echo "Install Node.js/npm manually, then rerun this script."
    exit 1
  fi

  require_command "npx" "npx is still unavailable after install attempt."
}

require_vscode() {
  require_command "code" "VS Code CLI 'code' not found. In VS Code, run: Shell Command: Install 'code' command in PATH."
}

has_codex() {
  command -v codex >/dev/null 2>&1
}
