#!/usr/bin/env bash
# Verify resources recorded by the lab, or verify cleanup by tagged/prefix inventory.
set -euo pipefail
MODE="${1:-check}"
MANIFEST_FILE="manifest.json"
command -v aws >/dev/null 2>&1 || { echo "AWS CLI is required"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required"; exit 1; }
aws sts get-caller-identity >/dev/null

if [[ "$MODE" == "cleanup" ]]; then
  FAIL=0
  [[ ! -f "$MANIFEST_FILE" ]] || { echo "FAIL: manifest.json still exists"; FAIL=1; }
  BUCKETS=$(aws s3api list-buckets --query 'Buckets[].Name' --output text)
  for bucket in $BUCKETS; do
    if [[ "$bucket" == autoelite-app-media-* ]]; then echo "Potential Day 3 bucket remains: $bucket"; FAIL=1; fi
  done
  USERS=$(aws iam list-users --query "Users[?starts_with(UserName, 'autoelite-app-user-')].UserName" --output text)
  if [[ -n "$USERS" && "$USERS" != "None" ]]; then echo "Potential Day 3 IAM user remains: $USERS"; FAIL=1; fi
  if [[ $FAIL -eq 0 ]]; then echo "Cleanup checks passed."; else echo "Cleanup verification failed or found matching resources."; exit 1; fi
elif [[ "$MODE" == "check" ]]; then
  [[ -f "$MANIFEST_FILE" ]] || { echo "manifest.json missing; run ./setup.sh first."; exit 1; }
  BUCKET_NAME=$(jq -r '.resources[] | select(.type=="AWS::S3::Bucket") | .name' "$MANIFEST_FILE")
  USER_NAME=$(jq -r '.resources[] | select(.type=="AWS::IAM::User") | .name' "$MANIFEST_FILE")
  aws s3api head-bucket --bucket "$BUCKET_NAME"
  aws s3api get-bucket-policy --bucket "$BUCKET_NAME" >/dev/null
  aws iam get-user --user-name "$USER_NAME" >/dev/null
  echo "Recorded bucket, policy, and IAM user checks passed."
else
  echo "Usage: ./verify-cleanup.sh [check|cleanup]"; exit 2
fi
