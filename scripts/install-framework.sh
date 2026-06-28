#!/usr/bin/env bash
set -euo pipefail

INSTALL_FABRIC=false
INSTALL_POSTGRES=false
INSTALL_DBT=false
INSTALL_DATABRICKS=false
INSTALL_ALL=false

show_help() {
  cat <<EOF
AI Framework Installer

Usage:
  ./scripts/install-framework.sh [options]

Options:
  --fabric        Install Microsoft Fabric skills
  --postgres      Install PostgreSQL AI tooling
  --dbt           Install dbt AI tooling
  --databricks    Install Databricks skills
  --all           Install everything supported
  --help, -h      Show this help

Examples:
  ./scripts/install-framework.sh --fabric
  ./scripts/install-framework.sh --fabric --dbt
  ./scripts/install-framework.sh --all
EOF
}

if [ "$#" -eq 0 ]; then
  show_help
  exit 0
fi

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --fabric)
      INSTALL_FABRIC=true
      ;;
    --postgres)
      INSTALL_POSTGRES=true
      ;;
    --dbt)
      INSTALL_DBT=true
      ;;
    --databricks)
      INSTALL_DATABRICKS=true
      ;;
    --all)
      INSTALL_ALL=true
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo ""
      show_help
      exit 1
      ;;
  esac
  shift
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================="
echo " Installing AI Framework"
echo "======================================="

if [ "$INSTALL_ALL" = true ] || [ "$INSTALL_FABRIC" = true ]; then
  echo ""
  echo "Installing Microsoft Fabric skills..."
  "$SCRIPT_DIR/install-fabric-skills.sh"
fi

if [ "$INSTALL_ALL" = true ] || [ "$INSTALL_POSTGRES" = true ]; then
  echo ""
  echo "Installing PostgreSQL AI tooling..."
  "$SCRIPT_DIR/install-postgres-ai.sh"
fi

if [ "$INSTALL_ALL" = true ] || [ "$INSTALL_DBT" = true ]; then
  echo ""
  echo "Installing dbt AI tooling..."
  "$SCRIPT_DIR/install-dbt-ai.sh"
fi

if [ "$INSTALL_ALL" = true ] || [ "$INSTALL_DATABRICKS" = true ]; then
  echo ""
  echo "Installing Databricks skills..."
  "$SCRIPT_DIR/install-databricks-skills.sh"
fi

echo ""
echo "AI Framework installation complete."