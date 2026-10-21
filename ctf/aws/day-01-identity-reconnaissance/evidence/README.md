# Day 1 Proof of Work

## Evidence captured

1. `01-ssm-reconnaissance.png` — AWS CLI discovery and SSM SecureString flag retrieval.
2. `02-verification-and-cleanup.png` — verification output and teardown completion.
3. `03-submission-review.png` — Day 1 submission review and remediation notes.

## What the evidence supports

- A parameter named `/ctf/day-01/flag-0fa830ad` was found in `us-east-1`.
- The parameter type was `SecureString`.
- The terminal showed successful retrieval of a value in `FLAG{...}` format.
- The teardown output reported that the challenge parameter and local manifest were removed.

The screenshots are referenced here by intended filename, but the binary image files themselves have not been uploaded by the available GitHub connection. Add the original images to this folder to make the evidence links render.
