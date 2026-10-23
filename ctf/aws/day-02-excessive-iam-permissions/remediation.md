# Remediation Worksheet: Least-Privilege IAM Policy for AutoElite Motors

## 1. Executive Summary
This document outlines the remediation for the over-privileged developer identity (`dev-intern`) discovered during the Day 2 security review. By replacing the overly broad inline policy with a tightly scoped least-privilege policy, AutoElite Motors eliminates the risk of unauthorized access to cloud resources while preserving required operational capabilities.

---

## 2. Original Over-Privileged Policy (Summary of Risks)
- **Problem 1:** Granted `s3:*` / `s3:ListAllMyBuckets` across all S3 resources (`*`), allowing the developer to enumerate and potentially access sensitive buckets across the entire AWS account.
- **Problem 2:** Granted `dynamodb:*` / `dynamodb:ListTables` across all DynamoDB tables (`*`), exposing all database assets.
- **Problem 3:** Granted `iam:GetUser`, `iam:ListUsers`, etc., on `*`, enabling unnecessary reconnaissance into IAM principals.

---

## 3. Corrected Least-Privilege Policy

Replace `OverPrivilegedDeveloperPolicy` with the following strict policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LeastPrivilegeS3BucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::cloudsec-ctf-day02-assets-<suffix>",
        "arn:aws:s3:::cloudsec-ctf-day02-assets-<suffix>/*"
      ]
    },
    {
      "Sid": "LeastPrivilegeDynamoDBTableAccess",
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:Query"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:<account-id>:table/cloudsec-ctf-day02-inventory-<suffix>"
    }
  ]
}
```

---

## 4. Verification & Testing

To verify that the corrected policy functions correctly and denies unauthorized actions, run the AWS IAM Policy Simulator:

```bash
aws iam simulate-principal-policy \
    --policy-source-arn arn:aws:iam::<account-id>:user/dev-intern-<suffix> \
    --action-names s3:GetObject s3:ListAllMyBuckets dynamodb:GetItem dynamodb:ListTables \
    --resource-arns arn:aws:s3:::cloudsec-ctf-day02-assets-<suffix>/flag.txt arn:aws:dynamodb:us-east-1:<account-id>:table/cloudsec-ctf-day02-inventory-<suffix>
```

**Expected Results:**
- `s3:GetObject` on lab asset → **Allowed**
- `s3:ListAllMyBuckets` on `*` → **Implicitly Denied**
- `dynamodb:GetItem` on lab table → **Allowed**
- `dynamodb:ListTables` on `*` → **Implicitly Denied**
