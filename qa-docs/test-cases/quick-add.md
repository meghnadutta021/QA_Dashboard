# 🧪 Quick Add — Test Cases

**Feature:** Quick Add (new-ui only — all 4 UI variants)
**Page:** All tab-root pages (`/fit/summary`, `/fit/challenges`, `/fit/programs`, `/fit/community`)
**Component Paths:**
- `projects/fit/src/ui/new-ui/components/quick-add-fab/quick-add-fab.component.ts`
- `projects/fit/src/ui/new-ui/components/quick-add-sheet/quick-add-sheet.component.html`
- `projects/fit/src/ui/new-ui/components/top-nav/top-nav.component.html`
- `projects/fit/src/ui/new-ui/components/floating-dock/floating-dock.component.html`
- `projects/fit/src/ui/new-ui/components/app-qr/app-qr-modal.component.html`
- `projects/fit/src/ui/new-ui/components/app-qr/app-qr-content.component.html`
- `projects/fit/src/ui/new-ui/services/quick-add.service.ts`
- `projects/fit/src/ui/new-ui/models/nav.model.ts`

**Cross-reference Prototype:** ❌ Not available — generated from Angular code
**Last Updated:** 2026-05-21
**Total Test Cases:** 45
**Automation Framework:** Playwright (planned)

---

## ⚠️ Critical Risk Areas

| Risk | Detail |
|------|--------|
| Four independent UI variants | FAB+Sheet (mobile embedded), Desktop Popover (TopNav), Floating Dock (desktop embedded), and QR Modal must all be tested independently. Each variant has its own open/close mechanism, no shared state. |
| Legacy dialog boundary | 4 of the 5 web-action items (Track Mood, Log Sleep, Log Water, Update Weight) open LEGACY dialogs from `projects/fit/src/ui/dialogs/log-*-dialog/`. These dialogs have no `role="dialog"`, no `aria-label`, and no `data-testid` on interactive elements. Automation is partially blocked. |
| Keyboard accessibility gap | `QuickAddSheetComponent` and `FloatingDockComponent` have no `@HostListener('document:keydown.escape')`. Only `TopNavComponent` and `AppQrModalComponent` respond to Escape. Sheet and Dock panel are keyboard-inaccessible to dismiss. |
| FAB/Dock visibility guard | Both FAB and Dock use `TAB_ROOT_PATHS.has(currentPath)` via `normalizeNavPath()`. Auxiliary outlet URLs (`/fit/challenges/(challengesOutlet:listing)`) must be normalised first — the FAB/Dock could disappear mid-tab if normalisation is broken. |
| App-only vs web-action routing | `QuickAddService.canRunOnWeb(item)` controls dispatch vs QR modal. Items with `action` go to web; items with `appOnly: true` open `fit-qr-modal`. A model data regression (missing `action` field) would silently convert a web action into an app-only QR prompt. |
| No loading/error states in sheet | `QuickAddSheetComponent` renders synchronously from `QUICK_ADD_CATEGORIES` — no API call, no error state, no shimmer. Errors only appear after the dispatched dialog/route opens. |

---

## 🐛 Bugs Found (Pre-Development)

| # | Description | Related TC | Severity |
|---|-------------|------------|----------|
| BUG_QA_01 | Sheet X close button (`<button class="x">`) has no `aria-label` or accessible name. Screen readers announce the button without any label. WCAG 4.1.2 violation. | QAD_011 | P2 |
| BUG_QA_02 | `QuickAddSheetComponent` has no `@HostListener('document:keydown.escape')`. Pressing Escape while the sheet is open does nothing — sheet stays open. Keyboard-only users who cannot visually locate the X button have no dismiss path. | QAD_013 | P2 |
| BUG_QA_03 | `FloatingDockComponent` has no backdrop and no Escape key handler for its `.dock-sheet` panel. The panel can only be dismissed by clicking the same category icon again. No accessible keyboard dismiss path exists. | QAD_044 | P2 |
| BUG_QA_04 | Dock inline QR close button (`<button class="qr-close">`) has no `aria-label`. Dock QR back button (`<button class="qr-back">`) has no `aria-label` either. Both are inaccessible to screen readers. | QAD_036 | P3 |
| BUG_QA_05 | `AppQrModalComponent` has no router subscription — if the user navigates while the modal is open (e.g., via keyboard shortcut or browser back), the modal overlay stays rendered on top of the new route until the user manually closes it. | QAD_045 | P3 |

---

## 🚦 Smoke Test Checklist (P1 only)

- [ ] QAD_001 — FAB visible on /fit/summary at 375px (embedded mode)
- [ ] QAD_006 — FAB click opens Quick Add sheet
- [ ] QAD_007 — Sheet heading "Quick Add" renders
- [ ] QAD_008 — Sheet shows all 4 category sections
- [ ] QAD_009 — All 12 items render with correct labels under correct category
- [ ] QAD_014 — Log Activity click: sheet closes and navigates to /fit/log-activity
- [ ] QAD_016 — Track Mood click opens legacy mood dialog
- [ ] QAD_018 — Log Water click opens legacy water dialog
- [ ] QAD_020 — "Add" button visible at ≥768px (embedded mode)
- [ ] QAD_022 — "Add" button click opens popover
- [ ] QAD_023 — Popover shows all 4 category tabs
- [ ] QAD_026 — Web-action item in popover dispatches action
- [ ] QAD_032 — Dock renders on tab-root at desktop embedded mode
- [ ] QAD_035 — Dock icon click opens dock sheet for that category
- [ ] QAD_037 — Log Activity from dock navigates to /fit/log-activity

---

## 📋 Full Test Case Table

| TC_ID | Module | Scenario | Pre-condition | Steps | Expected Result | Priority | Type | Automation | Locator Hint | Interaction Type |
|-------|--------|----------|---------------|-------|-----------------|----------|------|------------|--------------|-----------------|
| QAD_001 | FAB | FAB renders on /fit/summary in embedded mode at 375px | App in embedded mode, user on /fit/summary | 1. Set viewport 375×812 2. Navigate to `/fit/summary` | `button.fab` is present in DOM and visible | P1 | Functional | Yes | `page.locator('button.fab')` ⚠️ ADD data-testid="quick-add-fab" to `<button class="fab">` in quick-add-fab.component.ts | validate-visible |
| QAD_002 | FAB | FAB renders on all 4 TAB_ROOT_PATHS at mobile | App in embedded mode, viewport 375×812 | 1. Navigate to each of `/fit/summary`, `/fit/challenges`, `/fit/programs`, `/fit/community` 2. Observe FAB on each | `button.fab` visible on all 4 routes | P2 | Functional | Yes | `page.locator('button.fab')` | validate-visible |
| QAD_003 | FAB | FAB absent on non-tab-root page (/fit/diary) at mobile | App in embedded mode, viewport 375×812 | 1. Navigate to `/fit/diary` 2. Observe FAB | `button.fab` not present in DOM (`*ngIf="visible"` is false) | P2 | Functional | Yes | `page.locator('button.fab')` | validate-hidden |
| QAD_004 | FAB | FAB absent in standalone mode at mobile | App in standalone mode (`navMode.mode === 'standalone'`), viewport 375×812 | 1. Set `navMode` to standalone 2. Navigate to `/fit/summary` | `button.fab` not rendered (visibility guard requires embedded mode) | P2 | Functional | Yes | `page.locator('button.fab')` | validate-hidden |
| QAD_005 | FAB | FAB has `.open` class when sheet is open | FAB visible on /fit/summary, mobile | 1. Click FAB 2. Inspect FAB element | `button.fab` has `.open` class; sheet is visible | P3 | State | Yes | `page.locator('button.fab.open')` | validate-class |
| QAD_006 | FAB + Sheet | FAB click opens Quick Add sheet | FAB visible, mobile viewport | 1. Click `button.fab` | `.sheet` element becomes visible; `.overlay` backdrop renders | P1 | Functional | Yes | `page.locator('button.fab')` → assert `page.locator('.sheet')` visible | click |
| QAD_007 | Sheet | Sheet heading "Quick Add" renders | Sheet open | 1. Open sheet 2. Observe heading | `<h3>Quick Add</h3>` present and visible | P1 | Functional | Yes | `page.getByRole('heading', { level: 3, name: 'Quick Add' })` | validate-visible |
| QAD_008 | Sheet | Sheet shows all 4 category sections | Sheet open | 1. Open sheet 2. Count `.cat` sections and read `.cat-head h4` labels | Exactly 4 sections: "Workout", "Mindfulness", "Log Diary", "Track Habits" | P1 | Functional | Yes | `page.locator('.cat-head h4')` — count 4; assert each label ⚠️ ADD data-testid per category section | validate-count |
| QAD_009 | Sheet | All 12 items render with correct labels under correct category | Sheet open | 1. Open sheet 2. Read all `.item-label` text in each `.cat` section | Workout: Log Activity, Start Outdoor Workout, Start 7-Minute Workout; Mindfulness: Track Mood, Log Sleep, Guided Meditation; Log Diary: Log Water, Update Weight, Log Meal; Track Habits: Log Smoking, Avoid Sugar, Daily Workout | P1 | Functional | Yes | `page.locator('.item-label')` — assert 12 items total ⚠️ ADD data-testid or aria-label to `<button class="item">` | validate-text |
| QAD_010 | Sheet | App-only items show "Track on app" badge; web-action items do not | Sheet open | 1. Open sheet 2. Inspect each `.item` for `.track-on-app` span | 7 app-only items have `.track-on-app` span; 5 web-action items do not (Log Activity, Track Mood, Log Sleep, Log Water, Update Weight) | P2 | Functional | Yes | `page.locator('.item .track-on-app')` — count 7 ⚠️ ADD data-testid="track-on-app-badge" | validate-count |
| QAD_011 | Sheet | Sheet X close button closes sheet | Sheet open | 1. Open sheet 2. Click `.sheet .x` button | Sheet hidden; overlay hidden; FAB no longer has `.open` class | P1 | Functional | Yes | `page.locator('.sheet .x')` ⚠️ ADD aria-label="Close" to `<button class="x">` in quick-add-sheet.component.html | click |
| QAD_012 | Sheet | Sheet backdrop click closes sheet | Sheet open | 1. Open sheet 2. Click `.overlay` element | Sheet hidden; overlay hidden | P1 | Functional | Yes | `page.locator('.overlay')` ⚠️ ADD data-testid="quick-add-overlay" | click |
| QAD_013 | Sheet | Escape key does NOT close sheet (no handler) | Sheet open | 1. Open sheet 2. Press Escape key | Sheet stays open — `QuickAddSheetComponent` has no `@HostListener('document:keydown.escape')` | P2 | Keyboard | Yes | `page.keyboard.press('Escape')` → assert `page.locator('.sheet')` still visible | keyboard |
| QAD_014 | Sheet | Log Activity click: sheet closes, navigates to /fit/log-activity | Sheet open, mobile | 1. Open sheet 2. Click item with label "Log Activity" | Sheet closes; URL becomes `/fit/log-activity` (with `?date=` query param for today) | P1 | Navigation | Yes | `page.locator('.item', { hasText: 'Log Activity' })` ⚠️ ADD aria-label="Log Activity" | click |
| QAD_015 | Sheet | App-only item click: sheet closes and QR modal opens | Sheet open, mobile | 1. Open sheet 2. Click "Start Outdoor Workout" item | Sheet closes; `fit-qr-modal` opens (`open=true`); `.backdrop` visible | P2 | Functional | Yes | `page.locator('.item', { hasText: 'Start Outdoor Workout' })` → assert `page.locator('fit-qr-modal .backdrop')` | click |
| QAD_016 | Legacy Dialog | Track Mood click opens LogMoodDialog | Sheet open, mobile | 1. Open sheet 2. Click "Track Mood" item | `mat-dialog-container` rendered in DOM; mood icon buttons (`.icon-btn`) visible | P1 | Functional | No | ⚠️ LEGACY DIALOG — locator depends on `projects/fit/src/ui/dialogs/log-mood-dialog/`. Use `page.locator('mat-dialog-container')` for container; `.icon-btn` elements have no aria-label | click |
| QAD_017 | Legacy Dialog | Log Sleep click opens LogSleepDialog | Sheet open, mobile | 1. Open sheet 2. Click "Log Sleep" item | `mat-dialog-container` rendered; "Save" button visible by text | P1 | Functional | No | ⚠️ LEGACY DIALOG — locator depends on `projects/fit/src/ui/dialogs/log-sleep-dialog/`. Use `page.locator('mat-dialog-container')` → `page.getByRole('button', { name: 'Save' })` | click |
| QAD_018 | Legacy Dialog | Log Water click opens LogWaterDialog | Sheet open, mobile | 1. Open sheet 2. Click "Log Water" item | `mat-dialog-container` rendered; "Save Water Intake" button visible by text | P1 | Functional | No | ⚠️ LEGACY DIALOG — locator depends on `projects/fit/src/ui/dialogs/log-water-dialog/`. Use `page.locator('mat-dialog-container')` → `page.getByRole('button', { name: 'Save Water Intake' })` | click |
| QAD_019 | Legacy Dialog | Update Weight click opens LogWeightDialog | Sheet open, mobile | 1. Open sheet 2. Click "Update Weight" item | `mat-dialog-container` rendered; "Save Changes" button visible by text | P1 | Functional | No | ⚠️ LEGACY DIALOG — locator depends on `projects/fit/src/ui/dialogs/log-weight-dialog/`. Use `page.locator('mat-dialog-container')` → `page.getByRole('button', { name: 'Save Changes' })` | click |
| QAD_020 | Desktop Popover | "Add" button visible at ≥768px in embedded mode | App in embedded mode, viewport ≥768px | 1. Navigate to `/fit/summary` at 1280×900 | `button.quick-add-trigger` rendered with text "Add" and `aria-label="Quick add"` | P1 | Functional | Yes | `page.getByRole('button', { name: 'Quick add' })` ✓ (aria-label confirmed) | validate-visible |
| QAD_021 | Desktop Popover | "Add" button aria-label is "Quick add" | Desktop embedded, popover closed | 1. Inspect `button.quick-add-trigger` | Element has `aria-label="Quick add"` | P2 | Accessibility | Yes | `page.getByRole('button', { name: 'Quick add' })` — assert accessible name | validate-attribute |
| QAD_022 | Desktop Popover | "Add" button click opens popover | Desktop embedded, viewport ≥768px | 1. Click `page.getByRole('button', { name: 'Quick add' })` | `.quick-add-popover` visible; `.popover-backdrop` rendered; button has `.active` class | P1 | Functional | Yes | `page.getByRole('button', { name: 'Quick add' })` → assert `page.locator('.quick-add-popover')` ⚠️ ADD data-testid="quick-add-popover" | click |
| QAD_023 | Desktop Popover | Popover shows all 4 category tabs | Popover open | 1. Open popover 2. Count `.qa-tab` buttons | Exactly 4 tabs: "Workout", "Mindfulness", "Log Diary", "Track Habits"; each rendered with icon | P1 | Functional | Yes | `page.locator('.qa-tab')` — count 4; assert labels ⚠️ ADD aria-label per `.qa-tab` | validate-count |
| QAD_024 | Desktop Popover | Default active tab is "Workout"; items show Workout category | Popover open | 1. Open popover 2. Observe active tab and items | `.qa-tab[Workout]` has `.active` class; `.qa-items` shows Log Activity, Start Outdoor Workout, Start 7-Minute Workout | P2 | State | Yes | `page.locator('.qa-tab.active')` → assert text "Workout"; `page.locator('.qa-item')` count 3 ⚠️ ADD aria-label per `.qa-tab` | validate-class |
| QAD_025 | Desktop Popover | Clicking Mindfulness tab switches item list | Popover open, Workout tab active | 1. Click Mindfulness tab 2. Observe items | Mindfulness tab has `.active`; items list shows Track Mood, Log Sleep, Guided Meditation | P1 | Functional | Yes | `page.locator('.qa-tab', { hasText: 'Mindfulness' })` ⚠️ ADD aria-label="Mindfulness tab" | click |
| QAD_026 | Desktop Popover | Web-action item in popover dispatches action and closes popover | Popover open, Workout tab active | 1. Click "Log Activity" qa-item | Popover closes; URL navigates to `/fit/log-activity` | P1 | Functional | Yes | `page.locator('.qa-item', { hasText: 'Log Activity' })` ⚠️ ADD aria-label="Log Activity" to `<button class="qa-item">` | click |
| QAD_027 | Desktop Popover | Escape key closes quick-add popover | Popover open | 1. Open popover 2. Press Escape | Popover hidden; backdrop hidden; "Add" button no longer has `.active` class (`TopNavComponent` has `@HostListener('document:keydown.escape')`) | P1 | Keyboard | Yes | `page.keyboard.press('Escape')` → assert `page.locator('.quick-add-popover')` hidden | keyboard |
| QAD_028 | Desktop Popover | Backdrop click closes popover | Popover open | 1. Open popover 2. Click `.popover-backdrop` | Popover hidden; backdrop hidden | P1 | Functional | Yes | `page.locator('.popover-backdrop').first()` ⚠️ ADD data-testid="quick-add-popover-backdrop" | click |
| QAD_029 | Desktop Popover | Tab key moves focus through category tabs in popover | Popover open, first tab focused | 1. Open popover 2. Focus first `.qa-tab` 3. Press Tab repeatedly | Focus advances through all 4 `.qa-tab` buttons in DOM order | P2 | Keyboard | No | `page.keyboard.press('Tab')` → assert `page.locator('.qa-tab').nth(1)` is focused ⚠️ ADD aria-label per `.qa-tab` | keyboard |
| QAD_030 | Desktop Popover | App-only item click shows inline QR overlay | Popover open, Workout tab active | 1. Click "Start Outdoor Workout" qa-item | `.qa-qr-overlay` becomes visible inside popover; `.qa-qr-label` shows "Start Outdoor Workout"; `fit-qr-content` renders | P2 | Functional | Yes | `page.locator('.qa-item', { hasText: 'Start Outdoor Workout' })` → assert `page.locator('.qa-qr-overlay')` | click |
| QAD_031 | Desktop Popover | Enter key activates focused qa-item button | Popover open, qa-item focused | 1. Open popover 2. Tab to a web-action `.qa-item` 3. Press Enter | Item action dispatched (same as click); popover closes | P2 | Keyboard | No | `page.keyboard.press('Enter')` after focusing `page.locator('.qa-item', { hasText: 'Log Activity' })` ⚠️ ADD aria-label per `.qa-item` | keyboard |
| QAD_032 | Floating Dock | Dock renders on tab-root at desktop in embedded mode | App in embedded mode, viewport ≥768px | 1. Navigate to `/fit/summary` at 1280×900 | `.dock-wrap` visible; dock bar shows "Quick Add" title and 4 category icon buttons | P1 | Functional | Yes | `page.locator('.dock-wrap')` ⚠️ ADD data-testid="floating-dock" | validate-visible |
| QAD_033 | Floating Dock | Dock hidden on non-tab-root page at desktop | Desktop, embedded | 1. Navigate to `/fit/diary` at 1280×900 | `.dock-wrap` not present in DOM (`*ngIf="visible"` is false) | P2 | Functional | Yes | `page.locator('.dock-wrap')` → assert not visible | validate-hidden |
| QAD_034 | Floating Dock | Dock category icon button has aria-label = category label | Dock visible | 1. Inspect each `.icon-btn` in `.dock-icons` | Each button has `aria-label` matching category label: "Workout", "Mindfulness", "Log Diary", "Track Habits" | P2 | Accessibility | Yes | `page.getByRole('button', { name: 'Workout' })` ✓ (`[attr.aria-label]="c.label"` confirmed in template) | validate-attribute |
| QAD_035 | Floating Dock | Clicking dock icon opens dock sheet for that category | Dock visible, no sheet open | 1. Click `page.getByRole('button', { name: 'Mindfulness' })` | `.dock-sheet` becomes visible; `.tabs` shows 4 category tabs; `.items` shows Mindfulness items | P1 | Functional | Yes | `page.getByRole('button', { name: 'Mindfulness' })` → assert `page.locator('.dock-sheet')` | click |
| QAD_036 | Floating Dock | App-only item in dock sheet opens inline QR popover | Dock sheet open for Workout | 1. Open dock sheet for Workout 2. Click "Start Outdoor Workout" `.dock-item` | `.qr-overlay` backdrop renders; `.qr-popover` visible; `fit-qr-content` renders horizontally | P2 | Functional | Yes | `page.locator('.dock-item', { hasText: 'Start Outdoor Workout' })` → assert `page.locator('.qr-popover')` ⚠️ ADD aria-label to `.dock-item` buttons; ADD aria-label="Close" to `.qr-close`; ADD aria-label="Back" to `.qr-back` | click |
| QAD_037 | Floating Dock | Log Activity from dock navigates to /fit/log-activity | Dock sheet open for Workout | 1. Open dock sheet 2. Click "Log Activity" `.dock-item` | URL becomes `/fit/log-activity` with today's date as `?date=` param | P1 | Navigation | Yes | `page.locator('.dock-item', { hasText: 'Log Activity' })` → `await expect(page).toHaveURL(/\/fit\/log-activity/)` ⚠️ ADD aria-label="Log Activity" to `.dock-item` | click |
| QAD_038 | Responsive | FAB visible at 767px (one pixel below CSS breakpoint) | App in embedded mode, on /fit/summary | 1. `page.setViewportSize({ width: 767, height: 812 })` 2. Navigate to `/fit/summary` | `button.fab` is visible (CSS `@media (min-width: 768px) { .fab { display: none } }` not triggered) | P1 | Responsive | Yes | `page.setViewportSize({ width: 767, height: 812 })` → `page.locator('button.fab')` visible | validate-visible |
| QAD_039 | Responsive | FAB hidden at exactly 768px (CSS breakpoint boundary) | App in embedded mode, on /fit/summary | 1. `page.setViewportSize({ width: 768, height: 900 })` 2. Navigate to `/fit/summary` | `button.fab` has `display: none` via media query; element may still be in DOM but not visible | P1 | Responsive | Yes | `page.setViewportSize({ width: 768, height: 900 })` → `page.locator('button.fab')` not visible | validate-hidden |
| QAD_040 | Responsive | QR modal shows `.mobile-sheet` at 375px (not `.desktop-modal`) | App-only item tapped to open QR modal | 1. `page.setViewportSize({ width: 375, height: 812 })` 2. Trigger QR modal | `.mobile-sheet` visible; `.desktop-modal` not visible | P2 | Responsive | Yes | `page.setViewportSize({ width: 375, height: 812 })` → `page.locator('.mobile-sheet')` visible; `page.locator('.desktop-modal')` not visible | validate-visible |
| QAD_041 | Responsive | QR modal shows `.desktop-modal` at 1280px (not `.mobile-sheet`) | App-only item clicked to open QR modal | 1. `page.setViewportSize({ width: 1280, height: 900 })` 2. Trigger QR modal | `.desktop-modal` visible; `.mobile-sheet` not visible | P2 | Responsive | Yes | `page.setViewportSize({ width: 1280, height: 900 })` → `page.locator('.desktop-modal')` visible; `page.locator('.mobile-sheet')` not visible | validate-visible |
| QAD_042 | QR Modal | Escape key closes QR modal (AppQrModal has @HostListener) | QR modal open | 1. Open QR modal 2. Press Escape | Modal closes; `.backdrop` hidden; `open` binding becomes `false` | P2 | Keyboard | Yes | `page.keyboard.press('Escape')` → assert `page.locator('fit-qr-modal .backdrop')` hidden | keyboard |
| QAD_043 | QR Modal | QR modal close button closes modal | QR modal open | 1. Open QR modal 2. Click close button | Modal closes; backdrop hidden | P1 | Functional | Yes | `page.getByRole('button', { name: 'Close' })` ✓ (aria-label="Close" confirmed on `.close-btn`) | click |
| QAD_044 | Floating Dock | Escape key does NOT close dock sheet panel (no handler) | Dock sheet open | 1. Open dock sheet 2. Press Escape | Dock sheet stays open — `FloatingDockComponent` has no `@HostListener('document:keydown.escape')` | P2 | Keyboard | Yes | `page.keyboard.press('Escape')` → assert `page.locator('.dock-sheet')` still visible | keyboard |
| QAD_045 | QR Modal | QR modal persists through router navigation (no router subscription) | QR modal open | 1. Open QR modal 2. Programmatically navigate to `/fit/challenges` | Modal overlay remains open on `/fit/challenges` — `AppQrModalComponent` has no `router.events` subscription to auto-close | P3 | Edge Case | No | `page.locator('fit-qr-modal .backdrop')` → assert still visible after navigation ⚠️ ADD router subscription to AppQrModalComponent to close on NavigationStart | validate-visible |

---

## 🚧 Testability Gaps

### `projects/fit/src/ui/new-ui/components/quick-add-sheet/quick-add-sheet.component.html`

| Element | Gap | Suggested Fix |
|---------|-----|---------------|
| `<div class="sheet">` | No `role="dialog"`, no `aria-label`, no `data-testid` | ADD `role="dialog" aria-label="Quick Add" data-testid="quick-add-sheet"` |
| `<button class="x">` | No `aria-label` — screen readers cannot identify this as "Close" | ADD `aria-label="Close"` |
| `<button class="item">` (×12) | No `aria-label` per item, no `data-testid` — only text content available; getByText collides with identical labels | ADD `[attr.aria-label]="item.label"` or `[attr.data-testid]="'qa-item-' + item.label"` |
| `<div class="overlay">` | No `data-testid` | ADD `data-testid="quick-add-overlay"` |
| `<section class="cat">` (×4) | No `data-testid` per category | ADD `[attr.data-testid]="'qa-cat-' + cat.key"` |

### `projects/fit/src/ui/new-ui/components/top-nav/top-nav.component.html`

| Element | Gap | Suggested Fix |
|---------|-----|---------------|
| `<div class="quick-add-popover">` | No `role="menu"`, no `data-testid` | ADD `data-testid="quick-add-popover"` |
| `<button class="qa-tab">` (×4) | No `aria-label` per tab — only text + icon available | ADD `[attr.aria-label]="c.label + ' tab'"` |
| `<button class="qa-item">` (×12) | No `aria-label`, no `data-testid` — only text; `hasText` is the only selector | ADD `[attr.aria-label]="item.label"` or `[attr.data-testid]="'qa-popover-item-' + item.label"` |
| `<div class="popover-backdrop">` | No `data-testid` (×2 — one for quick-add, one for more menu) | ADD `data-testid="quick-add-popover-backdrop"` to first instance |
| `<button class="qa-qr-back">` | No `aria-label` (text "Back" present but not an ARIA label) | ADD `aria-label="Back"` |

### `projects/fit/src/ui/new-ui/components/floating-dock/floating-dock.component.html`

| Element | Gap | Suggested Fix |
|---------|-----|---------------|
| `<div class="dock-wrap">` | No `data-testid` | ADD `data-testid="floating-dock"` |
| `<div class="dock-sheet">` | No `data-testid`, no `role` | ADD `data-testid="dock-sheet"` |
| `<button class="tab">` (×4) | No `aria-label` — only text content | ADD `[attr.aria-label]="c.label + ' tab'"` |
| `<button class="dock-item">` (×12) | No `aria-label`, no `data-testid` | ADD `[attr.aria-label]="item.label"` or `[attr.data-testid]="'dock-item-' + item.label"` |
| `<div class="qr-overlay">` | No `data-testid` | ADD `data-testid="dock-qr-overlay"` |
| `<button class="qr-back">` | No `aria-label` | ADD `aria-label="Back"` |
| `<button class="qr-close">` | No `aria-label` | ADD `aria-label="Close"` |

### `projects/fit/src/ui/new-ui/components/quick-add-fab/quick-add-fab.component.ts`

| Element | Gap | Suggested Fix |
|---------|-----|---------------|
| `<button class="fab">` | No `aria-label`, no `data-testid` | ADD `aria-label="Quick Add" data-testid="quick-add-fab"` |

### `projects/fit/src/ui/new-ui/components/app-qr/app-qr-content.component.html`

| Element | Gap | Suggested Fix |
|---------|-----|---------------|
| `<button class="save-btn">` | No `aria-label` — only text "Save QR" + icon | ADD `aria-label="Save QR code"` |

### `projects/fit/src/ui/new-ui/components/app-qr/app-qr-modal.component.html`

| Element | Gap | Suggested Fix |
|---------|-----|---------------|
| `<div class="backdrop">` | No `data-testid` | ADD `data-testid="qr-modal-backdrop"` |

---

## 🔗 Legacy Dialog Dependencies

The following legacy dialogs are triggered by web-action items in Quick Add. They reside outside the new-ui component tree and must be maintained separately.

| Dialog Component | Trigger Item | Affected TCs | Location |
|-----------------|--------------|--------------|----------|
| `LogMoodDialogComponent` | Track Mood (Mindfulness category) | QAD_016 | `projects/fit/src/ui/dialogs/log-mood-dialog/log-mood-dialog.component.html` |
| `LogSleepDialogComponent` | Log Sleep (Mindfulness category) | QAD_017 | `projects/fit/src/ui/dialogs/log-sleep-dialog/log-sleep-dialog.component.html` |
| `LogWaterDialogComponent` | Log Water (Log Diary category) | QAD_018 | `projects/fit/src/ui/dialogs/log-water-dialog/log-water-dialog.component.html` |
| `LogWeightDialogComponent` | Update Weight (Log Diary category) | QAD_019 | `projects/fit/src/ui/dialogs/log-weight-dialog/log-weight-dialog.component.html` |

**Known issues in legacy dialogs (shared with Diary page test suite):**

| Dialog | Issue |
|--------|-------|
| All 4 | No `role="dialog"` on component root — automation must target `mat-dialog-container` |
| All 4 | No `data-testid` on any interactive element |
| `LogMoodDialogComponent` | `.icon-btn` mood selector buttons have no `aria-label` — cannot select mood by accessible name |
| `LogSleepDialogComponent` | Time inputs use hidden `ngxTimepicker` (`style="display: none"`) — native input interaction blocked |
| `LogWaterDialogComponent` | Add/remove glass controls are raw `<div>` elements with no accessible names |
| `LogWeightDialogComponent` | `input.stepper-input` has no `data-testid` or `aria-label` |

---

## 🤖 Automation Notes

```typescript
// Viewport setup for FAB/responsive TCs
await page.setViewportSize({ width: 767, height: 812 }); // FAB visible
await page.setViewportSize({ width: 768, height: 900 }); // FAB hidden

// Open Quick Add sheet (mobile)
await page.locator('button.fab').click();
await expect(page.locator('.sheet')).toBeVisible();

// Open Quick Add popover (desktop)
await page.getByRole('button', { name: 'Quick add' }).click();
await expect(page.locator('.quick-add-popover')).toBeVisible();

// Dismiss popover via Escape (TopNavComponent has @HostListener)
await page.keyboard.press('Escape');
await expect(page.locator('.quick-add-popover')).toBeHidden();

// Dismiss QR modal via Escape (AppQrModalComponent has @HostListener)
await page.keyboard.press('Escape');
await expect(page.locator('fit-qr-modal .backdrop')).toBeHidden();

// Assert Log Activity navigation
await page.locator('.dock-item', { hasText: 'Log Activity' }).click();
await expect(page).toHaveURL(/\/fit\/log-activity/);

// QR image check
await expect(page.locator('img[alt="Download Vantage Fit"]')).toBeVisible();

// Store links
await expect(page.locator('a[href*="apps.apple.com"]')).toBeVisible();
await expect(page.locator('a[href*="play.google.com"]')).toBeVisible();

// Legacy dialog — target mat-dialog-container (no role="dialog" on component root)
await page.locator('.item', { hasText: 'Track Mood' }).click();
await expect(page.locator('mat-dialog-container')).toBeVisible();
```

**Mock endpoints required:**

| Endpoint | Used By | Mock Value |
|----------|---------|------------|
| None (sheet renders from static `QUICK_ADD_CATEGORIES` model) | All sheet TCs | N/A |
| `POST /api/v3/diary/mood` | QAD_016 (after dialog save) | `{ success: true }` |
| `POST /api/v3/diary/sleep` | QAD_017 (after dialog save) | `{ success: true }` |
| `POST /api/v3/diary/water` | QAD_018 (after dialog save) | `{ success: true }` |
| `POST /api/v3/diary/weight` | QAD_019 (after dialog save) | `{ success: true }` |
