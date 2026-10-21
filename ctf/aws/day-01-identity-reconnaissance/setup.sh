#!/bin/bash
# Day 1: Identity and Reconnaissance - Setup Script
# Creates a single SSM SecureString parameter with a random flag in us-east-1
# Run from WSL with your AWS credentials configured

set -euo pipefail

REGION="us-east-1"
PARAM_PREFIX="/ctf/day-01/flag-"
MANIFEST_FILE="resource-manifest.json"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  AWS Cloud Security CTF - Day 1: Identity & Reconnaissance  ║"
echo "║                        SETUP SCRIPT                           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo

echo "▶ Pre-flight checks..."
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Install: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
    exit 1
fi
echo "  ✓ AWS CLI: $(aws --version 2>&1 | head -1)"

if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured or invalid."
    echo "   Run: aws configure  (or set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN)"
    exit 1
fi

IDENTITY=$(aws sts get-caller-identity --output json)
ACCOUNT_ID=$(echo "$IDENTITY" | jq -r .Account)
USER_ARN=$(echo "$IDENTITY" | jq -r .Arn)
echo "  ✓ Authenticated as: $USER_ARN"
echo "  ✓ Account ID: $ACCOUNT_ID"

if ! aws ec2 describe-regions --region "$REGION" --query "Regions[?RegionName=='$REGION'].OptInStatus" --output text | grep -q "opt-in-not-required\|opted-in"; then
    echo "❌ Region $REGION is not enabled for this account."
    echo "   Enable it in the console or choose a different region."
    exit 1
fi
echo "  ✓ Region $REGION is available"

EXISTING=$(aws ssm describe-parameters --region "$REGION" \
    --parameter-filters "Key=Name,Option=BeginsWith,Values=$PARAM_PREFIX" \
    --query "Parameters[0].Name" --output text 2>/dev/null || echo "None")

if [[ "$EXISTING" != "None" && "$EXISTING" != "" ]]; then
    echo
    echo "⚠️  Existing Day 1 resource found: $EXISTING"
    read -p "   Re-create flag? This will overwrite the existing parameter. [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "   Setup aborted. Existing resource preserved."
        exit 0
    fi
    echo "   Deleting existing parameter..."
    aws ssm delete-parameter --region "$REGION" --name "$EXISTING"
fi

echo
echo "▶ Generating challenge flag..."
RANDOM_SUFFIX=$(openssl rand -hex 4)
PARAM_NAME="${PARAM_PREFIX}${RANDOM_SUFFIX}"
FLAG_CONTENT="FLAG{$(openssl rand -hex 16)}"
echo "  ✓ Parameter name: $PARAM_NAME"
echo "  ✓ Flag generated (not displayed - discover it via CLI!)"

echo
echo "▶ Creating SSM SecureString parameter in $REGION..."
aws ssm put-parameter \
    --region "$REGION" \
    --name "$PARAM_NAME" \
    --value "$FLAG_CONTENT" \
    --type "SecureString" \
    --description "CTF Day 1 Flag - Discover via 'aws ssm get-parameter --with-decryption'" \
    --tags Key=Project,Value=CloudSecurityCTF Key=Day,Value=Day1 Key=Type,Value=ChallengeFlag
echo "  ✓ Parameter created successfully"

echo
echo "▶ Writing resource manifest..."
cat > "$MANIFEST_FILE" <<EOF
{
  "challenge": "day-01-identity-reconnaissance",
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "region": "$REGION",
  "account_id": "$ACCOUNT_ID",
  "resources": [
    {
      "type": "AWS::SSM::Parameter",
      "name": "$PARAM_NAME",
      "arn": "arn:aws:ssm:$REGION:$ACCOUNT_ID:parameter$PARAM_NAME",
      "description": "CTF Day 1 Flag (SecureString)"
    }
  ],
  "cleanup_commands": [
    "aws ssm delete-parameter --region $REGION --name $PARAM_NAME"
  ]
}
EOF
echo "  ✓ Manifest written to $MANIFEST_FILE"

echo
echo "▶ Verifying resource exists..."
VERIFY=$(aws ssm describe-parameters --region "$REGION" \
    --parameter-filters "Key=Name,Option=Equals,Values=$PARAM_NAME" \
    --query "Parameters[0].{Name:Name,Type:Type,LastModified:LastModified}" \
    --output json)
echo "  $VERIFY" | jq .

echo
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  ✅ SETUP COMPLETE                                            ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo
echo "📋 Next Steps:"
echo "  1. Read the challenge: cat CHALLENGE.md"
echo "  2. Start investigating: aws sts get-caller-identity"
echo "  3. Find the flag in Parameter Store (hint: us-east-1)"
echo
echo "💡 The flag is NOT printed here. You must discover it using AWS CLI."
echo "   Try: aws ssm describe-parameters --region us-east-1 --parameter-filters Key=Name,Option=BeginsWith,Values=/ctf/day-01/flag-"
