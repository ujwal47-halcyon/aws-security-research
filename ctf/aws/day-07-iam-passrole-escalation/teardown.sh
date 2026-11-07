#!/usr/bin/env bash
# Safe Day 7 teardown guard. It refuses broad prefix-based account cleanup.
set -euo pipefail
MANIFEST_FILE="${MANIFEST_FILE:-manifest.json}"
[[ -f "$MANIFEST_FILE" ]] || { echo "Private manifest missing; refusing discovery-based deletion." >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }
aws sts get-caller-identity >/dev/null
ACCOUNT="$(aws sts get-caller-identity --query Account --output text)"
MANIFEST_ACCOUNT="$(jq -r '.account_id // empty' "$MANIFEST_FILE")"
[[ -n "$MANIFEST_ACCOUNT" && "$ACCOUNT" == "$MANIFEST_ACCOUNT" ]] || { echo "Manifest/account mismatch; refusing cleanup." >&2; exit 1; }
echo "This guard does not perform deletion."
echo "Use a reviewed manifest-scoped teardown plan for the exact Day 7 resource IDs."
echo "No account-wide prefix search or deletion is permitted."
