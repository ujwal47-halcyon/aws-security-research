#!/usr/bin/env bash
# Creates the isolated Day 6 IAM practice user and vulnerable inline policy.
# Run only in an explicitly approved personal AWS sandbox.
set -euo pipefail
command -v aws >/dev/null || { echo "AWS CLI is required" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }
command -v openssl >/dev/null || { echo "openssl is required" >&2; exit 1; }
aws sts get-caller-identity >/dev/null
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
SUFFIX="$(openssl rand -hex 4)"
USER_NAME="AutoEliteDay6-DevUser-${SUFFIX}"
POLICY_NAME="AutoEliteDay6-DevPolicy"
FLAG="FLAG{$(openssl rand -hex 16)}"
echo "Target account: ${ACCOUNT_ID}; region: ${REGION}"
read -r -p "Type CREATE-DAY6-IAM-USER to create the lab IAM user: " CONFIRM
[[ "$CONFIRM" == "CREATE-DAY6-IAM-USER" ]] || { echo "Cancelled"; exit 1; }
aws iam create-user --user-name "$USER_NAME" --tags Key=Project,Value=CloudSecCTF Key=Day,Value=Day6 Key=Owner,Value=AutoEliteMotors >/dev/null
cleanup_on_error() { aws iam delete-user-policy --user-name "$USER_NAME" --policy-name "$POLICY_NAME" 2>/dev/null || true; aws iam delete-user --user-name "$USER_NAME" 2>/dev/null || true; }
trap cleanup_on_error ERR
POLICY="$(jq -nc '{Version:"2012-10-17",Statement:[{Effect:"Allow",Action:"iam:AttachUserPolicy",Resource:"*"}]}')"
aws iam put-user-policy --user-name "$USER_NAME" --policy-name "$POLICY_NAME" --policy-document "$POLICY"
aws iam update-user --user-name "$USER_NAME" --description "$FLAG"
jq -n --arg region "$REGION" --arg account "$ACCOUNT_ID" --arg user "$USER_NAME" --arg flag "$FLAG" --arg policy "$POLICY_NAME" '{challenge:"day-06-iam-privilege-escalation",region:$region,account_id:$account,user_name:$user,credentials:{user_name:$user,flag:$flag,vulnerable_policy:$policy}}' > manifest.json
chmod 600 manifest.json
trap - ERR
echo "Lab created. Private manifest saved to manifest.json (do not commit or share it)."
echo "User: $USER_NAME"
