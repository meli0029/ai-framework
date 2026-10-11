#!/usr/bin/env bash
set -euo pipefail

MODE="check"

show_help() {
  cat <<'EOF'
Fabric CLI workstation bootstrap

Usage:
  ./scripts/bootstrap-fabric-tools.sh --check
  ./scripts/bootstrap-fabric-tools.sh --install

Options:
  --check      Report missing prerequisites without changing the workstation (default).
  --install    Install missing prerequisites. May require sudo and network access.
  --help, -h   Show this help.

Supported install platforms: Debian/Ubuntu/WSL and macOS.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --check) MODE="check" ;;
    --install) MODE="install" ;;
    --help|-h) show_help; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; show_help >&2; exit 2 ;;
  esac
done

has() {
  command -v "$1" >/dev/null 2>&1
}

platform() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)
      if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        case "${ID:-}:${ID_LIKE:-}" in
          ubuntu:*|debian:*|*:debian*) echo "debian" ;;
          *) echo "linux-unsupported" ;;
        esac
      else
        echo "linux-unsupported"
      fi
      ;;
    *) echo "unsupported" ;;
  esac
}

check_tools() {
  local missing=0
  local tool os tools
  os="$(platform)"
  tools="git curl python3 jq rsync tar bzip2 az sqlcmd"
  if [ "$os" = "debian" ]; then
    tools="$tools sha256sum"
  fi

  for tool in $tools; do
    if has "$tool"; then
      printf 'OK       %s\n' "$tool"
    else
      printf 'MISSING  %s\n' "$tool"
      missing=1
    fi
  done

  if has az; then
    az version --query '"azure-cli"' -o tsv 2>/dev/null | sed 's/^/VERSION  az /' || true
  fi
  if has sqlcmd; then
    sqlcmd --version 2>/dev/null | head -n 1 | sed 's/^/VERSION  /' || true
  fi

  return "$missing"
}

install_debian_base() {
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl git python3 jq rsync tar bzip2 coreutils
}

install_azure_cli() {
  local os="$1"
  if has az; then
    return
  fi

  case "$os" in
    debian)
      curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
      ;;
    macos)
      brew install azure-cli
      ;;
    *)
      echo "Azure CLI automatic installation is unsupported on this platform." >&2
      return 1
      ;;
  esac
}

install_sqlcmd() (
  local os="$1"
  if has sqlcmd; then
    return
  fi

  if [ "$os" = "macos" ]; then
    brew install sqlcmd
    return
  fi

  if [ "$os" != "debian" ]; then
    echo "sqlcmd automatic installation is unsupported on this platform." >&2
    return 1
  fi

  local machine release_json asset_name asset_url expected_digest temp_dir archive binary
  machine="$(uname -m)"
  case "$machine" in
    x86_64|amd64) asset_name="sqlcmd-linux-amd64.tar.bz2" ;;
    aarch64|arm64) asset_name="sqlcmd-linux-arm64.tar.bz2" ;;
    s390x) asset_name="sqlcmd-linux-s390x.tar.bz2" ;;
    *) echo "Unsupported Linux architecture for sqlcmd: $machine" >&2; return 1 ;;
  esac

  release_json="$(curl -fsSL https://api.github.com/repos/microsoft/go-sqlcmd/releases/latest)"
  asset_url="$(printf '%s' "$release_json" | python3 -c 'import json,sys; name=sys.argv[1]; data=json.load(sys.stdin); print(next(a["browser_download_url"] for a in data["assets"] if a["name"] == name))' "$asset_name")"
  expected_digest="$(printf '%s' "$release_json" | python3 -c 'import json,sys; name=sys.argv[1]; data=json.load(sys.stdin); print(next(a.get("digest", "") for a in data["assets"] if a["name"] == name).removeprefix("sha256:"))' "$asset_name")"

  temp_dir="$(mktemp -d)"
  trap 'rm -rf -- "$temp_dir"' EXIT
  archive="$temp_dir/$asset_name"
  curl -fL "$asset_url" -o "$archive"

  if [ -z "$expected_digest" ]; then
    echo "The official release did not provide a SHA-256 digest; refusing installation." >&2
    return 1
  fi
  printf '%s  %s\n' "$expected_digest" "$archive" | sha256sum --check --status

  tar -xjf "$archive" -C "$temp_dir"
  binary="$(find "$temp_dir" -type f -name sqlcmd -print -quit)"
  if [ -z "$binary" ]; then
    echo "sqlcmd binary was not found in the official release archive." >&2
    return 1
  fi
  sudo install -m 0755 "$binary" /usr/local/bin/sqlcmd
)

install_tools() {
  local os
  os="$(platform)"
  case "$os" in
    debian)
      install_debian_base
      ;;
    macos)
      if ! has brew; then
        echo "Homebrew is required on macOS. Install it from https://brew.sh and rerun." >&2
        exit 1
      fi
      brew install git curl python jq rsync
      ;;
    *)
      echo "Automatic installation is unsupported on this platform." >&2
      echo "See AI Framework/playbooks/fabric-workstation-onboarding.md for Windows instructions." >&2
      exit 1
      ;;
  esac

  install_azure_cli "$os"
  install_sqlcmd "$os"
}

if [ "$MODE" = "install" ]; then
  echo "Installing Fabric CLI workstation prerequisites..."
  install_tools
  echo
fi

echo "Checking Fabric CLI workstation prerequisites..."
if check_tools; then
  echo "All required command-line tools are available."
else
  echo "One or more required tools are missing." >&2
  if [ "$MODE" = "check" ]; then
    echo "Review the list, then run this script with --install if appropriate." >&2
  fi
  exit 1
fi
