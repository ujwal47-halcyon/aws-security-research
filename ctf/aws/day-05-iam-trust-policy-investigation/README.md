# AWS Cloud Security CTF - Day 5: IAM Trust Policy Investigation

## Lab overview
Inspect an IAM role intended for AWS Lambda that contains an unintended trusted AWS account principal. Identify the trust-policy issue, retrieve the synthetic flag from the role description, and document a least-privilege correction.

## Files
- `CHALLENGE.md`: scope and investigation steps
- `teardown.sh`: removes the exact role recorded in the local manifest
- `verify-cleanup.sh`: checks the lab role and verifies cleanup
- `manifest.json.template`: safe template; a local `manifest.json` is created during setup
- `evidence-template.md`: investigation worksheet
- `remediation.md`: remediation worksheet

**Note:** The setup script has not been committed. Do not run the lab until a reviewed setup script is added.

## Before running
Use only an AWS account you control. Review the scripts and check syntax:

```bash
bash -n teardown.sh
bash -n verify-cleanup.sh
```

The challenge is intended for policy inspection only. Do not assume the role or attempt privilege escalation.

## Security and cost notes
The generated local `manifest.json` may contain account details and the challenge flag. Do not commit or share it; `.gitignore` excludes it. Review current AWS pricing and account eligibility before creating resources. Free Tier eligibility does not guarantee a $0 bill.
