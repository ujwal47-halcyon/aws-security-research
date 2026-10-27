#!/usr/bin/env bash
# Remove only the exact Day 5 role recorded in the local manifest.
set -euo pipefail
MANIFEST_FILE="manifest.json"
command -v aws >/dev/null 2>&1 || { echo "AWS CLI is required"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required"; exit 1; }
aws sts get-caller-identity >/dev/null

if [[ ! -f "$MANIFEST_FILE" ]]; then
  echo "manifest.json not found. Refusing prefix-wide deletion."
  echo "Verify the exact lab role manually before cleanup."
  exit 1
fi

ROLE_NAME=$(jq -r '.role_name // empty' "$MANIFEST_FILE")
[[ "$ROLE_NAME" == AutoEliteDay5-AuditRole-* ]] || { echo "Unexpected role name; refusing cleanup."; exit 1; }

echo "This will delete the exact lab role: $ROLE_NAME"
read -r -p "Type DELETE-DAY5-LAB to continue: " CONFIRM
[[ "$CONFIRM" == "DELETE-DAY5-LAB" ]] || { echo "Cancelled."; exit 1; }

if aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
  aws iam delete-role --role-name "$ROLE_NAME"
  echo "Deleted $ROLE_NAME"
else
  echo "Role already absent or not accessible."
fi

rm -f "$MANIFEST_FILE"
echo "Removed local manifest. Run ./verify-cleanup.sh cleanup to verify."
