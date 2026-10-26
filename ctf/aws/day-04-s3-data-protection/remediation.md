# Day 4: S3 Data Protection Remediation Worksheet

## 1. Problem summary
Describe the observed encryption and versioning settings, and explain the compliance impact against SEC-DP-2026. Separate confirmed findings from assumptions.

## 2. Recommended remediation

### A. Enable bucket versioning
```bash
aws s3api put-bucket-versioning --bucket [BUCKET_NAME] --versioning-configuration Status=Enabled
aws s3api get-bucket-versioning --bucket [BUCKET_NAME]
``
Expected: `"Status": "Enabled"`. Versioning preserves previous object versions after overwrites, but it is not a substitute for an independently protected backup or disaster-recovery plan.

### B. Enforce the required default encryption
For the lab's baseline SSE-S3:
```bash
aws s3api put-bucket-encryption --bucket [BUCKET_NAME] --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
``
For data requiring SSE-KMS, select an approved customer-managed KMS key, configure key policy and rotation according to organizational policy, then enforce the required algorithm and key through bucket policy. Review cost implications before creating or using KMS keys.

### C. Restrict access to the backup identity
Use a bucket policy that names the approved IAM principal and grants only required actions. Keep bucket-level actions on the bucket ARN and object-level actions on object ARNs. Avoid wildcard principals for a private backup repository.

### D. Verify
- [ ] Versioning reports Enabled.
- [ ] Default encryption matches policy.
- [ ] Only the approved backup identity has required access.
- [ ] Unauthorized and anonymous access tests fail when the bucket is private.
- [ ] Historical recovery is tested where appropriate.
- [ ] Logs and access patterns reviewed.
- [ ] Cleanup verified if this was a disposable lab.

## 3. Verification commands
```bash
aws s3api get-bucket-versioning --bucket [BUCKET_NAME]
aws s3api get-bucket-encryption --bucket [BUCKET_NAME]
aws s3api list-object-versions --bucket [BUCKET_NAME]
``

## 4. Cost and safety
Check current AWS pricing and account eligibility before applying changes. Free Tier eligibility does not guarantee zero cost. Do not publish credentials, flags, account identifiers, or private backup contents.
