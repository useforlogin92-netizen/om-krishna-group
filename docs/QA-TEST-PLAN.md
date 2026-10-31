# OM Krishna Group Website — QA Test Plan

**Branch:** `feature/website-v2`  
**Status:** Planned; tests have not yet been executed in a browser or against a live backend.  
**Safety boundary:** Do not merge to `main`, change repository visibility, configure DNS/hosting, or run SQL against a live Supabase project as part of this plan.

## 1. Current prototype smoke tests

| ID | Test | Expected result | Status |
|---|---|---|---|
| WEB-01 | Open `index.html` from the feature branch | Homepage loads and navigation links resolve | Not run |
| WEB-02 | Open Om, Acting & Dance, Cricket, Krishna, Activities, Contact and Admin pages | Each page loads with shared styling and navigation | Not run |
| WEB-03 | Use mobile navigation at a narrow viewport | Menu opens/closes and `aria-expanded` reflects state | Not run |
| ACT-01 | Select each activity filter | Only matching cards display; All restores the full feed | Not run |
| ACT-02 | Submit an empty activity form | Browser validation prevents submission | Not run |
| ACT-03 | Submit a valid sample post | A local preview card appears; notice clearly says it is not uploaded/published | Not run |
| ACT-04 | Choose JPG, PNG or WebP | Image preview displays; preview card image remains available after form reset | Not run |
| ACT-05 | Choose MP4, WebM or MOV | Video preview controls appear; no server upload is implied | Not run |
| ACT-06 | Choose an unsupported file type | Clear validation message; no preview created | Not run |
| ACT-07 | Choose a file over 50 MB | Clear size warning; file is rejected | Not run |
| ACT-08 | Enter HTML-like text in title/description | Text is displayed as text, not interpreted as markup | Not run |
| CONTACT-01 | Submit contact form | UI must not claim that an email was sent unless a real provider is connected | Not run |
| ADMIN-01 | Open admin scaffold while logged out | Page must not be treated as a secure admin system | Not run |

## 2. Required backend and privacy tests before launch

- [ ] Confirm the exact Supabase project and inspect its existing schema before any migration.
- [ ] Create test accounts for anonymous visitor, child, guardian and administrator.
- [ ] Verify a child can create only their own draft and cannot approve or publish it.
- [ ] Verify a guardian can review only activities belonging to a child explicitly linked to that guardian.
- [ ] Verify a normal user cannot promote their role, change guardian links, set approval fields, or modify another user's activity.
- [ ] Verify public visitors can read only approved activities explicitly marked public.
- [ ] Verify rejected/private/family-only activity data and media remain inaccessible to unauthorized users.
- [ ] Verify media type and size on the server, not only in the browser.
- [ ] Use a private Storage bucket and test upload, read, replacement and delete policies.
- [ ] Confirm no service-role/secret key is included in frontend files or Git history.
- [ ] Test email verification, session expiry, password reset and guardian notifications.
- [ ] Run SQL/RLS checks and Supabase security/performance advisors before considering launch.

## 3. Release gate

Do not publish until smoke tests pass, authorization tests pass using separate accounts, child privacy is reviewed, and a backup/rollback plan is documented. The SQL draft is not production-ready and has not been executed.
