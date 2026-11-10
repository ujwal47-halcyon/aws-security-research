#!/usr/bin/env bash
# Safe public scaffold. Deliberately does not start services or kill processes.
set -euo pipefail
echo "No service is started by this public scaffold."
echo "Use a separately reviewed local-only implementation and bind only to 127.0.0.1."
