#!/usr/bin/env bash
# Read-only semantic check of the named Day 6 inline policy.
# This checks the lab's named policy only; inspect every other inline/attached
# policy separately before claiming the IAM user is fully remediated.
set -euo pipefail
[[ -f manifest.json ]] || { echo "manifest.json missing; run setup.sh first" >&2; exit 1; }
USER_NAME="$(jq -r '.user_name // empty' manifest.json)"
POLICY_NAME="$(jq -r '.credentials.vulnerable_policy // empty' manifest.json)"
[[ -n "$USER_NAME" && -n "$POLICY_NAME" ]] || { echo "Invalid manifest" >&2; exit 1; }
DOC="$(aws iam get-user-policy --user-name "$USER_NAME" --policy-name "$POLICY_NAME" --query PolicyDocument --output json)"
if jq -e '
  def vals: if type == "array" then .[] else . end;
  any(.Statement[]?;
    .Effect == "Allow"
    and ((.Action | vals) == "iam:AttachUserPolicy" or (.Action | vals) == "iam:PutUserPolicy")
    and ((.Resource | vals) == "*")
  )
' <<<"$DOC" >/dev/null; then
  echo "FAIL: dangerous wildcard policy permission remains"
  exit 1
fi
echo "PASS: named inline policy contains no direct Allow for AttachUserPolicy/PutUserPolicy on Resource *."
echo "LIMITATION: inspect all other inline and attached managed policies before concluding the user is fully remediated."
