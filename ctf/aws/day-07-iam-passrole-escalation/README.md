# Day 7 — IAM PassRole Privilege Escalation

This lab investigates how excessive `iam:PassRole` combined with Lambda deployment permissions can let a deployment identity run code under a more privileged execution role.

## Project files

| File | Purpose |
|---|---|
| [CHALLENGE.md](./CHALLENGE.md) | Scenario, objectives, and investigation path |
| [setup.sh](./setup.sh) | Lab setup entry point and safety checks |
| [teardown.sh](./teardown.sh) | Manifest-scoped teardown; no account-wide prefix deletion |
| [verify-cleanup.sh](./verify-cleanup.sh) | Checks only resources recorded in the private manifest |
| [get-flag.sh](./get-flag.sh) | Local flag-gate entry point |
| [evidence-template.md](./evidence-template.md) | Investigation evidence worksheet |
| [remediation.md](./remediation.md) | Least-privilege remediation guide |
| [.gitignore](./.gitignore) | Excludes manifests, credentials, flags, and generated artifacts |

## Evidence

Place redacted screenshots in `evidence/screenshots/` and link them from `evidence/REPORT.md`. Never commit the live manifest, access keys, secret keys, account-specific ARNs, or actual challenge flags.

## Safety notes

- Review scripts before running them. Setup and teardown change AWS resources.
- Use a dedicated sandbox account and confirm the caller identity before setup.
- The lab should create only tagged resources with `Project=CloudSecurityCTF` and `Day=Day7`.
- Do not create or publish a publicly reachable service.
- IAM and Lambda usage may incur charges; Free Tier eligibility is not a guarantee of zero cost.
- The original teardown's prefix-based fallback was removed from the published version. Cleanup must use exact resource identifiers from the private local manifest.

## Completion requirements

Submit both flags privately, evidence of the same deployment user and target role throughout the investigation, the remediation verification result, and independent cleanup verification. A successful script message alone is not proof that the attack path is closed.
