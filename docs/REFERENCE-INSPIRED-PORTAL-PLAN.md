# OM Krishna Group — Reference-Inspired Feature Plan

Status: planning/audit branch only. No production changes, merges, deployments, paid branches, or Supabase schema changes.

## Objective
Use general editorial/content-site patterns as inspiration (featured content, category navigation, search, tags, recent updates, pagination), adapted for OM Krishna Group. Do not copy protected branding, assets, text, or source code from the reference site.

## Scope
1. Homepage design: featured update area, Om and Krishna profile cards, latest activity cards, responsive navigation.
2. Profiles and activity publishing: separate profiles, activity detail pages, categories/tags, image alt text, safe admin publishing workflow.
3. Member access: registration, email verification, optional admin approval, role-based authorization.
4. Family private chat: one-to-one and group threads, unread indicators, block/report, moderation and server-enforced participant checks.
5. Visitor contact: validated enquiry form, protected server-side delivery, spam controls, admin inbox/status.
6. Discovery: search, category filters, tags, pagination, page metadata and accessible responsive layout.
7. Admin experience: manageable profile/activity content, member approvals, visitor enquiries, audit trail and least-privilege access.

## Free-only implementation principles
- Reuse the existing frontend stack and currently available free-tier services where possible.
- Do not create or enable paid Supabase branches or paid subscriptions.
- Check free-tier quotas and service limits before enabling any provider.
- Keep SQL in draft files until separately reviewed; never apply drafts to production during this work.
- If a secure feature cannot be delivered within free-tier limits, leave it disabled and document the blocker rather than silently enabling a paid service.

## Required workflow
1. Confirm the actual production repository and baseline read-only; this repository's current `main` must not be assumed to be production until verified.
2. Inventory existing homepage/login/routes and record baseline tests/screenshots.
3. Implement each feature on an isolated feature branch; keep homepage/login changes out of scope unless explicitly reviewed as a separate optional patch.
4. Add unit/static tests and run accessibility, mobile, auth, authorization, and regression checks.
5. Review database RLS and server-side authorization before testing any real messages or contact submissions.
6. Test only on an isolated preview, with non-sensitive test data.
7. Report results and remaining risks. No merge or production deployment.

## Acceptance criteria
- Existing homepage and login remain unchanged in the feature diff.
- Search, category/tag filters and pagination work with test content.
- Member-only routes and messages are denied to unauthorised users at the server/database layer.
- Visitors cannot read member chat or submit arbitrary database writes.
- Visitor enquiries show clear privacy/consent text and are delivered only through a tested protected service.
- Responsive layout and keyboard navigation pass basic checks.
- Tests and preview URL are reported with clear limitations.

## Known blockers / current state
- Existing branch `feature/family-private-chat-visitor-live-chat` includes unrelated profile/site files in addition to chat, so it is not a safe merge candidate.
- Its chat and registration pages are preview-only; visitor submissions are intentionally intercepted and are not sent or stored.
- The existing static smoke test success does not prove live authentication, realtime messaging, backend persistence, or security.
- The production repository/baseline has not yet been independently confirmed through the connected GitHub access. Do not implement integration changes until that is resolved.
- Docker Desktop is not installed. Do not require Docker for static UI checks; evaluate only free-compatible local testing options if backend testing becomes necessary.

## Explicit exclusions
No production edits, Supabase production schema/policy changes, paid branch, merge, auto-merge, deployment, or real user-data testing.
