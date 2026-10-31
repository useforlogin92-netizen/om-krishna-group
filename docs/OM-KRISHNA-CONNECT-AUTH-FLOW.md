# OM Krishna Connect — Registration, Approval and Password Recovery

## Scope
This is a feature specification for an isolated preview feature. It must not replace or modify the existing OM Krishna Group homepage or existing login. No production deployment or merge is authorized by this document.

## Account lifecycle
1. A visitor submits name, email, password and one or more requested membership categories.
2. Email verification is completed using the authentication provider's verified-email flow.
3. A new profile is created with status `pending`; it cannot use member-only chat, groups, media or calls.
4. An Admin receives an approval request email containing the minimum necessary profile information and authenticated dashboard actions to Approve or Reject.
5. Approval is a one-time state transition from `pending` to `approved`. Approved status persists across logout, login and password changes. It does not require re-approval unless an Admin suspends/revokes the account or the user requests a category/group permission requiring separate authorization.
6. Admin decisions are recorded in an audit log with actor, action, target account and timestamp.

## Admin email approval security
- Approval/rejection links must not directly mutate account state through a GET request.
- The email link opens an Admin-authenticated page. The action requires an active Admin session, CSRF protection, confirmation, and server-side role verification.
- Never place a permanent secret, service-role key, or reusable approval token in the URL.
- Email must be sent only to a configured Admin recipient. Do not hard-code a guessed address; configure `ADMIN_APPROVAL_EMAIL` in the server environment.
- Do not expose member information to unauthenticated recipients.

## Password recovery
### Option 1 — User self-service
- Login screen includes “Forgot password”.
- User enters the registered email.
- Server/auth provider returns a generic response to avoid email enumeration.
- Send a short-lived, single-use reset link to that email.
- The user sets a new password on a trusted HTTPS page.
- Notify the user by email after a successful reset.
- Revoke or offer to revoke existing sessions after reset.

### Option 2 — Request a reset link from Admin
- User submits a “Request help from Admin” form.
- Create a rate-limited support request; do not reveal whether an email/account exists to unauthenticated visitors.
- Admin sees the request in the protected dashboard and can select “Send reset link”.
- The system sends the provider-generated reset link only to the account's verified email address.
- The user chooses and submits their own new password. Admin never sees, sets, or shares the user's password.
- Log request, Admin action and outcome, without logging reset tokens or passwords.

Neither password recovery path triggers a new membership approval.

## Membership categories and access
Initial requested categories: Public Member, Om Friend, Om School Friend, Krishna Friend, Krishna School Friend, Om–Krishna Common Friend, Family Member. Multiple categories may be requested; private group access is separately enforced by membership/role rules. A category label alone does not grant access to private conversations or calls.

## Child-safety and transparency
- Show a clear notice that messages and safety-related activity may be reviewed by authorized Admins for moderation and safeguarding.
- Admin audit views may include message content, sender/recipient/group, timestamps, reports and call metadata (participants, start/end time, duration, status).
- Do not secretly record call audio/video. Any recording feature would require explicit notice, valid consent, strict access control and a separate retention policy.
- Restrict unsolicited direct messages/calls by default; provide block/report tools and rate limits.
- Minimize data collection, apply retention/deletion rules, and enforce database Row Level Security (RLS).

## Implementation sequence
1. Inspect existing frontend and Supabase schema/RLS; do not apply migrations until reviewed.
2. Implement registration, verified email and persistent approval state.
3. Implement Admin notification and authenticated approve/reject actions.
4. Implement both password reset paths using the authentication provider's secure reset flow.
5. Add tests for pending/approved/suspended states, authorization, token expiry, rate limits, and password reset.
6. Build and test in preview only; no merge or production deployment without explicit approval.

## Configuration required before email workflow can be enabled
- `ADMIN_APPROVAL_EMAIL`: actual Admin inbox supplied by the owner.
- Verified sender/domain and email delivery provider credentials, stored as environment secrets.
- Production/preview redirect URLs configured in the auth provider.
