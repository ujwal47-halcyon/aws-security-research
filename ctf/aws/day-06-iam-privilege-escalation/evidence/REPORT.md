# Day 6 Evidence — IAM Privilege Escalation

**Status:** Evidence captured; remediation and cleanup require further verification.

## Evidence index

| ID | Evidence | What it demonstrates | Review |
|---|---|---|---|
| E01 | Inline policy scoped resource | Policy document with `iam:AttachUserPolicy` scoped to a specific policy ARN | Captured |
| E02 | Inline policy wildcard resource | Policy document with `iam:AttachUserPolicy` and `Resource: "*"` | Finding identified |
| E03 | Inline policy inventory | Developer user's inline policy name | Captured |
| E04 | Verification result | Script reports wildcard condition false and verification passed | Needs same-user consistency check |
| E05 | Flag release | Flag gate released the challenge flag | Flag intentionally not published |
| E06 | Investigation flowchart | Investigation sequence and reasoning | Redacted copy prepared |

## Finding
The submitted screenshots show two different developer-user suffixes. One policy contains a wildcard resource; another contains a scoped resource. The evidence does not establish that both policy states belong to the same IAM user or that the verifier inspected every relevant inline and attached managed policy.

## Remediation review
The verifier's success output alone is insufficient to establish remediation. Re-run read-only inspection against the exact same lab username, inspect all inline policies and attached managed policies, and confirm no unrestricted policy-attachment or policy-writing permission remains.

## Cleanup review
No teardown output or independent absence check is included in the submitted screenshots. Cleanup remains unverified.

## Sensitive information handling
Public evidence must redact AWS account ID, IAM usernames/ARNs, account-specific policy ARNs, and the flag. Keep the original screenshots and live manifest private. The actual flag is intentionally omitted from this report.

## Screenshot location
Redacted screenshots are currently in the downloadable evidence ZIP, under `screenshots-redacted/`. They have not yet been uploaded as image files into this GitHub evidence directory.
