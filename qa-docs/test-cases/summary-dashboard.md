# Summary Dashboard — Test Cases

**Feature:** Summary Dashboard (new-ui only)  
**Scope:** `projects/fit/src/ui/new-ui/pages/summary-page.component.*` and direct child components  
**Child components in scope:**
- `components/summary-snapshot-card/`
- `components/summary-challenge-card/`
- `components/summary-badge-card/`

**Out of scope (legacy dependencies, test separately):**
- `projects/fit/src/ui/components/community/` (`vc-fit-community`)

---

## 🚦 Smoke Test Checklist (P1 only)

- [ ] SUM_001 — Summary page loads for authenticated user
- [ ] SUM_002 — Page header shows "Summary" and today's date
- [ ] SUM_003 — Shimmer/skeleton shown while data is loading
- [ ] SUM_004 — Snapshot card renders with activity rings and stats
- [ ] SUM_005 — "Open Diary" CTA navigates to diary page
- [ ] SUM_010 — Challenge card renders with title, image, and progress bar
- [ ] SUM_011 — "View challenge" button navigates to challenge detail
- [ ] SUM_016 — Badge card renders with medal, title, and subtitle
- [ ] SUM_020 — Support row (league tile, vitals, health) visible for standard user
- [ ] SUM_025 — One-time client: support row hidden
- [ ] SUM_026 — One-time client: highlights row hidden
- [ ] SUM_027 — One-time client: "Open Diary" opens DiarySnapshotDialog (not routing)
- [ ] SUM_031 — Unauthenticated access redirects to /auth
- [ ] SUM_032 — API error: error state/fallback shown

---

## 📋 Full Test Case Table

| TC_ID | Module | Scenario | Pre-condition | Steps | Expected Result | Priority | Type | Automation | Locator Hint | Interaction Type |
|-------|--------|----------|---------------|-------|-----------------|----------|------|------------|--------------|-----------------|
| SUM_001 | Summary Page | Page loads for authenticated user | User is logged in | 1. Navigate to `/fit/summary` | Page renders without console errors; main grid visible | P1 | Functional | Yes | `getByTestId('summary-page')` ⚠️ ADD data-testid="summary-page" to `<div class="page-wrap">` | validate-text |
| SUM_002 | Summary Page | Header shows "Summary" and today's date | User is logged in, page loaded | 1. Observe page header section | h1 reads "Summary"; date string matches today in `d MMM yyyy` format | P1 | Functional | Yes | `getByRole('heading', { level: 1 })` | validate-text |
| SUM_003 | Summary Page | Shimmer shown while loading | Network throttled to Slow 3G | 1. Navigate to `/fit/summary` 2. Observe immediately | `fit-page-shimmer` component visible; main grid not visible | P1 | State | Yes | `getByTestId('page-shimmer')` ⚠️ ADD data-testid="page-shimmer" to `<fit-page-shimmer>` | validate-text |
| SUM_004 | Snapshot Card | Card renders with rings and stats | API returns valid home data | 1. Wait for load 2. Observe snapshot card area | SVG rings visible (`.ring-outer`, `.ring-inner`); stats list has ≥1 `<li>` entries | P1 | Functional | Yes | `getByTestId('snapshot-card')` ⚠️ ADD data-testid="snapshot-card" to `<fit-summary-snapshot-card>` | validate-text |
| SUM_005 | Snapshot Card | "Open Diary" CTA navigates to diary | User is standard (not one-time client) | 1. Click "Open Diary" button | URL changes to `/fit/today` | P1 | Navigation | Yes | `getByRole('button', { name: 'Open Diary' })` | click |
| SUM_006 | Snapshot Card | Stat values display with correct format | API returns numeric metrics | 1. Observe stat items in snapshot card | Each `.stat-current` shows integer (no decimals); % bars show `X%` with `number:'1.0-0'` pipe applied | P2 | UI | Yes | `getByTestId('stat-item')` ⚠️ ADD data-testid="stat-item" to each `<li>` in `ul.stats` | validate-text |
| SUM_007 | Snapshot Card | Stat bar width reflects percentage | API returns metrics with varying pct values | 1. Observe `.bar-pct` elements 2. Compare widths to displayed % values | Bar inline width matches the displayed percentage value | P2 | UI | No | `getByTestId('stat-bar')` ⚠️ ADD data-testid="stat-bar" to `.bar-pct` | validate-text |
| SUM_008 | Snapshot Card | Insight footer renders | API returns trends caption | 1. Observe `.snap-foot` area | Insight text from `trends.caption` is visible in footer | P2 | Functional | Yes | `getByTestId('snapshot-footer')` ⚠️ ADD data-testid="snapshot-footer" to `.snap-foot` | validate-text |
| SUM_009 | Snapshot Card | "View Trends" link navigates correctly | Page loaded | 1. Click "View Trends" link/button | URL changes to `/fit/activity-stats` | P2 | Navigation | Yes | `getByTestId('view-trends-btn')` ⚠️ ADD data-testid="view-trends-btn" to trends CTA | click |
| SUM_010 | Challenge Card | Card renders with title, image, and progress bar | API returns ≥1 challenge | 1. Observe challenge card | Article has eyebrow pill, title, image, and progress bar (`.ch-prog-fg`) visible | P1 | Functional | Yes | `getByRole('article', { name: /^Open / })` | validate-text |
| SUM_011 | Challenge Card | "View challenge" navigates to challenge | Challenge card loaded | 1. Click `button.ch-cta` ("View challenge") | URL changes to challenge detail route | P1 | Navigation | Yes | `getByRole('button', { name: 'View challenge' })` | click |
| SUM_012 | Challenge Card | Pagination dots update on slide navigation | API returns ≥2 challenges | 1. Click next chevron 2. Observe dots | Active dot moves to index 1; slide transitions to second challenge | P2 | Functional | Yes | `getByRole('button', { name: 'Next challenge' })` | click |
| SUM_013 | Challenge Card | Previous button disabled on first slide | Page loaded with challenges | 1. Observe prev button on slide 0 | Prev button (`aria-label="Previous challenge"`) is disabled or absent | P2 | UI | Yes | `getByRole('button', { name: 'Previous challenge' })` | validate-text |
| SUM_014 | Challenge Card | Rank pill visible when rank > 0 | API returns challenge with `rank > 0` | 1. Observe `.ch-rank-pill` | Rank pill visible with correct rank text | P2 | Functional | Yes | `getByTestId('rank-pill')` ⚠️ ADD data-testid="rank-pill" to `.ch-rank-pill` | validate-text |
| SUM_015 | Challenge Card | Long subtitle shows info pill instead of CTA | API returns challenge with subtitle > threshold | 1. Observe challenge card with long subtitle | `.ch-info-pill` visible; `button.ch-cta` ("View challenge") not rendered | P3 | UI | No | `getByTestId('challenge-info-pill')` ⚠️ ADD data-testid="challenge-info-pill" to `.ch-info-pill` | validate-text |
| SUM_016 | Badge Card | Card renders with medal, title, subtitle | API returns badge data | 1. Observe badge card | `.aw-medal`, `h3.aw-title`, `.aw-sub`, `.aw-label` all visible | P1 | Functional | Yes | `getByTestId('badge-card')` ⚠️ ADD data-testid="badge-card" to `<fit-summary-badge-card>` | validate-text |
| SUM_017 | Badge Card | Locked badge has locked visual state | API returns `badge.isUnlocked = false` | 1. Observe badge card | Article has class `aw-locked`; `aria-disabled="true"` present | P2 | UI | Yes | `getByTestId('badge-article')` ⚠️ ADD data-testid="badge-article" to `<article>` in badge card | validate-text |
| SUM_018 | Badge Card | Unlocked badge does not show locked state | API returns `badge.isUnlocked = true` | 1. Observe badge card | Article does NOT have class `aw-locked`; `aria-disabled="false"` | P2 | UI | Yes | `getByTestId('badge-article')` ⚠️ ADD data-testid="badge-article" to `<article>` in badge card | validate-text |
| SUM_019 | Badge Card | Badge aria-label matches badge title | API returns badge with known title | 1. Inspect article element aria-label | `aria-label` equals `badge.title` from API response | P2 | UI | Yes | `getByTestId('badge-article')` ⚠️ ADD data-testid="badge-article" to `<article>` | validate-text |
| SUM_020 | Support Row | League tile, vitals, health visible for standard user | Standard user, all data present | 1. Observe support row below main grid | League tile, vitals tile, and health tile all rendered | P1 | Functional | Yes | `getByTestId('support-row')` ⚠️ ADD data-testid="support-row" to support row container | validate-text |
| SUM_021 | Support Row | League tile has correct data-tier attribute | API returns `leagueLevel = "Gold"` | 1. Inspect league tile DOM | `[data-tier]` = `"gold"` (lowercase) | P2 | Functional | Yes | `getByTestId('league-tile')` ⚠️ ADD data-testid="league-tile" to league tile | validate-text |
| SUM_022 | Support Row | Support row hidden when data is null | API returns null vitals/health | 1. Observe support row | Support row tiles for null data are not rendered (controlled by `hasSupportRow` / `hasSupportStats`) | P2 | Edge | No | `getByTestId('support-row')` ⚠️ ADD data-testid="support-row" | validate-text |
| SUM_023 | Highlights | Up to 6 community feed cards shown | API returns ≥6 feeds | 1. Observe highlights section | Max 6 `vc-fit-community` cards rendered (slice:0:6) | P2 | Functional | Yes | `getByTestId('highlights-section')` ⚠️ ADD data-testid="highlights-section" to highlights row | validate-text |
| SUM_024 | Highlights | "See all highlights" button navigates to community | Highlights section loaded | 1. Click button `aria-label="See all highlights"` | URL changes to `/fit/community` | P2 | Navigation | Yes | `getByRole('button', { name: 'See all highlights' })` | click |
| SUM_025 | One-Time Client | Support row hidden for one-time client | `isOneTimeClient = true` in config | 1. Log in as one-time client 2. Navigate to summary | Support row not rendered | P1 | Functional | Yes | `getByTestId('support-row')` ⚠️ ADD data-testid="support-row" | validate-text |
| SUM_026 | One-Time Client | Highlights row hidden for one-time client | `isOneTimeClient = true` | 1. Log in as one-time client 2. Navigate to summary | Highlights section not rendered | P1 | Functional | Yes | `getByTestId('highlights-section')` ⚠️ ADD data-testid="highlights-section" | validate-text |
| SUM_027 | One-Time Client | "Open Diary" opens dialog, not route | `isOneTimeClient = true` | 1. Click "Open Diary" button | `DiarySnapshotDialogComponent` modal opens; URL does NOT change to `/fit/today` | P1 | Functional | Yes | `getByRole('button', { name: 'Open Diary' })` | click |
| SUM_028 | One-Time Client | One-time client nav restricted to Summary + Challenges | `isOneTimeClient = true` | 1. Inspect navigation tabs | Only Summary and Challenges tabs visible in nav | P2 | Functional | No | `getByTestId('nav-tabs')` ⚠️ ADD data-testid="nav-tabs" to nav container | validate-text |
| SUM_029 | Edge Case | Zero value metric displayed as "0" not blank | API returns metric with value = 0 | 1. Observe snapshot stats with 0-value metric | Stat shows "0", not empty string or hidden | P2 | Edge | Yes | `getByTestId('stat-current')` ⚠️ ADD data-testid="stat-current" to `.stat-current` | validate-text |
| SUM_030 | Edge Case | Single challenge — no dots, no nav arrows | API returns exactly 1 challenge | 1. Observe challenge card | `.ch-dots` has 1 dot; prev/next buttons absent or disabled | P2 | Edge | Yes | `getByTestId('challenge-dots')` ⚠️ ADD data-testid="challenge-dots" to `.ch-dots` | validate-text |
| SUM_031 | Auth / Security | Unauthenticated user redirected to auth | User is logged out | 1. Navigate directly to `/fit/summary` | Redirected to `/auth` | P1 | Negative | Yes | `getByTestId('auth-page')` ⚠️ ADD data-testid="auth-page" to auth component | validate-text |
| SUM_032 | State | API error shows error state / fallback | Mock API to return 500 | 1. Navigate to `/fit/summary` | Error feedback shown or graceful empty state (no unhandled exception, no blank white screen) | P1 | Negative | Yes | `getByTestId('error-state')` ⚠️ ADD data-testid="error-state" to error fallback element | validate-text |
| SUM_033 | State | Empty challenges array — card handles gracefully | API returns `challenges: []` | 1. Load summary page | Challenge card shows empty state or is hidden; no JS error | P2 | Negative | Yes | `getByRole('article', { name: /^Open / })` | validate-text |
| SUM_034 | State | Null badge info — badge card hidden or empty state | API returns `latestBadgeInfo: null` | 1. Load summary page | Badge card not rendered or shows placeholder; no runtime error | P2 | Negative | Yes | `getByTestId('badge-card')` ⚠️ ADD data-testid="badge-card" | validate-text |
| SUM_035 | State | RateLimiter serves stale cache on second visit within 5 min | Visit page, leave, return within 5 min | 1. Navigate to summary 2. Note data 3. Navigate away 4. Return within 5 min | Data loads instantly from cache; no new network request to `/api/v1/app/home` | P3 | Edge | No | Network panel (no locator) | validate-network |

---

## 🚧 Testability Gaps

All 4 HTML templates currently have **zero `data-testid` attributes**. The following additions are required before automation can be implemented.

### `projects/fit/src/ui/new-ui/pages/summary-page.component.html`

| Suggested `data-testid` | Element | Used by TCs |
|-------------------------|---------|-------------|
| `summary-page` | `<div class="page-wrap">` (root wrapper) | SUM_001 |
| `page-shimmer` | `<fit-page-shimmer>` | SUM_003 |
| `snapshot-card` | `<fit-summary-snapshot-card>` | SUM_004 |
| `view-trends-btn` | Trends article CTA button/link | SUM_009 |
| `support-row` | Support row container | SUM_020, SUM_022, SUM_025 |
| `league-tile` | League tile element | SUM_021 |
| `highlights-section` | Highlights row container | SUM_023, SUM_026 |
| `nav-tabs` | Navigation tabs container | SUM_028 |
| `error-state` | Error fallback element | SUM_032 |

### `projects/fit/src/ui/new-ui/components/summary-snapshot-card/summary-snapshot-card.component.html`

| Suggested `data-testid` | Element | Used by TCs |
|-------------------------|---------|-------------|
| `stat-item` | Each `<li>` in `ul.stats` | SUM_006 |
| `stat-bar` | `.bar-pct` span inside each stat `<li>` | SUM_007 |
| `stat-current` | `.stat-current` span | SUM_029 |
| `snapshot-footer` | `.snap-foot` element | SUM_008 |

### `projects/fit/src/ui/new-ui/components/summary-challenge-card/summary-challenge-card.component.html`

| Suggested `data-testid` | Element | Used by TCs |
|-------------------------|---------|-------------|
| `rank-pill` | `.ch-rank-pill` | SUM_014 |
| `challenge-info-pill` | `.ch-info-pill` | SUM_015 |
| `challenge-dots` | `.ch-dots` container | SUM_030 |

### `projects/fit/src/ui/new-ui/components/summary-badge-card/summary-badge-card.component.html`

| Suggested `data-testid` | Element | Used by TCs |
|-------------------------|---------|-------------|
| `badge-card` | `<fit-summary-badge-card>` (in parent) | SUM_016, SUM_034 |
| `badge-article` | `<article>` inside badge card template | SUM_017, SUM_018, SUM_019 |

---

## 🤖 Automation Notes

- **Framework:** Playwright (not yet set up; codebase currently uses Karma/Jasmine only)
- **Locator priority:** `getByTestId` > `getByRole` > `getByLabel` > `getByText` > CSS
- **Pre-automation blocker:** All 17 `data-testid` gaps above must be resolved by devs before full automation is viable
- **Partially automatable now (existing hooks):**
  - `getByRole('heading', { level: 1 })` — page title (SUM_002)
  - `getByRole('button', { name: 'Open Diary' })` — diary CTA (SUM_005, SUM_027)
  - `getByRole('button', { name: 'See all highlights' })` — highlights nav (SUM_024)
  - `getByRole('button', { name: 'Previous challenge' })` — challenge prev (SUM_013)
  - `getByRole('button', { name: 'Next challenge' })` — challenge next (SUM_012)
  - `getByRole('article', { name: /^Open / })` — challenge card (SUM_010, SUM_033)
  - `getByRole('button', { name: 'View challenge' })` — challenge CTA (SUM_011)
- **One-time client tests (SUM_025–028):** Require test account with `isOneTimeClient = true` in `/api/v1/configuration` response, or mock via MSW/intercept
- **SUM_035 (cache test):** Cannot be automated with Playwright locators alone; requires network interception (`page.route`) to assert no second request
- **Legacy risk:** `vc-fit-community` component in Highlights section is from legacy codebase — locators inside it are not covered here; treat as black-box in summary tests
