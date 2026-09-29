import os
import json
import secrets
import requests
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, flash, jsonify, Response

app = Flask(__name__)
app.secret_key = secrets.token_hex(16)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, "data")
PROGRESS_FILE = os.path.join(DATA_DIR, "progress.json")
os.makedirs(DATA_DIR, exist_ok=True)

# Simulated "Cloud" Environment State
CLOUD_STATE = {
    "buckets": {
        "user-data-1002": {
            "public": False,
            "objects": ["profile.jpg", "notes.txt"]
        },
        "aws-beginner-lab-public": {
            "public": True,
            "objects": ["welcome.pdf", "system_config.backup"]
        },
        "meridian-internal-vault": {
            "public": False,
            "objects": ["root_credentials.txt", "db_password.env"]
        }
    },
    "iam": {
        "roles": {
            "AppServerRole": {
                "id": "AROA1234567890EXAMPLE",
                "access_key": "AKIA1234567890LAB",
                "secret_key": "aws_lab_secret_key_v1",
                "token": "IQoJb3JpZ2luX2VjEOb//////////wE="
            }
        }
    }
}

CHALLENGES = [
    {
        "id": 1,
        "title": "Public Exposure",
        "skill": "S3 Recon",
        "hint": "Check if there are any publicly accessible S3 buckets. Maybe 'aws-beginner-lab-public'?",
        "flag": "AWS{s3_buckets_should_not_be_public}",
    },
    {
        "id": 2,
        "title": "Metadata Leak",
        "skill": "SSRF (IMDSv1)",
        "hint": "The 'External URL Checker' doesn't validate IPs. Try reaching 169.254.169.254.",
        "flag": "AWS{ssrf_to_imds_is_dangerous}",
    },
    {
        "id": 3,
        "title": "Identity Theft",
        "skill": "IAM Credentials",
        "hint": "Extract the temporary credentials from the metadata service. What's the secret key?",
        "flag": "AWS{extracted_iam_creds_successfully}",
    },
    {
        "id": 4,
        "title": "Vault Breach",
        "skill": "Privilege Escalation",
        "hint": "Use the stolen credentials to access the internal vault bucket.",
        "flag": "AWS{vault_compromised_via_iam_role}",
    },
    {
        "id": 5,
        "title": "Root Takeover",
        "skill": "Hardcoded Secrets",
        "hint": "Check the objects inside the internal vault for root credentials.",
        "flag": "AWS{you_are_now_the_cloud_admin}",
    },
]

def load_progress():
    if os.path.exists(PROGRESS_FILE):
        with open(PROGRESS_FILE, 'r') as f:
            return json.load(f)
    return {"solved_ids": []}

def save_progress(progress):
    with open(PROGRESS_FILE, 'w') as f:
        json.dump(progress, f)

@app.route('/')
def index():
    progress = load_progress()
    return render_template('index.html',
                           challenges=CHALLENGES,
                           solved_ids=progress["solved_ids"],
                           solved_count=len(progress["solved_ids"]),
                           total=len(CHALLENGES))

@app.route('/challenges')
def challenges():
    progress = load_progress()
    return render_template('challenges.html',
                           challenges=CHALLENGES,
                           solved_ids=progress["solved_ids"],
                           solved_count=len(progress["solved_ids"]),
                           total=len(CHALLENGES))

@app.route('/flags', methods=['GET', 'POST'])
def flags():
    progress = load_progress()
    message = None
    status = "info"

    if request.method == 'POST':
        submitted_flag = request.form.get('flag', '').strip()
        found = False
        for c in CHALLENGES:
            if submitted_flag == c["flag"]:
                if c["id"] not in progress["solved_ids"]:
                    progress["solved_ids"].append(c["id"])
                    save_progress(progress)
                    message = f"Correct! Flag {c['id']} solved."
                    status = "success"
                else:
                    message = "You already solved this one!"
                found = True
                break
        if not found:
            message = "Invalid flag. Keep hunting!"
            status = "danger"

    return render_template('flags.html',
                           challenges=CHALLENGES,
                           solved_ids=progress["solved_ids"],
                           solved_count=len(progress["solved_ids"]),
                           total=len(CHALLENGES),
                           message=message,
                           status=status)

@app.route('/reset', methods=['POST'])
def reset():
    save_progress({"solved_ids": []})
    return redirect(url_for('flags'))

# --- VULNERABLE APP ROUTES ---

@app.route('/app')
def app_home():
    return render_template('app/home.html')

@app.route('/app/checker', methods=['GET', 'POST'])
def url_checker():
    # SSRF VULNERABILITY: No validation on URL
    url = request.form.get('url') if request.method == 'POST' else request.args.get('url')
    result = None
    if url:
        try:
            if "169.254.169.254" in url:
                # Simulate AWS Metadata Service
                path = url.split("169.254.169.254")[-1]
                if path.endswith("iam/security-credentials/AppServerRole"):
                    result = json.dumps(CLOUD_STATE["iam"]["roles"]["AppServerRole"], indent=2)
                    # Flag 2 is for reaching the service
                    # Flag 3 is for seeing the creds
                elif path.endswith("latest/meta-data/"):
                    result = "iam/\ninstance-id\nlocal-hostname"
                else:
                    result = "Available paths: latest/meta-data/"
            else:
                # Real external request (or fake error)
                response = requests.get(url, timeout=3)
                result = response.text[:500]
        except Exception as e:
            result = f"Error: {str(e)}"

    return render_template('app/checker.html', result=result, url=url)

@app.route('/app/storage')
def storage_browser():
    bucket_name = request.args.get('bucket')
    if not bucket_name:
        return render_template('app/storage.html', buckets=CLOUD_STATE["buckets"])

    bucket = CLOUD_STATE["buckets"].get(bucket_name)
    if not bucket:
        return "Bucket not found", 404

    # Flag 1: Found the public bucket backup file
    if bucket_name == "aws-beginner-lab-public":
        # Simulate seeing the flag inside a file content if they "view" it
        pass

    # IAM check simulation for Flag 4
    token = request.headers.get('X-Amz-Security-Token')
    is_authorized = bucket["public"] or (token == CLOUD_STATE["iam"]["roles"]["AppServerRole"]["token"])

    if not is_authorized:
        return "Access Denied: Missing or invalid IAM token", 403

    return render_template('app/bucket_view.html', bucket_name=bucket_name, objects=bucket["objects"])

@app.route('/app/storage/view')
def view_object():
    bucket_name = request.args.get('bucket')
    obj_name = request.args.get('object')
    token = request.headers.get('X-Amz-Security-Token')

    bucket = CLOUD_STATE["buckets"].get(bucket_name)
    if not bucket: return "Not found", 404

    is_authorized = bucket["public"] or (token == CLOUD_STATE["iam"]["roles"]["AppServerRole"]["token"])
    if not is_authorized: return "Access Denied", 403

    # Flag logic
    content = f"Binary content of {obj_name}..."
    if bucket_name == "aws-beginner-lab-public" and obj_name == "system_config.backup":
        content = "DB_HOST=prod-db.internal\nFLAG1=AWS{s3_buckets_should_not_be_public}\n# TODO: Move to secret manager"

    if bucket_name == "meridian-internal-vault":
        if obj_name == "root_credentials.txt":
            content = "USER: cloud-admin\nPASS: SuperSecretCloudPass2026\nFLAG5=AWS{you_are_now_the_cloud_admin}"
        elif obj_name == "db_password.env":
            content = "DB_PASS=meridian_prod_8822\nFLAG4=AWS{vault_compromised_via_iam_role}"

    return Response(content, mimetype='text/plain')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
