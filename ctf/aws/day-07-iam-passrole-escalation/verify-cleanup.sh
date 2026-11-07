#!/usr/bin/env bash
# Cleanup verification must use exact identifiers in the private manifest.
set -euo pipefail
MANIFEST_FILE="${MANIFEST_FILE:-manifest.json}"
[[ -f "$MANIFEST_FILE" ]] || { echo "Private manifest missing; cannot verify exact resource cleanup." >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }
aws sts get-caller-identity >/dev/null
ACCOUNT="$(aws sts get-caller-identity --query Account --output text)"
MANIFEST_ACCOUNT="$(jq -r '.account_id // empty' "$MANIFEST_FILE")"
[[ -n "$MANIFEST_ACCOUNT" && "$ACCOUNT" == "$MANIFEST_ACCOUNT" ]] || { echo "Manifest/account mismatch; refusing verification." >&2; exit 1; }
echo "Manifest/account scope matched."
echo "This published verifier is a guard only; verify each exact resource ID from manifest.json before removing the private manifest."
