# OM Krishna Group — Website Inspiration Blueprint

Status: design specification on the isolated planning branch only. This document does not change the live website, application code, login, database, or deployment.

## Design direction

Combine three general patterns:
- **Public personal-brand presentation:** a strong featured story, achievements, concise profile cards, and editorial-quality imagery.
- **Private family portal:** authenticated family updates, albums, timeline, events, and private conversations.
- **Modern responsive portfolio:** clean typography, consistent spacing, accessible contrast, fast mobile layout, and clear navigation.

Reference links for inspiration (do not copy their code, protected assets, wording, or branding):
- Virat Kohli: https://www.iviratkohli.com/
- FamTree: https://myfamtree.app/
- FamilyCrossings: https://www.familycrossings.com/
- Kunbaa: https://www.kunbaa.com/
- Familial: https://www.familialmedia.com/
- Hostinger tutorials / portfolio examples: https://www.hostinger.com/in/tutorials/

## Proposed information architecture

### Public pages
1. **Home** — welcome/brand statement, featured update, Om and Krishna profile cards, latest public achievements, photo highlights, and a clear sign-in link.
2. **Om's Profile** — approved public bio, cricket role and achievements, dated milestones, selected public photos/videos.
3. **Krishna's Profile** — approved bio, activities, achievements, and timeline.
4. **Updates** — date-ordered posts with categories such as Cricket, Education, Events, Achievements, and Family News.
5. **Update Detail** — post title/date/category, accessible media, caption, and previous/next links.
6. **Contact** — a small validated enquiry form with privacy notice and spam protection. Do not expose private family contact details.

### Authenticated family area
1. **Family Dashboard** — recent posts, upcoming events, unread-message count, and quick links.
2. **Private Timeline** — family-only posts and milestones.
3. **Albums** — private-by-default media, with access checks for each item.
4. **Family Chat** — one-to-one and group conversations, unread state, and participant-only access.
5. **Events** — birthdays, matches, school events, and family reminders.
6. **Account & Privacy** — profile, notification preferences, and sign-out.

### Admin area
- Manage profiles and public/private visibility.
- Draft, preview, publish, edit, and archive updates.
- Review member registrations and role assignments.
- Moderate reported chat content and review visitor enquiries.
- Record security-sensitive actions in an audit trail.

## Homepage wireframe (content order)

1. Header: OM Krishna Group logo/name; Home, Profiles, Updates, Contact; Sign in.
2. Hero: concise family/project introduction, one primary call to action, one secondary action.
3. Featured update: latest approved highlight with date and category.
4. Two profile cards: Om and Krishna, with approved image, short description, and “View profile”.
5. Latest updates: three to six cards; category and date visible.
6. Highlights strip: selected achievements and milestones with dates.
7. Photo highlights: a small curated set; no private photos on the public page.
8. Footer: navigation, privacy notice, contact route, and copyright.

## Visual system

- Use a restrained palette with one primary brand colour, one accent, neutral backgrounds, and tested text contrast.
- Use a consistent spacing scale, readable body type, clear heading hierarchy, and visible keyboard focus.
- Use real, permission-cleared family images; never scrape or reuse reference-site photos.
- Use responsive single-column cards on mobile and two/three-column grids only where space allows.
- Respect reduced-motion settings; avoid autoplay media and heavy animations.
- Provide meaningful alt text, labels for form fields, and keyboard-operable navigation.

## Privacy and security rules

- Public content must be explicitly marked public; all new posts and albums default to private until reviewed.
- Never include children’s school timetable, live location, personal phone numbers, identity documents, or sensitive details in public pages.
- Hide private chat, family timeline, and private media from visitors at both the UI and server/database authorization layers.
- Verify a user's identity, role, and conversation membership on the server for every private read/write; do not rely on hidden buttons alone.
- Apply least-privilege roles and database row-level security where supported.
- Keep credentials and service-role keys out of frontend code and Git history.
- Use test accounts and synthetic content in previews; do not test with real private family messages.
- Add rate limiting / spam controls to public enquiry and registration routes.

## Free-first delivery phases

### Phase 0 — verify the baseline
- Identify the actual production repository and branch.
- Read-only inventory of routes, homepage, login, current hosting configuration, and existing tests.
- Capture a baseline and list any existing errors before editing code.

### Phase 1 — static design prototype
- Create the homepage/profile/update layouts in an isolated branch using the existing frontend stack.
- Use synthetic text and placeholder/permission-cleared imagery.
- No database schema changes, authentication rewrites, or production edits.

### Phase 2 — content and navigation
- Add accessible profile/update cards, categories, filters, and pagination against local mock data.
- Check mobile widths, keyboard navigation, loading/error/empty states, and broken links.

### Phase 3 — private features (only after a separate security review)
- Review the existing authentication and database policies first.
- Draft—not apply—any required schema/policy changes.
- Test role and participant authorization with synthetic accounts on a preview.
- Leave realtime chat and uploads disabled if secure delivery exceeds free-tier limits.

### Phase 4 — preview validation and handover
- Run available build, lint, unit, static smoke, accessibility, and route checks.
- Confirm the homepage/login diff is empty unless a separately approved patch says otherwise.
- Publish a test report and preview link if the current hosting setup supports it without changing production.
- Stop for explicit approval before merge or deployment.

## Acceptance checklist

- [ ] Correct production repository identified and baseline recorded.
- [ ] Homepage and login untouched in the proposed feature diff.
- [ ] Public/private visibility defaults to private for family content.
- [ ] Private routes and data are denied server-side to unauthorised users.
- [ ] Mobile, keyboard, contrast, empty/loading/error states checked.
- [ ] No paid service, paid branch, or new recurring cost enabled.
- [ ] Tests and known limitations documented.
- [ ] No merge or production deployment without explicit approval.

## Current blocker

The connected GitHub access previously returned a 404 for the repository believed to be linked to the live Render service. Until the actual production source repository and baseline are confirmed, this blueprint remains planning documentation; do not infer that the preview repository is the live source.
