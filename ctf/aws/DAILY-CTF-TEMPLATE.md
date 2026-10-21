# AWS Cloud Security CTF — Day XX: [Challenge Name]

**Date:** YYYY-MM-DD  
**Status:** In progress / Completed  
**Environment:** AWS CLI from WSL  
**Region:** `region`  
**Services:** [services used]

## Objective
- [What the challenge is designed to test]

## Investigation
- [Identity and scope checks]
- [Commands and resource discovery]
- [Evidence collected, with secrets redacted]

## Finding
- **Resource:** [resource identifier, redact sensitive details if needed]
- **Issue:** [what was misconfigured or exposed]
- **Impact:** [what an attacker with these permissions could do]
- **Evidence limitation:** [what has and has not been proven]

## Remediation
- [Least-privilege changes]
- [Logging and monitoring]
- [Validation steps]

## Cleanup
- **Status:** [verified / reported complete / pending]
- **Evidence:** [cleanup verification output]

## Proof of work
Store screenshots in `evidence/` and embed them below:

- `evidence/01-reconnaissance.png`
- `evidence/02-exploitation-or-validation.png`
- `evidence/03-remediation-and-cleanup.png`

## Files
- `CHALLENGE.md`
- `setup.sh`
- `teardown.sh`
- `verify-cleanup.sh`
- `resource-manifest.json.template`
- `evidence/`

## Safety
- Never commit credentials, session tokens, live flags, or generated manifests with sensitive account details.
- Run lab scripts only in an authorized account and inspect destructive actions before execution.
- Distinguish observed evidence from assumptions; do not claim a specific IAM policy caused a finding unless it was inspected.
