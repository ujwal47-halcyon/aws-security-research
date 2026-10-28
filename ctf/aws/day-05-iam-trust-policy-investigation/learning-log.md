# Day 5 Learning Log: IAM Trust Policy

## Key observations
- The lab role was intended to trust the AWS Lambda service principal: `lambda.amazonaws.com`.
- The trust policy also included the account root principal: `arn:aws:iam::<ACCOUNT_ID>:root`.
- The extra trusted principal was the misconfiguration investigated in this challenge.
- The lab flag was stored in the role description. The flag is intentionally not repeated in this public log.
- The proposed corrected trust policy retains the Lambda service principal and removes the unintended account principal.

## Security takeaway
An IAM role trust policy defines who may assume a role. Keep trusted principals limited to the identities and services that actually need access. Review the trust policy itself rather than relying only on the role name or intended purpose.

## Evidence and verification
- Captured CLI evidence for caller identity and the role trust policy.
- Compared the original trust policy with a corrected policy containing only the Lambda service principal.
- Public screenshots and the separate evidence report are being prepared with account identifiers and the flag redacted.
- Cleanup is not recorded as verified in this log.

## Quick review
- [ ] Can explain the difference between a role trust policy and a permissions policy.
- [ ] Can identify the intended and unintended principals in the original trust policy.
- [ ] Can explain why trusted principals should be restricted.
- [ ] Can confirm the final policy and cleanup status before marking the lab fully complete.
