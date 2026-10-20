# Day 1 Lab: IAM Least Privilege

**Related theory:** [Day 1: AWS Security Fundamentals](../learning-log/day-01-aws-security-fundamentals.md)

## What this lab does

Create a small customer-managed IAM policy that allows listing one example S3 bucket but does not grant write or delete access. Use the IAM Policy Simulator to check the intended permissions.

This lab creates an IAM policy only. It does not create an S3 bucket or upload data.

## What you need

- An AWS account you control
- Permission to create and delete customer-managed IAM policies
- Access to the IAM console

## Setup

1. Open the [IAM console](https://console.aws.amazon.com/iam/).
2. Go to **Policies** and choose **Create policy**.
3. Select the JSON editor and use the policy below.
4. Replace `YOUR-TEST-BUCKET-NAME` with a bucket name you control. If you only want to review the policy, you can leave the example name as-is.
5. Name the policy `Day1S3ListOnlyLab` and create it.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListOneBucket",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::YOUR-TEST-BUCKET-NAME"
    }
  ]
}
```

This policy grants only the `s3:ListBucket` action on the named bucket. It does not grant permission to read, upload or delete objects. Creating the policy alone does not grant it to a user or role.

## Test it

1. Open the [IAM Policy Simulator](https://policysim.aws.amazon.com/).
2. Select the policy or test it in the context of an identity to which it is attached.
3. Test `s3:ListBucket` against the matching bucket ARN.
4. Test an action that is not allowed by this policy, such as `s3:DeleteObject`.
5. Record what the simulator reports. Results can depend on the selected identity, other policies and resource settings, so only report what you actually observed.

## Cleanup

1. If you attached the policy to any user, group or role, detach it first.
2. Open IAM → **Policies**.
3. Select `Day1S3ListOnlyLab` and delete it.
4. Confirm it no longer appears in the policy list.

No S3 bucket was created by this lab, so there is no bucket to delete.

## What to note down

- Which action was allowed?
- Which action was not allowed by this policy?
- Why is granting only the required action safer than broad S3 access?
