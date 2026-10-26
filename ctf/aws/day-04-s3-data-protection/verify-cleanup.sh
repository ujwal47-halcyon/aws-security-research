#!/usr/bin/env bash
# Check the lab state using the local manifest, or verify cleanup by known resource prefixes.
set -euo pipefail
MODE="${1:-check}"
MANIFEST_FILE="manifest.json"
command -v aws >/dev/null 2>&1 || { echo "AWS CLI is required"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required"; exit 1; }
aws sts get-caller-identity >/dev/null

if [[ "$MODE" == "cleanup" ]]; then
  FAIL=0
  [[ ! -f "$MANIFEST_FILE" ]] || { echo "FAIL: local manifest still exists"; FAIL=1; }
  BUCKETS=$(aws s3api list-buckets --query 'Buckets[].Name' --output text)
  for bucket in $BUCKETS; do
    if [[ "$bucket" == autoelite-app-backups-* ]]; then echo "Potential Day 4 bucket remains: $bucket"; FAIL=1; fi
  done
  USERS=$(aws iam list-users --query "Users[?starts_with(UserName, 'autoelite-backup-user-')].UserName" --output text)
  if [[ -n "$USERS" && "$USERS" != "None" ]]; then echo "Potential Day 4 IAM user remains: $USERS"; FAIL=1; fi
  if [[ "$FAIL" -ne 0 ]]; then echo "Cleanup verification failed or found resources matching Day 4 naming patterns."; exit 1; fi
  echo "Cleanup checks passed for the checked naming patterns."
elif [[ "$MODE" == "check" ]]; then
  [[ -f "$MANIFEST_FILE" ]] || { echo "manifest.json missing; run ./setup.sh first."; exit 1; }
  BUCKET=$(jq -r '.resources[] | select(.type=="AWS::S3::Bucket") | .name' "$MANIFEST_FILE")
  USER=$(jq -r '.resources[] | select(.type=="AWS::IAM::User") | .name' "$MANIFEST_FILE")
  aws s3api head-bucket --bucket "$BUCKET"
  aws s3api list-object-versions --bucket "$BUCKET" --prefix db-backup-2026.json >/dev/null
  aws iam get-user --user-name "$USER" >/dev/null
  echo "Recorded bucket, object history, and IAM user checks passed."
else
  echo "Usage: ./verify-cleanup.sh [check|cleanup]"; exit 2
fi
