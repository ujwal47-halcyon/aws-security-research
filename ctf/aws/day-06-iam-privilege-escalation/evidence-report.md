# Day 6 Lab Evidence Report

## Finding
The submitted CLI evidence contains an IAM inline policy granting `iam:AttachUserPolicy`. One captured document uses `Resource: "*"`, while another scopes the resource to a specific policy ARN.

## Evidence captured
- An inline policy inventory shows `AutoEliteDay6-DevPolicy`.
- One policy document shows the wildcard resource.
- Another shows a scoped policy ARN.
- The verifier output reports the wildcard condition as false and releases the flag. The flag value is deliberately excluded.

## Impact
Unrestricted `iam:AttachUserPolicy` can allow an identity to attach powerful managed policies to IAM users, subject to other IAM controls and policy evaluation. No escalation attempt is evidenced or recommended.

## Verification limitations
The screenshots show different random developer-user suffixes. They do not establish that the wildcard policy, scoped policy, inventory, and verifier output refer to the same user at one point in time. The verifier must inspect all relevant inline and attached managed policies, handle scalar and array forms of Action and Resource, and fail closed on API errors.

## Remediation status
Partially evidenced. A fresh read-only inspection of the same user is required to confirm the final state.

## Cleanup status
Not evidenced. Do not mark cleanup complete until teardown and an independent check confirm the Day 6 user and lab policies are absent.

## Follow-up
1. Read the exact lab username from the private local manifest.
2. List and inspect all inline policies.
3. List attached managed policies and inspect their default versions.
4. Confirm no relevant policy grants unrestricted `iam:AttachUserPolicy` or `iam:PutUserPolicy`.
5. Run cleanup and verify the lab user is absent.
