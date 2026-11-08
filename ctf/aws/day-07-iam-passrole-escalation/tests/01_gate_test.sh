#!/bin/bash
# Day 7: Pre-exploitation Gate Test
# Verifies the lab is properly set up with the vulnerable configuration
# before exploitation begins.

set -euo pipefail

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Day 7: IAM PassRole Escalation - Gate Test                   ║"
echo "║                PRE-EXPLOTATION VERIFICATION                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo

# ─── Pre-flight Checks ──────────────────────────────────────────
echo "▶ Pre-flight checks..."

if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ jq not found."
    exit 1
fi

IDENTITY=$(aws sts get-caller-identity --output json)
ACCOUNT_ID=$(echo "$IDENTITY" | jq -r .Account)
USER_ARN=$(echo "$IDENTITY" | jq -r .Arn)
echo "  ✓ Authenticated as: $USER_ARN"
echo "  ✓ Account ID: $ACCOUNT_ID"
echo

# ─── Check Prerequisites ─────────────────────────────────────────
echo "▶ Checking prerequisites..."

# Check manifest exists
if [[ ! -f "manifest.json" ]]; then
    echo "❌ FAIL: Manifest file not found. Run ./setup.sh first."
    exit 1
fi
echo "  ✓ Manifest file exists"

# Load manifest
EXPECTED_USER=$(jq -r '.credentials.user_name // empty' manifest.json 2>/dev/null || echo "")
EXPECTED_ROLE=$(jq -r '.resources[] | select(.type=="AWS::IAM::Role") | .name' manifest.json 2>/dev/null || echo "")
EXPECTED_VAULT=$(jq -r '.resources[] | select(.type=="AWS::S3::Bucket") | .name' manifest.json 2>/dev/null || echo "")

if [[ -z "$EXPECTED_USER" || "$EXPECTED_USER" == "null" ]]; then
    echo "❌ FAIL: No user name in manifest. Run ./setup.sh first."
    exit 1
fi
echo "  ✓ Expected user: $EXPECTED_USER"

if [[ -z "$EXPECTED_ROLE" || "$EXPECTED_ROLE" == "null" ]]; then
    echo "❌ FAIL: No execution role in manifest. Run ./setup.sh first."
    exit 1
fi
echo "  ✓ Expected role: $EXPECTED_ROLE"

# Verify target resources exist
echo
echo "▶ Verifying target resources exist..."

if ! aws iam get-user --user-name "$EXPECTED_USER" 2>/dev/null; then
    echo "❌ FAIL: Deployment user not found: $EXPECTED_USER"
    exit 1
fi
echo "  ✓ Deployment user exists"

if ! aws iam get-role --role-name "$EXPECTED_ROLE" 2>/dev/null; then
    echo "❌ FAIL: Execution role not found: $EXPECTED_ROLE"
    exit 1
fi
echo "  ✓ Execution role exists"

if ! aws s3api head-bucket --bucket "$EXPECTED_VAULT" 2>/dev/null; then
    echo "❌ FAIL: S3 vault not found: $EXPECTED_VAULT"
    exit 1
fi
echo "  ✓ S3 vault exists"

# ─── Verify Vulnerable Configuration ───────────────────────────────
echo
echo "▶ Verifying vulnerable configuration..."

# Check user has DeployPolicy with PassRole
POLICY_DOC=$(aws iam get-user-policy --user-name "$EXPECTED_USER" --policy-name "DeployPolicy" --query "PolicyDocument" --output json 2>/dev/null || echo "")

if [[ -z "$POLICY_DOC" ]]; then
    echo "  ❌ FAIL: DeployPolicy not found on user"
    exit 1
fi
echo "  ✓ DeployPolicy exists on user"

# Check for PassRole with wildcard or broad resource
PASSROLE_RESOURCE=$(echo "$POLICY_DOC" | jq -r '.Statement[] | select(.Action=="iam:PassRole" or (.Action | tostring | contains("PassRole"))).Resource // empty' 2>/dev/null || echo "")

if [[ -z "$PASSROLE_RESOURCE" || "$PASSROLE_RESOURCE" == "null" ]]; then
    echo "  ❌ FAIL: iam:PassRole permission not found in DeployPolicy"
    exit 1
fi

if [[ "$PASSROLE_RESOURCE" == "*" ]]; then
    echo "  ✓ PASSRole has wildcard resource (*) - VULNERABLE TO ESCALATION"
elif [[ "$PASSROLE_RESOURCE" == "arn:aws:iam::$ACCOUNT_ID:role/*" ]]; then
    echo "  ✓ PassRole has role wildcard - VULNERABLE TO ESCALATION"
else
    echo "  ⚠️  PassRole resource: $PASSROLE_RESOURCE (may need manual verification)"
fi

# Check role trust policy allows Lambda
TRUST_POLICY=$(aws iam get-role --role-name "$EXPECTED_ROLE" --query "Role.AssumeRolePolicyDocument" --output json 2>/dev/null || echo "")

if [[ -z "$TRUST_POLICY" ]]; then
    echo "  ❌ FAIL: Cannot read role trust policy"
    exit 1
fi

LAMBDA_TRUST=$(echo "$TRUST_POLICY" | jq -r '.Statement[] | select(.Principal.Service=="lambda.amazonaws.com" or (.Principal | tostring) | contains("lambda.amazonaws.com")) | .Effect // empty' 2>/dev/null || echo "")

if [[ -n "$LAMBDA_TRUST" && "$LAMBDA_TRUST" == "Allow" ]]; then
    echo "  ✓ Execution role trusts lambda.amazonaws.com"
else
    echo "  ❌ FAIL: Execution role does not trust lambda.amazonaws.com"
    exit 1
fi

# Check vault contains flag
echo
echo "▶ Verifying flag vault content..."
FLAG_CHECK=$(aws s3 cp "s3://${EXPECTED_VAULT}/flag1.txt" - 2>/dev/null || echo "")
if [[ "$FLAG_CHECK" =~ ^FLAG\{.+\}$ ]]; then
    echo "  ✓ Flag 1 accessible in S3 vault"
else
    echo "  ❌ FAIL: Flag not found or invalid format in vault"
    exit 1
fi

# ─── Final Summary ────────────────────────────────────────────────
echo
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✅ GATE TEST PASSED - Lab ready for exploitation              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo
echo "The lab is properly configured with:"
echo "  • Vulnerable PassRole permission"
echo "  • Execution role with Lambda trust"
echo "  • Accessible flag vault"
echo
echo "Proceed with exploitation to retrieve Flag 1."