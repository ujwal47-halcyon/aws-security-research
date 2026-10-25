# Day 3 Evidence: S3 Misconfiguration

**Date:** 25 October 2026

## Evidence files

- `01-s3-bucket-inventory.png` — S3 bucket listing from the AWS CLI.
- `02-public-bucket-policy.png` — bucket policy showing a wildcard principal with `s3:GetObject` and `s3:ListBucket`.
- `03-public-access-block.png` — bucket-level Block Public Access settings.
- `04-flag-retrieval.png` — successful retrieval of the lab's `flag.txt`; the flag value is redacted.
- `05-iam-access-denied.png` — IAM `ListUsers` request denied for the challenge identity; account ID and ARN are redacted.
- `report.png` — workflow-board screenshot for the Day 3 investigation.

## Redaction notes

The challenge flag, AWS account identifier, local machine label, and bucket names were blurred in the prepared evidence images. No password, access key secret, or session token was visible in the screenshots.

## What the screenshots support

- A bucket policy was configured with `Principal: "*"` and allowed `s3:GetObject` and `s3:ListBucket`.
- The displayed bucket Block Public Access configuration had `BlockPublicPolicy: false` and `RestrictPublicBuckets: false`, while `BlockPublicAcls` and `IgnorePublicAcls` were true.
- The challenge flag object was retrieved successfully using the AWS CLI.
- The challenge identity's `iam:ListUsers` call returned `AccessDenied`.

## Limitation

The screenshots show a public or broad-read policy configuration, but do not by themselves prove that an unauthenticated external client can successfully read the object. Confirming that requires a controlled anonymous request in the authorized lab environment.

## Cleanup

Cleanup is not marked complete because the supplied screenshots do not show teardown or cleanup verification.
