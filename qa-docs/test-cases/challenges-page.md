# 🧪 Challenges Page — Test Cases

**Feature:** Challenges Page (new-ui only)
**Page:** /fit/challenges
**Component Path:** projects/fit/src/ui/new-ui/pages/challenges-page.component.ts
**Cross-reference Prototype:** fit-prototype/src/routes/challenges.tsx
**Last Updated:** 2026-05-21
**Total Test Cases:** 40
**Automation Framework:** Playwright (planned)

---

## 🐛 Bugs Found (Pre-Development)

| # | Description | Related TC | Severity |
|---|-------------|------------|----------|
| BUG_CH_01 | Invalid `?tab=xyz` silently loads Past data with no active tab pill highlighted; no validation feedback | CHL_032 | P1 |
| BUG_CH_02 | Progress > 100%: header shows raw value (e.g., "115%") but progress bar clamps to 100% — inconsistent display | CHL_038 | P2 |
| BUG_CH_03 | Past pagination nav disappears silently when API response omits `count` field (`totalPages = 0`) | CHL_036 | P2 |

---

## 🚦 Smoke Test Checklist (P1 only)

- [ ] CHL_001 — Page loads with Ongoing tab active by default
- [ ] CHL_002 — Ongoing tab shows challenge cards for user with active challenges
- [ ] CHL_003 — Upcoming tab loads and displays challenge rows
- [ ] CHL_004 — Past tab loads and displays challenge rows with rank
- [ ] CHL_005 — Progress bar renders with correct percentage
- [ ] CHL_013 — Loading shimmer shown during Ongoing fetch
- [ ] CHL_014 — Loading shimmer shown during Upcoming fetch
- [ ] CHL_015 — Loading shimmer shows 6 skeleton rows for Past tab
- [ ] CHL_016 — Empty Ongoing tab shows correct empty state
- [ ] CHL_017 — Empty Upcoming tab shows correct empty state
- [ ] CHL_019 — Clicking Upcoming row navigates to challenge detail
- [ ] CHL_020 — Clicking Past row navigates to challenge detail
- [ ] CHL_021 — Tab updates URL query param on switch
- [ ] CHL_029 — Refresh on Upcoming tab restores Upcoming tab
- [ ] CHL_030 — Direct URL with `?tab=past` opens Past tab
- [ ] CHL_031 — Back navigation from detail restores previous tab and list
- [ ] CHL_032 — Invalid tab value `?tab=xyz` silently loads Past data (BUG_CH_01)
- [ ] CHL_033 — 404 challenge ID shows "Challenge not found" state
- [ ] CHL_034 — Ongoing API failure shows empty state (no dedicated error UI)
- [ ] CHL_035 — Past API failure shows empty state
- [ ] CHL_037 — Single ongoing challenge auto-navigates to detail

---

## 📋 Full Test Case Table

| TC_ID | Module | Scenario | Pre-condition | Steps | Expected Result | Priority | Type | Automation | Locator Hint | Interaction Type |
|-------|--------|----------|---------------|-------|-----------------|----------|------|------------|--------------|-----------------|
| CHL_001 | Challenges Page | Page loads with Ongoing tab active by default | User is authenticated; no `?tab=` param in URL | 1. Navigate to `/fit/challenges` | Page renders; "Ongoing" tab pill has active state; `?tab=ongoing` present in URL; challenge list or empty state visible | P1 | Functional | Yes | `getByRole('tab', { name: 'Ongoing' })` | validate-visible |
| CHL_002 | Challenges Page | Ongoing tab shows challenge cards for user with active challenges | API returns ≥1 ongoing challenge | 1. Navigate to `/fit/challenges?tab=ongoing` 2. Wait for load | Each challenge renders as `fit-summary-challenge-card` in listing variant; title, image/fallback trophy icon, and color gradient background visible per card | P1 | Functional | Yes | `getByTestId('challenge-card-listing')` ⚠️ ADD data-testid="challenge-card-listing" to `div.ch-slide-standalone` in `summary-challenge-card.component.html` | validate-visible |
| CHL_003 | Challenges Page | Upcoming tab loads and displays challenge rows | API returns ≥1 upcoming challenge | 1. Click "Upcoming" tab 2. Wait for load | URL updates to `?tab=upcoming`; list of button rows shown with thumbnail icon, title, subtitle (if present) | P1 | Functional | Yes | `getByRole('tab', { name: 'Upcoming' })` | click |
| CHL_004 | Challenges Page | Past tab loads and displays challenge rows with rank | API returns past challenges including some with `rank > 0` | 1. Click "Past" tab 2. Wait for load | URL updates to `?tab=past`; rows show title, thumbnail, "Rank N" badge only for challenges where rank > 0 | P1 | Functional | Yes | `getByRole('tab', { name: 'Past' })` | click |
| CHL_005 | Challenges Page | Progress bar renders with correct percentage | API returns ongoing challenge with `progress = 65`, `progressTitle = "Steps done"` | 1. Load Ongoing tab 2. Observe challenge card progress row | Header shows "Steps done" on left and "65%" on right; `.ch-prog-fg` bar width is 65% of container | P1 | Functional | Yes | `getByTestId('challenge-progress-header')` ⚠️ ADD data-testid="challenge-progress-header" to `.ch-prog-hd` in `summary-challenge-card.component.html` | validate-text |
| CHL_006 | Challenges Page | Rank pill visible on card when rank > 0 and rankText non-empty | API returns ongoing challenge with `rank = 4`, `rankText = "4"`, `rankTitle = "Rank"` | 1. Load Ongoing tab 2. Observe card rank area | Rank pill `.ch-rank-pill` shows "Rank 4"; both `rankTitle` and `rankText` rendered | P2 | Functional | Yes | `getByTestId('rank-pill')` ⚠️ ADD data-testid="rank-pill" to `span.ch-rank-pill` in `summary-challenge-card.component.html` | validate-text |
| CHL_007 | Challenges Page | Past tab pagination controls render when totalPages > 1 | API returns past challenges with `count` yielding ≥11 entries (≥2 pages of 10) | 1. Navigate to `?tab=past` 2. Wait for load | Pagination nav shows "Page 1 of N"; Previous button disabled; Next button enabled | P2 | Functional | Yes | `getByRole('button', { name: 'Next page' })` | validate-visible |
| CHL_008 | Challenges Page | Next page loads new set of past challenges | Past tab loaded on page 1 | 1. Click Next page button 2. Wait for load | List clears and re-populates with page 2 challenges; "Page 2 of N" shown; Previous button now enabled | P2 | Functional | Yes | `getByRole('button', { name: 'Next page' })` | click |
| CHL_009 | Challenges Page | Previous page button disabled on first page | Past tab on page 1 | 1. Navigate to `?tab=past` 2. Observe Previous button | Previous page button has `disabled` attribute | P2 | UI | Yes | `getByRole('button', { name: 'Previous page' })` | validate-visible |
| CHL_010 | Challenges Page | Active tab pill has distinct active styling | Challenges page loaded | 1. Click "Upcoming" tab 2. Observe all 3 pills | "Upcoming" pill has `active` class; "Ongoing" and "Past" pills do not | P2 | UI | Yes | `getByRole('tab', { name: 'Upcoming' })` | validate-visible |
| CHL_011 | Challenges Page | Challenge card gradient background matches API color values | API returns challenge with `color.first = "#FF6B6B"`, `color.second = "#C62828"` | 1. Load Ongoing tab 2. Inspect card background | Card `[style.background]` is `linear-gradient(135deg, #FF6B6B, #C62828)` | P3 | UI | No | `getByTestId('challenge-card-listing')` ⚠️ ADD data-testid="challenge-card-listing" to `div.ch-slide-standalone` in `summary-challenge-card.component.html` | validate-visible |
| CHL_012 | Challenges Page | Fallback trophy icon shown when challenge has no image | API returns challenge with `image = ""` or `image = null` | 1. Load any tab 2. Find card with missing image | `fallbackIcon="trophy"` renders in place of broken image | P2 | UI | Yes | `getByTestId('challenge-img')` ⚠️ ADD data-testid="challenge-img" to `<fit-img>` in `button.uc-row` (`upcoming-challenges.component.html`) and `button.pc-row` (`past-challenges.component.html`) | validate-visible |
| CHL_013 | Challenges Page | Loading shimmer shown during Ongoing fetch | Network throttled to Slow 3G | 1. Navigate to `?tab=ongoing` 2. Observe immediately | 4 skeleton cards rendered; real cards not visible | P1 | State | Yes | `getByTestId('ongoing-shimmer')` ⚠️ ADD data-testid="ongoing-shimmer" to `div.oc-shim-card` in `ongoing-challenges.component.html` | validate-visible |
| CHL_014 | Challenges Page | Loading shimmer shown during Upcoming fetch | Network throttled; switch to Upcoming tab | 1. Click "Upcoming" tab 2. Observe immediately | 4 skeleton rows rendered; real rows not visible | P1 | State | Yes | `getByTestId('upcoming-shimmer')` ⚠️ ADD data-testid="upcoming-shimmer" to `div.uc-shim-row` in `upcoming-challenges.component.html` | validate-visible |
| CHL_015 | Challenges Page | Loading shimmer shows 6 skeleton rows for Past tab | Network throttled; switch to Past tab | 1. Click "Past" tab 2. Observe immediately | 6 skeleton rows rendered; real rows not visible | P1 | State | Yes | `getByTestId('past-shimmer')` ⚠️ ADD data-testid="past-shimmer" to `div.pc-shim-row` in `past-challenges.component.html` | validate-count |
| CHL_016 | Challenges Page | Empty Ongoing tab shows correct empty state | API returns `ongoing/all` with empty array | 1. Load `?tab=ongoing` | `fit-empty-state` visible; title = "No ongoing challenges"; description = "Check back soon for new challenges." | P1 | State | Yes | `getByText('No ongoing challenges')` | validate-text |
| CHL_017 | Challenges Page | Empty Upcoming tab shows correct empty state | API returns `upcoming/all` with empty array | 1. Load `?tab=upcoming` | `fit-empty-state` visible; title = "No upcoming challenges"; description = "New challenges will appear here when they're scheduled." | P1 | State | Yes | `getByText('No upcoming challenges')` | validate-text |
| CHL_018 | Challenges Page | Empty Past tab shows correct empty state | API returns `past/all` with empty array | 1. Load `?tab=past` | `fit-empty-state` visible; title = "No past challenges"; description = "Completed challenges will show up here." | P2 | State | Yes | `getByText('No past challenges')` | validate-text |
| CHL_019 | Challenge Detail | Clicking Upcoming row navigates to challenge detail | Upcoming tab loaded with ≥1 challenge | 1. Click any challenge row button | URL updates to outlet info route with `tab=upcoming&id=<N>&navBack=true`; detail view renders | P1 | Navigation | Yes | `getByTestId('upcoming-challenge-row')` ⚠️ ADD data-testid="upcoming-challenge-row" to `button.uc-row` in `upcoming-challenges.component.html` | click |
| CHL_020 | Challenge Detail | Clicking Past row navigates to challenge detail | Past tab loaded with ≥1 challenge | 1. Click any challenge row button | URL updates to outlet info route with `tab=past&id=<N>&navBack=true`; detail view loads | P1 | Navigation | Yes | `getByTestId('past-challenge-row')` ⚠️ ADD data-testid="past-challenge-row" to `button.pc-row` in `past-challenges.component.html` | click |
| CHL_021 | Challenge Detail | Tab updates URL query param on switch | Challenges page on Ongoing tab | 1. Click "Past" tab | URL `?tab=past` reflected immediately; browser history has new entry | P1 | Navigation | Yes | URL assertion — `expect(page).toHaveURL(/[?&]tab=past/)` | validate-url |
| CHL_022 | Challenge Detail | navBack param included when list has more than 1 challenge | Ongoing tab loaded with ≥2 challenges | 1. Click any challenge card | URL contains `&navBack=true` | P2 | Navigation | Yes | URL assertion — `expect(page).toHaveURL(/navBack=true/)` | validate-url |
| CHL_023 | Challenge Detail | navBack param absent when single challenge auto-navigates | API returns exactly 1 ongoing challenge | 1. Load `?tab=ongoing` (auto-navigate fires) | URL contains `id=<N>` but does NOT contain `navBack=true` | P2 | Navigation | No | URL assertion — `expect(page).not.toHaveURL(/navBack/)` | validate-url |
| CHL_024 | Challenge Detail | Journey challenge shows milestone carousel | API returns challenge with `layoutType = 'journeyInfo'` | 1. Navigate to journey challenge detail | `<vc-fit-journey-info>` renders; "Next Milestone" label shown if applicable; milestone swiper cards visible | P2 | Functional | No | `getByText('Next Milestone')` | validate-visible |
| CHL_025 | Challenge Detail | Journey rank shows API-driven label, not hardcoded "Rank" | Journey challenge with `rankTitle = "Overall rank"`, `rank = 12` | 1. Open journey challenge detail | Rank displays "Overall rank 12" (not "Rank 12") | P2 | Functional | No | `getByTestId('journey-rank')` ⚠️ ADD data-testid="journey-rank" to `.rank` div in `journey-info.component.html` (legacy) | validate-text |
| CHL_026 | Challenge Detail | Multi-week challenge shows week picker swiper | API returns `weekInfo.totalWeeks = 4` | 1. Open multi-week challenge detail | Week selector swiper visible with 4 tiles; current week tile is active | P2 | Functional | No | `getByTestId('week-picker-tile')` ⚠️ ADD data-testid="week-picker-tile" to `div.week` in `challenge-info.component.html` (legacy) | validate-visible |
| CHL_027 | Challenge Detail | Quit challenge confirmation modal appears | User is on challenge detail; challenge has quit option | 1. Click quit/leave challenge button | SweetAlert2 confirmation modal appears with confirm and cancel options | P2 | Functional | No | `page.locator('.swal2-container')` | validate-visible |
| CHL_028 | Challenge Detail | Certificate download button visible for completed challenge | API returns `certificate.showCertificate = true` | 1. Navigate to completed challenge detail | "Download Certificate" button with PDF icon visible | P2 | Functional | Yes | `getByRole('button', { name: /Download Certificate/ })` | validate-visible |
| CHL_029 | Browser | Refresh on Upcoming tab restores Upcoming tab | User is on `?tab=upcoming` | 1. Navigate to Upcoming tab 2. Press F5 / reload | Page reloads; Upcoming tab is active; `?tab=upcoming` in URL | P1 | Browser | Yes | `getByRole('tab', { name: 'Upcoming' })` | validate-visible |
| CHL_030 | Browser | Direct URL with `?tab=past` opens Past tab | Fresh session, no prior navigation | 1. Navigate directly to `/fit/challenges?tab=past` | Past tab is active; past challenges load | P1 | Browser | Yes | URL assertion — `expect(page).toHaveURL(/[?&]tab=past/)` | validate-url |
| CHL_031 | Browser | Back navigation from detail restores previous tab and list | User navigated from Upcoming tab to detail | 1. Click any upcoming challenge 2. Press browser Back | URL returns to `?tab=upcoming`; Upcoming tab active; list re-renders | P1 | Browser | Yes | `getByRole('tab', { name: 'Upcoming' })` | navigate |
| CHL_032 | Negative | Invalid tab value `?tab=xyz` silently loads Past data | Navigate with crafted URL | 1. Navigate to `/fit/challenges?tab=xyz` | Past challenges API fires; Past data displayed; no tab pill is highlighted as active for "xyz"; no validation error shown | P1 | Negative | Yes | URL assertion — `expect(page).toHaveURL(/tab=xyz/)` | validate-url |
| CHL_033 | Negative | 404 challenge ID shows "Challenge not found" state | Navigate to detail with non-existent ID | 1. Navigate to outlet route with `id=999999` | Detail view shows "Challenge not found" or error state; no unhandled exception | P1 | Negative | Yes | `getByTestId('challenge-not-found')` ⚠️ ADD data-testid="challenge-not-found" to error element in `challenge-info.component.html` (legacy) | validate-text |
| CHL_034 | Negative | Ongoing API failure shows empty state (no dedicated error UI) | Mock `GET /challenge/ongoing/all` to return 500 | 1. Navigate to `?tab=ongoing` 2. Wait | Empty state "No ongoing challenges" shown; no retry button; no toast | P1 | Negative | Yes | `getByText('No ongoing challenges')` | validate-text |
| CHL_035 | Negative | Past API failure shows empty state | Mock `GET /challenge/past/all` to return 500 | 1. Navigate to `?tab=past` | Empty state "No past challenges" shown; pagination nav absent; no JS error | P1 | Negative | Yes | `getByText('No past challenges')` | validate-text |
| CHL_036 | Negative | Past pagination disappears silently when API omits `count` | API returns `past/all` with `data[]` but no `count` field | 1. Load `?tab=past` | `totalPages = 0`; pagination nav not rendered even if 10 rows present | P2 | Negative | No | `getByTestId('past-pagination')` ⚠️ ADD data-testid="past-pagination" to `nav.pc-pagination` in `past-challenges.component.html` | validate-visible |
| CHL_037 | Edge | Single ongoing challenge auto-navigates to detail | API returns exactly 1 ongoing challenge | 1. Navigate to `?tab=ongoing` | User taken directly to detail without clicking; URL contains outlet info path | P1 | Edge | Yes | URL assertion — `expect(page).toHaveURL(/challengesOutlet.*info\|challengesOutlet:info/)` | validate-url |
| CHL_038 | Edge | Progress > 100% — display and bar are inconsistent | API returns challenge with `progress = 115` | 1. Load ongoing card with `progress = 115` | Header text shows "115%"; bar width clamped to 100%; display and bar disagree — known bug (BUG_CH_02) | P2 | Edge | No | `getByTestId('challenge-progress-header')` ⚠️ ADD data-testid="challenge-progress-header" to `.ch-prog-hd` in `summary-challenge-card.component.html` | validate-text |
| CHL_039 | Edge | Long challenge title (>30 chars) applies compact CSS class | API returns challenge with title of 35 characters | 1. Load Ongoing tab 2. Observe card title element | Title `h3` has class `ch-title-compact`; title is visible without overflowing card bounds | P2 | Edge | No | `getByTestId('challenge-title')` ⚠️ ADD data-testid="challenge-title" to `h3.ch-title-leading` in `summary-challenge-card.component.html` | validate-visible |
| CHL_040 | Edge | Long subtitle (>28 chars or colon) shows info-pill, hides CTA in summary variant | API returns challenge with subtitle = "Running: 5km daily challenge goal" | 1. Load Summary Dashboard challenge card (summary variant) | `.ch-info-pill` visible with full subtitle; `button.ch-cta` ("View challenge") NOT rendered | P2 | Edge | No | `getByTestId('challenge-info-pill')` ⚠️ ADD data-testid="challenge-info-pill" to `div.ch-info-pill` in `summary-challenge-card.component.html` | validate-visible |

---

## 🚧 Testability Gaps

### `projects/fit/src/ui/new-ui/pages/challenges-page.component.ts` (inline template)

**No gaps.** Tab buttons rendered by `fit-page-submenu` use `role="tab"` with text labels — fully locatable via `getByRole('tab', { name: '...' })`.

---

### `projects/fit/src/ui/new-ui/components/challenge-list/challenge-list.component.html`

**No gaps.** File contains only conditional sub-component rendering (`*ngIf`) with no interactive or observable elements of its own.

---

### `projects/fit/src/ui/new-ui/components/challenge-list/ongoing-challenges.component.html`

| Suggested `data-testid` | Element | Reason | Used by TCs |
|-------------------------|---------|--------|-------------|
| `ongoing-shimmer` | `div.oc-shim-card` (each skeleton card) | No hook exists; CSS class only | CHL_013 |
| `ongoing-grid` | `div.oc-grid` (loaded state, inside `#ongoingList`) | No hook to confirm list is rendered and not shimmer | CHL_002 |

---

### `projects/fit/src/ui/new-ui/components/challenge-list/upcoming-challenges.component.html`

| Suggested `data-testid` | Element | Reason | Used by TCs |
|-------------------------|---------|--------|-------------|
| `upcoming-shimmer` | `div.uc-shim-row` (each skeleton row) | No hook exists; CSS class only | CHL_014 |
| `upcoming-challenge-row` | `button.uc-row` | No `aria-label` and no `data-testid`; accessible name derived from inner text is dynamic and test-fragile | CHL_019 |
| `challenge-img` | `<fit-img>` inside `button.uc-row` | No hook on image element to assert fallback icon state | CHL_012 |

---

### `projects/fit/src/ui/new-ui/components/challenge-list/past-challenges.component.html`

| Suggested `data-testid` | Element | Reason | Used by TCs |
|-------------------------|---------|--------|-------------|
| `past-shimmer` | `div.pc-shim-row` (each skeleton row) | No hook exists; CSS class only | CHL_015 |
| `past-challenge-row` | `button.pc-row` | No `aria-label` and no `data-testid`; inner text is dynamic | CHL_020 |
| `past-rank-badge` | `span.pc-rank` | No hook to assert rank badge text or visibility | CHL_004 |
| `past-pagination` | `nav.pc-pagination` | No hook for presence/absence assertion of the whole nav block | CHL_036 |
| ✅ Existing | `button[aria-label="Previous page"]` / `button[aria-label="Next page"]` | Both pagination buttons already have `aria-label` — no addition needed | CHL_007, CHL_008, CHL_009 |

---

### `projects/fit/src/ui/new-ui/components/summary-challenge-card/summary-challenge-card.component.html`

| Suggested `data-testid` | Element | Reason | Used by TCs |
|-------------------------|---------|--------|-------------|
| `challenge-card-listing` | `div.ch-slide-standalone` (slideOnly=true, listing variant) | `aria-label="Open <title>"` is dynamic; stable testid required for card-level assertions | CHL_002, CHL_011 |
| `rank-pill` | `span.ch-rank-pill` | No hook to assert rank text content or visibility | CHL_006 |
| `challenge-progress-header` | `div.ch-prog-hd` | No hook to assert progress % text and label; only CSS class | CHL_005, CHL_038 |
| `challenge-title` | `h3.ch-title-leading` (listing variant) | No hook to assert compact class is applied or to read title text | CHL_039 |
| `challenge-info-pill` | `div.ch-info-pill` (summary variant) | No hook to assert pill visibility vs CTA button visibility | CHL_040 |

---

### Legacy files — outside `new-ui/` scope ⚠️ High Risk

These components are mounted inside `challengesOutlet` but live in the legacy tree. Changes here can break Challenges Page tests without touching new-ui code.

| File | Suggested `data-testid` | Element | Used by TCs |
|------|-------------------------|---------|-------------|
| `projects/fit/src/ui/pages/challenge/challenge-info/challenge-info.component.html` | `challenge-not-found` | Error/404 state element — **does not exist yet; entire state needs to be implemented** | CHL_033 |
| `projects/fit/src/ui/pages/challenge/challenge-info/challenge-info.component.html` | `week-picker-tile` | `div.week` inside week swiper | CHL_026 |
| `projects/fit/src/ui/components/journey-info/journey-info.component.html` | `journey-rank` | `.rank` div containing `{{ journeyData.rankTitle }} {{ journeyData.rank }}` | CHL_025 |

---

## 🤖 Automation Notes

- **Framework:** Playwright + TypeScript
- **Locator priority:** `getByTestId` > `getByRole` > `getByLabel` > `getByText` > CSS
- **Cross-reference:** Prototype at `fit-prototype/` for tab URL behavior, 404 handling, journey/standard variations
- **Auto-navigate edge case (CHL_037):** mock API to return exactly 1 challenge via `page.route('**/challenge/ongoing/all', ...)`
- **Mocked endpoints required:**
  - `GET /vantagefit/api/v1/challenge/ongoing/all`
  - `GET /vantagefit/api/v1/challenge/upcoming/all`
  - `GET /vantagefit/api/v1/challenge/past/all`
  - `GET /vantagefit/api/v1/challenge/info`
- **URL assertion pattern:** `expect(page).toHaveURL(/[?&]tab=ongoing/)`
- **Session cache note:** Ongoing and Upcoming use a no-TTL session cache on `FitService` (`ongoingChallengeState`, `upcomingChallengeState`). To test fresh-fetch behaviour, reload the page or clear the cache between test runs.
- **SweetAlert2 (CHL_027):** Renders outside Angular component tree; use `page.locator('.swal2-container')` — not locatable via Angular Testing Library selectors.
- **Legacy outlet risk:** `ChallengeInfoComponent` (detail view) is a legacy component mounted in `challengesOutlet`. Tests for CHL_024–CHL_028, CHL_033 depend on legacy HTML that currently has zero `data-testid` attributes.
- **Pre-automation blocker:** 14 `data-testid` additions required across 5 files before full automation is viable (see Testability Gaps above).
