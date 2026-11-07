# Day 7 — IAM PassRole Remediation

## Root cause

The deployment identity has `iam:PassRole` access broader than the specific execution role required by its deployment workflow. When combined with Lambda create/update permissions and a role trusted by Lambda, this can allow code to execute with the target role's permissions.

## Preferred fix

If the deployment identity does not need to pass roles, remove `iam:PassRole` entirely.

If it must pass a role, scope `Resource` to the exact approved execution-role ARN or a narrowly controlled role path. Add `iam:PassedToService` condition restricting the service to `lambda.amazonaws.com` where appropriate. Do not use `Resource: "*"`.

Example policy statement (replace the placeholder with the exact approved role ARN):

```json
{
  "Effect": "Allow",
  "Action": "iam:PassRole",
  "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/<APPROVED_LAMBDA_EXECUTION_ROLE>",
  "Condition": {
    "StringEquals": {
      "iam:PassedToService": "lambda.amazonaws.com"
    }
  }
}
```

## Verification

1. Re-read the deployment user's inline and attached policies.
2. Simulate `iam:PassRole` against the previously targeted execution role.
3. Confirm the unauthorized role is denied.
4. Confirm any approved deployment role remains allowed.
5. Confirm Lambda trust policy and deployment workflow still operate as intended.
6. Ensure the test used the exact same deployment identity and target role before and after the fix.

## Cleanup

Use the exact identifiers in the private Day 7 manifest. Do not use broad prefix searches to delete resources across the account.
