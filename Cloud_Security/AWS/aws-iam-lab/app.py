from flask import Flask, request, jsonify, render_template
import requests
import json
import os

app = Flask(__name__)

# Mock Data
DATA = {
    'role_credentials': {
        'AccessKeyId': 'EXAMPLE_MOCK_ACCESS_KEY_NOT_REAL',
        'SecretAccessKey': 'EXAMPLE_MOCK_SECRET_KEY_NOT_REAL',
        'Token': 'EXAMPLE_MOCK_SESSION_TOKEN_NOT_REAL',
        'Expiration': '2099-01-01T00:00:00Z'
    },
    'secrets': {
        'DB_PASSWORD': 'EXAMPLE_ONLY_NOT_A_REAL_PASSWORD',
        'API_KEY': 'EXAMPLE_API_KEY_NOT_REAL'
    },
    's3_buckets': ['user-data', 'app-backups', 'sensitive-logs']
}

# --- Web App Zone (SSRF Vulnerable) ---
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/proxy', methods=['GET'])
def proxy():
    url = request.args.get('url')
    if not url:
        return "Missing URL parameter", 400
    try:
        # Intentionally vulnerable proxy (SSRF)
        response = requests.get(url, timeout=2)
        return response.text
    except Exception as e:
        return f"Error: {str(e)}", 500

# --- Mock AWS Metadata Service ---
@app.route('/latest/api/token', methods=['PUT'])
def imds_token():
    return "MOCK-IMDS-TOKEN-ABC", 200

@app.route('/latest/meta-data/iam/security-credentials/<role_name>', methods=['GET'])
def imds_credentials(role_name):
    if role_name == 'ec2-role':
        return jsonify(DATA['role_credentials'])
    return "Not Found", 404

# --- Mock AWS API ---
@app.route('/aws/s3/list-buckets', methods=['GET'])
def s3_list():
    # Simulate auth check
    if request.headers.get('Authorization') != 'Bearer EXAMPLE_MOCK_ACCESS_KEY_NOT_REAL':
        return jsonify({'error': 'Unauthorized'}), 403
    return jsonify({'buckets': DATA['s3_buckets']})

@app.route('/aws/secretsmanager/get-secret', methods=['POST'])
def secrets_get():
    # Simulate auth check
    if request.headers.get('Authorization') != 'Bearer EXAMPLE_MOCK_ACCESS_KEY_NOT_REAL':
        return jsonify({'error': 'Unauthorized'}), 403
    secret_name = request.json.get('secret_id')
    return jsonify({'secret': DATA['secrets'].get(secret_name, 'Secret not found')})

@app.route('/admin', methods=['GET', 'POST'])
def mock_console():
    return render_template('console.html')

if __name__ == '__main__':
    app.run(port=5000, debug=True)
