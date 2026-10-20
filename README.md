# AWS security notes

My notes and practice labs from learning AWS security, plus some Linux and networking basics. The labs run on my own machine or in my own AWS account.

## Notes

- `Cloud_Security/AWS/theory` and `learning-log`: Day 1 notes on AWS security fundamentals
- `Cloud_Security/AWS/labs`: Day 1 IAM least-privilege lab
- `Cloud_Security/Networks/day2-networking-answers.md`: answers for the Day 2 networking lab

## Practice labs

| Folder | What it covers |
|---|---|
| `AWS/aws-beginner-lab` | Simulated AWS environment: public S3 buckets, SSRF to the instance metadata service (IMDSv1), IAM credential theft |
| `AWS/aws-iam-lab` | SSRF to the metadata service to take over an EC2 role |
| `AWS/cloud-iam-lab` | IAM privilege escalation through `iam:PassRole` and similar misconfigurations, with a remediation guide |
| `AWS/aws-ssh-lab` | Finding, exploiting and fixing insecure SSH settings on EC2 |
| `AWS/s3-misconfig-lab` | S3 bucket misconfigurations, with setup, exploit and cleanup scripts |
| `AWS/IAM/Lab/iam-privesc-ctf` | IAM privilege escalation using the AWS CLI, with setup and cleanup scripts |
| `AWS/cloudsec-day2-ctf` | Account security basics: free tier, root MFA, billing alarm, IAM admin user |
| `AWS/cloudsec-day3-ctf` | SSRF to an S3 misconfiguration leak |
| `Linux/linux-ctf-lab` | A 10-level Linux CTF |
| `Networks/day2-ctf-lab` | 10 networking recon and concept challenges |

`Cloud_Security/Scripts` holds the small shell scripts used by some of the labs.

## Things to know

- Several labs are web apps that are vulnerable on purpose. Run them only on localhost.
- `s3-misconfig-lab` and `iam-privesc-ctf` create real AWS resources. Run their cleanup scripts and keep an eye on billing.
