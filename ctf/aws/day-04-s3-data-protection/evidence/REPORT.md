# Day 4 Report: S3 Data Protection

**Status:** Investigation evidence captured. Cleanup status is not established by these screenshots.

## Findings

- **Default encryption:** The bucket reports `AES256` server-side encryption (SSE-S3). Default encryption is configured. Whether this meets the lab's higher-value data policy depends on whether SSE-KMS is explicitly required.
- **Versioning:** The bucket reports `Suspended`, which is a data-protection gap because new writes no longer receive normal versioning protection.
- **Historical versions:** `list-object-versions` shows multiple versions of `db-backup-2026.json`, including a non-current historical version.
- **Recovery:** `get-object` using the historical version ID succeeded. The recovered JSON shows `status: HEALTHY` and a recovery flag. The flag value is intentionally redacted in the public evidence.
- **Access controls:** These screenshots do not establish the full bucket policy or prove that the dedicated low-privilege identity has only the intended permissions. Verify those separately.

## Recommended remediation

1. Re-enable bucket versioning and verify with `aws s3api get-bucket-versioning`.
2. Confirm the data classification policy. Use SSE-KMS with an approved key if required, including key access controls, rotation, and audit monitoring.
3. Review bucket and IAM policies for least privilege. Limit access to the intended backup service identity and required actions.
4. Consider S3 Object Lock or separate protected backups where retention and recovery requirements warrant it. Versioning alone is not a complete backup or disaster-recovery strategy.
5. Run the lab teardown and cleanup verification scripts, then record the actual results before marking cleanup complete.

## Evidence index

- `01-encryption-config.png` — default encryption configuration; bucket name blurred.
- `02-object-versions.png` — object versions; bucket name, version identifiers, and account owner identifier blurred.
- `03-versioning-status.png` — versioning status; bucket name blurred.
- `04-historical-object-retrieval.png` — historical object retrieval; bucket and version identifiers blurred.
- `05-recovered-object-redacted.png` — recovered object metadata; flag value blurred.

## Public sharing note

The original screenshots contained a bucket name, object version IDs, an AWS account owner identifier, and the CTF flag. These values are obscured in the public evidence images. No AWS access key or secret access key is visible in the supplied screenshots. Keep any local `manifest.json` containing credentials out of GitHub.
