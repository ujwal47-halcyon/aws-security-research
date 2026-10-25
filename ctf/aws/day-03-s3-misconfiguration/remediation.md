# Day 3 Remediation: S3 Public Access

## Finding
The inspected bucket policy used a wildcard principal and allowed `s3:GetObject` and `s3:ListBucket`. The bucket-level Block Public Access configuration showed `BlockPublicPolicy=false` and `RestrictPublicBuckets=false`.

## Recommended actions
1. Remove the wildcard principal unless public access is a documented requirement.
2. Scope read/list permissions to the specific trusted IAM principal and required bucket/object ARNs.
3. Enable all four bucket-level S3 Block Public Access controls unless an approved exception is required.
4. Check account-level settings and organization controls before changing the bucket.
5. Validate expected access and denial behavior after the change.
6. Review available logs for unexpected access.

## Example private bucket policy
Replace the placeholders with the actual account, role, bucket, and required prefix. Do not apply this example without reviewing application requirements.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowReadOnlyToApprovedRole",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<account-id>:role/<approved-role>"
      },
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::<lab-bucket>/<approved-prefix>/*"
    }
  ]
}
```

If listing is needed, add a separate `s3:ListBucket` statement scoped to the bucket ARN and, where appropriate, a prefix condition. Keep object-level and bucket-level resources distinct.

## Validation checklist
- [ ] Confirm the policy no longer grants unintended public access.
- [ ] Confirm approved identity can access only required objects.
- [ ] Confirm unauthenticated access is denied.
- [ ] Confirm public access block settings match the intended posture.
- [ ] Review logs for unexpected access.
- [ ] Verify cleanup if this was a disposable lab.

**Note:** Do not paste actual account IDs or secrets into public evidence.
