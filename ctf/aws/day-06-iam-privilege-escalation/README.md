# Day 6 — IAM Privilege Escalation CTF

This folder contains the Day 6 IAM policy-manipulation challenge and evidence notes.

## Security
- The live `manifest.json`, account-specific identifiers, AWS credentials, and actual flag are intentionally excluded.
- Never commit the generated local manifest or credentials.
- Screenshots are shared separately in the redacted evidence ZIP.

## Evidence status
The captured screenshots show both a wildcard policy and a scoped policy, but the developer-user suffixes differ. They do not prove both states belong to the same user. Cleanup is not evidenced. See `evidence-report.md` before marking Day 6 complete.

## Review warning
The original verification and flag-release scripts require a code review before reuse. A successful message alone is not proof that every relevant inline and attached managed policy was checked.
