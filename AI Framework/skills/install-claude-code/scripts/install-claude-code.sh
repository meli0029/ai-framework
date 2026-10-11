#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --check | --install [--channel latest|stable]"
}

mode=""
channel="latest"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check|--install)
      if [[ -n "$mode" ]]; then
        echo "Choose exactly one of --check or --install." >&2
        exit 2
      fi
      mode="$1"
      ;;
    --channel)
      shift
      if [[ $# -eq 0 ]]; then
        echo "--channel requires latest or stable." >&2
        exit 2
      fi
      channel="$1"
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

if [[ -z "$mode" ]]; then
  usage >&2
  exit 2
fi

if [[ "$channel" != "latest" && "$channel" != "stable" ]]; then
  echo "Unsupported channel: $channel (expected latest or stable)." >&2
  exit 2
fi

native_path="${HOME}/.local/bin/claude"

check_installation() {
  if command -v claude >/dev/null 2>&1; then
    resolved_path="$(command -v claude)"
    case "$resolved_path" in
      */extensions/anthropic.claude-code-*/*)
        echo "PATH points to a versioned editor extension; install the standalone CLI." >&2
        return 1
        ;;
    esac
    echo "Claude Code executable: $resolved_path"
    claude --version
    return 0
  fi

  if [[ -x "$native_path" ]]; then
    echo "Claude Code is installed at $native_path but is not available on PATH." >&2
    echo 'Add $HOME/.local/bin to PATH, then start a new shell.' >&2
    return 1
  fi

  extension_binary="$(find "${HOME}/.vscode-server/extensions" -maxdepth 4 -type f -path '*/anthropic.claude-code-*/resources/native-binary/claude' -perm -u+x 2>/dev/null | sort -V | tail -n 1 || true)"
  if [[ -n "$extension_binary" ]]; then
    echo "Claude Code VS Code extension found, but the standalone CLI is not installed." >&2
    echo "Extension binary (not stable for PATH use): $extension_binary" >&2
  else
    echo "Claude Code standalone CLI is not installed." >&2
  fi
  return 1
}

if [[ "$mode" == "--check" ]]; then
  check_installation
  exit $?
fi

if check_installation; then
  echo "Claude Code is already installed; no changes made."
  exit 0
fi

case "$(uname -s)" in
  Linux|Darwin) ;;
  *)
    echo "This script supports Linux, WSL, and macOS. Use Anthropic's official Windows installer on native Windows." >&2
    exit 1
    ;;
esac

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required to run Anthropic's official installer." >&2
  exit 1
fi

installer_dir="$(mktemp -d)"
trap 'rm -rf "$installer_dir"' EXIT
installer_path="$installer_dir/install-claude-code.sh"

echo "Downloading Anthropic's official Claude Code installer..."
curl -fsSL https://claude.ai/install.sh -o "$installer_path"
echo "Installing Claude Code from the Anthropic $channel channel..."
bash "$installer_path" "$channel"

export PATH="${HOME}/.local/bin:${PATH}"
hash -r
check_installation
