# Local website testing

This repository currently contains a static HTML/CSS/JavaScript prototype. No build step or dependency installation is required for the site itself.

## Requirements
- Node.js 20 or later (for automated checks)
- Python 3 (for a simple local HTTP server), or another static file server

## Run automated checks
From the repository root:

```bash
npm test
```

The test suite checks expected pages, basic document metadata, local links/assets, inline JavaScript syntax, activity-page safety notices, and obvious service-role secret strings in frontend HTML.

## Preview in a browser
From the repository root:

```bash
python -m http.server 8000
```

Then open `http://localhost:8000/`. Stop the server with Ctrl+C.

Use an HTTP server instead of opening `index.html` as a file so relative paths and browser behavior are closer to normal hosting.

## Manual test checklist
- [ ] Open the homepage and every navigation link.
- [ ] At a narrow viewport, open and close the menu; verify it closes after choosing a link.
- [ ] On Activities, test each category filter and the All filter.
- [ ] Submit the activity form with missing fields and verify browser validation.
- [ ] Submit a sample activity; confirm it is only a local preview and not uploaded.
- [ ] Test JPG, PNG, WebP, MP4, WebM and MOV preview files.
- [ ] Test an unsupported file and a file larger than 50 MB.
- [ ] Enter text resembling HTML in the title/description and verify it is displayed as text.
- [ ] Submit the Contact form and confirm it clearly says preview-only, not sent.
- [ ] Inspect the site at desktop and mobile widths.

## Not yet testable end-to-end
Real registration/email verification, login/session persistence, database writes, private media uploads, guardian approval, admin access, and email delivery are not implemented in the static prototype.

## Supabase safety note
The connected Supabase project already contains tables for the existing family profile and cricket-opportunity workflow. Do not apply the separate `okg_*` draft schema automatically: review the existing schema and authorization model first. No database schema was changed as part of preparing this test harness.
