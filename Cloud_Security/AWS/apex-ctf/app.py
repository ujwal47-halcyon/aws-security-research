import os
import flask.cli
flask.cli.load_dotenv = lambda *args, **kwargs: None
import time
import sqlite3
import jwt
import threading
from flask import Flask, request, render_template, redirect, url_for, session, jsonify, render_template_string
from markupsafe import escape

app = Flask(__name__)
app.secret_key = os.urandom(24)

# Simulated Database Connection helper
def get_db():
    conn = sqlite3.connect('data/apex.db')
    conn.row_factory = sqlite3.Row
    return conn

# Mock Background Admin Bot to simulate Blind XSS execution
def admin_bot_worker():
    while True:
        time.sleep(15)  # Run every 15 seconds
        try:
            conn = get_db()
            cursor = conn.cursor()
            # Find unread tickets
            cursor.execute("SELECT * FROM tickets WHERE status = 'Open'")
            tickets = cursor.fetchall()
            for ticket in tickets:
                # Simulate an Admin viewing the ticket
                # If there's an XSS payload, we mock-execute it.
                # In a real environment, this would run in a headless browser (Puppeteer).
                # We simulate an Out-of-band/Blind XSS trigger by scanning for script tags, img tags, etc.
                message = ticket['message']
                if "<script>" in message or "onerror=" in message or "onload=" in message:
                    print(f"[*] Admin Bot viewed ticket {ticket['id']} - XSS Payload Executed!")
                    # Log flag for stored XSS
                    cursor.execute("INSERT OR IGNORE INTO submitted_flags (flag, points) VALUES ('FLAG{BLIND_STORED_XSS_ADMIN_COOKIE}', 100)")

                # Mark ticket as viewed/closed
                cursor.execute("UPDATE tickets SET status = 'Reviewed' WHERE id = ?", (ticket['id'],))
            conn.commit()
            conn.close()
        except Exception as e:
            print(f"[!] Admin Bot Error: {e}")

# Start the admin worker in a background thread
threading.Thread(target=admin_bot_worker, daemon=True).start()

# ----------------- INLINE CAPTCHA ENGINE -----------------
# We create an intentionally vulnerable text-based CAPTCHA
# Vulnerability: The captcha text is stored in the session cookie (which is clientside-readable if secure flags are missing)
# and it doesn't rotate on failure or allows replay attacks.
def generate_captcha():
    import random
    chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    captcha_text = "".join(random.choice(chars) for _ in range(5))
    return captcha_text

# ----------------- SECURITY HEADERS -----------------
@app.after_request
def apply_security_headers(response):
    # Clickjacking vulnerability: Intentionally missing frame-ancestors / X-Frame-Options on target endpoints
    if "/transfer" not in request.path:
        response.headers['X-Frame-Options'] = 'DENY'
    return response

# ----------------- ROUTES -----------------

@app.route('/')
def home():
    return render_template('index.html')

# 1. AUTH BYPASS & RATE LIMIT OVERVIEW
@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    # No Rate Limit on Login Route
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        captcha_input = request.form.get('captcha')

        # CAPTCHA Validation Logic with Flaws:
        # Replay/Validation bypass: if captcha session is not cleared, same solver can be reused.
        if session.get('captcha_val') != captcha_input:
            error = "Invalid CAPTCHA!"
        else:
            conn = get_db()
            cursor = conn.cursor()
            # Vulnerable SQL Injection parameter
            query = f"SELECT * FROM users WHERE username = '{username}' AND password = '{password}'"
            try:
                cursor.execute(query)
                user = cursor.fetchone()
                if user:
                    session['user_id'] = user['id']
                    session['username'] = user['username']
                    session['role'] = user['role']
                    return redirect(url_for('dashboard'))
                else:
                    error = f"Invalid Credentials! Debug Query executed: {query}"
            except Exception as e:
                error = f"SQL Database Error: {e}"

    session['captcha_val'] = generate_captcha()
    return render_template('login.html', error=error, captcha=session['captcha_val'])

# JWT Auth Bypass Endpoint
@app.route('/api/auth/jwt', methods=['POST'])
def api_jwt_login():
    # Vulnerability: Accepts 'None' algorithm in the JWT header verification
    token = request.headers.get('Authorization')
    if not token:
        return jsonify({"error": "Missing token"}), 401

    try:
        # The library jwt.decode can be tricked if the attacker specifies algorithm 'none'
        # depending on configuration, or we simulate a custom vulnerable parser:
        header = jwt.get_unverified_header(token)
        if header.get('alg').lower() == 'none':
            payload = jwt.decode(token, options={"verify_signature": False})
        else:
            payload = jwt.decode(token, "SuperSecretCryptoKey2026!", algorithms=["HS256"])

        if payload.get('role') == 'admin':
            return jsonify({"status": "Authorized", "flag": "FLAG{AUTH_BYPASS_JWT_NONE_SUCCESS}"})
        return jsonify({"status": "Authenticated", "user": payload.get('user')})
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# 2. XSS ENDPOINTS
@app.route('/search', methods=['GET'])
def search():
    q = request.args.get('q', '')
    # Reflected XSS: Input returned without escaping
    # Try: <script>alert(1)</script>
    # Try bypass: with filter rules
    sanitized_q = q.replace('<script>', '').replace('</script>', '') # Intentionally weak
    return render_template('search.html', q=q, sanitized_q=sanitized_q)

# Stored / Blind XSS
@app.route('/support', methods=['GET', 'POST'])
def support():
    if 'user_id' not in session:
        return redirect(url_for('login'))

    if request.method == 'POST':
        subject = request.form.get('subject')
        message = request.form.get('message') # Target field for Blind XSS

        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("INSERT INTO tickets (user_id, subject, message, status) VALUES (?, ?, ?, 'Open')",
                       (session['user_id'], subject, message))
        conn.commit()
        conn.close()
        return render_template('support.html', success="Ticket submitted. Admin will review within 15 seconds.")

    return render_template('support.html')

# 3. IDOR ENDPOINTS
@app.route('/invoice/<int:invoice_id>')
def view_invoice(invoice_id):
    if 'user_id' not in session:
        return redirect(url_for('login'))

    # Vulnerability: Sequential IDOR
    # Attacker user_id = 3, Invoice 1001 belongs to user_id = 2.
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM invoices WHERE id = ?", (invoice_id,))
    invoice = cursor.fetchone()
    conn.close()

    if invoice:
        # Broken Access Control: No verification of invoice['user_id'] == session['user_id']
        return render_template('invoice.html', invoice=invoice)
    return "Invoice not found", 404

# Cryptographic Hash IDOR
@app.route('/api/v2/statement')
def view_statement():
    statement_id = request.args.get('id', '')
    # Vulnerability: Attacker can find the UUID statement ID leaked on another user's public profile page!
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM invoices WHERE uuid = ?", (statement_id,))
    invoice = cursor.fetchone()
    conn.close()

    if invoice:
        return jsonify({"status": "Success", "data": invoice['description']})
    return jsonify({"error": "Statement not found"}), 404

@app.route('/profile/<int:user_id>')
def public_profile(user_id):
    # Leaks the statements UUID inside the HTML source of user 2
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT username, email FROM users WHERE id = ?", (user_id,))
    user = cursor.fetchone()
    conn.close()
    if user:
        # Simulated profile script leaking private statement hash
        statement_leak = ""
        if user_id == 2:
            statement_leak = "f9e8d7c6-b5a4-3210-fedc-ba9876543210"
        return render_template('profile.html', user=user, leak=statement_leak)
    return "User not found", 404

# 4. CSRF & CLICKJACKING TARGETS
@app.route('/transfer', methods=['GET', 'POST'])
def transfer():
    if 'user_id' not in session:
        return redirect(url_for('login'))

    # Vulnerability: Intentionally missing Anti-CSRF Tokens
    # cookies set to SameSite=None to allow cross-site POST simulation
    if request.method == 'POST':
        to_user = request.form.get('to_user')
        amount = float(request.form.get('amount', 0))

        conn = get_db()
        cursor = conn.cursor()

        # Deduct balance from current user
        cursor.execute("UPDATE users SET balance = balance - ? WHERE id = ?", (amount, session['user_id']))
        # Add to target
        cursor.execute("UPDATE users SET balance = balance + ? WHERE username = ?", (amount, to_user))
        conn.commit()
        conn.close()

        return f"Transfer of ${amount} to {to_user} successful! FLAG{CLICKJACKING_TRANSFER_VICTIM}"

    return render_template('transfer.html', balance=1500)

# 5. SCORING PORTAL / FLAG SUBMISSION
@app.route('/scoring', methods=['GET', 'POST'])
def scoring():
    message = None
    if request.method == 'POST':
        submitted_flag = request.form.get('flag', '').strip()
        conn = get_db()
        cursor = conn.cursor()
        try:
            cursor.execute("INSERT INTO submitted_flags (flag, points) VALUES (?, ?)", (submitted_flag, 100))
            conn.commit()
            message = "Flag Submitted Successfully! +100 Points"
        except sqlite3.IntegrityError:
            message = "Flag already submitted or invalid format!"
        conn.close()

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM submitted_flags")
    flags = cursor.fetchall()
    conn.close()

    return render_template('scoring.html', flags=flags, message=message)

@app.route('/dashboard')
def dashboard():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    return render_template('dashboard.html', username=session['username'], role=session['role'])

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8000, debug=True)
