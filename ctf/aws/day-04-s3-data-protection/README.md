# AWS Cloud Security CTF — Day 4: S3 Data Protection

## Lab overview
Investigate an S3 backup bucket for encryption, versioning, historical object recovery, and access-boundary issues.

## Files
- `CHALLENGE.md`: scenario and investigation steps
- `setup.sh`: creates the isolated lab resources
- `teardown.sh`: removes only resources recorded in the local manifest
- `verify-cleanup.sh`: checks lab state or cleanup
- `manifest.json.template`: safe template; setup creates a local `manifest.json`
- `evidence-template.md`: investigation worksheet
- `remediation.md`: remediation and validation worksheet

## Run
From this directory in WSL, with AWS CLI, `jq`, and `openssl` installed:

```bash
bash -n setup.sh
bash -n teardown.sh
bash -n verify-cleanup.sh
chmod +x setup.sh teardown.sh verify-cleanup.sh
./setup.sh
```

Follow `CHALLENGE.md`, complete the worksheets, then run:

```bash
./teardown.sh
./verify-cleanup.sh cleanup
```

The generated `manifest.json` contains account/resource identifiers and temporary IAM credentials. It is excluded by `.gitignore`; never commit or share it.

## Cost and safety
The lab creates an S3 bucket, object versions, an IAM user, and an access key. Charges depend on region, usage, account eligibility, and current AWS pricing. Free Tier eligibility does not guarantee a $0 bill. Check pricing before running. Do not run the scripts in an account you do not control or lack authorization to use.
