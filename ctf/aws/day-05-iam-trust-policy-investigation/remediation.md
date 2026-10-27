# Day 5: Remediation Worksheet

## Vulnerability
The role is intended to trust the Lambda service principal, `lambda.amazonaws.com`, but the policy also trusts an AWS account root principal. This broadens the set of identities that may be trusted to assume the role, subject to applicable IAM authorization and controls.

## Recommended corrected trust policy
Remove the unintended AWS principal statement and retain only the required Lambda service principal.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

## Validation plan
1. Review the corrected policy JSON before applying it.
2. Apply changes only to the exact lab role in the authorized sandbox.
3. Re-read the trust policy and confirm only the intended principal remains.
4. Validate the intended Lambda integration using an appropriate controlled service test. Do not attempt to assume the role from an unauthorized principal.
5. Run teardown and cleanup verification.

## Apply and inspect
Save the corrected JSON as `fixed-trust-policy.json`, then use these commands only against the exact lab role:

```bash
aws iam update-assume-role-policy --role-name <ROLE_NAME> --policy-document file://fixed-trust-policy.json
aws iam get-role --role-name <ROLE_NAME> --query "Role.AssumeRolePolicyDocument" --output json
```

## Checklist
- [ ] Unintended principal removed from the proposed policy
- [ ] Intended Lambda service principal preserved
- [ ] Corrected policy reviewed
- [ ] Validation results documented
- [ ] Cleanup verified
