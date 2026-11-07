# Day 7 Challenge — IAM PassRole Privilege Escalation

## Scenario

AutoElite Motors uses a deployment identity to create and manage Lambda functions. An overly broad `iam:PassRole` permission may let that identity pass an unintended execution role to Lambda.

## Objectives

1. Confirm the AWS caller identity and intended sandbox account.
2. Identify the Day 7 deployment user and enumerate its inline and attached policies.
3. Find the `iam:PassRole` statement and determine which role ARNs it can pass.
4. Inspect the target role's trust policy and effective permissions.
5. Demonstrate the issue only against the synthetic lab resource in the isolated lab.
6. Restrict or remove the excessive permission using least privilege.
7. Verify the same-user/same-role attack path is closed.
8. Retrieve the second flag only after remediation verification.
9. Run teardown and independently verify cleanup.

## Investigation commands

```bash
aws sts get-caller-identity
aws iam list-users --query "Users[?contains(UserName, 'autoelite-deploy-user')]"
aws iam list-user-policies --user-name <DEPLOYMENT_USER>
aws iam list-attached-user-policies --user-name <DEPLOYMENT_USER>
aws iam get-user-policy --user-name <DEPLOYMENT_USER> --policy-name DeployPolicy
aws iam list-roles --query "Roles[?contains(RoleName, 'autoelite-lambda-exec')]"
aws iam get-role --role-name <EXECUTION_ROLE>
```

Test authorization with the policy simulator before attempting the controlled lab demonstration:

```bash
aws iam simulate-principal-policy \
  --policy-source-arn <DEPLOYMENT_USER_ARN> \
  --action-names iam:PassRole \
  --resource-arns <EXECUTION_ROLE_ARN>
```

## Key concept

`iam:PassRole` authorizes passing a role to an AWS service. Its `Resource` refers to the role ARN, not a Lambda function ARN. The target role must trust the service (for Lambda, `lambda.amazonaws.com`), and the deployment identity also needs the relevant Lambda deployment permissions.

## Rules of engagement

- Use only a dedicated AWS sandbox.
- Keep all lab resources private and tagged for Day 7.
- Do not touch resources outside the lab manifest.
- Do not publish flags, credentials, account IDs, or live ARNs.
- Do not assume Free Tier means zero cost.

## Submission

Provide Flag 1 privately after the controlled demonstration, Flag 2 privately after remediation verification, completed evidence and remediation worksheets, and cleanup verification. Do not put either flag in GitHub.
