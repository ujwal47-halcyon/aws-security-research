#!/usr/bin/env bash
# Verify Day 5 lab resources or confirm cleanup.
set -euo pipefail
MODE="${1:-check}"
MANIFEST_FILE="manifest.json"
command -v aws >/dev/null 2>&1 || { echo "AWS CLI is required"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required"; exit 1; }
aws sts get-caller-identity >/dev/null

if [[ "$MODE" == "check" ]]; then
  [[ -f "$MANIFEST_FILE" ]] || { echo "manifest.json missing; run setup.sh first."; exit 1; }
  ROLE_NAME=$(jq -r '.role_name // empty' "$MANIFEST_FILE")
  [[ "$ROLE_NAME" == AutoEliteDay5-AuditRole-* ]] || { echo "Unexpected role name in manifest."; exit 1; }
  ROLE_JSON=$(aws iam get-role --role-name "$ROLE_NAME" --output json)
  DESC=$(jq -r '.Role.Description // empty' <<<"$ROLE_JSON")
  POLICY=$(jq -c '.Role.AssumeRolePolicyDocument' <<<"$ROLE_JSON")
  [[ "$DESC" =~ ^FLAG\{.+\}$ ]] || { echo "Role description does not contain expected flag format."; exit 1; }
  jq -e '[.Statement[] | select(.Principal.Service == "lambda.amazonaws.com")] | length > 0' <<<"$POLICY" >/dev/null || { echo "Intended Lambda principal not found."; exit 1; }
  ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
  jq -e --arg p "arn:aws:iam::$ACCOUNT_ID:root" '[.Statement[] | select(.Principal.AWS == $p)] | length > 0' <<<"$POLICY" >/dev/null || { echo "Unintended account principal not found; challenge state may have changed."; exit 1; }
  echo "Day 5 role and expected challenge trust policy verified."
elif [[ "$MODE" == "cleanup" ]]; then
  [[ ! -f "$MANIFEST_FILE" ]] || { echo "FAIL: manifest.json still exists."; exit 1; }
  REMAINING=$(aws iam list-roles --query "Roles[?starts_with(RoleName, 'AutoEliteDay5-AuditRole-')].RoleName" --output text)
  if [[ -n "$REMAINING" && "$REMAINING" != "None" ]]; then
    echo "FAIL: potential Day 5 roles remain: $REMAINING"
    exit 1
  fi
  echo "Cleanup verification passed: no Day 5 role with the lab prefix was found."
else
  echo "Usage: ./verify-cleanup.sh [check|cleanup]"
  exit 2
fi
