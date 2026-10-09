# Day 3 Cloud Security CTF — SSRF to S3 Misconfiguration Leak

Welcome to your first intermediate-level hands-on laboratory! 

In today's CTF, you will learn how an attacker bridges application-level flaws (SSRF) to exploit cloud infrastructure keys (AWS IAM/IMDS) and retrieve sensitive cloud-hosted assets (AWS S3).

## Vulnerability Overview

1. **Server-Side Request Forgery (SSRF)**: Occurs when a backend web application fetches a URL supplied by a user without proper validation.
2. **Instance Metadata Service (IMDS)**: Cloud instances (like AWS EC2) run a metadata service at `http://169.254.169.254/` containing configuration details, identity, and temporary AWS IAM security keys assigned to that virtual machine.
3. **AWS S3 Misconfiguration**: Private files kept in secure S3 storage can be exfiltrated if the IAM credentials leaked via SSRF have overly permissive read rights on confidential S3 buckets.

## How to Start the Lab

1. Ensure Flask is installed:
   ```bash
   pip install flask
   ```

2. Run the application from your terminal:
   ```bash
   python app.py
   ```

3. Access the web interface at `http://localhost:5001` in your browser.

## Step-by-Step Exercise Guide

### Step 1: Identify and Probe the SSRF Endpoint
On the web page, use the **Fetch Status Web Tool** to test standard domains, like `https://google.com`.
Then, probe the internal metadata range:
- Put `http://169.254.169.254/latest/` in the tool input and press **Send Request**.
- You will see the directory structure of the cloud instance's metadata returned.

### Step 2: Traverse Metadata to Exfiltrate IAM Keys
Travel down the metadata path:
1. Fetch `http://169.254.169.254/latest/meta-data/` to discover what endpoints exist.
2. Fetch `http://169.254.169.254/latest/meta-data/iam/security-credentials/` to find the exact name of the IAM role attached to the EC2 host.
3. Fetch `http://169.254.169.254/latest/meta-data/iam/security-credentials/<role-name>` to leak the active session keys (`AccessKeyId`, `SecretAccessKey`, `Token`).

### Step 3: Configure your Terminal Environment
Paste the exfiltrated credentials (`AccessKeyId` and `SecretAccessKey`) into the configuration boxes in the **AWS CLI Terminal Simulator** (on the right side of the page).

### Step 4: Audit & Exfiltrate S3 Buckets
Now, simulate a real AWS penetration test inside the terminal simulator widget:
1. List all active buckets:
   ```bash
   aws s3 ls
   ```
2. One of the buckets is confidential. List its items to see what files are kept inside:
   ```bash
   aws s3 ls s3://<bucket-name>
   ```
3. Retrieve the secret flag file! Copy it to your local simulated folder to view the flag contents:
   ```bash
   aws s3 cp s3://<bucket-name>/flag.txt flag.txt
   ```

---

## 📝 Deliverables / What to Submit Today

Once you have successfully extracted the flag, write up your report inside a file: `cloudsec-day3-ctf/answers.txt`. Include:

1. **The Secret Flag:** Put the exact text of the flag.
2. **Vulnerability Analysis:**
   - In your own words, why did the SSRF vulnerability allow access to `169.254.169.254`?
   - How does AWS protect against IMDS credentials abuse in the real world? (Hint: Research **AWS IMDSv2** vs **IMDSv1**).
3. **Remediation Plan:**
   - How would you secure the Flask status checking code to prevent SSRF?
   - What IAM policy changes should be made to prevent the stolen credentials from listing confidential buckets?

Good luck, Engineer! Let's secure the cloud. 🚀
Co-Authored-By: Claude <noreply@anthropic.com>
🤖 Generated with [Claude Code](https://claude.com/claude-code)
