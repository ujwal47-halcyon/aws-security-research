# Day 7 Evidence Worksheet

> Keep the live manifest and both flags private. Redact AWS account IDs, user names, role names/ARNs, access key IDs, secret keys, and bucket identifiers before publishing screenshots.

## Scope
- Date:
- AWS region:
- Sandbox account: [redacted]
- Deployment user: [redacted]
- Execution role: [redacted]

## 1. Identity and discovery
- Caller identity verified:
- Deployment user identified:
- Evidence screenshot:

## 2. Permission analysis
- Attached managed policies:
- Inline policies:
- `iam:PassRole` resource scope:
- Lambda deployment permissions:
- Evidence screenshot:

## 3. Target role analysis
- Trust principal:
- Trust action:
- Effective permissions:
- Synthetic resource only confirmed:

## 4. Capability test
- Policy simulator result:
- Same deployment user and target role used throughout:
- Evidence screenshot:

## 5. Controlled demonstration
- Lambda deployment result:
- Invocation result:
- Flag 1 stored privately (do not paste it here):

## 6. Remediation
- Permission removed or scoped:
- Why this is least privilege:
- Post-remediation policy simulator result:
- Legitimate deployment operation still works:

## 7. Flag 2
- Verification gate passed:
- Flag 2 stored privately (do not paste it here):

## 8. Cleanup
- Teardown result:
- Exact resources independently checked:
- No Day 7 resources remain:
- Manifest removed locally only after verification:
