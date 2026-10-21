#!/bin/bash
# Day 1: Identity and Reconnaissance - Verification Script
# Verifies challenge resources exist and are intact, OR confirms clean removal
# Run from WSL with your AWS credentials configured

set -euo pipefail
REGION="us-east-1"
PARAM_PREFIX="/ctf/day-01/flag-"
MANIFEST_FILE="resource-manifest.json"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  AWS Cloud Security CTF - Day 1: Identity & Reconnaissance  ║"
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
    echo "▶ Verifying cleanup (no Day 1 resources should exist)..."
    PARAMS=$(aws ssm describe-parameters --region "$REGION" \
        --parameter-filters "Key=Name,Option=BeginsWith,Values=$PARAM_PREFIX" \
        --query "Parameters[].Name" --output text 2>/dev/null || echo "")
    if [[ -z "$PARAMS" || "$PARAMS" == "None" ]]; then
        echo "  ✅ PASS: No Day 1 parameters found in $REGION"
    else
        echo "  ❌ FAIL: Day 1 parameters still exist:"
        for PARAM in $PARAMS; do
            echo "      - $PARAM"
        done
        exit 1
    fi
    if [[ -f "$MANIFEST_FILE" ]]; then
        echo "  ❌ FAIL: Manifest file still exists: $MANIFEST_FILE"
        exit 1
    else
        echo "  ✅ PASS: Manifest file removed"
    fi
    echo
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║  ✅ CLEANUP VERIFIED - All Day 1 resources removed           ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
else
    echo "▶ Verifying Day 1 challenge resources exist and are intact..."
    if [[ ! -f "$MANIFEST_FILE" ]]; then
        echo "  ⚠️  Manifest file not found: $MANIFEST_FILE"
        echo "     Run ./setup.sh first to create the challenge."
        exit 1
    fi
    echo "  ✓ Manifest file exists"
    EXPECTED_PARAM=$(jq -r '.resources[0].name' "$MANIFEST_FILE" 2>/dev/null || echo "")
    EXPECTED_ARN=$(jq -r '.resources[0].arn' "$MANIFEST_FILE" 2>/dev/null || echo "")
    if [[ -z "$EXPECTED_PARAM" || "$EXPECTED_PARAM" == "null" ]]; then
        echo "  ❌ FAIL: Could not parse expected parameter from manifest"
        exit 1
    fi
    echo "  ✓ Expected parameter: $EXPECTED_PARAM"

    echo
    echo "▶ Checking AWS SSM Parameter Store..."
    ACTUAL=$(aws ssm describe-parameters --region "$REGION" \
        --parameter-filters "Key=Name,Option=Equals,Values=$EXPECTED_PARAM" \
        --query "Parameters[0].{Name:Name,Type:Type,LastModified:LastModified,Description:Description}" \
        --output json 2>/dev/null)
    if [[ "$ACTUAL" == "null" || -z "$ACTUAL" ]]; then
        echo "  ❌ FAIL: Parameter not found in AWS: $EXPECTED_PARAM"
        echo "     The challenge may have been deleted or never created."
        exit 1
    fi

    PARAM_NAME=$(echo "$ACTUAL" | jq -r .Name)
    PARAM_TYPE=$(echo "$ACTUAL" | jq -r .Type)
    PARAM_MODIFIED=$(echo "$ACTUAL" | jq -r .LastModified)
    PARAM_DESC=$(echo "$ACTUAL" | jq -r .Description)
    echo "  ✓ Parameter found in AWS:"
    echo "      Name:        $PARAM_NAME"
    echo "      Type:        $PARAM_TYPE"
    echo "      Modified:    $PARAM_MODIFIED"
    echo "      Description: $PARAM_DESC"

    if [[ "$PARAM_TYPE" != "SecureString" ]]; then
        echo "  ❌ FAIL: Parameter is not a SecureString (type: $PARAM_TYPE)"
        exit 1
    fi
    echo "  ✓ Parameter type is SecureString (correct)"

    echo
    echo "▶ Attempting to retrieve flag value (with decryption)..."
    FLAG_VALUE=$(aws ssm get-parameter --region "$REGION" \
        --name "$EXPECTED_PARAM" --with-decryption \
        --query "Parameter.Value" --output text 2>/dev/null || echo "")
    if [[ -z "$FLAG_VALUE" ]]; then
        echo "  ❌ FAIL: Could not retrieve parameter value (permission issue?)"
        exit 1
    fi
    if [[ "$FLAG_VALUE" =~ ^FLAG\{.+\}$ ]]; then
        echo "  ✓ Flag format valid: FLAG{...}"
        echo "  ✓ Flag retrieved successfully (value hidden for security)"
    else
        echo "  ❌ FAIL: Flag format invalid. Expected FLAG{...}, got: $FLAG_VALUE"
        exit 1
    fi

    echo
    echo "▶ Cross-referencing manifest with AWS state..."
    MANIFEST_REGION=$(jq -r '.region' "$MANIFEST_FILE")
    MANIFEST_ACCOUNT=$(jq -r '.account_id' "$MANIFEST_FILE")
    if [[ "$MANIFEST_REGION" != "$REGION" ]]; then
        echo "  ⚠️  Manifest region ($MANIFEST_REGION) differs from check region ($REGION)"
    else
        echo "  ✓ Manifest region matches: $REGION"
    fi
    if [[ "$MANIFEST_ACCOUNT" != "$ACCOUNT_ID" ]]; then
        echo "  ⚠️  Manifest account ($MANIFEST_ACCOUNT) differs from current ($ACCOUNT_ID)"
    else
        echo "  ✓ Manifest account matches: $ACCOUNT_ID"
    fi

    echo
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║  ✅ VERIFICATION PASSED - Challenge resources intact          ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo
    echo "📋 Summary:"
    echo "  • Parameter: $PARAM_NAME"
    echo "  • Region:    $REGION"
    echo "  • Type:      SecureString"
    echo "  • Flag:      Valid format (hidden)"
    echo
    echo "💡 To verify cleanup later, run: ./verify-cleanup.sh cleanup"
fi
