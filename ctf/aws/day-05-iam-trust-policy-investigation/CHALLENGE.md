# Challenge: IAM Trust Policy Investigation

## Lab context
AutoElite Motors uses IAM roles for service-to-service access. An engineer created a role for AWS Lambda, but its trust policy contains an unintended principal.

## Objective
1. Locate the Day 5 lab role with prefix `AutoEliteDay5-AuditRole-`.
2. Inspect its `AssumeRolePolicyDocument`.
3. Identify the unintended trusted principal.
4. Recover the synthetic flag from the role description.
5. Document findings in `evidence-template.md`.
6. Draft a least-privilege fix in `remediation.md`.

## Rules and scope
- Use only your authorized AWS sandbox.
- Inspect with admin or power-user credentials.
- Do not create access keys, assume the role, or exercise the trust relationship.
- Do not attempt privilege escalation.
- Keep the recovered flag out of public evidence.

## Investigation

### 1. Verify identity
```bash
aws sts get-caller-identity
```

### 2. Find the role
```bash
aws iam list-roles --query "Roles[?contains(RoleName, 'AutoEliteDay5-AuditRole')].[RoleName, Arn, CreateDate]" --output table
```

### 3. Inspect the trust policy
Replace `<ROLE_NAME>` with the exact role name:
```bash
aws iam get-role --role-name <ROLE_NAME> --query "Role.AssumeRolePolicyDocument" --output json
```

The intended service principal is `lambda.amazonaws.com`. Check whether another principal is also trusted.

### 4. Retrieve the flag
```bash
aws iam get-role --role-name <ROLE_NAME> --query "Role.Description" --output text
```

Keep the flag in private lab notes, not public GitHub evidence.

### 5. Optional tag check
```bash
aws iam list-role-tags --role-name <ROLE_NAME>
```

Expected tags include `Project=CloudSecCTF`, `Day=Day5`, and `Owner=AutoEliteMotors`.

## Completion criteria
- Role located and trust policy analyzed.
- Unintended principal identified.
- Flag retrieved and kept private.
- Evidence and remediation worksheets completed.
- `./teardown.sh` and `./verify-cleanup.sh cleanup` pass.

## Cost note
This lab creates an IAM role. Review current AWS pricing and account eligibility; Free Tier eligibility does not guarantee a $0 bill.
