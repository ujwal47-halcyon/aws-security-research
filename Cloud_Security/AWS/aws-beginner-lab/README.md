# AWS Cloud Security Lab (Beginner)

A deliberately vulnerable simulated AWS environment to practice real-world cloud security vulnerabilities.

## Scope

- Public S3 bucket enumeration
- Server-Side Request Forgery (SSRF) to Instance Metadata Service (IMDSv1)
- IAM credential theft
- Privilege escalation across S3 buckets
- Cloud admin takeover

## How to Run

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Start the lab:
   ```bash
   python app.py
   ```

3. Open `http://localhost:5000` in your browser.

## Structure

- `app.py` — Flask application simulating AWS services.
- `templates/` — HTML templates for the lab interface.
- `static/` — CSS styling.
- `data/` — Stores your progress in `progress.json`.

## Solutions

See `SOLUTIONS.md` for the step-by-step exploitation guide. **Try the lab blind first.**