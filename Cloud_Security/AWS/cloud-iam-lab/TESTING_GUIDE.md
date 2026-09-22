# Cloud IAM Privilege Escalation Lab - Testing Guide

## Lab Overview
This lab simulates a common AWS IAM misconfiguration: an overly permissive `iam:PassRole` permission that allows a lower-privileged user to assume a role with administrative privileges, leading to access to sensitive data stored in Secrets Manager.

## Learning Objectives
- Understand the risks of excessive `iam:PassRole` permissions.
- Learn how to identify and exploit IAM privilege escalation paths.
- Practice techniques for detecting and remediating IAM misconfigurations.

## Lab Setup
1.  Navigate to the lab directory:
    ```bash
    cd "C:\Users\Ujwal\Downloads\cloud Security\cloud-iam-lab"
    ```
2.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
3.  Start the Flask application:
    ```bash
    python app.py
    ```
4.  Open a web browser and go to `http://localhost:5000`.

## Initial Access
- Use the default developer credentials:
    - **Username:** `developer`
    - **Password:** `devpassword123`

## Exploitation Steps

### Step 1: Recon - Understand Your Initial Permissions
1.  After logging in, click the "Refresh Identity" button in the Identity & Access panel.
2.  Observe the output. You should see something like:
    ```json
    {
      "user": "developer",
      "role": "DeveloperRole",
      "permissions": [
        "ec2:DescribeInstances",
        "s3:ListBucket",
        "iam:PassRole"
      ]
    }
    ```
3.  Note that you have `iam:PassRole` but no direct administrative permissions.

### Step 2: Enumerate Accessible Resources
1.  Click on the "EC2" card to expand it, then click "List Instances".
2.  Observe the output. You should see an EC2 instance with an IAM Instance Profile:
    ```json
    {
      "instances": [
        {
          "id": "i-0abcd1234efgh5678",
          "name": "Production-App-Server",
          "state": "running",
          "iam_instance_profile": "EC2AdminRole"
        }
      ]
    }
    ```
3.  Click on the "S3" card and list buckets to confirm your read-only access there.

### Step 3: Identify the Privilege Escalation Vector
- The key finding is that the EC2 instance `i-0abcd1234efgh5678` has an IAM Instance Profile of `EC2AdminRole`.
- Your developer role has the permission `iam:PassRole`.
- In AWS, `iam:PassRole` allows you to attach a role to an EC2 instance (or Lambda function, etc.). If you can pass a role with administrative privileges, you can effectively gain those privileges.
- In this simulator, we model this as the ability to **assume** the `EC2AdminRole` directly via the STS AssumeRole API (a common simplification for labs).

### Step 4: Exploit - Assume the EC2AdminRole
1.  Click on the "IAM" card to expand it.
2.  In the "Assume Role (STS)" section, you will see a pre-filled Role ARN: `arn:aws:iam::123456789012:role/EC2AdminRole`.
3.  Click the "Assume Role" button.
4.  Observe the output. You should see a success message and your role updated to `EC2AdminRole` (or similar).
5.  Click "Refresh Identity" again to confirm your new permissions. You should now see:
    ```json
    {
      "user": "developer",
      "role": "EC2AdminRole",
      "permissions": [
        "ec2:*",
        "ssm:*"
      ]
      // or potentially ["*"] if the role is treated as admin
    }
    ```

### Step 5: Access the Sensitive Data (Secrets Manager)
1.  Now that you have assumed the `EC2AdminRole`, navigate to the "Secrets Manager" panel at the bottom.
2.  The Secret ID is pre-filled to `prod/database/password`. Click "Get Secret Value".
3.  Observe the output. You should retrieve the first flag:
    ```json
    {
      "secret_id": "prod/database/password",
      "secret_value": "DB_SECRET{aws_rds_root_pass_9981}"
    }
    ```
4.  Change the Secret ID to `prod/api/master_key` and click "Get Secret Value" again to retrieve the second flag:
    ```json
    {
      "secret_id": "prod/api/master_key",
      "secret_value": "API_SECRET{stripe_live_key_9999a}"
    }
    ```

## Alternative Exploitation Paths (Discussion)
- In a real AWS environment, after assuming `EC2AdminRole`, you could:
    - Use the EC2 API to create a new instance with the `EC2AdminRole` attached and then use SSM to execute commands on it.
    - Directly use the Secrets Manager API (as we simulated) or other privileged EC2/SSM actions.
- The lab demonstrates that `iam:PassRole` is a powerful privilege that can often lead to full account compromise if not properly restricted.

## Cleanup
- To reset the lab, simply stop the Flask application (Ctrl+C) and restart it. The state is reloaded from `data/cloud_state.json` on each start, so any session changes are not persisted.

## Reference
- AWS IAM Documentation on [PassRole](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_iam-constraints.html#condition-keys-passrole)
- Common IAM Privilege Escalation Paths: [Rhinosecuritylabs - IAM Privilege Escalation](https://rhinosecuritylabs.com/aws/aws-privilege-escalation-methods-mitigation-part-1/)