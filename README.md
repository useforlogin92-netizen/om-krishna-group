# OM Krishna Group Website

A family-managed, modular website for OM Krishna Group, with separate pages for Om, acting and dance, cricket, school activities, study projects, and Krishna.

## Status
- Website source is under active development.
- Repository remains private.
- No hosting, DNS, merge, or production deployment has been performed.
- Activity posting is a preview until secure authentication, database storage, media uploads, and guardian approval are implemented.

## Planned stack
- HTML5 for page structure
- CSS3 for responsive design and styling
- JavaScript for client-side interactions and activity preview
- Python: optional future backend/API (not currently required for the static preview)
- SQL/PostgreSQL: planned database for users, activities, approval status, and metadata; not connected yet
- GitHub for source control
- GoDaddy domain and hosting decision after website review

## Privacy
Do not publish children's full date of birth, private phone number, home address, school IDs, precise schedules, or unverified achievements. Guardian approval is required before a child's post or media is made public.

## Test readiness

Automated static smoke checks are available with Node.js 20+:

```bash
npm test
```

For browser preview, run a static server from the repository root:

```bash
python -m http.server 8000
```

Open `http://localhost:8000/`. Detailed instructions and manual checks are in [docs/LOCAL-TESTING.md](docs/LOCAL-TESTING.md); release/security checks are in [docs/QA-TEST-PLAN.md](docs/QA-TEST-PLAN.md).

A GitHub Actions workflow runs the static checks on pushes to `main` or `feature/website-v2` and on pull requests targeting `main`.

## Supabase integration boundary

The connected `om-krishna-group` Supabase project already contains `family_profiles` and `cricket_opportunities` tables with RLS enabled. The activity schema under `supabase/drafts/` is a separate proposal and has **not** been applied. Review the existing project and authorization model before any database migration. The static website remains a preview until authentication, activity persistence, private media storage, guardian approval and email delivery are implemented and tested.
