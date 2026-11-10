# Day 8 Challenge — SSRF, IMDS and Credential Exposure

## Scenario
Northstar Payments operates an invoice-processing application. The security team wants to understand whether server-side URL fetching could reach internal-only services, including an EC2-style metadata endpoint, and whether exposed workload credentials could increase impact.

## Objectives
1. Map the application's server-side request functionality.
2. Identify missing URL and destination validation.
3. Explain why metadata endpoints and workload credentials are sensitive.
4. Demonstrate the issue only in a fully local simulation with synthetic data.
5. Apply destination allowlisting, redirect controls, and safe network boundaries.
6. Verify blocked internal destinations while legitimate approved requests continue to work.
7. Document evidence and remove only lab-owned processes and files.

## Rules
- Local simulation only. Do not point the lab at real metadata endpoints, internal networks, or cloud accounts.
- Never use real AWS access keys, session tokens, account identifiers, or production data.
- Never publish generated flags or the local manifest.
- Do not run broad process-kill commands or delete resources by loose name prefixes.

## Completion evidence
Record the vulnerable code path, safe synthetic demonstration, remediation diff, negative tests for loopback/link-local/private destinations, positive test for an approved destination, and cleanup verification. Redact all secrets and identifiers before sharing.
