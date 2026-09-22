# Cloud IAM & Privilege Escalation Lab - AutoElite Cloud Security CTF

Welcome to your first AWS IAM and Cloud Security CTF lab! This lab has been created and stored in your **Downloads/cloud Security/cloud-iam-lab** directory, adhering to your cloud security lab storage convention.

## Lab Architecture & Scenario

You are tasked with auditing a simulated cloud environment where a developer account (`developer`) has been compromised or misused. Your goal is to find how an attacker can leverage IAM misconfigurations to escalate privileges from a standard developer role to an administrative role (`EC2AdminRole`) and exfiltrate sensitive secrets from **AWS Secrets Manager**.

### Key Vulnerabilities Simulated:
1. **Over-Permissive `iam:PassRole`**: The developer role possesses `iam:PassRole` without resource scoping or condition checks.
2. **Instance Profile Misconfiguration**: An EC2 instance in the environment is associated with an administrative role (`EC2AdminRole`).
3. **Privilege Escalation via Role Assumption**: By leveraging the `PassRole` / `AssumeRole` capability, the user elevates their permissions to full EC2/SSM control.
4. **Data Exfiltration**: Access to AWS Secrets Manager (`prod/database/password`, `prod/api/master_key`) containing CTF flags.

---

## Getting Started

### 1. File Location
All lab files are located at:
`C:\Users\Ujwal\Downloads\cloud Security\cloud-iam-lab\`

### 2. Running the Lab
Open your terminal (PowerShell or Bash) and run:

```powershell
cd "C:\Users\Ujwal\Downloads\cloud Security\cloud-iam-lab"
pip install -r requirements.txt
python app.py
```

Then open your browser and navigate to:
`http://localhost:5000`

### 3. Credentials
- **Username:** `developer`
- **Password:** `devpassword123`

---

## Walkthrough & Documentation

- **Exploitation Guide:** `C:\Users\Ujwal\Downloads\cloud Security\cloud-iam-lab\TESTING_GUIDE.md`
  - Step-by-step instructions on how to perform the recon, identify the flaw, escalate privileges, and capture the flags.
- **Remediation Guide:** `C:\Users\Ujwal\Downloads\cloud Security\cloud-iam-lab\REMEDIATION_GUIDE.md`
  - Explains the security concepts behind the flaw (Principle of Least Privilege, scoping `iam:PassRole` with `iam:PassedToService` conditions, and monitoring with CloudTrail/GuardDuty).

---

### Flags to Capture:
1. `FLAG{aws_iam_passrole_ec2_ssm_privesc_2026}` (Role assumption milestone)
2. `DB_SECRET{aws_rds_root_pass_9981}` (Secrets Manager database password)
3. `API_SECRET{stripe_live_key_9999a}` (Secrets Manager master API key)
