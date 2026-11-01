# Challenge: IAM Privilege Escalation via Policy Manipulation

## Scenario
AutoElite Motors has a developer IAM user whose permissions may allow unrestricted policy attachment. Your task is to audit the user's permissions and propose a least-privilege remediation.

## Objectives
1. Verify the AWS identity and account scope.
2. Locate the Day 6 developer user.
3. List and inspect its inline policies.
4. Identify any `iam:AttachUserPolicy` or `iam:PutUserPolicy` permission with an unrestricted resource.
5. Propose and apply an approved least-privilege correction in the lab.
6. Verify the final policy state and document evidence.
7. Clean up only the lab-owned resources and independently verify cleanup.

## Safe investigation commands
```bash
aws sts get-caller-identity
aws iam list-users --query "Users[?contains(UserName, 'AutoEliteDay6-DevUser')].[UserName,Arn]" --output table
aws iam list-user-policies --user-name <LAB_USER>
aws iam get-user-policy --user-name <LAB_USER> --policy-name <POLICY_NAME> --query PolicyDocument --output json
aws iam list-attached-user-policies --user-name <LAB_USER>
```

Inspect attached managed policies' default versions as well as inline policies. Do not attempt privilege escalation or attach AdministratorAccess.

## Evidence
Record the same exact lab username for every before/after command. Redact account identifiers, user ARNs, credentials, and the flag before publishing evidence.

## Acceptance
- The dangerous permission is identified correctly.
- The remediation is least-privilege and verified against the same user.
- The verifier inspects policy semantics and fails closed.
- Cleanup is independently confirmed.
