# Day 6 Remediation Worksheet

## Vulnerable pattern
```json
{
  "Effect": "Allow",
  "Action": "iam:AttachUserPolicy",
  "Resource": "*"
}
```

This can allow attachment of managed policies to IAM users without a meaningful resource restriction, creating a privilege-escalation path.

## Preferred remediation
If the developer role does not need to attach policies, remove `iam:AttachUserPolicy` and `iam:PutUserPolicy` entirely. If a legitimate workflow requires attachment, scope permissions to explicitly approved policy ARNs and intended target user ARNs, and validate the exact IAM action/resource authorization model.

## Verification
- Inspect every inline policy on the same developer user.
- Inspect every attached managed policy and its active default version.
- Check Action and Resource values whether represented as strings or arrays.
- Confirm no applicable statement allows unrestricted policy attachment or policy writing.
- Fail closed if any policy cannot be read.
- Do not treat deletion of the developer user as successful remediation.

## Evidence
Capture before and after policy documents for the same username, verifier output, and independent cleanup results. Redact account IDs, user ARNs, credentials, and flags.
