#!/usr/bin/env bash
set -euo pipefail

INSTALL_FABRIC=false
INSTALL_POSTGRES=false
INSTALL_DBT=false
INSTALL_DATABRICKS=false
INSTALL_POWER_BI=false
INSTALL_ALL=false

show_help() {
  echo "AI Framework Installer"
  echo ""
  echo "Usage:"
  echo "  ./scripts/install-framework.sh [options]"
  echo ""
  echo "Options:"
  echo "  --fabric        Install Microsoft Fabric Skills"
  echo "  --postgres      Install PostgreSQL AI tooling"
  echo "  --dbt           Install dbt AI tooling"
  echo "  --databricks    Install Databricks Skills"
  echo "  --power-bi      Install Power BI AI tooling"
  echo "  --all           Install every supported integration"
  echo "  --help, -h      Show this help"
}

if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fabric) INSTALL_FABRIC=true ;;
    --postgres) INSTALL_POSTGRES=true ;;
    --dbt) INSTALL_DBT=true ;;
    --databricks) INSTALL_DATABRICKS=true ;;
    --power-bi) INSTALL_POWER_BI=true ;;
    --all) INSTALL_ALL=true ;;
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

echo ""
echo "=========================================="
echo " AI Framework Installation"
echo "=========================================="

if [[ "$INSTALL_ALL" == true || "$INSTALL_FABRIC" == true ]]; then
  "$SCRIPT_DIR/install-fabric-skills.sh"
fi

if [[ "$INSTALL_ALL" == true || "$INSTALL_POSTGRES" == true ]]; then
  "$SCRIPT_DIR/install-postgres-ai.sh"
fi

if [[ "$INSTALL_ALL" == true || "$INSTALL_DBT" == true ]]; then
  "$SCRIPT_DIR/install-dbt-ai.sh"
fi

if [[ "$INSTALL_ALL" == true || "$INSTALL_DATABRICKS" == true ]]; then
  "$SCRIPT_DIR/install-databricks-skills.sh"
fi

if [[ "$INSTALL_ALL" == true || "$INSTALL_POWER_BI" == true ]]; then
  "$SCRIPT_DIR/install-power-bi-ai.sh"
fi

echo ""
echo "AI Framework installation complete."
