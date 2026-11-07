# Day 7 Evidence Report — IAM PassRole

**Status:** Evidence pending review.

## Finding
The supplied Day 7 challenge materials describe a deployment identity with Lambda deployment permissions and an `iam:PassRole` permission scoped broadly to roles in the account. The potential escalation path depends on the target role trusting Lambda and granting access beyond the deployment identity.

## Evidence checklist
| ID | Evidence | Status |
|---|---|---|
| E01 | Caller identity and sandbox scope | Pending |
| E02 | Deployment user's attached and inline policies | Pending |
| E03 | PassRole resource scope | Pending |
| E04 | Execution-role trust policy and permissions | Pending |
| E05 | Policy simulator result for exact user and role | Pending |
| E06 | Controlled synthetic-resource demonstration | Pending |
| E07 | Post-remediation denial and approved-role test | Pending |
| E08 | Independent cleanup verification | Pending |

## Sensitive data handling
The generated manifest contains account/resource identifiers, access-key fields, and challenge flags. It is excluded from GitHub. Both flags must remain private and must never appear in screenshots or repository files.

## Important verification note
A successful script message is not sufficient. Use the exact same deployment identity and execution role for before/after checks. Inspect attached and inline policies and verify both the unauthorized path is denied and any approved deployment path remains functional.

## Cleanup
Cleanup has not been evidenced in the submitted material. Do not mark the lab complete until each resource in the private manifest has been independently checked and removed.
