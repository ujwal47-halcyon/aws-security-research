# AWS Cloud Security CTF - Day 5: IAM Trust Policy Investigation

## Lab overview
Inspect an IAM role intended for AWS Lambda that contains an unintended trusted AWS account principal. Identify the trust-policy issue, retrieve the synthetic flag from the role description, and document a least-privilege correction.

## Files
- `CHALLENGE.md`: scope and investigation steps
- `setup.sh`: creates the challenge IAM role
- `teardown.sh`: removes the role recorded in the local manifest
- `verify-cleanup.sh`: checks the lab role and verifies cleanup
- `manifest.json.template`: safe template; setup creates a local `manifest.json`
- `evidence-template.md`: investigation worksheet
- `remediation.md`: remediation worksheet

## Run
Requirements: AWS CLI, jq, and OpenSSL in WSL. Use only an AWS account you control.

First review the scripts and check syntax:

```bash
bash -n setup.sh
bash -n teardown.sh
bash -n verify-cleanup.sh
```

Then review the permissions and current AWS pricing before running:

```bash
chmod +x setup.sh teardown.sh verify-cleanup.sh
./setup.sh
```

Follow `CHALLENGE.md`. This is a policy-analysis lab: do not assume the role or attempt privilege escalation. Complete `evidence-template.md` and `remediation.md`.

When finished, run:

```bash
./teardown.sh
./verify-cleanup.sh cleanup
```

Do not claim cleanup is complete unless verification succeeds.

## Security and cost notes
The generated local `manifest.json` contains the account ID, role details, and flag. Do not commit or share it; `.gitignore` excludes it. The lab creates an IAM role only, but AWS pricing and account eligibility can change. Do not assume Free Tier eligibility guarantees a $0 bill.
