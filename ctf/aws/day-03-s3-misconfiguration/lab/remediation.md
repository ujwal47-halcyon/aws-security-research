# Day 3: S3 Bucket Policy Remediation Worksheet

## 1. Problem summary

Describe the original bucket policy and explain why its principal, actions, resources, and missing conditions may create risk. Distinguish a risky configuration from confirmed effective public access.

## 2. Recommended least-privilege bucket policy

Replace placeholders with the correct account, role, bucket, and prefix. Review application requirements before applying any policy.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowLeastPrivilegeMediaRead",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::ACCOUNT_ID:role/AutoEliteAppRole"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::BUCKET_NAME/approved-prefix/*"
    }
  ]
}
```

If listing is required, add a separate `s3:ListBucket` statement scoped to the bucket ARN and, where appropriate, a prefix condition. Object-level actions use object ARNs; bucket-level actions use the bucket ARN. Avoid wildcard principals unless public access is an explicit, reviewed requirement.

## 3. Justification

1. **Principal scope:** Replace `*` with the specific trusted role or account.
2. **Action scope:** Grant only operations required by the application.
3. **Resource scope:** Limit access to the required bucket or object prefix.
4. **Conditions:** Add appropriate conditions when they meaningfully restrict access.
5. **Public access controls:** Enable the intended S3 Block Public Access settings after checking application requirements and account-level controls.

## 4. Verification and testing

### Test A: Authorized identity

```bash
aws sts get-caller-identity
aws s3 cp s3://[BUCKET_NAME]/[APPROVED_OBJECT] -
```

Expected: access succeeds only for the intended principal and object scope.

### Test B: Anonymous identity

```bash
aws s3 cp s3://[BUCKET_NAME]/[APPROVED_OBJECT] - --no-sign-request
```

Expected: access denied for a private bucket. Run only against the authorized lab bucket.

### Checklist

- [ ] No unintended public access remains.
- [ ] Approved identity can access only required objects.
- [ ] Anonymous access is denied when the bucket is intended to be private.
- [ ] Block Public Access settings match the approved posture.
- [ ] Available logs reviewed for unexpected access.
- [ ] Cleanup verified if the lab was disposable.

Do not publish real account IDs, credentials, session tokens, flags, or private object contents.
