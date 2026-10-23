# Day 2 Evidence & Findings Record

Use this template to record your investigation steps, findings, and remediation for Day 2.

## 1. Metadata
- **Investigator:** [Your Name / Alias]
- **Date:** [YYYY-MM-DD]
- **AWS Region:** us-east-1
- **Investigated Identity (Caller):** [Your principal ARN]

---

## 2. Reconnaissance & Enumeration Findings

### A. Developer Identity Discovered
- **Username:** `dev-intern-<suffix>`
- **User ARN:** `arn:aws:iam::<account-id>:user/dev-intern-<suffix>`
- **Creation Date:** [Date/Time]

### B. Attached Policies
- **Managed Policies:** [None / List ARNs]
- **Inline Policies:** 
  - Policy Name: `OverPrivilegedDeveloperPolicy`

---

## 3. Policy Analysis & Excessive Permissions

| Statement ID (Sid) | Allowed Actions (`Action`) | Resource Scope (`Resource`) | Risk / Why Excessive |
|--------------------|----------------------------|----------------------------|----------------------|
| `IntendedS3Access` | `s3:GetObject`, `s3:PutObject`, `s3:ListBucket` | Lab bucket ARN + `/*` | Required for job (least privilege). |
| `IntendedDynamoDBAccess` | `dynamodb:GetItem`, `dynamodb:Query` | Lab table ARN | Required for job (least privilege). |
|                    |                            |                            |                      |
|                    |                            |                            |                      |
|                    |                            |                            |                      |

---

## 4. Controlled Impact Demonstration

### A. S3 Scope Check
- **Command Run:** `aws s3 ls` (using `dev-intern` credentials)
- **Observation:** [Can you list all buckets in the account? Is this expected?]

### B. DynamoDB Scope Check
- **Command Run:** `aws dynamodb list-tables --region us-east-1`
- **Observation:** [Can you see tables outside your scope?]

---

## 5. Flag Retrieval

- **Source S3 / DynamoDB:** [S3 bucket or DynamoDB table name]
- **Flag Value:** `FLAG{...}`

---

## 6. Remediation & Least-Privilege Validation

- **Policy Validation Command:** `aws iam simulate-principal-policy ...`
- **Validation Results:** [Pass/Fail for allowed vs denied actions]
