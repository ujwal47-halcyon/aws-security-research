#!/bin/bash
# Day 1: Identity and Reconnaissance - Teardown Script
# Removes only the Day 1 challenge resources
# Run from WSL with your AWS credentials configured

set -euo pipefail
REGION="us-east-1"
PARAM_PREFIX="/ctf/day-01/flag-"
MANIFEST_FILE="resource-manifest.json"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  AWS Cloud Security CTF - Day 1: Identity & Reconnaissance  ║"
echo "║                       TEARDOWN SCRIPT                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo

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
echo "▶ Searching for Day 1 resources in $REGION..."
PARAMS=$(aws ssm describe-parameters --region "$REGION" \
    --parameter-filters "Key=Name,Option=BeginsWith,Values=$PARAM_PREFIX" \
    --query "Parameters[].Name" --output text 2>/dev/null || echo "")

if [[ -z "$PARAMS" || "$PARAMS" == "None" ]]; then
    echo "  ℹ No Day 1 parameters found. Nothing to clean up."
else
    echo "  Found parameters:"
    for PARAM in $PARAMS; do
        echo "    - $PARAM"
        echo "      Deleting..."
        aws ssm delete-parameter --region "$REGION" --name "$PARAM"
        echo "      ✓ Deleted"
    done
fi

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
echo "All Day 1 challenge resources have been removed."
echo "No other resources in your account were affected."
