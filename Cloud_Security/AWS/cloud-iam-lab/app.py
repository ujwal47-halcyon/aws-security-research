from flask import Flask, render_template, request, redirect, url_for, session, jsonify, flash
import json
import os

app = Flask(__name__)
app.secret_key = 'supersecretkeythatisnotsoshortbutokayforlab'  # Change in production

DATA_FILE = os.path.join(os.path.dirname(__file__), 'data', 'cloud_state.json')

def load_data():
    with open(DATA_FILE, 'r') as f:
        return json.load(f)

def save_data(data):
    with open(DATA_FILE, 'w') as f:
        json.dump(data, f, indent=2)

def get_user_role_permissions(username):
    data = load_data()
    user_info = data.get('users', {}).get(username)
    if not user_info:
        return None
    role_name = user_info['role']
    role_info = data.get('roles', {}).get(role_name, {})
    policies = role_info.get('policies', [])
    # Flatten policies into permissions list (simplified)
    permissions = []
    # In a real lab we would map policy names to permissions; for simplicity we hardcode
    if 'EC2ReadOnly' in policies:
        permissions.append('ec2:DescribeInstances')
    if 'S3ReadOnly' in policies:
        permissions.append('s3:ListBucket')
    if 'IAMPassRolePolicy' in policies:
        permissions.append('iam:PassRole')
        # For this lab, PassRole allows passing EC2AdminRole
    if 'FullEC2Control' in policies:
        permissions.extend(['ec2:*', 'ssm:*'])
    if 'SSMExecutionPolicy' in policies:
        permissions.append('ssm:DescribeInstanceInformation')
    # Admin wildcard
    if '*' in permissions or any(p == '*' for p in permissions):
        permissions = ['*']
    return {
        'role': role_name,
        'permissions': list(set(permissions)),
        'secret_arn': role_info.get('secret')  # If role has an associated secret flag
    }

def has_permission(permission_needed):
    if 'user' not in session:
        return False
    perms = session.get('permissions', [])
    if '*' in perms:
        return True
    # Simple check: permission_needed string starts with any of the perms (if perms are like 'ec2:*')
    for perm in perms:
        if perm.endswith('*'):
            if permission_needed.startswith(perm[:-1]):
                return True
        elif perm == permission_needed:
            return True
    return False

@app.route('/')
def index():
    if 'user' not in session:
        return redirect(url_for('login'))
    return render_template('console.html', username=session['user'])

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        data = load_data()
        user = data.get('users', {}).get(username)
        if user and user['password'] == password:
            session['user'] = username
            role_info = get_user_role_permissions(username)
            session['role'] = role_info['role']
            session['permissions'] = role_info['permissions']
            flash(f'Logged in as {username} ({role_info["role"]})', 'success')
            return redirect(url_for('index'))
        else:
            flash('Invalid credentials', 'danger')
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

# --- Mock AWS API Endpoints ---

@app.route('/api/ec2/list')
def ec2_list():
    if not has_permission('ec2:DescribeInstances'):
        return jsonify({'error': 'Unauthorized'}), 403
    data = load_data()
    instances = data.get('resources', {}).get('ec2_instances', [])
    # Return simplified info
    return jsonify({'instances': [{'id': i['id'], 'name': i['name'], 'state': i['state'], 'iam_instance_profile': i.get('iam_instance_profile')} for i in instances]})

@app.route('/api/s3/ls')
def s3_ls():
    if not has_permission('s3:ListBucket'):
        return jsonify({'error': 'Unauthorized'}), 403
    data = load_data()
    buckets = data.get('resources', {}).get('s3_buckets', [])
    return jsonify({'buckets': [{'name': b['name'], 'files': b['files']} for b in buckets]})

@app.route('/api/iam/whoami')
def iam_whoami():
    if 'user' not in session:
        return jsonify({'error': 'Unauthorized'}), 401
    return jsonify({
        'user': session['user'],
        'role': session['role'],
        'permissions': session['permissions']
    })

@app.route('/api/sts/assume-role', methods=['POST'])
def assume_role():
    if not has_permission('iam:PassRole'):
        return jsonify({'error': 'Unauthorized: Missing iam:PassRole'}), 403
    data = request.get_json()
    role_arn = data.get('role_arn')
    if not role_arn:
        return jsonify({'error': 'Missing role_arn'}), 400
    # Extract role name from ARN (simplified)
    role_name = role_arn.split('/')[-1] if '/' in role_arn else role_arn
    # Load allowed roles to pass (in real AWS, this is governed by iam:PassRole permissions on specific roles)
    # For lab, we allow passing EC2AdminRole if the user has iam:PassRole (DeveloperRole)
    cloud_data = load_data()
    allowed_roles_to_pass = ['EC2AdminRole']  # Could be more sophisticated
    if role_name not in allowed_roles_to_pass:
        return jsonify({'error': f'Cannot pass role {role_name}. Not allowed by your iam:PassRole policy.'}), 403
    # Assume the role: switch session permissions to that role's permissions
    role_info = cloud_data.get('roles', {}).get(role_name)
    if not role_info:
        return jsonify({'error': f'Role {role_name} not found'}), 404
    # Build permissions for the assumed role (simplified)
    assumed_permissions = []
    policies = role_info.get('policies', [])
    if 'FullEC2Control' in policies:
        assumed_permissions.extend(['ec2:*', 'ssm:*'])
    if 'SSMExecutionPolicy' in policies:
        assumed_permissions.append('ssm:DescribeInstanceInformation')
    # If any policy grants wildcard, treat as admin
    if any(p == '*' for p in policies) or '*' in assumed_permissions:
        assumed_permissions = ['*']
    # Update session
    session['role'] = role_name
    session['permissions'] = assumed_permissions
    flash(f'Assumed role: {role_name}', 'info')
    return jsonify({
        'message': f'Assumed role {role_name} successfully',
        'assumed_role': role_name,
        'permissions': assumed_permissions
    })

@app.route('/api/secrets/get')
def secrets_get():
    # Requires secretsmanager:GetSecretValue - we'll check if user has any EC2/SSM permission as proxy for having assumed EC2AdminRole
    # In real lab, you'd check for secretsmanager:GetSecretValue on specific secret ARN.
    # For simplicity, we allow if user has ec2:* or ssm:* (i.e., assumed EC2AdminRole)
    if not (has_permission('ec2:*') or has_permission('ssm:*') or has_permission('*')):
        return jsonify({'error': 'Unauthorized: Cannot access secrets'}), 403
    secret_name = request.args.get('secret_id')
    if not secret_name:
        return jsonify({'error': 'Missing secret_id parameter'}), 400
    data = load_data()
    secret_value = data.get('resources', {}).get('secrets', {}).get(secret_name)
    if secret_value is None:
        return jsonify({'error': 'Secret not found'}), 404
    return jsonify({'secret_id': secret_name, 'secret_value': secret_value})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)