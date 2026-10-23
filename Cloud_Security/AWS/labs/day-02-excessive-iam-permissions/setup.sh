#!/bin/bash
# Day 2: Excessive IAM Permissions - Setup Script
# Creates a disposable IAM user with an over-privileged inline policy,
# an S3 bucket with the flag, and a DynamoDB table with the flag.
# Run from WSL with your AWS credentials configured.

set -euo pipefail

# ─── Configuration ──────────────────────────────────────────────
REGION="us-east-1"
RANDOM_SUFFIX=$(openssl rand -hex 4)
USER_NAME="dev-intern-${RANDOM_SUFFIX}"
BUCKET_NAME="cloudsec-ctf-day02-assets-${RANDOM_SUFFIX}"
TABLE_NAME="cloudsec-ctf-day02-inventory-${RANDOM_SUFFIX}"
MANIFEST_FILE="manifest.json"
# ────────────────────────────────────────────────────────────────

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  AWS Cloud Security CTF - Day 2: Excessive IAM Permissions    ║"
echo "║                        SETUP SCRIPT                           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo

# ─── Pre-flight Checks ──────────────────────────────────────────
echo "▶ Pre-flight checks..."

if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found."
    exit 1
fi
echo "  ✓ AWS CLI: $(aws --version 2>&1 | head -1)"

if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured or invalid."
    echo "   Run: aws configure"
    exit 1
fi

IDENTITY=$(aws sts get-caller-identity --output json)
ACCOUNT_ID=$(echo "$IDENTITY" | jq -r .Account)
USER_ARN=$(echo "$IDENTITY" | jq -r .Arn)
echo "  ✓ Authenticated as: $USER_ARN"
echo "  ✓ Account ID: $ACCOUNT_ID"

if ! aws ec2 describe-regions --region "$REGION" --query "Regions[?RegionName=='$REGION'].OptInStatus" --output text | grep -q "opt-in-not-required\|opted-in"; then
    echo "❌ Region $REGION is not enabled."
    exit 1
fi
echo "  ✓ Region $REGION is available"

# ─── Generate Flag ──────────────────────────────────────────────
echo
echo "▶ Generating challenge flag..."
FLAG_CONTENT="FLAG{$(openssl rand -hex 16)}"
echo "  ✓ Flag generated securely (hidden from output)"

# ─── Create IAM User with Excessive Inline Policy ───────────────
echo
echo "▶ Creating IAM user: $USER_NAME..."
aws iam create-user \
    --user-name "$USER_NAME" \
    --tags Key=Project,Value=CloudSecurityCTF Key=Day,Value=Day2 Key=Owner,Value=dev-intern

echo "  ✓ IAM user created"

echo
echo "▶ Attaching excessive inline policy ('OverPrivilegedDeveloperPolicy')..."
# The policy grants intended read/write to specific resources,
# but ALSO excessive permissions: s3:*, dynamodb:*, and iam:GetUser/ListUsers on *
POLICY_DOCUMENT=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "IntendedS3Access",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${BUCKET_NAME}",
        "arn:aws:s3:::${BUCKET_NAME}/*"
      ]
    },
    {
      "Sid": "IntendedDynamoDBAccess",
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:Query"
      ],
      "Resource": "arn:aws:dynamodb:${REGION}:${ACCOUNT_ID}:table/${TABLE_NAME}"
    },
    {
      "Sid": "ExcessiveS3Admin",
      "Effect": "Allow",
      "Action": [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ExcessiveDynamoDBAdmin",
      "Effect": "Allow",
      "Action": [
        "dynamodb:ListTables",
        "dynamodb:DescribeTable"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ExcessiveIAMEnumeration",
      "Effect": "Allow",
      "Action": [
        "iam:GetUser",
        "iam:ListUsers",
        "iam:ListUserPolicies",
        "iam:GetUserPolicy"
      ],
      "Resource": "*"
    }
  ]
}
EOF
)

aws iam put-user-policy \
    --user-name "$USER_NAME" \
    --policy-name "OverPrivilegedDeveloperPolicy" \
    --policy-document "$POLICY_DOCUMENT"

echo "  ✓ Excessive inline policy attached"

# Create Access Keys for dev-intern so student can test with them
echo
echo "▶ Creating access keys for $USER_NAME..."
CREDENTIALS=$(aws iam create-access-key --user-name "$USER_NAME" --output json)
ACCESS_KEY_ID=$(echo "$CREDENTIALS" | jq -r .AccessKey.AccessKeyId)
SECRET_ACCESS_KEY=$(echo "$CREDENTIALS" | jq -r .AccessKey.SecretAccessKey)
echo "  ✓ Access keys created"

# ─── Create S3 Bucket & Upload Flag ─────────────────────────────
echo
echo "▶ Creating S3 lab bucket: $BUCKET_NAME in $REGION..."
if [[ "$REGION" == "us-east-1" ]]; then
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
else
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" \
        --create-bucket-configuration LocationConstraint="$REGION"
fi

aws s3api put-bucket-tagging --bucket "$BUCKET_NAME" --tagging 'TagSet=[{Key=Project,Value=CloudSecurityCTF},{Key=Day,Value=Day2}]'

echo "  ✓ Uploading flag to S3..."
echo "$FLAG_CONTENT" | aws s3 cp - "s3://${BUCKET_NAME}/flag.txt"
echo "  ✓ Flag uploaded to s3://${BUCKET_NAME}/flag.txt"

# ─── Create DynamoDB Table & Put Flag ───────────────────────────
echo
echo "▶ Creating DynamoDB lab table: $TABLE_NAME..."
aws dynamodb create-table \
    --region "$REGION" \
    --table-name "$TABLE_NAME" \
    --attribute-definitions AttributeName=pk,AttributeType=S \
    --key-schema AttributeName=pk,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --tags Key=Project,Value=CloudSecurityCTF Key=Day,Value=Day2

echo "  ⏳ Waiting for DynamoDB table to become active..."
aws dynamodb wait table-exists --region "$REGION" --table-name "$TABLE_NAME"

echo "  ✓ Inserting flag into DynamoDB..."
aws dynamodb put-item \
    --region "$REGION" \
    --table-name "$TABLE_NAME" \
    --item "{\"pk\": {\"S\": \"flag\"}, \"secret_flag\": {\"S\": \"${FLAG_CONTENT}\"}, \"description\": {\"S\": \"AutoElite Motors secure configuration asset\"}}"

echo "  ✓ Flag item inserted into table $TABLE_NAME"

# ─── Create Resource Manifest ───────────────────────────────────
echo
echo "▶ Writing resource manifest ($MANIFEST_FILE)..."

cat > "$MANIFEST_FILE" <<EOF
{
  "challenge": "day-02-excessive-iam-permissions",
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "region": "$REGION",
  "account_id": "$ACCOUNT_ID",
  "resources": [
    {
      "type": "AWS::IAM::User",
      "name": "$USER_NAME",
      "arn": "arn:aws:iam::${ACCOUNT_ID}:user/${USER_NAME}"
    },
    {
      "type": "AWS::IAM::Policy",
      "name": "OverPrivilegedDeveloperPolicy",
      "scope": "inline"
    },
    {
      "type": "AWS::S3::Bucket",
      "name": "$BUCKET_NAME",
      "arn": "arn:aws:s3:::${BUCKET_NAME}"
    },
    {
      "type": "AWS::DynamoDB::Table",
      "name": "$TABLE_NAME",
      "arn": "arn:aws:dynamodb:${REGION}:${ACCOUNT_ID}:table/${TABLE_NAME}"
    }
  ],
  "credentials": {
    "user_name": "$USER_NAME",
    "aws_access_key_id": "$ACCESS_KEY_ID",
    "aws_secret_access_key": "$SECRET_ACCESS_KEY"
  },
  "cleanup_commands": [
    "aws iam delete-access-key --user-name $USER_NAME --access-key-id $ACCESS_KEY_ID",
    "aws iam delete-user-policy --user-name $USER_NAME --policy-name OverPrivilegedDeveloperPolicy",
    "aws iam delete-user --user-name $USER_NAME",
    "aws s3 rm s3://$BUCKET_NAME/flag.txt",
    "aws s3api delete-bucket --bucket $BUCKET_NAME --region $REGION",
    "aws dynamodb delete-table --region $REGION --table-name $TABLE_NAME"
  ]
}
EOF

echo "  ✓ Manifest written successfully"

echo
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  ✅ SETUP COMPLETE                                            ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo
echo "📋 Lab Credentials for testing (dev-intern):"
echo "  • AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID"
echo "  • AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY"
echo "  • Region: $REGION"
echo
echo "💡 Next Steps:"
echo "  1. Read CHALLENGE.md"
echo "  2. Configure a profile or export credentials to investigate the dev-intern user."
echo "  3. Find the excessive permissions and retrieve the flag."
echo "  4. Run ./teardown.sh when finished."
