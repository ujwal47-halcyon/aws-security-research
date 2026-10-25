#!/usr/bin/env bash
# Remove only the exact resources recorded in this lab's local manifest.
set -euo pipefail
REGION="us-east-1"
MANIFEST_FILE="manifest.json"
command -v aws >/dev/null 2>&1 || { echo "AWS CLI is required"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required"; exit 1; }
aws sts get-caller-identity >/dev/null

if [[ ! -f "$MANIFEST_FILE" ]]; then
  echo "No manifest.json found. Refusing broad prefix-based deletion."
  echo "Recover the exact lab resource identifiers before cleanup."
  exit 1
fi
BUCKET_NAME=$(jq -r '.resources[] | select(.type=="AWS::S3::Bucket") | .name' "$MANIFEST_FILE")
USER_NAME=$(jq -r '.resources[] | select(.type=="AWS::IAM::User") | .name' "$MANIFEST_FILE")
ACCESS_KEY_ID=$(jq -r '.credentials.aws_access_key_id // empty' "$MANIFEST_FILE")
[[ "$BUCKET_NAME" == autoelite-app-media-* ]] || { echo "Unexpected bucket name; refusing cleanup."; exit 1; }
[[ "$USER_NAME" == autoelite-app-user-* ]] || { echo "Unexpected IAM user name; refusing cleanup."; exit 1; }
echo "This will delete only the recorded lab bucket and user:"
echo "  Bucket: $BUCKET_NAME"
echo "  IAM user: $USER_NAME"
read -r -p "Type DELETE-DAY3-LAB to continue: " CONFIRM
[[ "$CONFIRM" == "DELETE-DAY3-LAB" ]] || { echo "Cancelled."; exit 1; }

if aws iam get-user --user-name "$USER_NAME" >/dev/null 2>&1; then
  if [[ -n "$ACCESS_KEY_ID" ]]; then
    aws iam delete-access-key --user-name "$USER_NAME" --access-key-id "$ACCESS_KEY_ID" 2>/dev/null || true
  fi
  KEYS=$(aws iam list-access-keys --user-name "$USER_NAME" --query 'AccessKeyMetadata[].AccessKeyId' --output text 2>/dev/null || true)
  for key in $KEYS; do aws iam delete-access-key --user-name "$USER_NAME" --access-key-id "$key" 2>/dev/null || true; done
  POLICIES=$(aws iam list-user-policies --user-name "$USER_NAME" --query 'PolicyNames[]' --output text 2>/dev/null || true)
  for policy in $POLICIES; do aws iam delete-user-policy --user-name "$USER_NAME" --policy-name "$policy"; done
  aws iam delete-user --user-name "$USER_NAME"
fi

if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  aws s3api delete-bucket-policy --bucket "$BUCKET_NAME" 2>/dev/null || true
  aws s3 rm "s3://$BUCKET_NAME" --recursive
  aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$REGION"
fi
rm -f "$MANIFEST_FILE"
echo "Teardown commands completed. Now run ./verify-cleanup.sh cleanup."
