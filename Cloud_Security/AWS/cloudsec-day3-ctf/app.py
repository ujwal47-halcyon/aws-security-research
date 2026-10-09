import os
import json
import urllib.parse
import re
from flask import Flask, render_template, request, jsonify, redirect, url_for, session

app = Flask(__name__)
app.secret_key = os.urandom(24)

# Mocked AWS Environment State
MOCK_METADATA = {
    "iam": {
        "security-credentials": {
            "logistics-s3-read-role": {
                "Code": "Success",
                "LastUpdated": "2026-08-20T12:00:00Z",
                "Type": "AWS-HMAC-SHA256",
                "AccessKeyId": "ASIA_FLAG_SSRF_MASTER_KEYS_2026",
                "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
                "Token": "IQoJb3JpZ2luX2VjEAMaCXVzLWVhc3QtMSJIMEYCIQDbq17pI3lV2vOun3H340b+Xq7A9...[TRUNCATED SESSION TOKEN]...===",
                "Expiration": "2026-08-21T00:00:00Z"
            }
        }
    },
    "instance-id": "i-09ab7c3fde492a881",
    "local-ipv4": "10.0.1.15",
    "public-ipv4": "54.210.32.18"
}

MOCK_S3_BUCKETS = {
    "global-logistics-public-assets": [
        {"name": "logo.png", "size": "15 KB", "public": True, "content": "[Binary PNG Data]"},
        {"name": "index.css", "size": "8 KB", "public": True, "content": "/* Style definitions */"}
    ],
    "logistics-confidential-backups": [
        {"name": "db_backup_20260815.sql", "size": "142 MB", "public": False, "content": "[SQL Dump - Encrpyted]"},
        {"name": "flag.txt", "size": "45 bytes", "public": False, "content": "FLAG{SSRF_AND_S3_MISCONFIG_CHAMPION_2026}"},
        {"name": "aws_architecture_threat_model.pdf", "size": "1.2 MB", "public": False, "content": "[PDF Design Document]"}
    ]
}

# --- MIDDLEWARE & MOCKS ---
def mock_fetch_url(url):
    """Simulates a network fetch, including loopback and IMDS ranges."""
    parsed = urllib.parse.urlparse(url)
    hostname = parsed.hostname or ""
    path = parsed.path.strip("/")

    # Standardize loopback / link-local addresses
    if hostname == "169.254.169.254":
        # IMDS endpoint simulation
        if not path:
            return "latest/"
        if path == "latest":
            return "meta-data/"
        if path == "latest/meta-data":
            return "iam/\ninstance-id\nlocal-ipv4\npublic-ipv4"
        if path == "latest/meta-data/iam":
            return "security-credentials/"
        if path == "latest/meta-data/iam/security-credentials":
            return "logistics-s3-read-role"
        if path == "latest/meta-data/iam/security-credentials/logistics-s3-read-role":
            return json.dumps(MOCK_METADATA["iam"]["security-credentials"]["logistics-s3-read-role"], indent=4)
        return "404 Not Found"

    elif hostname in ["localhost", "127.0.0.1"]:
        return "Local administrative portal. Access restricted to internal network devices."

    elif "google.com" in hostname:
        return "Google Search Portal Home Page"

    return f"Failed to resolve host: {hostname} or request timed out. Connection refused."


# --- ROUTES ---
@app.route("/")
def index():
    return render_template("index.html")

@app.route("/admin")
def admin_portal():
    """Simulated internal admin area - requires logged-in state or credentials"""
    return render_template("admin.html")

@app.route("/api/fetch", methods=["POST"])
def fetch_api():
    """Vulnerable endpoint allowing SSRF"""
    data = request.get_json() or {}
    target_url = data.get("url", "")

    if not target_url:
        return jsonify({"error": "Missing parameter 'url'"}), 400

    try:
        # Perform Simulated URL Fetch
        fetched_content = mock_fetch_url(target_url)
        return jsonify({
            "status": "success",
            "url": target_url,
            "response": fetched_content
        })
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

# AWS CLI Simulator Route
@app.route("/api/aws-cli", methods=["POST"])
def aws_cli():
    """Simulates basic AWS CLI commands using leaked credentials"""
    data = request.get_json() or {}
    command = data.get("command", "").strip()
    aws_access_key = data.get("aws_access_key_id", "").strip()
    aws_secret_key = data.get("aws_secret_access_key", "").strip()

    if not command:
        return jsonify({"error": "No command provided"}), 400

    # Check credentials
    correct_access = MOCK_METADATA["iam"]["security-credentials"]["logistics-s3-read-role"]["AccessKeyId"]
    correct_secret = MOCK_METADATA["iam"]["security-credentials"]["logistics-s3-read-role"]["SecretAccessKey"]

    if aws_access_key != correct_access or aws_secret_key != correct_secret:
        return jsonify({
            "output": "An error occurred (SignatureDoesNotMatch) when calling the operational AWS API: The request signature we calculated does not match the signature you provided. Check your AWS Secret Access Key."
        })

    # Standardize command inputs
    parts = re.split(r'\s+', command)
    if parts[0] != "aws":
        return jsonify({"output": f"bash: {parts[0]}: command not found"})

    if len(parts) < 2:
        return jsonify({"output": "usage: aws [options] <command> <subcommand> [parameters]"})

    service = parts[1]
    if service != "s3":
        return jsonify({"output": f"Command 'aws {service}' not implemented in this simulator. Focus on S3!"})

    if len(parts) < 3:
        return jsonify({"output": "usage: aws s3 <subcommand> [parameters] (implemented: ls, cp)"})

    subcommand = parts[2]

    if subcommand == "ls":
        # Check if listing all buckets or specific bucket
        if len(parts) == 3:
            # list all buckets
            buckets_output = "\n".join([f"2026-08-15 14:10:24 s3://{b}" for b in MOCK_S3_BUCKETS.keys()])
            return jsonify({"output": buckets_output})
        else:
            # list files in a bucket
            bucket_url = parts[3]
            parsed_bucket = bucket_url.replace("s3://", "").strip("/")
            if parsed_bucket in MOCK_S3_BUCKETS:
                files_output = "\n".join([
                    f"2026-08-16 09:12:43 {f['size']:>8} {f['name']}" for f in MOCK_S3_BUCKETS[parsed_bucket]
                ])
                return jsonify({"output": files_output})
            else:
                return jsonify({"output": "An error occurred (NoSuchBucket) when calling the ListObjectsV2 operation: The specified bucket does not exist."})

    elif subcommand == "cp":
        # Copy a file
        if len(parts) < 5:
            return jsonify({"output": "usage: aws s3 cp s3://bucket-name/filename <local_destination>"})

        src = parts[3]
        dest = parts[4]

        if not src.startswith("s3://"):
            return jsonify({"output": "Error: Source must be an s3:// URL inside this simulation."})

        src_path = src.replace("s3://", "").split("/", 1)
        if len(src_path) < 2:
            return jsonify({"output": "Error: Specify full path, e.g., s3://bucket-name/file.txt"})

        bucket_name, file_name = src_path[0], src_path[1]

        if bucket_name not in MOCK_S3_BUCKETS:
            return jsonify({"output": "An error occurred (NoSuchBucket) when calling the GetObject operation."})

        bucket_files = MOCK_S3_BUCKETS[bucket_name]
        target_file = next((f for f in bucket_files if f["name"] == file_name), None)

        if not target_file:
            return jsonify({"output": "An error occurred (NoSuchKey) when calling the GetObject operation: The specified key does not exist."})

        return jsonify({
            "output": f"download: s3://{bucket_name}/{file_name} to {dest}\n\n[FILE CONTENTS OF {file_name}]:\n{target_file['content']}"
        })

    return jsonify({"output": f"Subcommand '{subcommand}' is not supported in this lab."})

if __name__ == "__main__":
    print("====================================================")
    print("🔥 Starting Day 3 Cloud Security CTF Lab server!")
    print("📍 URL: http://localhost:5001")
    print("====================================================")
    app.run(host="0.0.0.0", port=5001, debug=True)
