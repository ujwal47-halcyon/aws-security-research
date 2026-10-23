# Day 2: Excessive IAM Permissions — Lab Guide & Run Order

Welcome to **Day 2** of your AWS Cloud Security CTF! Today you will investigate an over-privileged developer identity, discover excessive IAM permissions, safely demonstrate the risk using lab-owned resources, retrieve the flag, and write a least-privilege remediation policy.

---

## 🚀 Exact Run Order

### Step 1: Review Safety & Cost
- All resources are restricted to `Project=CloudSecurityCTF`, `Day=Day2`.
- Uses AWS Free Tier eligible services (IAM, S3, and DynamoDB), where available. **Cost is not guaranteed to be $0.00**: eligibility and usage limits depend on your account plan, account age, Region, and actual usage. Check the AWS Free Tier and pricing for your account before running the lab, monitor billing, and clean up resources afterward.
- No EC2 instances, NAT gateways, RDS databases, or public endpoints are created.

### Step 2: Run Setup
From your WSL terminal in the repository directory:
```bash
cd ctf/aws/day-02-excessive-iam-permissions
./setup.sh
```
*Note: Setup will output temporary credentials for the `dev-intern` user (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`). Keep these safe for testing.*

### Step 3: Verify Resource Creation
```bash
./verify-cleanup.sh
```
This confirms that the IAM user, inline policy, S3 bucket, DynamoDB table, and flags exist and are intact.

### Step 4: Investigate & Solve
1. Open and read `CHALLENGE.md`.
2. Use `evidence-template.md` to record your notes and findings.
3. Investigate the `dev-intern` identity and analyze its policy.
4. Use the `dev-intern` credentials to verify excessive access (e.g. `aws s3 ls`, `aws dynamodb list-tables`) and retrieve the flag (`FLAG{...}`).

### Step 5: Complete Remediation
Fill in `remediation.md` with your proposed least-privilege IAM policy and test it using the AWS IAM Policy Simulator.

### Step 6: Teardown & Clean Up
When you have successfully completed the challenge and recorded your findings:
```bash
./teardown.sh
```

### Step 7: Verify Cleanup
```bash
./verify-cleanup.sh cleanup
```
This checks whether the lab resources have been removed. Review its output and verify the resources in AWS before assuming cleanup is complete.

---

## 🔒 Safety Guarantees
- Idempotent scripts ensure no duplicate resource accumulation.
- Explicit resource manifests prevent accidental deletion of unrelated resources.
- Fully compatible with WSL and AWS CLI.
