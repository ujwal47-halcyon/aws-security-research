# Day 1: Identity and Reconnaissance

## Objective
Verify AWS identity, explore regions, and discover resources using AWS CLI only.

## Skills
- Verify identity with `aws sts get-caller-identity`
- List regions with `aws ec2 describe-regions`
- Discover resources across IAM, S3, EC2, Lambda, SSM, Secrets Manager, and DynamoDB
- Filter results with `--query` and `--output`

## Investigation path
1. Verify the active identity.
2. List enabled regions.
3. Discover resources in the authorized account.
4. Follow naming clues such as `ctf`, `flag`, `challenge`, and `day-01`.
5. Inspect the candidate resource and confirm the value matches `FLAG{...}`.

## Rules
- Use only an account you own or are authorized to test.
- Do not assume roles into other accounts.
- Keep the investigation read-only until the authorized cleanup phase.
- Check the AWS CLI profile and region before running lab scripts.

## Success criteria
Find the flag, record the resource location, explain the access issue carefully, and document remediation and cleanup.