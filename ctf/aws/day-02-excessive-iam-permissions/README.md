# Day 2: AWS Cloud Security CTF — Excessive IAM Permissions

**Date:** 23 October 2026  
**Status:** Investigation evidence captured; cleanup not shown in the supplied screenshots  
**Environment:** AWS CLI from WSL  
**Region:** `us-east-1`  
**Services:** AWS IAM, Amazon S3, Amazon DynamoDB

## Objective
Inspect a purpose-built IAM identity with excessive permissions, identify the resources it can enumerate, and retrieve the challenge flag from the lab's S3 object.

## Investigation
- Listed inline policies for the challenge user and identified `OverPrivilegedDeveloperPolicy`.
- Inspected the policy document and observed intended resource-scoped S3 and DynamoDB access alongside broader enumeration permissions.
- Used `aws s3api get-object` to retrieve the challenge object's `flag.txt`.
- Enumerated DynamoDB tables and confirmed the challenge table was present.
- Described the challenge table and observed that its status was `ACTIVE`.
- Listed S3 buckets to inspect the account's bucket inventory.

## Finding
The inspected inline policy included broad account-level discovery permissions, including `s3:ListAllMyBuckets`, `s3:GetBucketLocation`, `dynamodb:ListTables`, `dynamodb:DescribeTable`, and IAM user/policy enumeration actions. The policy also included intended access scoped to the challenge bucket and table. This demonstrates that the policy exposes more resource metadata than the stated task requires.

## Flag handling
The terminal output showed a value in `FLAG{...}` format. The flag value has been blurred in the published evidence so the repository does not disclose the challenge secret.

## Remediation
- Remove unnecessary account-wide enumeration permissions.
- Keep S3 object actions scoped to the required bucket and its objects.
- Keep DynamoDB data actions scoped to the required table.
- Grant IAM read actions only when explicitly required for the user's duties.
- Validate the revised policy with `aws iam simulate-principal-policy` and test both expected allows and expected denies.
- Review CloudTrail for resource enumeration and sensitive object reads.

## Cleanup status
The supplied screenshots do not show teardown or an independent cleanup verification. Cleanup is therefore **not claimed as complete** in this report. After the challenge, run the lab's teardown script and verify that only the Day 2 resources have been removed.

## Proof of work
See the redacted screenshots in [evidence/](evidence/). The final workflow-board screenshot is saved as [report.jpg](evidence/report.jpg).

## Safety and privacy
The screenshots were reviewed before publication. The visible flag value, local machine label, AWS account identifier, and unrelated bucket inventory details were obscured where present. No AWS access key, secret access key, session token, or password was visible in the supplied screenshots.

Only use this workflow in an AWS account you own or are explicitly authorized to test.
