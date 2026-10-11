#!/usr/bin/env bash
set -euo pipefail
if ! command -v apm >/dev/null 2>&1; then
  echo "Microsoft APM is required. Install it using https://microsoft.github.io/apm/ and retry." >&2
  exit 1
fi
exec apm install microsoft/skills-for-fabric --global --target codex --only apm --update
