#!/usr/bin/env bash
# Flag values are generated and held locally; never print or commit them from this helper.
set -euo pipefail
[[ -f manifest.json ]] || { echo "Private manifest missing." >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }
echo "Flag retrieval is intentionally not implemented in this public-safe starter."
echo "Use the local, reviewed challenge gate and keep both flags out of Git."
