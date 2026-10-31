# OM Krishna Connect — Family Private Chat and Visitor Live Chat

## Scope and safety boundary
This feature is isolated on `feature/family-private-chat-visitor-live-chat`. It must not change the production homepage/login or deploy to production. The static page is a UI preview only; it does not claim to send, persist, or deliver chat messages.

## Chat experiences
- **Family private chat:** registered users must verify their email before access. The database must authorize every conversation/message read and write. Membership registration alone must not allow reading all conversations; the participant relationship is required.
- **Visitor contact/live-chat intake:** a visitor can submit a limited contact request through a protected server/Edge Function after it is connected. Public clients must never write directly to family/private chat tables. Add rate limits, spam protection, input validation, and a generic success response.
- **Moderation:** provide block/report and authorized guardian/admin review. Display a clear notice that authorized admins may review reported or safety-related messages. No audio/video recording.
- **Child safety:** no public display of private phone numbers, home addresses, school IDs, exact live schedules, or other sensitive details.

## Current preview behavior
- `src/pages/chat.html` offers the two flows.
- `src/shared/styles/chat.css` styles responsive cards/forms.
- `src/shared/scripts/chat.js` explicitly reports that the visitor form is preview-only; it does not store or transmit form contents.
- The registration link is a planned route and must be connected to a verified signup flow before use.
- The homepage navigation addition is limited to a Chat & Contact link; existing homepage content and login are otherwise untouched.

## Backend requirements before calling it live
1. Review the active Supabase project schema, existing RLS policies and Auth configuration.
2. Use a development database branch or separate test project. Do not apply draft SQL to production.
3. Create private conversation, participant, message, report and visitor-request tables with RLS.
4. Enforce verified email + approved registration for family member chat; validate conversation participation on every query.
5. Route visitor requests through an Edge Function/server with rate limiting and a configured email/chat provider. Never expose a service-role key in browser code.
6. Add realtime subscriptions scoped to authorized conversations only; paginate messages and validate size/type.
7. Test anonymous, verified member, non-participant member, participant, admin and suspended user access. Verify visitor spam/rate-limit behavior.
8. Configure environment variables/secrets in the preview environment only, then run browser tests. Do not merge/deploy to production.

## Acceptance checks
- Chat page is reachable from homepage navigation.
- Mobile layout stacks cards without horizontal overflow.
- Empty required fields block form submission.
- Visitor form always states that preview data is not sent or saved.
- No frontend key or secret is committed.
- Private-chat UI does not imply backend connectivity until authentication, database RLS and realtime are verified.
