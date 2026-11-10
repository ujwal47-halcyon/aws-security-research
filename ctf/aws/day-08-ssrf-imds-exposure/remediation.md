# Day 8 — SSRF and Metadata Exposure Remediation

## Root cause
A server-side fetch feature that accepts arbitrary user-supplied URLs can become an SSRF primitive. If the application can reach loopback, private networks, link-local addresses, or cloud metadata endpoints, an attacker may pivot into internal services or workload identity data.

## Application controls
- Prefer a strict hostname allowlist over a denylist.
- Parse and normalize URLs; allow only expected schemes, normally HTTPS.
- Resolve hostnames and reject loopback, private, link-local, multicast, reserved, and unspecified IP ranges.
- Re-check every redirect destination or disable redirects.
- Defend against DNS rebinding by validating the resolved address used for the actual connection.
- Apply connection/read timeouts, response-size limits, and egress restrictions.
- Do not expose raw upstream responses or sensitive headers to users.

## Workload identity controls
- Require IMDSv2 on EC2 where supported.
- Minimize instance-profile permissions and resource scope.
- Avoid placing credentials in application responses, logs, error messages, or browser-visible content.
- Use network-level controls to limit which processes can reach metadata services where feasible.

## Verification
- Requests to loopback, link-local metadata, RFC1918 private ranges, alternate IP encodings, and redirect-to-private destinations are rejected.
- An explicitly approved external destination still works.
- DNS resolution and redirect handling cannot bypass destination checks.
- No real credentials are used in the test.
