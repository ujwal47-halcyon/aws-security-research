#!/usr/bin/env bash
# Deletes only the exact Day 6 IAM user recorded in the private manifest.
set -euo pipefail
[[ -f manifest.json ]] || { echo "manifest.json missing; refusing broad discovery/deletion" >&2; exit 1; }
USER_NAME="$(jq -r '.user_name // empty' manifest.json)"
POLICY_NAME="$(jq -r '.credentials.vulnerable_policy // empty' manifest.json)"
[[ "$USER_NAME" == AutoEliteDay6-DevUser-* && "$POLICY_NAME" == AutoEliteDay6-DevPolicy ]] || { echo "Manifest scope check failed" >&2; exit 1; }
echo "About to delete only lab user: $USER_NAME"
read -r -p "Type DELETE-$USER_NAME to continue: " CONFIRM
[[ "$CONFIRM" == "DELETE-$USER_NAME" ]] || { echo "Cancelled"; exit 1; }
aws iam delete-user-policy --user-name "$USER_NAME" --policy-name "$POLICY_NAME" 2>/dev/null || true
aws iam delete-user --user-name "$USER_NAME"
echo "Day 6 IAM user deleted. Run verify-cleanup.sh."
