# Day 3: S3 Misconfiguration

## Scenario
A media bucket may have an overly broad bucket policy. Investigate the policy, check S3 Block Public Access settings, and determine whether an object can be retrieved without intended authorization.

## Goals
1. Confirm the active AWS identity and region.
2. Inspect the target bucket policy.
3. Inspect the bucket's Block Public Access configuration.
4. Test object access only against the explicitly authorized lab bucket.
5. Record the impact and propose a least-privilege correction.
6. Verify remediation and cleanup.

## CLI investigation
Replace `<lab-bucket>` with the exact bucket name provided for your authorized lab.

```powershell
aws sts get-caller-identity
aws s3api get-bucket-policy --bucket <lab-bucket>
aws s3api get-public-access-block --bucket <lab-bucket>
aws s3api get-bucket-acl --bucket <lab-bucket>
aws s3api list-objects-v2 --bucket <lab-bucket>
```

Test retrieval only for an object that is explicitly in scope:

```powershell
aws s3 cp s3://<lab-bucket>/<approved-test-object> -
```

## Questions
- Does the policy use `Principal: "*"`?
- Which S3 actions are granted, and to which resources?
- Are `BlockPublicPolicy` and `RestrictPublicBuckets` enabled?
- Can the object be read without the intended identity?
- What is the least-privilege policy that would meet the actual requirement?

## Rules of engagement
- Use only an account and bucket you own or have explicit permission to test.
- Do not enumerate or retrieve data from unrelated buckets.
- Do not publish real flags, credentials, account IDs, or private object contents.
- Do not assume a bucket is disposable just because its name looks like a lab resource.
- Review pricing and account eligibility before creating resources. Free-tier eligibility does not guarantee zero cost.

## Completion criteria
- Evidence captured with sensitive values redacted.
- Public access risk explained accurately.
- Remediation proposed and validated.
- Cleanup status verified or clearly marked incomplete.
