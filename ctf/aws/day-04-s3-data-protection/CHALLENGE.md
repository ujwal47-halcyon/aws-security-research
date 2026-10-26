# Day 4: S3 Data Protection (Encryption & Versioning)

## Objective
Inspect the S3 backup bucket `autoelite-app-backups-<suffix>), review default encryption and versioning, recover an overwritten object from its historical version, assess the access boundary, and document remediation.

## Scenario
AutoElite Motors stores database backups in S3. The internal Data Protection & Compliance Policy (SEC-DP-2026) requires:
- **Req-1:** Default server-side encryption. High-value financial/customer backups may require SSE-KMS and key-rotation controls.
- **Req-2:** Bucket versioning enabled to protect against accidental overwrite or deletion.
- **Req-3:** Access restricted to the authorized backup identity `autoelite-backup-user-<suffix>`.

A developer changed the bucket configuration and overwrote `db-backup-2026.json`. The historical version contains the challenge flag.

## Rules
- Use AWS CLI only.
- Work only with the bucket and IAM user created by this lab.
- Do not modify or delete unrelated AWS resources.
- Keep generated credentials and the flag out of public commits.
- Review current AWS pricing and account eligibility. Free Tier does not guarantee zero cost.

## Investigation

### 1. Confirm identity and discover the lab resources
```bash
aws sts get-caller-identity
aws s3 ls
aws iam list-users --query "Users[?contains(UserName, 'autoelite-backup-user')]"
``

Identify the exact bucket suffix created by setup. Do not assume similarly named resources belong to this lab.

### 2. Inspect encryption
```bash
aws s3api get-bucket-encryption --bucket <bucket-name>
``
Record whether encryption is configured and whether the algorithm is `AES256` or `aws:kms`. Compare with SEC-DP-2026 Req-1.

### 3. Inspect versioning
```bash
aws s3api get-bucket-versioning --bucket <bucket-name>
``
Record whether the status is Enabled, Suspended, or absent. Explain why suspended versioning weakens recovery for new writes.

### 4. Inspect object history and recover the old version
```bash
aws s3api list-object-versions --bucket <bucket-name>
aws s3api get-object --bucket <bucket-name> --key db-backup-2026.json --version-id <HISTORICAL_VERSION_ID> recovered-backup.json
cat recovered-backup.json
``
The latest version contains scrubbed data; an older version contains a `FLAG{...}` value. Keep the flag private.

### 5. Test the dedicated backup user
Use the credentials created by setup from the local manifest. Do not paste credentials into GitHub, chat, or evidence screenshots.
```bash
export AWS_ACCESS_KEY_ID="<local access key>"
export AWS_SECRET_ACCESS_KEY="<local secret key>"
aws sts get-caller-identity
aws s3api list-object-versions --bucket <bucket-name>
``
Clear the temporary credentials from your shell when finished, or open a fresh terminal.

### 6. Complete the worksheets
- Fill in `evidence-template.md` with commands, observations, and redacted evidence.
- Complete `remediation.md` with corrected controls and verification tests.

## Analysis questions
- Does the configured encryption meet Req-1?
- Is versioning Enabled or Suspended, and why does it matter?
- Why does encryption at rest not stop an authorized identity from reading an object?
- How does versioning differ from a separate backup or disaster-recovery strategy?
- What is confirmed by the evidence, and what remains an assumption?

## Cleanup
```bash
./teardown.sh
./verify-cleanup.sh cleanup
``
Only report cleanup as complete if verification succeeds.
