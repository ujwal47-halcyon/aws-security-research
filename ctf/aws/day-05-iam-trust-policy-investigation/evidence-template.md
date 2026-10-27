# Day 5: Investigation Evidence Worksheet

## Analyst information
- **Analyst:** [Name or lab identity]
- **Date:** [Date]
- **Target role:** [Role name; redact account-specific details in public copies]

## 1. Identity and role discovery

```bash
aws sts get-caller-identity
aws iam list-roles --query "Roles[?contains(RoleName, 'AutoEliteDay5-AuditRole')].[RoleName, Arn]" --output table
```

- **Account ID:** [Keep private or redact]
- **Caller ARN:** [Keep private or redact]
- **Role name:** [Role name]
- **Role ARN:** [Redact account ID in public copy]

## 2. Trust policy inspection

```bash
aws iam get-role --role-name <ROLE_NAME> --query "Role.AssumeRolePolicyDocument" --output json
```

- **Intended principal:** [Expected service]
- **Actual principals:** [List]
- **Unintended principal:** [Describe]
- **Action:** [Expected sts:AssumeRole]

## 3. Risk assessment
- **Intended trust relationship:** [Explain]
- **Actual trust relationship:** [Explain]
- **Potential impact:** [Evidence-supported impact]
- **Least-privilege violation:** [Explain]
- **Limitations:** [What was not tested; do not assume role or exercise the trust]

## 4. Flag recovery

```bash
aws iam get-role --role-name <ROLE_NAME> --query "Role.Description" --output text
```

- **Flag recovered:** [Store privately; do not publish the value]
- **Proof file:** [Redacted evidence filename]

## 5. Verification and cleanup
- [ ] Trust policy reviewed
- [ ] Remediation drafted
- [ ] `./teardown.sh` executed
- [ ] `./verify-cleanup.sh cleanup` passed
- **Cleanup output:** [Summary]
- **Remaining resources or uncertainty:** [Details]

## Publication safety
Redact account IDs, ARNs, role names if sensitive, credentials, and the flag before publishing evidence. Never commit generated `manifest.json`.
