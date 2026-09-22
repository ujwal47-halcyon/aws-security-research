# Cloud IAM Security - Remediation & Defense Guide

## Overview
Privilege escalation via IAM misconfigurations (such as overly permissive `iam:PassRole`) is one of the most common vectors for unauthorized access in AWS environments. This guide outlines defensive measures to secure your AWS account against these attacks.

---

## 1. Securing `iam:PassRole`

The root cause of the vulnerability demonstrated in the lab is an unrestricted `iam:PassRole` permission combined with the ability to pass a highly privileged role to a service.

### ❌ Vulnerable Policy Example
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "*"
    }
  ]
}
```
*Why it's dangerous:* This allows the principal to pass **any** role in the AWS account to any supported AWS service.

### ✅ Secure Policy Example (Scoped Resources & Conditions)
1.  **Scope down the Resource:** Specify exact roles that can be passed rather than `*`.
2.  **Use Condition Keys:** Use `iam:PassedToService` to restrict which AWS services can receive the role.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::123456789012:role/StandardAppRole",
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": "ec2.amazonaws.com"
        }
      }
    }
  ]
}
```

---

## 2. Implementing the Principle of Least Privilege

- **Granular Permissions:** Avoid wildcard actions (`*`) and wildcard resources (`*`) wherever possible.
- **Regular Audits:** Use tools like AWS IAM Access Analyzer and AWS Trusted Advisor to review identity-based and resource-based policies.

---

## 3. Monitoring & Detection (CloudSecurity Operations)

- **AWS CloudTrail:** Enable CloudTrail across all regions and log management/data events.
- **Amazon GuardDuty:** Monitor for suspicious API calls, such as unexpected `AssumeRole`, `CreateAccessKey`, or unauthorized service access.
- **SIEM / Logging:** Set up alerts for users executing `PassRole` who do not normally require that capability.

---

## 4. Remediation Checklist for Developers & Admins

- [ ] Review all IAM users, roles, and groups with `iam:PassRole`, `iam:CreateAccessKey`, or `iam:UpdateAssumeRolePolicy`.
- [ ] Ensure that sensitive data (Secrets Manager, Parameter Store, S3 buckets) are protected by resource-based policies that explicitly deny access from unapproved roles.
- [ ] Enforce Multi-Factor Authentication (MFA) for all administrative and CLI access.
- [ ] Use AWS Organizations Service Control Policies (SCPs) to establish account-level guardrails.