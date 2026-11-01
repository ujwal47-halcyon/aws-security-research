#!/usr/bin/env bash
# Read-only cleanup check for the exact user in the private manifest.
set -euo pipefail
[[ -f manifest.json ]] || { echo "manifest.json missing; cannot verify exact lab user" >&2; exit 1; }
USER_NAME="$(jq -r '.user_name // empty' manifest.json)"
[[ "$USER_NAME" == AutoEliteDay6-DevUser-* ]] || { echo "Manifest scope check failed" >&2; exit 1; }
if aws iam get-user --user-name "$USER_NAME" >/dev/null 2>&1; then
  echo "FAIL: Day 6 user still exists: $USER_NAME"
  exit 1
fi
echo "PASS: Day 6 user is absent."
