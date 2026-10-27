# Day 5 Evidence: IAM Trust Policy Investigation

## Findings
- The lab role was identified with the prefix `AutoEliteDay5-AuditRole-`.
- Its trust policy included the intended AWS Lambda service principal (`lambda.amazonaws.com`) and an additional AWS account root principal.
- The extra account principal was the trust-policy misconfiguration for this lab. Trusting an account root principal can allow identities in that account to be considered for role assumption, subject to authorization and applicable controls.
- A corrected trust policy was drafted that retains only the Lambda service principal.

## Redaction
The public evidence package blurs the AWS account ID, caller/user identifiers, role name and ID, role ARN, and recovered CTF flag. Do not publish the original unredacted screenshots.

## Cleanup
The screenshots do not prove cleanup. Record teardown and cleanup-verification results separately before marking resources removed.

## Evidence files
The redacted screenshot package is provided as `day-05-iam-trust-policy-evidence.zip` in the conversation. The binary screenshots themselves have not been uploaded to this repository.
