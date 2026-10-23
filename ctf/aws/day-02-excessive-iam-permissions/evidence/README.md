# Day 2 Proof of Work

## Evidence captured
1. `01-s3-flag-proof.jpg` — successful retrieval of the challenge object's flag; the flag value is blurred.
2. `02-iam-policy-proof.jpg` — inline policy enumeration and policy-document inspection.
3. `03-dynamodb-enumeration-proof.jpg` — DynamoDB table enumeration.
4. `04-dynamodb-table-proof.jpg` — challenge table description and active status.
5. `05-s3-bucket-enumeration-proof.jpg` — S3 bucket inventory; unrelated bucket names are blurred.
6. `report.jpg` — workflow-board screenshot summarizing the investigation.

## What the evidence supports
- The challenge user's inline policy was named `OverPrivilegedDeveloperPolicy`.
- The inspected policy contained broad S3, DynamoDB, and IAM enumeration actions in addition to scoped challenge-resource access.
- The challenge S3 object was retrieved and returned a value in `FLAG{...}` format.
- The Day 2 DynamoDB table was listed and described as `ACTIVE`.

## Redactions
The flag value, local machine label, AWS account identifier, and unrelated bucket inventory details were blurred where present. No password, AWS secret access key, or session token was visible in the supplied screenshots.

## Limitations
These screenshots do not prove that cleanup was completed. The screenshots are evidence from the supplied terminal session, not an independent live verification by this repository.
