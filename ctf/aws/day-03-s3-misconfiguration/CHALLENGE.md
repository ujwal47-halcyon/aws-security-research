# Day 3: S3 Access Misconfiguration

## Objective

Investigate an AWS S3 bucket with a deliberately misconfigured bucket policy. Determine the effective access risk, test permissions using a dedicated low-privilege application identity, recover the intended lab flag, document a security finding, propose least-privilege remediation, and verify cleanup.

## Scenario

**AutoElite Motors** hosts a private application media repository in S3 (`autoelite-app-media-<suffix>`). A deployment introduced a bucket policy that appears to grant object read access too broadly.

The setup script provisions:
1. An S3 bucket with a misconfigured bucket policy (`"Principal": "*"`).
2. A dedicated low-privilege IAM user (`autoelite-app-user-<suffix>`) with access keys for testing.

Tasks:
1. Confirm your identity and target scope.
2. Inspect the bucket policy, ACLs, and Block Public Access (BPA) settings.
3. Test access as the low-privilege app user, your authorized admin identity, and anonymously (`--no-sign-request`).
4. Distinguish policy configuration from effective access.
5. Identify affected principal, actions, resources, and relevant conditions.
6. Recover the random flag using the authorized lab CLI path.
7. Write a finding that separates confirmed facts from assumptions.
8. Propose least-privilege remediation.
9. Define post-remediation tests for allowed and denied access.

## What you'll practice

- Switching AWS CLI identities with environment variables.
- Inspecting bucket policies and Block Public Access.
- Understanding IAM and resource-policy evaluation.
- Distinguishing a risky policy from proven effective public access.
- Retrieving S3 objects and writing least-privilege policies.

## Rules of engagement

| Rule | Description |
|---|---|
| CLI only | Use the AWS CLI; no console required. |
| Lab scope only | Interact only with resources created for this lab. |
| No unrelated data | Do not enumerate or retrieve data from unrelated buckets. |
| No destructive actions outside scope | Do not delete or modify non-lab resources. |
| Cost awareness | Review current AWS pricing and account eligibility. Free Tier eligibility does not guarantee zero cost. |

## Investigation path

### Step 1: Identify the target

Run these commands using your primary lab identity:

```bash
aws sts get-caller-identity
aws s3 ls
```

Find the bucket created by the lab setup script. Do not assume a similarly named bucket belongs to this lab.

### Step 2: Inspect policy and settings

```bash
aws s3api get-bucket-policy --bucket <bucket-name> --query Policy --output text | jq .
aws s3api get-public-access-block --bucket <bucket-name>
aws s3api get-bucket-acl --bucket <bucket-name>
```

### Step 3: Test the dedicated app identity

Use the credentials printed by `setup.sh` locally. Do not paste them into a report, commit, or chat. Confirm the identity:

```bash
aws sts get-caller-identity
aws s3 ls s3://<bucket-name>/
aws s3 cp s3://<bucket-name>/flag.txt -
```

### Step 4: Test anonymous access

Only against the bucket created by this lab:

```bash
aws s3 cp s3://<bucket-name>/flag.txt - --no-sign-request
```

Record whether it succeeds or fails. A wildcard principal in a policy is a warning sign, but the policy text alone does not prove that an anonymous request succeeds.

### Step 5: Analyze effective access

Consider how the bucket policy, identity policy, bucket/account Block Public Access settings, and other applicable controls affect access. Identify whether the evidence confirms public, cross-account, or only overly broad configured access.

### Step 6: Complete worksheets

- Fill in `evidence-template.md` with commands, observations, and effective-risk assessment.
- Fill in `remediation.md` with a corrected policy and validation test cases.

## Submission criteria

1. Record the flag in your private lab notes; do not publish it.
2. Complete the evidence worksheet with sensitive values redacted.
3. Complete the remediation worksheet.
4. Run `./teardown.sh` and `./verify-cleanup.sh cleanup`.
5. State cleanup status only after verification.

## Cost note

This lab creates one S3 bucket, two S3 objects, an IAM user, and an access key. Actual charges depend on pricing, region, usage, and account eligibility. Verify current AWS pricing before running; do not assume the lab is guaranteed to cost $0.

## Cleanup

```bash
./teardown.sh
./verify-cleanup.sh cleanup
```
