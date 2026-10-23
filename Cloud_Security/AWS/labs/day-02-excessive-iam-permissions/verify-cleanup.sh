#!/bin/bash
# Day 2: Excessive IAM Permissions - Verification Script
# Verifies that Day 2 challenge resources exist and are intact, OR confirms clean removal.
# Run from WSL with your AWS credentials configured.

set -euo pipefail

REGION="us-east-1"
MANIFEST_FILE="manifest.json"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  AWS Cloud Security CTF - Day 2: Excessive IAM Permissions    ║"
echo "║                    VERIFICATION SCRIPT                        ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo

MODE="${1:-check}"  # check | cleanup

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
echo

if [[ "$MODE" == "cleanup" ]]; then
    echo "▶ Verifying cleanup (no Day 2 resources should exist)..."
    FAIL=0
    if [[ -f "$MANIFEST_FILE" ]]; then
        echo "  ❌ FAIL: Manifest file still exists: $MANIFEST_FILE"
        FAIL=1
    else
        echo "  ✅ PASS: Manifest file removed"
    fi

    USERS=$(aws iam list-users --query "Users[?contains(UserName, 'dev-intern')].UserName" --output text 2>/dev/null || echo "")
    if [[ -n "$USERS" && "$USERS" != "None" ]]; then
        echo "  ❌ FAIL: Day 2 IAM user(s) still exist:"
        for U in $USERS; do
            echo "      - $U"
        done
        FAIL=1
    else
        echo "  ✅ PASS: No Day 2 IAM users found"
    fi

    BUCKETS=$(aws s3api list-buckets --query "Buckets[].Name" --output text 2>/dev/null || echo "")
    FOUND_BUCKET=0
    for B in $BUCKETS; do
        if [[ "$B" == cloudsec-ctf-day02-* ]]; then
            echo "  ❌ FAIL: S3 bucket still exists: $B"
            FOUND_BUCKET=1
            FAIL=1
        fi
    done
    if [[ $FOUND_BUCKET -eq 0 ]]; then
        echo "  ✅ PASS: No Day 2 S3 buckets found"
    fi

    TABLES=$(aws dynamodb list-tables --region "$REGION" --query "TableNames[]" --output text 2>/dev/null || echo "")
    FOUND_TABLE=0
    for T in $TABLES; do
        if [[ "$T" == cloudsec-ctf-day02-* ]]; then
            echo "  ❌ FAIL: DynamoDB table still exists: $T"
            FOUND_TABLE=1
            FAIL=1
        fi
    done
    if [[ $FOUND_TABLE -eq 0 ]]; then
        echo "  ✅ PASS: No Day 2 DynamoDB tables found"
    fi

    echo
    if [[ $FAIL -eq 0 ]]; then
        echo "╔═══════════════════════════════════════════════════════════════╗"
        echo "║  ✅ CLEANUP VERIFIED - All Day 2 resources removed           ║"
        echo "╚═══════════════════════════════════════════════════════════════╝"
    else
        echo "╔═══════════════════════════════════════════════════════════════╗"
        echo "║  ❌ CLEANUP FAILED - Some resources remain                    ║"
        echo "╚═══════════════════════════════════════════════════════════════╝"
        exit 1
    fi
else
    echo "▶ Verifying Day 2 challenge resources exist and are intact..."
    if [[ ! -f "$MANIFEST_FILE" ]]; then
        echo "  ⚠️  Manifest file not found: $MANIFEST_FILE"
        echo "     Run ./setup.sh first to create the challenge."
        exit 1
    fi
    echo "  ✓ Manifest file exists"

    EXPECTED_USER=$(jq -r '.resources[] | select(.type=="AWS::IAM::User") | .name' "$MANIFEST_FILE")
    EXPECTED_BUCKET=$(jq -r '.resources[] | select(.type=="AWS::S3::Bucket") | .name' "$MANIFEST_FILE")
    EXPECTED_TABLE=$(jq -r '.resources[] | select(.type=="AWS::DynamoDB::Table") | .name' "$MANIFEST_FILE")

    echo "  ✓ Expected IAM User:  $EXPECTED_USER"
    echo "  ✓ Expected S3 Bucket: $EXPECTED_BUCKET"
    echo "  ✓ Expected Table:     $EXPECTED_TABLE"

    echo
    echo "▶ Checking IAM User & Policy..."
    USER_CHECK=$(aws iam get-user --user-name "$EXPECTED_USER" --query "User.UserName" --output text 2>/dev/null || echo "")
    if [[ "$USER_CHECK" != "$EXPECTED_USER" ]]; then
        echo "  ❌ FAIL: IAM user not found: $EXPECTED_USER"
        exit 1
    fi
    echo "  ✓ IAM user exists"

    POLICY_CHECK=$(aws iam get-user-policy --user-name "$EXPECTED_USER" --policy-name "OverPrivilegedDeveloperPolicy" --query "PolicyName" --output text 2>/dev/null || echo "")
    if [[ "$POLICY_CHECK" != "OverPrivilegedDeveloperPolicy" ]]; then
        echo "  ❌ FAIL: Inline policy 'OverPrivilegedDeveloperPolicy' not found on user"
        exit 1
    fi
    echo "  ✓ Inline policy 'OverPrivilegedDeveloperPolicy' attached"

    echo
    echo "▶ Checking S3 Bucket & Flag..."
    if ! aws s3api head-bucket --bucket "$EXPECTED_BUCKET" 2>/dev/null; then
        echo "  ❌ FAIL: S3 bucket not found or inaccessible: $EXPECTED_BUCKET"
        exit 1
    fi
    echo "  ✓ S3 bucket exists"

    S3_FLAG=$(aws s3 cp "s3://$EXPECTED_BUCKET/flag.txt" - 2>/dev/null || echo "")
    if [[ "$S3_FLAG" =~ ^FLAG\{.+\}$ ]]; then
        echo "  ✓ Flag object exists in S3 with valid format"
    else
        echo "  ❌ FAIL: Flag object missing or invalid in S3"
        exit 1
    fi

    echo
    echo "▶ Checking DynamoDB Table & Flag..."
    TABLE_STATUS=$(aws dynamodb describe-table --region "$REGION" --table-name "$EXPECTED_TABLE" --query "Table.TableStatus" --output text 2>/dev/null || echo "")
    if [[ "$TABLE_STATUS" != "ACTIVE" ]]; then
        echo "  ❌ FAIL: DynamoDB table not active (status: $TABLE_STATUS)"
        exit 1
    fi
    echo "  ✓ DynamoDB table is ACTIVE"

    DYNAMO_FLAG=$(aws dynamodb get-item --region "$REGION" --table-name "$EXPECTED_TABLE" --key '{"pk":{"S":"flag"}}' --query "Item.secret_flag.S" --output text 2>/dev/null || echo "")
    if [[ "$DYNAMO_FLAG" =~ ^FLAG\{.+\}$ ]]; then
        echo "  ✓ Flag item exists in DynamoDB with valid format"
    else
        echo "  ❌ FAIL: Flag item missing or invalid in DynamoDB"
        exit 1
    fi

    echo
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║  ✅ VERIFICATION PASSED - Day 2 challenge resources intact     ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo
    echo "💡 To verify cleanup later, run: ./verify-cleanup.sh cleanup"
fi
