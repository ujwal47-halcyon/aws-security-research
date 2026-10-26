#!/usr/bin/env bash
# Day 4: S3 data protection lab setup.
# Creates one tagged S3 bucket, two object versions, and a dedicated IAM test user.
set -euo pipefail

REGION="us-east-1"
MANIFEST_FILE="manifest.json"
command -v aws >/dev/null 2>&1 || { echo "AWS CLI is required"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required"; exit 1; }
command -v openssl >/dev/null 2>&1 || { echo "openssl is required"; exit 1; }
aws sts get-caller-identity >/dev/null
IDENTITY=$(aws sts get-caller-identity --output json)
ACCOUNT_ID=$(jq -r .Account <<<"$IDENTITY")
SUFFIX=$(openssl rand -hex 4)
BUCKET_NAME="autoelite-app-backups-$SUFFIX"
USER_NAME="autoelite-backup-user-$SUFFIX"

if [[ -e "$MANIFEST_FILE" ]]; then
  echo "$MANIFEST_FILE already exists. Back it up or finish the previous lab first."
  exit 1
fi

echo "This creates an S3 bucket, object versions, an IAM user, and an access key."
echo "Charges depend on current pricing, region, usage, and account eligibility; Free Tier does not guarantee $0."
read -r -p "Type CREATE-DAY4-LAB to continue: " CONFIRM
[[ "$CONFIRM" == "CREATE-DAY4-LAB" ]] || { echo "Cancelled."; exit 1; }

# Create a private bucket and tag it for the lab.
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
aws s3api put-bucket-tagging --bucket "$BUCKET_NAME" --tagging 'TagSet=[{Key=Project,Value=CloudSecurityCTF},{Key=Day,Value=Day4},{Key=Owner,Value=AutoEliteMotors}]'
aws s3api put-public-access-block --bucket "$BUCKET_NAME" --public-access-block-configuration 'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'
# SSE-S3 default encryption. BucketKeyEnabled applies to SSE-KMS, not SSE-S3.
aws s3api put-bucket-encryption --bucket "$BUCKET_NAME" --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled
FLAG_CONTENT="FLAG{$(openssl rand -hex 16)}"
TMP1=$(mktemp); TMP2=$(mktemp)
trap 'rm -f "$TMP1" "$TMP2"' EXIT
printf '{"system":"AutoElite Core Database","backup_date":"2026-10-25T08:00:00Z","db_name":"autoelite_production","secret_recovery_flag":"%s","status":"HEALTHY"}
' "$FLAG_CONTENT" > "$TMP1"
V1=$(aws s3api put-object --bucket "$BUCKET_NAME" --key db-backup-2026.json --body "$TMP1" --content-type application/json --query VersionId --output text)
printf '{"system":"AutoElite Core Database","backup_date":"2026-10-25T10:30:00Z","db_name":"autoelite_production","notice":"Previous backup state overwritten during maintenance. No flag in current head version.","status":"RESET"}
' > "$TMP2"
V2=$(aws s3api put-object --bucket "$BUCKET_NAME" --key db-backup-2026.json --body "$TMP2" --content-type application/json --query VersionId --output text)
aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Suspended

aws iam create-user --user-name "$USER_NAME" --tags Key=Project,Value=CloudSecurityCTF Key=Day,Value=Day4 Key=Owner,Value=AutoEliteMotors >/dev/null
POLICY=$(cat <<EOF
{"Version":"2012-10-17","Statement":[{"Sid":"BackupReadAndVersionInspection","Effect":"Allow","Action":["s3:GetObject","s3:GetObjectVersion","s3:ListBucket","s3:ListBucketVersions","s3:GetBucketEncryption","s3:GetBucketVersioning"],"Resource":["arn:aws:s3:::$BUCKET_NAME","arn:aws:s3:::$BUCKET_NAME/*"]}]}
EOF
)
aws iam put-user-policy --user-name "$USER_NAME" --policy-name LeastPrivilegeBackupPolicy --policy-document "$POLICY"
CREDS=$(aws iam create-access-key --user-name "$USER_NAME" --output json)
KEY_ID=$(jq -r .AccessKey.AccessKeyId <<<"$CREDS")
SECRET_KEY=$(jq -r .AccessKey.SecretAccessKey <<<"$CREDS")
cat > "$MANIFEST_FILE" <<EOF
{
  "challenge":"day-04-s3-data-protection",
  "created":"$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "region":"$REGION",
  "account_id":"$ACCOUNT_ID",
  "resources":[
    {"type":"AWS::S3::Bucket","name":"$BUCKET_NAME","arn":"arn:aws:s3:::$BUCKET_NAME"},
    {"type":"AWS::S3::ObjectVersion","name":"s3://$BUCKET_NAME/db-backup-2026.json","version_1_id":"$V1","version_2_id":"$V2"},
    {"type":"AWS::IAM::User","name":"$USER_NAME","arn":"arn:aws:iam::$ACCOUNT_ID:user/$USER_NAME"}
  ],
  "credentials":{"user_name":"$USER_NAME","aws_access_key_id":"$KEY_ID","aws_secret_access_key":"$SECRET_KEY"}
}
EOF
chmod 600 "$MANIFEST_FILE"
trap - EXIT
rm -f "$TMP1" "$TMP2"
echo "Setup complete. Bucket: $BUCKET_NAME"
echo "Temporary credentials are stored in local $MANIFEST_FILE (gitignored). Do not commit or share it."
echo "Investigate using CHALLENGE.md, then run ./teardown.sh."
