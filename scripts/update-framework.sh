cat > scripts/update-framework.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "=========================================="
echo " Updating AI Framework"
echo "=========================================="

"$SCRIPT_DIR/install-framework.sh" "$@"

echo ""
echo "AI Framework update complete."
EOF

chmod +x scripts/update-framework.sh