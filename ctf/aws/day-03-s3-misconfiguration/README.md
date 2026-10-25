# Day 3: S3 Misconfiguration

**Date:** 25 October 2026  
**Status:** Investigation evidence captured  
**Region:** Not confirmed in the supplied screenshots  
**Service:** Amazon S3

## Objective
Investigate an S3 bucket policy that appears to allow public access, review the bucket's Block Public Access settings, and verify whether an object can be read without the intended permissions.

## Findings
- Listed S3 buckets and identified the challenge bucket `autoelite-app-media-3a8c09c1`.
- Retrieved the bucket policy. The policy statement used `"Principal": "*"` and allowed `s3:GetObject` and `s3:ListBucket` on the bucket and its objects.
- Checked the bucket's public access block configuration. `BlockPublicPolicy` and `RestrictPublicBuckets` were `false`, while `BlockPublicAcls` and `IgnorePublicAcls` were `true`.
- Retrieved `flag.txt` from the bucket.
- Attempted `aws iam list-users` and received `AccessDenied`, showing that the identity did not have that IAM enumeration permission.

## Security impact
A bucket policy granting read and list access to `Principal: "*"` can expose bucket contents to unauthenticated users if the policy is effective and public access is not blocked by other controls. The displayed settings do not block public bucket policies or restrict public buckets, so the configuration warrants remediation and validation.

## Recommended remediation
- Remove the public principal from the bucket policy unless public access is explicitly required.
- Grant access to specific IAM principals and only the necessary S3 actions.
- Enable all four S3 Block Public Access settings at the bucket level unless a documented business requirement says otherwise.
- Check account-level Block Public Access settings and any organization policies.
- Review CloudTrail data events, S3 server access logs if enabled, and access patterns for unexpected reads.
- Re-test access from an unauthenticated context after remediation.

## Evidence
See the redacted screenshots described in [evidence/README.md](evidence/README.md). The flag value, machine label, bucket identifiers, and account/user identifiers are redacted in the published evidence where visible.

## Cleanup status
The screenshots do not show teardown or a cleanup verification. Cleanup is not claimed as complete. Do not delete or modify any bucket unless it is confirmed to be a disposable lab resource owned by the investigator.

## Scope
This report records the supplied CTF screenshots and commands. It does not claim an independent live audit or prove that the bucket is still publicly accessible now.
