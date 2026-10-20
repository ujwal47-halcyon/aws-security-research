# Day 1: AWS Security Fundamentals

**Date:** 20 October 2026

## Theory

### Shared Responsibility Model

- AWS is responsible for security of the cloud, including the physical infrastructure and underlying services.
- Customers are responsible for security in the cloud, including IAM permissions, data access and guest OS patching on EC2.
- The exact split depends on the AWS service being used.

### IAM and least privilege

- IAM controls who can access AWS resources and what actions they can perform.
- Give identities only the permissions required for their task.
- Unneeded write or administrative permissions can allow accidental or unauthorised changes.
- Review policies and remove permissions that are no longer needed.

### Patching and vulnerability checks

- EC2 customers are generally responsible for patching the guest operating system.
- Amazon Inspector helps identify supported vulnerabilities and other security findings.
- AWS Systems Manager Patch Manager helps manage and apply operating system patches.
- Finding a vulnerability and installing a patch are different tasks.

## Practical lab

Continue with the [Day 1 IAM least-privilege lab](../labs/day-01-iam-least-privilege.md). It uses a small test policy and the IAM Policy Simulator.

## Revision checklist

- [ ] Explain the AWS Shared Responsibility Model.
- [ ] Give an example of excessive IAM permissions.
- [ ] Explain why least privilege matters.
- [ ] Distinguish vulnerability assessment from patching.
- [ ] Explain who patches the guest OS on an EC2 instance.

## Notes

This page covers the concepts. Record the actual steps and results in the linked lab page.
