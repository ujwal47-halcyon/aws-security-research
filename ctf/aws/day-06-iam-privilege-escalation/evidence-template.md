# Day 6 Evidence Template

> Keep the live manifest and flag private. Redact account IDs, ARNs, usernames, and credentials before publishing evidence.

## Scope
- AWS account: [redacted]
- Region: [region]
- Exact lab username: [private locally; use same username for all evidence]

## Initial finding
- Inline policy names:
- Dangerous action(s):
- Resource scope:
- Evidence file(s):

## Impact
Explain the realistic privilege-escalation risk without attempting escalation.

## Remediation
- Change made:
- Why it follows least privilege:

## Verification
- Same exact username used before and after: [yes/no]
- Inline policies inspected: [yes/no]
- Attached managed policies and default versions inspected: [yes/no]
- No unrestricted policy-attachment/writing permission remains: [yes/no]
- Verifier output and exit status:

## Cleanup
- Teardown command and result:
- Independent cleanup check and result:
- Remaining lab resources:
