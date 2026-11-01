#!/usr/bin/env bash
# Releases the synthetic flag only after the named inline policy passes verify.sh.
# This is a training gate, not a complete AWS IAM policy analyzer.
set -euo pipefail
./verify.sh
USER_NAME="$(jq -r '.user_name' manifest.json)"
FLAG="$(aws iam get-user --user-name "$USER_NAME" --query 'User.Description' --output text)"
[[ "$FLAG" == FLAG\{*\} ]] || { echo "Flag not found in user description" >&2; exit 1; }
echo "$FLAG"
