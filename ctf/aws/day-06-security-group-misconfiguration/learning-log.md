# Day 6 Prep Log: Security Group Misconfiguration

**Date:** 2026-10-29  
**Status:** Preparation only — challenge execution and evidence are still pending.

## Today's objective
Investigate AWS security group ingress rules and identify administrative ports exposed to the internet, especially SSH (TCP/22) or RDP (TCP/3389) from `0.0.0.0/0` or `::/0`.

## Safe first checks
Run read-only commands before making any changes:

```bash
aws sts get-caller-identity
aws configure get region
aws ec2 describe-security-groups --query 'SecurityGroups[*].{GroupId:GroupId,Name:GroupName,Ingress:IpPermissions}' --output json
```

Confirm the AWS account and region are the intended lab environment. Do not modify security groups or create resources until the lab setup has been reviewed.

## What I will document during the lab
- Finding: security group ID, affected port/protocol, and source CIDR.
- Evidence: redacted CLI output or screenshots; no credentials, account-sensitive details, or challenge flag in public files.
- Impact: explain the exposure risk without assuming a service is running or reachable.
- Remediation: restrict ingress to a justified trusted source or use a managed access method; verify the resulting rule
- Cleanup: run the lab cleanup and independently verify that lab-created resources are removed

## Completion gate
This prep note does **not** mean Day 6 is complete. I will submit the challenge flag privately if required, evidence, reasoning, remediation verification, and cleanup status for review before the next day is unlocked.
