#!/bin/bash
# Day 2: Excessive IAM Permissions - Teardown Script
# Idempotently removes only the Day 2 challenge resources listed in manifest.json.
# Run from WSL with your AWS credentials configured.

set -euo pipefail

# ─── Configuration ──────────────────────────────────────────────
REGION="us-east-1"
MANIFEST_FILE="manifest.json"
# ────────────────────────────────────────────────────────────────

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  AWS Cloud Security CTF - Day 2: Excessive IAM Permissions    ║"
echo "║                       TEARDOWN SCRIPT                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo

# ─── Pre-flight Checks ──────────────────────────────────────────
echo "▶ Pre-flight checks..."

if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found."
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured or invalid."
    exit 1
fi

IDENTITY=$(aws sts get-caller-identity --output json)
ACCOUNT_ID=$(echo "$IDENTITY" | jq -r .Account)
USER_ARN=$(echo "$IDENTITY" | jq -r .Arn)
echo "  ✓ Authenticated as: $USER_ARN"
echo "  ✓ Account ID: $ACCOUNT_ID"

# ─── Load Manifest or Search ────────────────────────────────────
echo
echo "▶ Checking for resource manifest ($MANIFEST_FILE)..."

if [[ ! -f "$MANIFEST_FILE" ]]; then
    echo "⚠️  Manifest file not found. Searching for resources with tags Project=CloudSecurityCTF, Day=Day2..."

    # Fallback cleanup logic using tags
    # Find IAM users
    USERS=$(aws iam list-users --query "Users[?Tags[?Key=='Day' && Value=='Day2']].UserName" --output text 2>/dev/null || echo "")
    for U in $USERS; do
        echo "  Found IAM user: $U"
        # Delete access keys
        KEYS=$(aws iam list-access-keys --user-name "$U" --query "AccessKeyMetadata[].AccessKeyId" --output text 2>/dev/null || echo "")
        for K in $KEYS; do
            echo "    Deleting access key $K..."
            aws iam delete-access-key --user-name "$U" --access-key-id "$K"
        done
        # Delete inline policies
        POLICIES=$(aws iam list-user-policies --user-name "$U" --query "PolicyNames[]" --output text 2>/dev/null || echo "")
        for P in $POLICIES; do
            echo "    Deleting inline policy $P..."
            aws iam delete-user-policy --user-name "$U" --policy-name "$P"
        done
        echo "    Deleting user $U..."
        aws iam delete-user --user-name "$U"
    done

    # Find S3 buckets
    BUCKETS=$(aws s3api list-buckets --query "Buckets[].Name" --output text 2>/dev/null || echo "")
    for B in $BUCKETS; do
        if [[ "$B" == cloudsec-ctf-day02-* ]]; then
            echo "  Found S3 bucket: $B"
            echo "    Empting bucket..."
            aws s3 rm "s3://$B" --recursive 2>/dev/null || true
            echo "    Deleting bucket..."
            aws s3api delete-bucket --bucket "$B" --region "$REGION" 2>/dev/null || true
        fi
    done

    # Find DynamoDB tables
    TABLES=$(aws dynamodb list-tables --region "$REGION" --query "TableNames[]" --output text 2>/dev/null || echo "")
    for T in $TABLES; do
        if [[ "$T" == cloudsec-ctf-day02-* ]]; then
            echo "  Found DynamoDB table: $T"
            echo "    Deleting table..."
            aws dynamodb delete-table --region "$REGION" --table-name "$T" 2>/dev/null || true
        fi
    done

    echo "  ✓ Fallback teardown completed."
    exit 0
fi

# ─── Manifest-driven Teardown ───────────────────────────────────
echo "  ✓ Manifest found. Extracting resource identifiers..."

USER_NAME=$(jq -r '.resources[] | select(.type=="AWS::IAM::User") | .name' "$MANIFEST_FILE" 2>/dev/null || echo "")
BUCKET_NAME=$(jq -r '.resources[] | select(.type=="AWS::S3::Bucket") | .name' "$MANIFEST_FILE" 2>/dev/null || echo "")
TABLE_NAME=$(jq -r '.resources[] | select(.type=="AWS::DynamoDB::Table") | .name' "$MANIFEST_FILE" 2>/dev/null || echo "")
ACCESS_KEY_ID=$(jq -r '.credentials.aws_access_key_id // empty' "$MANIFEST_FILE" 2>/dev/null || echo "")

# 1. Delete IAM Access Keys
if [[ -n "$USER_NAME" && "$USER_NAME" != "null" ]]; then
    echo
    echo "▶ Checking IAM user $USER_NAME access keys..."
    if [[ -n "$ACCESS_KEY_ID" && "$ACCESS_KEY_ID" != "null" ]]; then
        echo "  Deleting access key: $ACCESS_KEY_ID"
        aws iam delete-access-key --user-name "$USER_NAME" --access-key-id "$ACCESS_KEY_ID" 2>/dev/null || echo "  (Key already deleted or not found)"
    fi
    # Also catch any other keys
    KEYS=$(aws iam list-access-keys --user-name "$USER_NAME" --query "AccessKeyMetadata[].AccessKeyId" --output text 2>/dev/null || echo "")
    for K in $KEYS; do
        echo "  Deleting stray access key: $K"
        aws iam delete-access-key --user-name "$USER_NAME" --access-key-id "$K" 2>/dev/null || true
    done

    # 2. Delete inline policy
    echo "  Deleting inline policy 'OverPrivilegedDeveloperPolicy'..."
    aws iam delete-user-policy --user-name "$USER_NAME" --policy-name "OverPrivilegedDeveloperPolicy" 2>/dev/null || echo "  (Policy already deleted)"

    # 3. Delete IAM User
    echo "  Deleting IAM user: $USER_NAME..."
    aws iam delete-user --user-name "$USER_NAME" 2>/dev/null || echo "  (User already deleted)"
    echo "  ✓ IAM user cleaned up"
fi

# 4. Empty and Delete S3 Bucket
if [[ -n "$BUCKET_NAME" && "$BUCKET_NAME" != "null" ]]; then
    echo
    echo "▶ Cleaning up S3 bucket: $BUCKET_NAME..."
    if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
        echo "  Empting bucket (removing all objects)..."
        aws s3 rm "s3://$BUCKET_NAME" --recursive 2>/dev/null || true
        echo "  Deleting bucket..."
        aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$REGION" 2>/dev/null || true
        echo "  ✓ S3 bucket deleted"
    else
        echo "  ℹ S3 bucket already deleted or does not exist."
    fi
fi

# 5. Delete DynamoDB Table
if [[ -n "$TABLE_NAME" && "$TABLE_NAME" != "null" ]]; then
    echo
    echo "▶ Cleaning up DynamoDB table: $TABLE_NAME..."
    if aws dynamodb describe-table --region "$REGION" --table-name "$TABLE_NAME" 2>/dev/null; then
        aws dynamodb delete-table --region "$REGION" --table-name "$TABLE_NAME" 2>/dev/null || true
        echo "  ✓ DynamoDB table deletion requested"
    else
        echo "  ℹ DynamoDB table already deleted or does not exist."
    fi
fi

# 6. Remove Manifest File
if [[ -f "$MANIFEST_FILE" ]]; then
    echo
    echo "▶ Removing resource manifest..."
    rm -f "$MANIFEST_FILE"
    echo "  ✓ Manifest removed"
fi

echo
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  ✅ TEARDOWN COMPLETE                                         ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo
echo "All Day 2 challenge resources have been successfully removed."
