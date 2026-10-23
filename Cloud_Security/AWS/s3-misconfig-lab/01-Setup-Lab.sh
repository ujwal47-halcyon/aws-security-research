#!/bin/bash
# S3 Misconfiguration Lab Setup Script
# Creates 3 buckets: public, private, logging
# Uploads fake sensitive file and configures misconfigurations

set -e  # Exit on any error

# Configuration
LAB_NAME="s3-misconfig-lab-$(date +%s)"
REGION="us-east-1"
PUBLIC_BUCKET="${LAB_NAME}-public"
PRIVATE_BUCKET="${LAB_NAME}-private"
LOGGING_BUCKET="${LAB_NAME}-logging"
SENSITIVE_FILE="passwords.txt"
FAKE_CONTENT="admin:EXAMPLE_ONLY_NOT_A_REAL_PASSWORD
db_root:EXAMPLE_ONLY_NOT_A_REAL_PASSWORD
aws_key:EXAMPLE_AWS_ACCESS_KEY_NOT_REAL
aws_secret:EXAMPLE_AWS_SECRET_KEY_NOT_REAL
api_key:EXAMPLE_STRIPE_KEY_NOT_REAL"

echo "🔧 Setting up S3 Misconfiguration Lab..."
echo "📍 Region: $REGION"
echo "🏷️  Lab prefix: $LAB_NAME"

# Create buckets
echo "📦 Creating buckets..."

# Public bucket - world readable
echo "   Creating public bucket: $PUBLIC_BUCKET"
aws s3api create-bucket --bucket "$PUBLIC_BUCKET" --region "$REGION" || \
aws s3api create-bucket --bucket "$PUBLIC_BUCKET" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION"

# Private bucket - no public access
echo "   Creating private bucket: $PRIVATE_BUCKET"
aws s3api create-bucket --bucket "$PRIVATE_BUCKET" --region "$REGION" || \
aws s3api create-bucket --bucket "$PRIVATE_BUCKET" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION"

# Logging bucket - for access logs
echo "   Creating logging bucket: $LOGGING_BUCKET"
aws s3api create-bucket --bucket "$LOGGING_BUCKET" --region "$REGION" || \
aws s3api create-bucket --bucket "$LOGGING_BUCKET" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION"

# Create fake sensitive file
echo "📄 Creating fake sensitive file: $SENSITIVE_FILE"
echo "$FAKE_CONTENT" > "$SENSITIVE_FILE"

# Upload sensitive file to PRIVATE bucket (but we'll make it public by mistake)
echo "📤 Uploading sensitive file to private bucket..."
aws s3 cp "$SENSITIVE_FILE" "s3://$PRIVATE_BUCKET/$SENSITIVE_FILE"

# ACCIDENTAL MISCONFIGURATION: Make private bucket PUBLIC
echo "⚠️  INTENTIONAL MISCONFIGURATION: Making private bucket publicly accessible!"
aws s3api put-bucket-policy --bucket "$PRIVATE_BUCKET" --policy \
'{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::'"$PRIVATE_BUCKET"/*"
        }
    ]
}'

# Also make the bucket itself publicly listable
aws s3api put-bucket-policy --bucket "$PRIVATE_BUCKET" --policy \
'{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::'"$PRIVATE_BUCKET"",
                "arn:aws:s3:::'"$PRIVATE_BUCKET"/*"
            ]
        }
    ]
}'

# Set up access logging on the public bucket to the logging bucket
echo "📝 Setting up access logging..."
aws s3api put-bucket-logging --bucket "$PUBLIC_BUCKET" --bucket-logging-status \
'{
    "LoggingEnabled": {
        "TargetBucket": "'"$LOGGING_BUCKET"'",
        "TargetPrefix": "access-log-"
    }
}'

# Optional: Also enable logging on private bucket to see who accesses it
aws s3api put-bucket-logging --bucket "$PRIVATE_BUCKET" --bucket-logging-status \
'{
    "LoggingEnabled": {
        "TargetBucket": "'"$LOGGING_BUCKET"'",
        "TargetPrefix": "private-access-log-"
    }
}'

# Verify setup
echo "🔍 Verifying lab setup..."
echo "   Buckets:"
aws s3 ls | grep "$LAB_NAME"

echo ""
echo "📋 Lab Summary:"
echo "   Public Bucket:    s3://$PUBLIC_BUCKET"
echo "   Private Bucket:   s3://$PRIVATE_BUCKET (PUBLICLY ACCESSIBLE - INTENTIONAL MISCONFIG)"
echo "   Logging Bucket:   s3://$LOGGING_BUCKET"
echo ""
echo "🎯 Target: Find and access the leaked sensitive file in the private bucket"
echo "   File path: s3://$PRIVATE_BUCKET/$SENSITIVE_FILE"
echo ""
echo "🧪 Testing Commands (run these in 02-Exploit-Lab.sh):"
echo ""
echo "# Test 1: Access public bucket without credentials (should work)"
echo "aws s3 ls s3://$PUBLIC_BUCKET --no-sign-request"
echo ""
echo "# Test 2: Access private bucket without credentials (should work due to misconfig)"
echo "aws s3 ls s3://$PRIVATE_BUCKET --no-sign-request"
echo ""
echo "# Test 3: Download the sensitive file"
echo "aws s3 cp s3://$PRIVATE_BUCKET/$SENSITIVE_FILE . --no-sign-request"
echo ""
echo "# Test 4: Check access logs"
echo "aws s3 ls s3://$LOGGING_BUCKET/ --no-sign-request"
echo ""
echo "💾 Lab configuration saved to: lab-config.txt"
echo "LAB_NAME=$LAB_NAME" > lab-config.txt
echo "PUBLIC_BUCKET=$PUBLIC_BUCKET" >> lab-config.txt
echo "PRIVATE_BUCKET=$PRIVATE_BUCKET" >> lab-config.txt
echo "LOGGING_BUCKET=$LOGGING_BUCKET" >> lab-config.txt
echo "REGION=$REGION" >> lab-config.txt
echo "SENSITIVE_FILE=$SENSITIVE_FILE" >> lab-config.txt

echo "✅ Lab setup complete!"
echo "🚀 Run './02-Exploit-Lab.sh' to practice exploitation"
echo "🧹 Run './03-Cleanup-Lab.sh' when finished"