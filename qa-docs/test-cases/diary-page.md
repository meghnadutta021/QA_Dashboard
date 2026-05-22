# 🧪 Diary Page — Test Cases

**Feature:** Diary Page (new-ui only)
**Page:** /fit/today
**Component Path:** projects/fit/src/ui/new-ui/pages/diary-page/diary-page.component.ts
**Cross-reference Prototype:** ❌ Not available — generated from Angular code + design screenshots
**Last Updated:** 2026-05-21
**Total Test Cases:** 48
**Automation Framework:** Playwright (planned)

---

## ⚠️ Critical Risk Areas

| Risk | Detail |
|------|--------|
| Legacy dialog boundary | Diary uses LEGACY log dialogs from `projects/fit/src/ui/dialogs/log-*-dialog/` — 17 TCs cross the legacy boundary. These dialogs have no `role="dialog"`, no `aria-label`, and no `data-testid` on interactive elements. Automation is blocked until testability gaps are resolved. |
| One-time client redirect | One-time clients (`isOneTimeClient = true`) are redirected to `/fit/summary` by `DiaryGuard` — the full diary page never renders for them. They see `DiarySnapshotDialogComponent` instead. |
| Date / timezone handling | Midnight rollover behaviour is implementation-dependent. "Today" is computed client-side with no URL persistence — refresh always resets to today regardless of which date was being viewed. |
| No URL persistence for date | Selected date is held in component state only. There is no `?date=` URL param. A page reload always returns to today; deep-linking to a past date is not possible. |

---

## 🐛 Bugs Found (Pre-Development)

| # | Description | Related TC | Severity |
|---|-------------|------------|----------|
| BUG_DI_01 | Balance = 0 shows "Surplus" text (condition `>= 0`) but `[class.surplus]` binding uses strict `> 0` — at exactly 0 the text reads "Surplus" yet the `.surplus` CSS class is absent, creating an inconsistent visual state | DIA_040 | P2 |
| BUG_DI_02 | Mood dialog: `rawValue` outside 0–4 causes `findIndex()` to return -1; `moods[-1]` is `undefined`; `selectedMood` is null. Dialog opens with `defaultGradient` applied and no mood pre-selected — no guard or fallback exists | DIA_043 | P2 |
| BUG_DI_03 | Weight above 200 kg (or 440 lbs) is silently clamped to 200 by `validateWeight()` with no error message or user feedback — the user has no indication the value was changed | DIA_029 | P2 |

---

## 🚦 Smoke Test Checklist (P1 only)

- [ ] DIA_001 — Page loads for authenticated user showing today
- [ ] DIA_002 — Full-page shimmer shown on initial load
- [ ] DIA_004 — Snapshot card displays steps and active minutes rings
- [ ] DIA_005 — Calorie Ledger shows Meals, Resting, Active, Balance
- [ ] DIA_009 — Sleep card shows logged duration
- [ ] DIA_017 — Previous day button navigates to yesterday
- [ ] DIA_018 — Next day button disabled when on today
- [ ] DIA_019 — Date pill shows "Today" when viewing today
- [ ] DIA_021 — Refreshing diary always resets to today (no URL persistence)
- [ ] DIA_023 — Water dialog opens with current glass count pre-filled
- [ ] DIA_024 — Water logged via legacy dialog reflects on Intake card after save
- [ ] DIA_025 — Mood logged via legacy dialog reflects on Vitals card
- [ ] DIA_026 — Weight logged via legacy dialog reflects on Vitals card
- [ ] DIA_027 — Sleep logged via legacy dialog reflects on Sleep card
- [ ] DIA_028 — Weight below minimum (20 kg) shows snackbar error, does not save
- [ ] DIA_031 — Sleep save blocked when wake time ≤ bed time
- [ ] DIA_032 — Stats API 500 failure: all stat cards silently show empty states
- [ ] DIA_033 — Activities API failure: empty state shown silently
- [ ] DIA_036 — Future date navigation is fully blocked
- [ ] DIA_044 — One-time client: `/fit/today` redirected to `/fit/summary` by DiaryGuard
- [ ] DIA_045 — DiarySnapshotDialog shows rings + date switcher only (one-time client)

---

## 📋 Full Test Case Table

| TC_ID | Module | Scenario | Pre-condition | Steps | Expected Result | Priority | Type | Automation | Locator Hint | Interaction Type |
|-------|--------|----------|---------------|-------|-----------------|----------|------|------------|--------------|-----------------|
| DIA_001 | Diary Page | Page loads for authenticated user showing today | User is logged in, standard (not one-time) client | 1. Navigate to `/fit/today` | Page renders without errors; h1 "Diary" visible; subtitle shows "Today · DD Month YYYY"; all 8 cards visible in grid | P1 | Functional | Yes | `page.getByRole('heading', { level: 1, name: 'Diary' })` | validate-visible |
| DIA_002 | Diary Page | Full-page shimmer shown on initial load | Network throttled to Slow 3G | 1. Navigate to `/fit/today` 2. Observe immediately | `fit-page-shimmer` renders; no card content visible during load | P1 | State | Yes | `page.locator('fit-page-shimmer')` ⚠️ ADD data-testid="page-shimmer" to `<fit-page-shimmer>` in `diary-page.component.html` | validate-visible |
| DIA_003 | Diary Page | Per-card skeleton shown on date change (not full-page shimmer) | Diary page loaded on today | 1. Click "Previous day" button 2. Observe immediately | Individual `div.card-skeleton` shown per card; full-page shimmer NOT re-shown | P2 | State | Yes | `page.locator('.card-skeleton').first()` ⚠️ ADD data-testid="card-skeleton" to `div.card-skeleton` in each card | validate-visible |
| DIA_004 | Diary Page | Snapshot card displays steps and active minutes rings | API returns `stepsData` with `totalSteps = 8000`, `targetSteps = 10000` | 1. Load diary for today 2. Observe snapshot card | Rings visible; steps ring reflects 80% fill; "View Trends" CTA button present; insight footer hidden | P1 | Functional | No | `page.getByRole('button', { name: 'View Trends' })` | validate-visible |
| DIA_005 | Diary Page | Calorie Ledger shows Meals, Resting, Active, Balance | API returns `intakeCaloriesData` with all 4 fields | 1. Load diary page 2. Observe Calorie Ledger card | Labels "Meals", "Resting", "Active", "Balance" visible; values shown as integers (no decimals); equation layout rendered | P1 | Functional | Yes | `page.getByRole('heading', { level: 2, name: 'Calorie Ledger' })` | validate-text |
| DIA_006 | Diary Page | Balance label shows "Surplus" when balance ≥ 0 | API returns `balance = 200` | 1. Load diary page 2. Observe Balance cell unit label | "Surplus" text shown in `.cal-cell-unit`; `.surplus` CSS class applied to balance cell | P2 | Functional | No | `page.locator('.cal-cell-balance .cal-cell-unit')` ⚠️ ADD data-testid="calorie-balance-unit" to `.cal-cell-unit` inside `.cal-cell-balance` | validate-text |
| DIA_007 | Diary Page | Balance label shows "Deficit" when balance < 0 | API returns `balance = -150` | 1. Load diary page 2. Observe Balance cell | "Deficit" text shown; `.surplus` class absent from balance cell | P2 | Functional | No | `page.locator('.cal-cell-balance .cal-cell-unit')` ⚠️ ADD data-testid="calorie-balance-unit" | validate-text |
| DIA_008 | Diary Page | Food Log shows up to 3 items with meal type and kcal | API returns food history with 5 items | 1. Load diary page 2. Observe Food Log card | Exactly 3 food rows shown (`slice:0:3`); each row shows food name, meal type (BREAKFAST/LUNCH etc.), calorie value; header shows "5 items · N kcal" | P2 | Functional | Yes | `page.getByRole('heading', { level: 2, name: 'Food Log' })` | validate-count |
| DIA_009 | Diary Page | Sleep card shows logged duration | API returns `sleepData.data[0].value = "7h 30m"` | 1. Load diary page 2. Observe Sleep card | `.sleep-duration` shows "7h 30m"; `.sleep-caption` shows "Total sleep duration" | P1 | Functional | Yes | `page.getByText('Total sleep duration')` | validate-text |
| DIA_010 | Diary Page | Intake card shows water value and progress bar | API returns water `rawValue = 1.5` (litres) | 1. Load diary page 2. Observe Intake card water row | "1.5 / 2.5 L" shown; progress bar visible at 60% width; water icon rendered | P2 | Functional | Yes | `page.getByRole('heading', { level: 2, name: 'Intake' })` | validate-text |
| DIA_011 | Diary Page | Distance card always shows 3 rows (Moved, Jog·Run, Cycling) | API returns `distanceData` with values for some rows | 1. Load diary page 2. Observe Distance card | Exactly 3 rows rendered: "Moved", "Jog / Run", "Cycling"; rows with 0 or missing values show "—" | P2 | Functional | Yes | `page.getByRole('heading', { level: 2, name: 'Distance' })` | validate-count |
| DIA_012 | Diary Page | Activities card shows up to 3 rows; "View all" appears for >3 | API returns 5 logged activities | 1. Load diary page 2. Observe Activities card | 3 activity rows shown; header shows "5 logged"; "View all" button visible | P2 | Functional | Yes | `page.getByRole('button', { name: /View all/ })` | validate-visible |
| DIA_013 | Diary Page | Vitals card shows Mood, Heart Rate, Weight values | API returns all 3 vitals rows | 1. Load diary page 2. Observe Vitals card | "Mood" row shows value; "Heart Rate" row shows value; "Weight" row shows value; no "+" log buttons visible | P2 | Functional | Yes | `page.getByRole('heading', { level: 2, name: 'Vitals' })` | validate-text |
| DIA_014 | Navigation | "View Trends" button navigates to activity stats | Diary page loaded | 1. Click "View Trends" button on snapshot card | URL changes to `/fit/activity-stats` | P2 | Navigation | Yes | `page.getByRole('button', { name: 'View Trends' })` | click |
| DIA_015 | Navigation | "Log activity" empty-state button navigates to log activity page | Activities card shows empty state | 1. Click "Log activity" button | URL changes to `/fit/log-activity` | P2 | Navigation | Yes | `page.getByRole('button', { name: /Log activity/ })` | click |
| DIA_016 | Navigation | "View all" activities link navigates to log activity page | Activities card shows >3 logged activities | 1. Click "View all" link in Activities header | URL changes to `/fit/log-activity` | P2 | Navigation | Yes | `page.getByRole('button', { name: /View all/ })` | click |
| DIA_017 | Navigation | Previous day button navigates to yesterday | Diary page on today | 1. Note today's date 2. Click `aria-label="Previous day"` button | Date label in header updates to yesterday's weekday and date; data reloads for yesterday | P1 | Navigation | Yes | `page.getByRole('button', { name: 'Previous day' })` | click |
| DIA_018 | Navigation | Next day button disabled when on today | Diary page showing today's date | 1. Observe Next day button | Button has `disabled` attribute; clicking does nothing; date does not advance | P1 | Navigation | Yes | `page.getByRole('button', { name: 'Next day' })` | validate-visible |
| DIA_019 | Date Logic | Date pill shows "Today" when viewing today | Diary on today | 1. Load `/fit/today` 2. Observe date picker pill label | Pill shows timer icon + "Today" text | P1 | Date Logic | Yes | `page.getByRole('group', { name: 'Selected date' })` | validate-text |
| DIA_020 | Date Logic | Date pill shows short date (e.g., "20 May") for past dates | Navigate to a past date | 1. Click "Previous day" 2. Observe date pill | Pill shows short date format (en-GB: "D MMM"), not "Today" | P2 | Date Logic | Yes | `page.getByRole('group', { name: 'Selected date' })` | validate-text |
| DIA_021 | Date Logic | Refreshing diary always resets to today (no URL persistence) | User navigated to yesterday's diary | 1. Navigate to yesterday via prev arrow 2. Reload page (F5) | Page reloads showing today's data; date pill shows "Today"; yesterday's data not restored | P1 | Date Logic | Yes | `page.getByRole('group', { name: 'Selected date' })` (assert text contains "Today") | navigate |
| DIA_022 | Date Logic | Midnight rollover: "Today" re-evaluates when session spans midnight | Session active; clock passes midnight | 1. Load diary at 11:59 PM 2. Wait until 12:00 AM 3. Click "Previous day" then "Next day" | Next day re-evaluates to new "Today"; date label and button states update correctly; old "today" is now navigable | P3 | Date Logic | No | `page.getByRole('button', { name: 'Next day' })` | validate-visible |
| DIA_023 | Cross-Boundary | Water dialog opens with current glass count pre-filled | Diary loaded; API shows `waterLitres = 1.0` (4 glasses) | 1. Click `aria-label="Log water"` button 2. Observe water dialog | Dialog opens; beaker shows 4 glasses filled; counter shows "4 Glass(es)"; unit = "ml" (hardcoded in diary) | P1 | Cross-Boundary | No | `page.getByRole('button', { name: 'Log water' })` — ⚠️ LEGACY DIALOG — further locators depend on `log-water-dialog.component.html` | click |
| DIA_024 | Cross-Boundary | Water logged via legacy dialog reflects on Intake card after save | Water dialog open at 4 glasses | 1. Add 2 more glasses (total 6) 2. Click "Save Water Intake" 3. Observe Intake card | Dialog closes; Intake card reloads; water row shows updated value (6 glasses = 1.5 L); progress bar width updates | P1 | Cross-Boundary | No | `page.getByRole('button', { name: 'Save Water Intake' })` — ⚠️ LEGACY DIALOG — button text confirmed in `log-water-dialog.component.html` | click |
| DIA_025 | Cross-Boundary | Mood logged via legacy dialog reflects on Vitals card | Vitals card shows "+" mood log button (not yet logged) | 1. Click `aria-label="Log mood"` 2. Select "Awesome" (index 4) 3. Click "Next" 4. Select a reason 5. Click "Submit" | Dialog closes; Vitals card reloads; Mood row shows value; "+" log button disappears | P1 | Cross-Boundary | No | `page.getByRole('button', { name: 'Log mood' })` then `page.getByRole('button', { name: 'Next' })` / `page.getByRole('button', { name: 'Submit' })` — ⚠️ LEGACY DIALOG — mood `.icon-btn` elements have no aria-label | click |
| DIA_026 | Cross-Boundary | Weight logged via legacy dialog reflects on Vitals card | Vitals shows "Not logged" + "+" for weight | 1. Click `aria-label="Log weight"` 2. Set weight to 75 kg 3. Click "Save Changes" | Dialog closes; Vitals card reloads; Weight row shows "75 kg" (formatted); "+" weight log button disappears | P1 | Cross-Boundary | No | `page.getByRole('button', { name: 'Log weight' })` then `page.getByRole('button', { name: 'Save Changes' })` — ⚠️ LEGACY DIALOG | click |
| DIA_027 | Cross-Boundary | Sleep logged via legacy dialog reflects on Sleep card | Sleep card shows "Add Sleep Data" (not yet logged) | 1. Click "Add Sleep Data" button 2. Confirm defaults (bed 9 PM previous night, wake 5 AM today) 3. Click "Save" | Dialog closes; Sleep card reloads; duration value shown (e.g., "8h 0m"); "Add Sleep Data" button disappears | P1 | Cross-Boundary | No | `page.getByRole('button', { name: /Add Sleep Data/ })` then `page.getByRole('button', { name: 'Save' })` — ⚠️ LEGACY DIALOG — time inputs use hidden `ngxTimepicker` | click |
| DIA_028 | Negative | Weight below minimum (20 kg) shows snackbar error, does not save | Weight dialog open | 1. Enter weight = 15 2. Click "Save Changes" | Snackbar shows "Weight must be at least 20 KG or 44 LBS."; dialog stays open; no API call fired | P1 | Negative | No | `page.getByRole('button', { name: 'Save Changes' })` — ⚠️ LEGACY DIALOG — snackbar selector unverified; no snackbar element in `log-weight-dialog.component.html` | validate-text |
| DIA_029 | Negative | Weight above maximum (200 kg) silently clamped to 200 — no error shown (BUG_DI_03) | Weight dialog open | 1. Type 250 in weight input 2. Observe input value | Input clamps to 200; no error message; "Save Changes" enabled | P2 | Negative | No | `page.locator('input.stepper-input')` ⚠️ ADD data-testid="weight-input" to `input.stepper-input` in `log-weight-dialog.component.html` — ⚠️ LEGACY DIALOG | validate-text |
| DIA_030 | Negative | Water at 0 glasses: Save button disabled | Water dialog open | 1. Ensure glass count = 0 (remove all glasses) 2. Observe Save button | "Save Water Intake" button disabled (`[disabled]="glassCount > 0 ? false : true"`) | P2 | Negative | Yes | `page.getByRole('button', { name: 'Save Water Intake' })` — ⚠️ LEGACY DIALOG — `[disabled]` binding confirmed in `log-water-dialog.component.html` | validate-visible |
| DIA_031 | Negative | Sleep save blocked when wake time ≤ bed time | Sleep dialog open | 1. Set bed time to 06:00 AM today 2. Set wake time to 05:00 AM today (earlier) 3. Click "Save" | Snackbar shows "Wake time must be after bed time."; save blocked; dialog stays open | P1 | Negative | No | `page.getByRole('button', { name: 'Save' })` — ⚠️ LEGACY DIALOG — time inputs use hidden `ngxTimepicker`; no accessible name on inputs | validate-text |
| DIA_032 | Negative | Stats API 500 failure: all stat cards silently show empty states | Mock `POST /today/overview` to return 500 | 1. Navigate to diary page | All stat-driven cards (Sleep, Calorie Ledger, Distance, Vitals, Intake) show empty states; no error banner or retry button | P1 | Negative | No | `page.getByText('No calorie data for this day.')` | validate-text |
| DIA_033 | Negative | Activities API failure: empty state shown silently | Mock `GET /today/overview/activities` to return 500 | 1. Navigate to diary page | Activities card shows "No activities logged." empty state; no error indicator; no retry button | P1 | Negative | Yes | `page.getByText('No activities logged.')` | validate-text |
| DIA_034 | Negative | Network drop mid-save: mood save fails, snackbar shows error | Mood dialog open; network disconnected before save | 1. Select mood 2. Click "Next" 3. Select reason 4. Click "Submit" | API call fails; snackbar shows error from `error?.error?.err`; dialog stays open; loader hidden; Vitals card not updated | P2 | Negative | No | ⚠️ LEGACY DIALOG — `page.locator('.mdc-snackbar')` unverified; no snackbar element in `log-mood-dialog.component.html` — snackbar likely emitted by parent service | validate-text |
| DIA_035 | Edge | Zero steps: snapshot rings render at 0% fill, not broken | API returns `totalSteps = 0`, `targetSteps = 10000` | 1. Load diary page 2. Observe snapshot rings | Rings render with 0% fill (empty rings); "0 / 10000" or equivalent label; no crash | P2 | Edge | No | `page.locator('fit-summary-snapshot-card')` ⚠️ ADD data-testid="snapshot-card" to `<fit-summary-snapshot-card>` in `diary-page.component.html` | validate-visible |
| DIA_036 | Edge | Future date navigation is fully blocked | Diary on today | 1. Inspect Next day button 2. Attempt forward navigation via click or keyboard | Next button disabled; no forward navigation possible; date does not change; no URL param exists to manually navigate forward | P1 | Edge | Yes | `page.getByRole('button', { name: 'Next day' })` | validate-visible |
| DIA_037 | Edge | Water intake > 2.5 L: progress bar capped at 100%, displayed value shows actual | API returns `waterLitres = 3.2` | 1. Load diary page 2. Observe Intake water row | "3.2 / 2.5 L" shown as text; progress bar fill width is 100% (clamped by `Math.min(100, ...)`); bar does not overflow container | P2 | Edge | No | `page.locator('.intake-water-bar-fill')` ⚠️ ADD data-testid="water-progress-bar" to `div.intake-water-bar-fill` in `diary-page.component.html` | validate-visible |
| DIA_038 | Edge | Navigating to a very old past date (no lower bound) | Diary on today | 1. Click "Previous day" repeatedly 30+ times (or mock `selectedDate` to 3 years ago) | Page loads data for that date (or empty states); no error; no redirect; no lower-bound guard fires | P2 | Edge | No | `page.getByRole('button', { name: 'Previous day' })` | click |
| DIA_039 | Edge | Partial data: some sections logged, others show empty states | API returns stats with food + activities data but no sleep/vitals | 1. Load diary page | Food Log and Activities show data; Sleep shows "No Data" empty state; Vitals shows "+" buttons and "Not logged"; no cross-card error | P2 | Edge | No | `page.getByText('No Data')` | validate-visible |
| DIA_040 | Edge | Balance = 0 exactly shows "Surplus" text but .surplus CSS class absent (BUG_DI_01) | API returns `balance = 0` | 1. Load diary page 2. Observe Balance cell unit label | "Surplus" text shown (condition: `>= 0`); note: `.surplus` CSS class NOT applied (binding uses `> 0`) — inconsistent state | P2 | Edge | No | `page.locator('.cal-cell-balance .cal-cell-unit')` ⚠️ ADD data-testid="calorie-balance-unit" | validate-text |
| DIA_041 | Edge | Multiple water logs same day: each save appends, total increases | Diary showing 2 glasses (500 ml) | 1. Click "Log water" 2. Add 2 more glasses 3. Save 4. Observe Intake card | Water value increases to 4 glasses (1.0 L); water log button remains available (always shown); can log again | P2 | Edge | No | `page.getByRole('button', { name: 'Log water' })` — ⚠️ LEGACY DIALOG | click |
| DIA_042 | Edge | Mood dialog pre-fills with `rawValue = 2` default when moodRow missing | Vitals has no mood logged | 1. Click `aria-label="Log mood"` | Dialog opens with "Okay" (index 2, value 2) selected by default; correct emoji highlighted via `.selected` class on `.icon-btn` | P2 | Edge | No | `page.getByRole('button', { name: 'Log mood' })` — ⚠️ LEGACY DIALOG — mood `.icon-btn` elements have no aria-label; selection only verifiable via `.selected` CSS class | validate-visible |
| DIA_043 | Edge | Mood dialog: `rawValue` outside 0–4 opens dialog in broken state (BUG_DI_02) | API returns `moodRow.rawValue = 99` | 1. Click mood log button (if shown) | `findIndex()` returns -1; `moods[-1]` is `undefined`; `selectedMood` is null; dialog renders with `defaultGradient` and no mood selected | P2 | Edge | No | `page.locator('.dialog-body')` — ⚠️ LEGACY DIALOG — class confirmed in `log-mood-dialog.component.html`; no `role="dialog"` or `aria-label` present | validate-visible |
| DIA_044 | State | One-time client: `/fit/today` redirected to `/fit/summary` by DiaryGuard | User has `isOneTimeClient = true` in AppConfigService | 1. Navigate to `/fit/today` directly | `DiaryGuard.canActivate()` returns redirect to `/fit/summary`; full diary page never renders | P1 | State | Yes | `expect(page).toHaveURL(/\/fit\/summary/)` | validate-url |
| DIA_045 | State | DiarySnapshotDialog shows rings + date switcher only (one-time client) | One-time client on Summary page | 1. Click "Open Diary" CTA on Summary page | `DiarySnapshotDialogComponent` opens; h2 "Diary" visible; date picker pill visible; `fit-summary-snapshot-card` with `[hideCta]="true"` rendered; no other cards; Close button (`aria-label="Close"`) visible | P1 | State | Yes | `page.getByRole('button', { name: 'Close' })` | validate-visible |
| DIA_046 | State | DiarySnapshotDialog loading: skeleton shown, not full-page shimmer | One-time client opens snapshot dialog; network throttled | 1. Click "Open Diary" 2. Observe dialog body immediately | `fit-skeleton` (320px height) visible; snapshot card not yet rendered | P2 | State | No | `page.locator('fit-skeleton')` ⚠️ ADD data-testid="snapshot-skeleton" to `<fit-skeleton>` in `diary-snapshot-dialog.component.html` | validate-visible |
| DIA_047 | State | Calorie Ledger empty state when no calorie data returned | API returns `intakeCaloriesData = null` | 1. Load diary page 2. Observe Calorie Ledger card | "No calorie data for this day." paragraph visible; no equation cells rendered | P2 | State | Yes | `page.getByText('No calorie data for this day.')` | validate-text |
| DIA_048 | State | Food Log empty state shows "Log meals" QR modal trigger | API returns empty food history | 1. Load diary 2. Observe Food Log card 3. Click "Log meals" button | "No food logged for this day." shown; "Log meals" button visible; clicking opens `fit-qr-modal` (QR code — no web food-log flow exists) | P2 | State | No | `page.getByRole('button', { name: /Log meals/ })` | click |

---

## 🚧 Testability Gaps

### `projects/fit/src/ui/new-ui/pages/diary-page/diary-page.component.html`

| Gap | Suggested Fix | Affects |
|-----|---------------|---------|
| `<fit-page-shimmer>` has no accessible name and no data-testid | ADD `data-testid="page-shimmer"` to `<fit-page-shimmer *ngIf="initialLoading">` | DIA_002 |
| `div.card-skeleton` appears in 6+ cards with no data-testid | ADD `data-testid="card-skeleton"` to each `<div class="card-skeleton">` | DIA_003 |
| `.cal-cell-balance .cal-cell-unit` has no data-testid; scoped only by parent CSS class | ADD `data-testid="calorie-balance-unit"` to `<span class="cal-cell-unit">` inside `.cal-cell-balance` | DIA_006, DIA_007, DIA_040 |
| `[class.surplus]` bound to `(c.balance ?? 0) > 0` (strict) but label text condition uses `>= 0` — at `balance = 0` the text reads "Surplus" but the `.surplus` class is absent | Fix condition to `(c.balance ?? 0) >= 0` to match text logic — see BUG_DI_01 | DIA_040 |
| `<fit-summary-snapshot-card>` has no data-testid | ADD `data-testid="snapshot-card"` to `<fit-summary-snapshot-card class="diary-snapshot">` | DIA_035 |
| `div.intake-water-bar-fill` has no data-testid | ADD `data-testid="water-progress-bar"` to `<div class="intake-water-bar-fill">` | DIA_037 |

### `projects/fit/src/ui/new-ui/components/diary-snapshot-dialog/diary-snapshot-dialog.component.html`

| Gap | Suggested Fix | Affects |
|-----|---------------|---------|
| `<fit-skeleton>` in dialog body has no data-testid | ADD `data-testid="snapshot-skeleton"` to `<fit-skeleton *ngIf="loading">` | DIA_046 |
| Dialog root `<div class="dialog">` has no `role="dialog"` and no `aria-label` | ADD `role="dialog"` and `aria-label="Diary snapshot"` to root `<div class="dialog">` | DIA_045, DIA_046 |

### `projects/fit/src/ui/dialogs/log-weight-dialog/log-weight-dialog.component.html`

| Gap | Suggested Fix | Affects |
|-----|---------------|---------|
| `input.stepper-input` has no data-testid | ADD `data-testid="weight-input"` to `<input class="stepper-input">` | DIA_029 |
| Dialog root `<div class="dialog-container">` has no `role="dialog"` and no `aria-label` | ADD `role="dialog"` `aria-label="Weight Tracker"` to root `<div class="dialog-container">` | DIA_026, DIA_028, DIA_029 |
| Snackbar for validation errors not present in template — source unknown | Locate snackbar service and confirm CSS selector (`.mdc-snackbar` unverified) | DIA_028 |

### `projects/fit/src/ui/dialogs/log-mood-dialog/log-mood-dialog.component.html`

| Gap | Suggested Fix | Affects |
|-----|---------------|---------|
| Mood `.icon-btn` elements (5 moods) have no `aria-label`; selection only detectable via `.selected` CSS class | ADD `aria-label="{{ mood.label }}"` to each `.icon-btn` in the `*ngFor` loop | DIA_025, DIA_042, DIA_043 |
| Reason `.icon-btn` elements have no `aria-label` | ADD `aria-label="{{ reason.label }}"` to each reason `.icon-btn` | DIA_025 |
| Dialog root `<div class="dialog-container">` has no `role="dialog"` and no `aria-label` | ADD `role="dialog"` `aria-label="Log mood"` to root `<div class="dialog-container">` | DIA_025, DIA_043 |
| Snackbar for save errors not in template — emitted by parent service | Confirm snackbar selector — `.mdc-snackbar` is unverified from this template | DIA_034 |

### `projects/fit/src/ui/dialogs/log-sleep-dialog/log-sleep-dialog.component.html`

| Gap | Suggested Fix | Affects |
|-----|---------------|---------|
| Bed time and wake time inputs use `ngxTimepicker` rendered with `style="display: none"` — standard Playwright `fill()` will not work | ADD `data-testid="bed-time-trigger"` and `data-testid="wake-time-trigger"` to the visible `.input-trigger` wrapper divs | DIA_027, DIA_031 |
| "Save" button text is generic — could conflict if multiple dialogs are open | ADD `aria-label="Save sleep log"` to the Save button | DIA_027, DIA_031 |
| Dialog root `<div class="dialog-container">` has no `role="dialog"` and no `aria-label` | ADD `role="dialog"` `aria-label="Sleep Tracker"` to root `<div class="dialog-container">` | DIA_027, DIA_031 |

### `projects/fit/src/ui/dialogs/log-water-dialog/log-water-dialog.component.html`

| Gap | Suggested Fix | Affects |
|-----|---------------|---------|
| "Add glass" control is a raw `<div (click)="addGlasses()">` wrapping an SVG — no accessible name | ADD `role="button"` `aria-label="Add glass"` to the wrapping `<div>` | DIA_023, DIA_024, DIA_041 |
| "Remove glass" control is a raw `<div (click)="removeGlasses()">` wrapping an SVG — no accessible name | ADD `role="button"` `aria-label="Remove glass"` to the wrapping `<div>` | DIA_023 |
| Glass count display (`{{ glassCount }} Glass(es)`) has no data-testid | ADD `data-testid="glass-count"` to the wrapping `<div style="font-size: 22px">` | DIA_023, DIA_024 |
| Dialog root has no `role="dialog"` and no `aria-label` | ADD `role="dialog"` `aria-label="Log water"` to the root `<div>` | DIA_023, DIA_024, DIA_030 |

---

## 🔗 Legacy Dialog Dependencies

| Dialog | File Path | Triggered By | Affected TCs |
|--------|-----------|--------------|--------------|
| Log Water Dialog | `projects/fit/src/ui/dialogs/log-water-dialog/log-water-dialog.component.html` | `openLogWater()` — Intake card `aria-label="Log water"` button | DIA_023, DIA_024, DIA_030, DIA_041 |
| Log Mood Dialog | `projects/fit/src/ui/dialogs/log-mood-dialog/log-mood-dialog.component.html` | `openLogMood()` — Vitals card `aria-label="Log mood"` "+" button | DIA_025, DIA_034, DIA_042, DIA_043 |
| Log Weight Dialog | `projects/fit/src/ui/dialogs/log-weight-dialog/log-weight-dialog.component.html` | `openLogWeight()` — Vitals card `aria-label="Log weight"` "+" button | DIA_026, DIA_028, DIA_029 |
| Log Sleep Dialog | `projects/fit/src/ui/dialogs/log-sleep-dialog/log-sleep-dialog.component.html` | `openLogSleep()` — Sleep card "Add Sleep Data" button | DIA_027, DIA_031 |

---

## 🤖 Automation Notes

**Framework:** Playwright + TypeScript

**Locator priority order:**
1. `page.getByTestId('...')` — preferred; requires data-testid to exist in template
2. `page.getByRole('button' | 'heading' | 'group', { name: '...' })` — use for elements with aria-label or visible text
3. `page.getByLabel('...')` — use for form inputs with associated labels
4. `page.getByText('...')` — use for static display text / empty state messages
5. `page.locator('.css-class')` — last resort; use only when no accessible name exists

**Blocked TCs (legacy dialog gaps):**
17 TCs are blocked on legacy dialog testability gaps. The following must be resolved before automation can proceed:
- All 4 legacy dialog roots need `role="dialog"` + `aria-label`
- Mood icon-btns need `aria-label="{{ mood.label }}"`
- Sleep time inputs need `data-testid` on visible trigger wrappers (ngxTimepicker is hidden)
- Water add/remove glass controls need `role="button"` + `aria-label`
- Weight `input.stepper-input` needs `data-testid="weight-input"`

**Mocked endpoints required:**

| Endpoint | Used By |
|----------|---------|
| `POST /today/overview` | DIA_032 (mock 500) |
| `GET /today/overview/activities` | DIA_033 (mock 500) |
| `GET /api/v1/configuration` | DIA_044, DIA_045, DIA_046 (set `isOneTimeClient: true`) |

**Date control:**
Use Playwright's clock API to control "today" for date-sensitive tests:
```ts
await page.clock.install({ time: new Date('2026-05-21T23:59:00') }); // DIA_022 midnight rollover
await page.clock.install({ time: new Date('2026-05-21T09:00:00') }); // standard date tests
```

**One-time client tests:**
Mock `GET /api/v1/configuration` to return `isOneTimeClient: true` before navigating, then assert redirect via `expect(page).toHaveURL(/\/fit\/summary/)`.
