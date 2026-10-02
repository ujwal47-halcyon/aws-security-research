# ☁️ CloudSec Day 2 CTF

Local website-based CTF for Ujwal's Day 2 cloud security roadmap.

## Topics Covered Today

- AWS Free Tier account security
- Root MFA + billing alarm
- IAM admin user setup
- AWS CLI configuration in WSL
- Networking CTF Levels 1-3: IP address, subnet/network path, ports
- GitHub proof-of-work habit
- LinkedIn learning-in-public habit

## Run

```bash
cd /c/Users/Ujwal/Desktop/AI/cloudsec-day2-ctf
pip install -r requirements.txt
python app.py
```

Open:

```text
http://127.0.0.1:5000
```

## How to Use

1. Open each mission.
2. Do the task in AWS/WSL/GitHub/LinkedIn.
3. Open the mission's `flag.txt` only after task completion.
4. Submit:
   - FLAG
   - DEF: your explanation
   - EVIDENCE
   - CONFUSION
5. Download `submission.md`.
6. Send only `submission.md` to Claude for review.

## Rule

90% Cloud Security. Web security only after cloud work is complete.

## Safety

Never paste AWS secret keys, passwords, MFA codes, or tokens into this website.