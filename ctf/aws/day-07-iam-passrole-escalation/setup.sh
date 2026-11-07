#!/usr/bin/env bash
# Day 7 setup safety preflight.
# Review the lab plan before provisioning; this preflight does not create AWS resources.
set -euo pipefail
command -v aws >/dev/null || { echo "AWS CLI is required" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }
command -v openssl >/dev/null || { echo "openssl is required" >&2; exit 1; }
aws sts get-caller-identity
printf '\nThis published setup entry point is intentionally non-provisioning.\n'
printf 'Review the Day 7 challenge and build/approve an account-specific deployment plan before creating resources.\n'
printf 'Never commit manifest.json or credentials.\n'
