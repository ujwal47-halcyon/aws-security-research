# Day 6 Bug Analysis — IAM Privilege Escalation

The original workflow has a remediation-to-verification-to-flag-release consistency problem. Checks based only on a policy name can miss an equivalent dangerous policy under another name.

## Required verifier behavior
1. Inspect the actual policy documents, not only policy names.
2. Check all relevant inline policies and attached managed policies.
3. Detect `iam:AttachUserPolicy` and `iam:PutUserPolicy` with unrestricted resources, including scalar and array values.
4. Inspect the active default version of each managed policy.
5. Verify the intended developer user still exists; deleting the user must not count as successful remediation.
6. Fail closed on AWS API errors, incomplete results, or malformed policy documents.
7. Release no flag unless every verification condition passes.

## Test cases
- Vulnerable wildcard policy: fail and withhold flag.
- Correctly scoped policy: pass only if the full policy inventory is clean.
- Alternate policy name with the same dangerous statement: fail.
- User deleted: fail.
- Inactive managed policy version changed while vulnerable default remains: fail.
- Additional attached policy retains the dangerous permission: fail.
- Verifier/API error: fail closed.
- Cleanup: delete only Day 6-owned resources and preserve the administrator identity.
