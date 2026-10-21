# Day 1: AWS Cloud Security CTF — Identity & Reconnaissance

**Date:** 21 October 2026  
**Status:** Completed; cleanup reported complete  
**Environment:** AWS CLI from WSL  
**Region:** `us-east-1`  
**Service:** AWS Systems Manager Parameter Store

## Objective
Discover a challenge flag using AWS CLI reconnaissance, identify the relevant resource, retrieve the value, and remove the challenge resources afterward.

## Investigation
- Verified the active AWS identity with `aws sts get-caller-identity`.
- Enumerated AWS resources and checked Systems Manager Parameter Store in `us-east-1`.
- Found the parameter `/ctf/day-01/flag-0fa830ad`.
- Confirmed its type was `SecureString`.
- Retrieved the flag with `aws ssm get-parameter --region us-east-1 --name /ctf/day-01/flag-0fa830ad --with-decryption --query Parameter.Value --output text`.
- The flag matched the expected `FLAG{...}` format. The value is intentionally not published in this report.

## Finding
The challenge secret was discoverable through Parameter Store metadata and readable by the configured AWS identity when requesting the parameter with decryption. This demonstrates that the identity had sufficient effective access to retrieve the secret.

**Evidence limitation:** The screenshots show successful retrieval, but do not establish the exact IAM policy responsible. Avoid claiming a specific policy misconfiguration until the identity's attached and inherited policies are inspected.

## Remediation
- Apply least privilege to `ssm:GetParameter` and scope it to only the parameter resources the identity needs.
- Grant `ssm:DescribeParameters` only where discovery is required; remember that parameter names and metadata can disclose useful information.
- If using a customer-managed KMS key, restrict `kms:Decrypt` to the required key and encryption context. For the AWS-managed Parameter Store key, access is primarily controlled through SSM permissions.
- Separate discovery permissions from secret-value retrieval permissions where practical.
- Review CloudTrail events for parameter reads and periodically test effective permissions.

## Cleanup
The teardown script reported that the Day 1 parameter and resource manifest were removed and displayed **TEARDOWN COMPLETE**. This is recorded as reported evidence from the terminal screenshot, not an independent live AWS verification by this repository.

## Proof of work
See the screenshots in [evidence/](evidence/).

## Files
- `CHALLENGE.md`: scenario, rules, investigation path, and success criteria.
- `setup.sh`: creates a SecureString challenge parameter.
- `teardown.sh`: removes Day 1 challenge parameters and the local manifest.
- `verify-cleanup.sh`: verifies challenge state or checks cleanup.
- `resource-manifest.json.template`: manifest template.

## Safety notes
- The lab is intended for an account you own or are explicitly authorized to test.
- Do not commit live flags, AWS credentials, session tokens, or generated manifests containing account-specific data.
- Run scripts only after reviewing their actions and confirming the AWS CLI profile and region.
