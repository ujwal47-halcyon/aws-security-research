# Day 2: Excessive IAM Permissions

## 🎯 Objective
Investigate a fictional developer identity with excessive AWS IAM permissions. Identify the over-privileged policy, demonstrate the risk using a purpose-built lab resource, retrieve the hidden flag, and propose a least-privilege correction.

## 📋 Scenario
**AutoElite Motors** hired a developer named `dev-intern` to manage only:
- A specific S3 bucket: `cloudsec-ctf-day02-assets-<suffix>` (read/write objects)
- A specific DynamoDB table: `cloudsec-ctf-day02-inventory-<suffix>` (read items)

However, the attached IAM policy grants far more access than required. You are the security analyst tasked with:
1. Discovering the `dev-intern` identity
2. Analyzing its attached policies
3. Identifying which permissions exceed the stated job requirements
4. Safely demonstrating the risk on a purpose-built lab resource
5. Retrieving the flag that proves the excessive access
6. Writing a least-privilege policy that matches only the stated requirements

## 🔑 What You'll Practice
- Verifying caller identity and account context with `aws sts get-caller-identity`
- Enumerating IAM users, roles, and policies with `aws iam list-users`, `aws iam list-policies`
- Reading policy documents with `aws iam get-policy`, `aws iam get-policy-version`
- Understanding policy effects: `Allow` vs `Deny`, resource scoping, condition keys
- Identifying excessive permissions: wildcards (`*`), overly broad actions, missing resource constraints
- Using a lab identity's credentials (simulated via `aws sts assume-role` or provided access keys) to demonstrate impact
- Writing least-privilege IAM policies with explicit resource ARNs and minimal action sets
- Validating policies with `aws iam simulate-principal-policy`

## 🚫 Rules of Engagement
| Rule | Description |
|------|-------------|
| **No Console** | Use only AWS CLI — no web console |
| **No Destructive Actions** | No `delete`, `terminate`, `remove`, `detach`, `revoke` on non-lab resources |
| **Lab Scope Only** | Only interact with resources tagged `Project=CloudSecurityCTF,Day=Day2` |
| **No Privilege Escalation** | Do not create new users, roles, policies, or access keys outside the lab setup |
| **No Real Credentials** | The lab creates a disposable IAM user; never use your real credentials for the challenge |
| **Cost Awareness** | Lab creates IAM-only resources (free) + 1 S3 bucket + 1 DynamoDB table (free-tier eligible) |

## 🧭 Investigation Path (Intended Discovery Flow)

### Step 1: Establish Your Identity & Account
```bash
aws sts get-caller-identity
```
**Questions:**
- What Account ID are you operating in?
- Is this your personal account or a lab account?
- What permissions does your current identity have?

### Step 2: Discover the Fictional Developer Identity
```bash
aws iam list-users --query 'Users[?contains(UserName, `dev-intern`)].{Name:UserName,Arn:Arn,CreateDate:CreateDate}' --output table
```
**Questions:**
- Does the `dev-intern` user exist?
- When was it created?
- What tags identify it as a lab resource?

### Step 3: Enumerate Attached Policies
```bash
# List managed policies attached to dev-intern
aws iam list-attached-user-policies --user-name dev-intern

# List inline policies embedded on dev-intern
aws iam list-user-policies --user-name dev-intern
```
**Questions:**
- How many policies are attached?
- Are they AWS-managed, customer-managed, or inline?
- Which policy looks suspicious?

### Step 4: Inspect the Suspicious Policy Document
```bash
# For a managed policy
aws iam get-policy --policy-arn <arn> --query 'Policy.DefaultVersionId' --output text
aws iam get-policy-version --policy-arn <arn> --version-id <vX> --query 'PolicyVersion.Document' --output json

# For an inline policy
aws iam get-user-policy --user-name dev-intern --policy-name <name> --query 'PolicyDocument' --output json
```
**Questions:**
- What actions (`Action`) does the policy allow?
- What resources (`Resource`) does it apply to? Wildcards (`*`) or specific ARNs?
- Are there condition keys (`Condition`) restricting usage?
- Which statements exceed "read/write S3 bucket X" and "read DynamoDB table Y"?

### Step 5: Identify Excessive Permissions
Document each excessive statement:
| Statement | Allowed Actions | Resource Scope | Why Excessive |
|-----------|----------------|----------------|---------------|
| Sid1      | s3:*           | *              | Full S3 admin on all buckets |
| Sid2      | dynamodb:*     | *              | Full DynamoDB admin on all tables |
| Sid3      | iam:*          | *              | Full IAM admin (privilege escalation) |
| ...       | ...            | ...            | ... |

### Step 6: Demonstrate Controlled Impact (Authorized Lab Resource Only)
The lab setup creates **one** S3 bucket and **one** DynamoDB table tagged for Day 2.
Using the `dev-intern` credentials (provided by setup), attempt to:
```bash
# List ALL buckets (excessive: s3:ListAllMyBuckets on *)
aws s3 ls

# Read the flag object from the lab bucket (authorized: s3:GetObject on lab bucket)
aws s3 cp s3://cloudsec-ctf-day02-assets-<suffix>/flag.txt -

# Scan ALL DynamoDB tables (excessive: dynamodb:ListTables on *)
aws dynamodb list-tables

# Read the flag item from the lab table (authorized: dynamodb:GetItem on lab table)
aws dynamodb get-item --table-name cloudsec-ctf-day02-inventory-<suffix> --key '{"pk":{"S":"flag"}}'
```
**Note:** Only the lab-tagged bucket and table are in scope. Do not access other resources.

### Step 7: Retrieve the Flag
The flag is stored in **both** the lab S3 bucket and the lab DynamoDB table.
You only need to retrieve it **once** via either authorized path.
Format: `FLAG{...}`

### Step 8: Propose Least-Privilege Remediation
Fill in `remediation.md` with:
1. The original excessive policy (redacted for brevity)
2. A corrected least-privilege policy matching **only** the stated job requirements
3. Explanation of each change and why it reduces risk
4. How you would validate the new policy before deployment (e.g., `iam:simulate-principal-policy`, testing in a staging account)

## 💡 Hints (Progressive Disclosure — Request One at a Time)

<details>
<summary><strong>Hint 1: Find the developer user</strong></summary>
Run <code>aws iam list-users</code> and look for a username containing <code>dev-intern</code>. The lab user is tagged with <code>Project=CloudSecurityCTF</code> and <code>Day=Day2</code>.
</details>

<details>
<summary><strong>Hint 2: Check inline policies first</strong></summary>
The excessive permissions are in an <strong>inline policy</strong> embedded directly on the <code>dev-intern</code> user. Use <code>aws iam list-user-policies --user-name dev-intern</code> to see its name, then <code>aws iam get-user-policy --user-name dev-intern --policy-name <name></code> to read it.
</details>

<details>
<summary><strong>Hint 3: Policy analysis - look for wildcards</strong></summary>
Excessive permissions typically use <code>"Action": "*"</code>, <code>"Resource": "*"</code>, or broad service wildcards like <code>"s3:*"</code> instead of specific actions like <code>"s3:GetObject"</code>, <code>"s3:PutObject"</code>. The job only needs <code>s3:GetObject</code>, <code>s3:PutObject</code>, <code>s3:ListBucket</code> on one bucket, and <code>dynamodb:GetItem</code>, <code>dynamodb:Query</code> on one table.
</details>

<details>
<summary><strong>Hint 4: The flag location</strong></summary>
The flag is stored in two places (redundancy for learning):
1. S3 object: <code>s3://cloudsec-ctf-day02-assets-<suffix>/flag.txt</code>
2. DynamoDB item: Table <code>cloudsec-ctf-day02-inventory-<suffix></code>, Key <code>{"pk": {"S": "flag"}}</code>
<br>
You only need to retrieve it from one. The excessive policy allows <code>s3:*</code> and <code>dynamodb:*</code> on <code>*</code> — which is how you can discover the bucket/table names.
</details>

<details>
<summary><strong>Hint 5: Using the dev-intern credentials</strong></summary>
The setup script outputs temporary credentials for <code>dev-intern</code> (AccessKeyId, SecretAccessKey, SessionToken). Export them as environment variables or use <code>aws configure --profile dev-intern</code> to switch contexts. Then run the discovery commands as that identity.
</details>

<details>
<summary><strong>Hint 6: Validate your remediation</strong></summary>
Use <code>aws iam simulate-principal-policy --policy-source-arn arn:aws:iam::<account-id>:user/dev-intern --action-names s3:GetObject s3:PutObject dynamodb:GetItem --resource-arns <lab-bucket-arn> <lab-table-arn></code> to verify the corrected policy allows only the required actions on the lab resources.
</details>

## ✅ Success Criteria
You have completed Day 2 when you:
1. ✅ Identified the `dev-intern` user and its excessive inline policy
2. ✅ Documented each excessive permission with justification
3. ✅ Retrieved the flag (`FLAG{...}`) via an authorized lab resource
4. ✅ Completed `remediation.md` with a correct least-privilege policy
5. ✅ Validated your remediation policy using the AWS CLI simulator

## 💰 Cost Note
This lab creates:
- 1 IAM user (`dev-intern-<suffix>`) — **Free**
- 1 Inline policy on that user — **Free**
- 1 S3 bucket (`cloudsec-ctf-day02-assets-<suffix>`) — **Free tier: 5 GB storage, 20k GET/2k PUT requests/month**
- 1 DynamoDB table (`cloudsec-ctf-day02-inventory-<suffix>`) — **Free tier: 25 GB storage, 25 WCU/RCU**
- No compute, NAT, load balancers, or public endpoints

**Estimated cost: $0.00/month** (well within AWS Free Tier)

## 🧹 Cleanup
When done, run:
```bash
./teardown.sh
```
This removes only the Day 2 challenge resources (IAM user, policy, S3 bucket, DynamoDB table, flag objects).

Verify with:
```bash
./verify-cleanup.sh
```