#!/usr/bin/env bash
# Day 3: S3 Access Misconfiguration lab setup.
# Creates a tagged S3 bucket, broad-read test policy, low-privilege IAM user,
# two objects, and a local manifest containing generated credentials.
set -euo pipefail

REGION="us-east-1"
MANIFEST_FILE="manifest.json"
BUCKET_NAME="autoelite-app-media-$(openssl rand -hex 4)"
USER_NAME="autoelite-app-user-${BUCKET_NAME##*-}"
CREATED_USER=0
CREATED_BUCKET=0
ACCESS_KEY_ID=""

cleanup_on_error() {
  status=$?
  if [[ $status -ne 0 ]]; then
    echo "Setup failed. Review resources created so far before retrying."
    echo "If manifest.json exists, inspect it locally and run ./teardown.sh."
  fi
  exit "$status"
}
trap cleanup_on_error EXIT

for cmd in aws jq openssl; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Missing required command: $cmd"; exit 1; }
done
aws sts get-caller-identity >/dev/null
IDENTITY=$(aws sts get-caller-identity --output json)
ACCOUNT_ID=$(jq -r .Account <<<"$IDENTITY")
echo "Authenticated AWS account: $ACCOUNT_ID"
echo "Region: $REGION"
echo "This lab creates billable resources. Check current AWS pricing and account eligibility first."
read -r -p "Type CREATE-DAY3-LAB to continue: " CONFIRM
[[ "$CONFIRM" == "CREATE-DAY3-LAB" ]] || { echo "Cancelled."; exit 1; }

FLAG_CONTENT="FLAG{$(openssl rand -hex 16)}"

aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
CREATED_BUCKET=1
aws s3api put-bucket-tagging --bucket "$BUCKET_NAME" --tagging 'TagSet=[{Key=Project,Value=CloudSecurityCTF},{Key=Day,Value=Day3},{Key=Owner,Value=AutoEliteMotors}]'
aws s3api put-public-access-block --bucket "$BUCKET_NAME" --public-access-block-configuration 'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=false,RestrictPublicBuckets=false'

POLICY_DOCUMENT=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "AllowPublicOrBroadReadMedia",
    "Effect": "Allow",
    "Principal": "*",
    "Action": ["s3:GetObject", "s3:ListBucket"],
    "Resource": ["arn:aws:s3:::$BUCKET_NAME", "arn:aws:s3:::$BUCKET_NAME/*"]
  }]
}
EOF
)
aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy "$POLICY_DOCUMENT"

aws iam create-user --user-name "$USER_NAME" --tags Key=Project,Value=CloudSecurityCTF Key=Day,Value=Day3 Key=Owner,Value=AutoEliteMotors
CREATED_USER=1
USER_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "LeastPrivilegeMediaRead",
    "Effect": "Allow",
    "Action": ["s3:GetObject", "s3:ListBucket"],
    "Resource": ["arn:aws:s3:::$BUCKET_NAME", "arn:aws:s3:::$BUCKET_NAME/*"]
  }]
}
EOF
)
aws iam put-user-policy --user-name "$USER_NAME" --policy-name LeastPrivilegeAppPolicy --policy-document "$USER_POLICY"
CREDENTIALS=$(aws iam create-access-key --user-name "$USER_NAME" --output json)
ACCESS_KEY_ID=$(jq -r .AccessKey.AccessKeyId <<<"$CREDENTIALS")
SECRET_ACCESS_KEY=$(jq -r .AccessKey.SecretAccessKey <<<"$CREDENTIALS")

printf '%s' "$FLAG_CONTENT" | aws s3 cp - "s3://$BUCKET_NAME/flag.txt"
printf '{"app_name":"AutoElite Motors","environment":"production","media_cdn":"s3://%s"}' "$BUCKET_NAME" | aws s3 cp - "s3://$BUCKET_NAME/app-config.json"

# Local-only operational manifest. .gitignore excludes it because it contains credentials.
cat > "$MANIFEST_FILE" <<EOF
{
  "challenge": "day-03-s3-access-misconfiguration",
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "region": "$REGION",
  "account_id": "$ACCOUNT_ID",
  "resources": [
    {"type":"AWS::S3::Bucket","name":"$BUCKET_NAME","arn":"arn:aws:s3:::$BUCKET_NAME"},
    {"type":"AWS::S3::Object","name":"s3://$BUCKET_NAME/flag.txt"},
    {"type":"AWS::S3::Object","name":"s3://$BUCKET_NAME/app-config.json"},
    {"type":"AWS::IAM::User","name":"$USER_NAME","arn":"arn:aws:iam::$ACCOUNT_ID:user/$USER_NAME"},
    {"type":"AWS::IAM::Policy","name":"LeastPrivilegeAppPolicy","scope":"inline"}
  ],
  "credentials": {
    "user_name": "$USER_NAME",
    "aws_access_key_id": "$ACCESS_KEY_ID",
    "aws_secret_access_key": "$SECRET_ACCESS_KEY"
  }
}
EOF
chmod 600 "$MANIFEST_FILE"
trap - EXIT
echo "Setup complete."
echo "Bucket: $BUCKET_NAME"
echo "IAM user: $USER_NAME"
echo "Credentials were saved only in the local, gitignored manifest."
echo "Do not paste or commit manifest.json. Run ./teardown.sh when finished."
