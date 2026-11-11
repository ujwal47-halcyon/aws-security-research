# Day 8 — SSRF, IMDS and IAM Credential Exposure.

## Status
Sanitized project scaffold committed for review. The original upload contained a live-looking manifest with synthetic credential strings and two challenge flags. That manifest is deliberately excluded. The original scripts also printed those values and used broad process cleanup, so executable behavior is not carried into this public scaffold.

## Project map
- `CHALLENGE.md` — scenario and learning objectives
- `setup.sh`, `start.sh`, `teardown.sh`, `verify-cleanup.sh` — safe review gates; not provisioners
- `app.py`, `imds_server.py` — safe stubs; original vulnerable app code is not published in this scaffold
- `get-flag.sh` — safe flag-handling notice; no flag output
- `manifest.json.template` — placeholders only
- `remediation.md` — defensive controls
- `evidence-template.md` — evidence worksheet
- `evidence/REPORT.md` — evidence status

## Safety
This is a local-only training topic. Do not deploy an SSRF-vulnerable service publicly or connect it to real cloud credentials. Use unmistakably synthetic values. Keep generated manifests, tokens, keys, flags, logs containing secrets, and local state out of Git.

The scripts in this public scaffold intentionally do not start services, install packages, kill processes, or modify AWS resources. Review and test a fully local implementation separately before use.
