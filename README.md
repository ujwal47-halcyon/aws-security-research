# AWS Security Research

Notes from my AWS security learning and hands-on lab practice. This repository covers the basics first, then moves into AWS security controls and lab scenarios.

## Progress

### 1. Foundations

- Linux commands and file handling
- Networking fundamentals
- AWS account setup and IAM basics

### 2. Core AWS security

- IAM users, policies and permissions
- EC2 SSH hardening
- S3 bucket access and misconfiguration
- AWS Skill Builder exercises for IAM and S3
- Root-user protection and multi-factor authentication

### 3. Monitoring and threat modelling

- Introduction to AWS Security Hub
- Basic threat modelling for AWS environments
- Reviewing possible risks in cloud configurations

### 4. Hands-on security labs

- flaws.cloud exercises
- IAM privilege escalation scenarios
- Scenarios involving IAM, S3 and EC2 permissions

The original progress log used day numbers and lab numbers that were not always consistent. This order groups the work by topic and learning progression rather than treating those numbers as a reliable timeline.

## Lab write-up format

As I document each exercise, I aim to include:

1. **Objective:** What the lab is testing
2. **Setup:** The lab environment and prerequisites
3. **Steps:** What was done
4. **Result:** What actually happened
5. **Finding:** Why the result matters
6. **Fix:** How the risk could be reduced
7. **Verification:** How to check the change

Only include results and verification steps that were actually observed. If a lab is still in progress, mark it as such.

## Safety and costs

Use these exercises only in accounts and environments where testing is authorised. Check what resources a lab creates before deploying it, watch for AWS charges, and remove temporary resources when finished.

## About

I'm a BCA Cybersecurity and Digital Forensics student at REVA University, learning AWS cloud security. This repository is a work in progress.
