# OM Krishna Group — Technology Stack

## Used in the current prototype

| Technology | Purpose | Status |
|---|---|---|
| HTML5 | Semantic page structure and content | Implemented |
| CSS3 | Responsive layout, styling, mobile navigation | Implemented |
| JavaScript | Mobile menu, activity filters, local media preview, temporary post preview | Implemented |
| Git and GitHub | Source control and repository | Active; repository remains private |
| Markdown | Project documentation | Implemented |

## Planned for the secure full version

| Technology | Purpose | Status |
|---|---|---|
| React (optional) | Component-based interface if the site grows | Not added |
| Python + FastAPI, or Node.js + Express | API, authentication, approval workflow and validation | Not implemented |
| SQL + PostgreSQL | Accounts, activities, approval states and audit events | Not connected |
| Supabase Auth / Database / Storage (candidate) | Managed login, relational data and media storage | Provider decision pending |
| Email provider | Guardian notifications and contact form | Not connected |
| Automated tests | Link, form, API and access-control tests | Not configured |
| Hosting and custom domain | Publish website and connect omkrishnagroup.com | Deferred |

## Future data model
- profiles: profile owner, display name, bio, guardian owner
- activities: title, category, description, author, timestamp, status
- media_assets: storage key, type, size, uploader, approval status
- approvals: activity, reviewer, decision, timestamp, notes
- users and roles: guardian, child contributor, administrator

## Safety and security
1. Child accounts can create drafts but cannot publish publicly.
2. Only a guardian/admin can approve public posts.
3. Media storage must be private by default.
4. Authorization must be enforced on the server/database, not only in browser JavaScript.
5. Validate file type and size on client and server.
6. Do not publish a child's full birth date, private phone, home address, school ID, exact live schedule or unverified achievements.
7. Never store credentials or API secrets in front-end code or Git.
8. Keep repository private; this change does not configure hosting or deployment.

## Current limitations
Activity posts and media previews only exist in the current browser session; they do not persist to a database or upload to a server. The contact form is also a front-end preview only.
