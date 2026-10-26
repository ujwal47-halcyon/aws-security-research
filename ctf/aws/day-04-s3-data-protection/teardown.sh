#!/usr/bin/env bash
# Delete only the exact Day 4 resources recorded in the local manifest.
set -euo pipefail
REGION="us-east-1"
MANIFEST_FILE="manifest.json"
command -v aws >/dev/null 2>&1 || { echo "AWS CLI is required"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required"; exit 1; }
aws sts get-caller-identity >/dev/null
if [[ ! -f "$MANIFEST_FILE" ]]; then
  echo "Manifest missing. Refusing broad prefix-based cleanup to avoid deleting unrelated resources."
  echo "Recover the exact lab manifest or remove the lab resources manually after verifying their tags."
  exit 1
fi
BUCKET_NAME=$(jq -r '.resources[] | select(.type=="AWS::S3::Bucket") | .name' "$MANIFEST_FILE")
USER_NAME=$(jq -r '.resources[] | select(.type=="AWS::IAM::User") | .name' "$MANIFEST_FILE")
KEY_ID=$(jq -r '.credentials.aws_access_key_id // empty' "$MANIFEST_FILE")
[[ "$BUCKET_NAME" == autoelite-app-backups-* ]] || { echo "Unexpected bucket name; refusing."; exit 1; }
[[ "$USER_NAME" == autoelite-backup-user-* ]] || { echo "Unexpected IAM user name; refusing."; exit 1; }
echo "This will delete only the recorded Day 4 bucket and IAM user."
echo "Bucket: $BUCKET_NAME"
echo "IAM user: $USER_NAME"
read -r -p "Type DELETE-DAY4-LAB to continue: " CONFIRM
[[ "$CONFIRM" == "DELETE-DAY4-LAB" ]] || { echo "Cancelled."; exit 1; }

if aws iam get-user --user-name "$USER_NAME" >/dev/null 2>&1; then
  if [[ -n "$KEY_ID" ]]; then aws iam delete-access-key --user-name "$USER_NAME" --access-key-id "$KEY_ID" 2>/dev/null || true; fi
  KEYS=$(aws iam list-access-keys --user-name "$USER_NAME" --query 'AccessKeyMetadata[].AccessKeyId' --output text 2>/dev/null || true)
  for key in $KEYS; do aws iam delete-access-key --user-name "$USER_NAME" --access-key-id "$key"; done
  POLICIES=$(aws iam list-user-policies --user-name "$USER_NAME" --query 'PolicyNames[]' --output text 2>/dev/null || true)
  for policy in $POLICIES; do aws iam delete-user-policy --user-name "$USER_NAME" --policy-name "$policy"; done
  aws iam delete-user --user-name "$USER_NAME"
fi

if aws s3api head-bucket --bucket "$BUCKET_NAME" >/dev/null 2>&1; then
  # This lab creates only two versions, but loop until all returned versions and delete markers are gone.
  while true; do
    PAGE=$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --max-keys 1000 --output json)
    PAYLOAD=$(jq '{Objects: [(.Versions[]? | {Key,VersionId}),(.DeleteMarkers[]? | {Key,VersionId})]}' <<<"$PAGE")
    COUNT=$(jq '.Objects | length' <<<"$PAYLOAD")
    [[ "$COUNT" -gt 0 ]] || break
    aws s3api delete-objects --bucket "$BUCKET_NAME" --delete "$PAYLOAD" >/dev/null
    # Lab creates very few versions; if pagination exists, repeat listing.
    [[ $(jq -r '.IsTruncated' <<<"$PAGE") == "true" ]] || break
  done
  aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$REGION"
fi
rm -f "$MANIFEST_FILE"
echo "Teardown finished. Run ./verify-cleanup.sh cleanup to check for remaining resources."
