import sqlite3
import uuid

def init():
    conn = sqlite3.connect('data/apex.db')
    cursor = conn.cursor()

    # Users Table
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT,
        balance REAL,
        email TEXT,
        secret_token TEXT
    )
    ''')

    # Invoices (IDOR target)
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE,
        user_id INTEGER,
        amount REAL,
        description TEXT,
        status TEXT
    )
    ''')

    # Support Tickets (Blind XSS target)
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS tickets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        subject TEXT,
        message TEXT,
        status TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    ''')

    # Insert Demo Data
    cursor.execute("INSERT OR IGNORE INTO users (id, username, password, role, balance, email, secret_token) VALUES (1, 'admin', 'SuperSecureAdminPassword2026!', 'admin', 999999.99, 'admin@apexcorp.local', 'FLAG{AUTH_BYPASS_JWT_NONE_SUCCESS}')")
    cursor.execute("INSERT OR IGNORE INTO users (id, username, password, role, balance, email, secret_token) VALUES (2, 'victim_user', 'user123', 'user', 1500.00, 'victim@apexcorp.local', 'FLAG{CSRF_SAMESITE_NONE_BYPASS}')")
    cursor.execute("INSERT OR IGNORE INTO users (id, username, password, role, balance, email, secret_token) VALUES (3, 'attacker_user', 'attacker123', 'user', 10.00, 'attacker@apexcorp.local', 'FLAG{IDOR_HASH_LEAK_SUCCESS}')")

    # Invoices data
    cursor.execute("INSERT OR IGNORE INTO invoices (id, uuid, user_id, amount, description, status) VALUES (1001, 'a1b2c3d4', 2, 5500.00, 'Confidential Consulting Services - FLAG{IDOR_SEQUENTIAL_INVOICE_READ}', 'Unpaid')")
    cursor.execute("INSERT OR IGNORE INTO invoices (id, uuid, user_id, amount, description, status) VALUES (1002, 'f9e8d7c6-b5a4-3210-fedc-ba9876543210', 2, 1200.00, 'FLAG{IDOR_UUID_LEAKED_PROFILE}', 'Paid')")

    # Scoring/Flags Table
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS submitted_flags (
        flag TEXT UNIQUE,
        points INTEGER,
        submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    ''')

    conn.commit()
    conn.close()
    print("[+] SQLite Database initialized.")

if __name__ == '__main__':
    init()
