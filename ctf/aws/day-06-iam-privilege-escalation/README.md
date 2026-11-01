# Day 6 — IAM Privilege Escalation CTF

This folder contains the Day 6 IAM policy-manipulation challenge, lab scripts, remediation guidance, and evidence index.

## Project files

| File | Purpose |
|---|---|
| [CHALLENGE.md](./CHALLENGE.md) | Learner-facing challenge and objectives |
| [setup.sh](./setup.sh) | Creates the isolated Day 6 IAM lab user and vulnerable inline policy after explicit confirmation |
| [verify.sh](./verify.sh) | Checks the named inline policy for the targeted wildcard permission |
| [get-flag.sh](./get-flag.sh) | Runs the verification gate before reading the lab flag |
| [teardown.sh](./teardown.sh) | Deletes only the exact Day 6 user recorded in the private manifest |
| [verify-cleanup.sh](./verify-cleanup.sh) | Checks whether the exact lab user has been removed |
| [remediation.md](./remediation.md) | Least-privilege remediation guidance |
| [evidence-template.md](./evidence-template.md) | Template for recording investigation evidence |
| [BUG_ANALYSIS.md](./BUG_ANALYSIS.md) | Verifier limitations, edge cases, and test cases |
| [evidence-report.md](./evidence-report.md) | Earlier evidence review notes |

## Evidence

The evidence folder contains the indexed report and evidence-folder guide:

- [Evidence folder](./evidence/)
- [Evidence README](./evidence/README.md)
- [Evidence report](./evidence/REPORT.md)
- [Screenshots folder](./evidence/screenshots/)

### Screenshot index

| ID | Screenshot filename | What it shows |
|---|---|---|
| E01 | `01-inline-policy-scoped-resource.png` | Policy statement scoped to a specific policy ARN |
| E02 | `02-inline-policy-wildcard-resource.png` | Policy statement using `Resource: "*"` |
| E03 | `03-inline-policy-inventory.png` | Developer user's inline policy inventory |
| E04 | `04-verification-result-redacted.png` | Redacted verifier output |
| E05 | `05-flag-release-redacted.png` | Redacted flag-release output |

**Screenshot upload status:** The filenames above document the intended evidence layout. The PNGs are not yet committed as individual files in this GitHub folder. Add the redacted PNGs to `evidence/screenshots/` for the links to resolve. The downloadable ZIP is not a substitute for committing the images individually.

## Security

- The live `manifest.json`, account-specific identifiers, AWS credentials, and actual flag are intentionally excluded.
- Never commit the generated local manifest or credentials.
- Keep original unredacted screenshots private.
- Publish only redacted evidence.

## Review status

The captured screenshots show both a wildcard policy and a scoped policy, but the developer-user suffixes differ. They do not prove both states belong to the same user. The verifier output alone does not establish that all inline and attached managed policies were inspected. Cleanup is not evidenced.

Day 6 remains under review until same-user remediation verification and independent cleanup evidence are provided.
