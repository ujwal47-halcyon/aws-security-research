# Day 4: Investigation Evidence Worksheet

## Analyst information
- **Analyst:** [Name / identity]
- **Date:** [Date]
- **Target bucket:** [Bucket name; redact in public copy]
- **Target IAM user:** [User name; redact if needed]

## 1. Discovery and scope
Commands:
```bash
aws sts get-caller-identity
aws s3 ls
aws iam list-users --query "Users[?contains(UserName, 'autoelite-backup-user')]"
``
- Account ID: [Redact in public copy]
- Caller ARN: [Redact identifying values]
- Bucket: [Lab bucket]
- IAM user: [Lab user]

## 2. Encryption and versioning
Encryption command:
```bash
aws s3api get-bucket-encryption --bucket [BUCKET_NAME]
``
- SSE algorithm: [AES256 / aws:kms]
- KMS key ID, if applicable: [Key ID / none]
- SEC-DP-2026 Req-1: [Compliant / non-compliant and why]

Versioning command:
```bash
aws s3api get-bucket-versioning --bucket [BUCKET_NAME]
``
- Status: [Enabled / Suspended / absent]
- SEC-DP-2026 Req-2: [Compliant / non-compliant and why]

## 3. Object history and recovery
```bash
aws s3api list-object-versions --bucket [BUCKET_NAME]
aws s3api get-object --bucket [BUCKET_NAME] --key db-backup-2026.json --version-id [HISTORICAL_VERSION_ID] recovered.json
``
- Object key: `db-backup-2026.json`
- Latest version ID: [ID]
- Historical version ID: [ID]
- Flag recovered: [Keep private; do not publish]
- Evidence file names: [Redacted screenshots / notes]

## 4. Risk and gap analysis
- Why does encryption at rest not prevent an authorized IAM identity from reading data?
- Why is suspended versioning risky for backups?
- What sequence led to the overwritten backup?
- What does the evidence prove, and what remains uncertain?

## 5. Access control and cleanup
- Backup-user test: [Command and result; no credentials]
- Access boundary finding: [Evidence-based conclusion]
- Remediation applied: [Summary]
- Teardown run: [Yes / no]
- Cleanup verification: [Pass / fail]
- Remaining resources or uncertainty: [Details]

## Publication safety
Redact account IDs, ARNs, access key IDs, secret access keys, session tokens, sensitive bucket names, and the flag. Never commit the generated local `manifest.json`.
