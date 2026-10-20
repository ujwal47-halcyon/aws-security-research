# AWS Security Research

Notes from my AWS security learning and hands-on lab practice. The material is arranged from basic system and networking knowledge through core AWS controls and security labs.

## Repository layout

1. [Linux](Cloud_Security/Linux/) — commands and file handling
2. [Networks](Cloud_Security/Networks/) — networking fundamentals
3. [AWS](Cloud_Security/AWS/) — AWS concepts and security labs
4. [Scripts](Cloud_Security/Scripts/) — related scripts and small utilities

## Day-by-day notes and labs

- [Day 1 theory: AWS Security Fundamentals](Cloud_Security/AWS/learning-log/day-01-aws-security-fundamentals.md)
- [AWS labs index](Cloud_Security/AWS/labs/README.md)

Theory pages cover the concepts. Lab pages keep the practical setup, test and cleanup steps separate.

## Learning progression

### 1. Foundations

- Linux commands and file handling
- Networking fundamentals
- AWS account setup and IAM basics

### 2. Core AWS security

- IAM users, policies and permissions
- EC2 SSH hardening
- S3 access controls and misconfiguration
- AWS Skill Builder exercises for IAM and S3
- Root-user protection and multi-factor authentication

### 3. Monitoring and threat modelling

- Introduction to AWS Security Hub
- Basic threat modelling for AWS environments
- Reviewing risks in cloud configurations

### 4. Hands-on labs

- flaws.cloud exercises
- IAM privilege escalation scenarios
- Scenarios involving IAM, S3 and EC2 permissions

The old progress log used day numbers and lab numbers that were not always consistent. This README groups the material by topic and learning order instead of treating those numbers as an exact timeline.

## Lab notes

For each exercise, record the details that apply:

1. **Objective:** What the lab is testing
2. **Setup:** Environment and prerequisites
3. **Steps:** What was done
4. **Result:** What actually happened
5. **Finding:** Why the result matters
6. **Remediation:** How the risk could be reduced
7. **Verification:** How to check the change

Only include results and verification steps that were actually observed. Mark unfinished exercises as in progress.

## Safety and costs

Use these exercises only in accounts and environments where testing is authorised. Check which resources a lab creates before deploying it, watch for AWS charges, and remove temporary resources when finished.

## About

I'm a BCA Cybersecurity and Digital Forensics student at REVA University, learning AWS cloud security. This repository is a work in progress.
