# Day 3: Investigation Evidence Worksheet

## Analyst information
- **Analyst:** [Your name / identity]
- **Date:** [Date]
- **Target bucket:** [Lab bucket name; redact in public evidence]

## 1. Discovery and target identification

### Identity verification

```bash
aws sts get-caller-identity
```

- **Account ID:** [Redact in public copy]
- **Caller ARN:** [Redact identifying values in public copy]

### S3 bucket discovery

```bash
aws s3 ls
```

- **Discovered bucket:** [Lab bucket name; redact in public copy]

## 2. Policy and configuration inspection

### Bucket policy

```bash
aws s3api get-bucket-policy --bucket [BUCKET_NAME] --query Policy --output text | jq .
```

- **Effect:** [Allow / Deny]
- **Principal:** [Principal value]
- **Actions:** [Actions list]
- **Resources:** [Resource ARNs]
- **Conditions:** [Conditions or none]

### Block Public Access (BPA)

```bash
aws s3api get-public-access-block --bucket [BUCKET_NAME]
```

- **BlockPublicAcls:** [true / false]
- **IgnorePublicAcls:** [true / false]
- **BlockPublicPolicy:** [true / false]
- **RestrictPublicBuckets:** [true / false]

## 3. Effective access tests

- **App-user test:** [Command and result; do not include credentials]
- **Admin/authorized identity test:** [Command and result]
- **Anonymous test:** [Command and result]
- **Configured access:** What does the policy attempt to permit?
- **Effective access:** What is actually accessible given all applicable controls?
- **Impacted principals:** [Evidence-supported conclusion]
- **Business impact:** [Data exposure risk if access is effective]

## 4. Flag recovery

```bash
aws s3 cp s3://[BUCKET_NAME]/flag.txt -
```

- **Flag recovered:** [Record privately. Do not publish the flag in a public repository.]
- **Proof:** [Redacted screenshot or output reference]

## 5. Remediation and cleanup

- **Recommended policy change:** [Summary]
- **Allowed-access test:** [Expected and observed result]
- **Denied-access test:** [Expected and observed result]
- **Cleanup command run:** [Command]
- **Cleanup verification:** [Pass / fail, with evidence]
- **Remaining resources or uncertainty:** [Details]

## Publication safety

Before committing this worksheet, redact account IDs, ARNs, bucket names where sensitive, access key IDs, secret access keys, session tokens, and the flag. Never commit the generated local `manifest.json`.
