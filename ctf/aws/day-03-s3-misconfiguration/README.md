# AWS Cloud Security CTF - Day 3: S3 Access Misconfiguration

Welcome to **Day 3** of the AWS Cloud Security CTF.

## Lab overview

Investigate a fictional application media bucket with an overly broad S3 bucket policy (`"Principal": "*"`). The setup script creates a dedicated low-privilege IAM user for comparison testing.

## Files

| File | Purpose |
|---|---|
| `CHALLENGE.md` | Scenario, rules, investigation path, and submission criteria |
| `setup.sh` | Creates the lab bucket, policy, test user, and objects |
| `teardown.sh` | Removes resources recorded in the local manifest |
| `verify-cleanup.sh` | Checks lab resources or verifies cleanup |
| `manifest.json.template` | Safe template metadata; setup generates a local `manifest.json` |
| `evidence-template.md` | Investigation worksheet |
| `remediation.md` | Least-privilege remediation worksheet |

## Run the lab

Run from this directory in WSL. Requirements: AWS CLI, `jq`, and `openssl`. Use an AWS account you control and review permissions before running.

### 1. Check script syntax

```bash
bash -n setup.sh
bash -n teardown.sh
bash -n verify-cleanup.sh
```

### 2. Review cost and permissions

The lab creates an S3 bucket, two objects, an IAM user, and an access key. Charges depend on your account, region, usage, and current AWS pricing. Free Tier eligibility does **not** guarantee a $0 bill. Check current pricing and your account's eligibility before proceeding.

### 3. Set up

```bash
chmod +x setup.sh teardown.sh verify-cleanup.sh
./setup.sh
```

The setup script creates a local `manifest.json` containing resource identifiers and generated app-user credentials. **Never commit or share this generated file.** It is excluded by `.gitignore`.

### 4. Investigate

Follow `CHALLENGE.md`. Test the low-privilege identity and anonymous access only against the lab bucket created by this script. Do not publish the flag or credentials.

### 5. Document and clean up

Complete `evidence-template.md` and `remediation.md`, then run:

```bash
./teardown.sh
./verify-cleanup.sh cleanup
```

Do not claim cleanup is complete unless verification succeeds. Review script targets before running destructive commands.
