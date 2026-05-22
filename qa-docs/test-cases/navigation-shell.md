# 🧪 Navigation Shell — Test Cases

**Feature:** Navigation Shell (Top Nav + Mobile Tab Bar + Mobile Pill Nav + More Menu — new-ui only)
**Components Path:**
- projects/fit/src/ui/new-ui/components/top-nav/
- projects/fit/src/ui/new-ui/components/mobile-tab-bar/
- projects/fit/src/ui/new-ui/components/mobile-pill-nav/
- projects/fit/src/ui/new-ui/pages/more-page.component.ts
- projects/fit/src/ui/new-ui/app-wrapper.component.ts

**Cross-reference Prototype:** fit-prototype/src/components/top-nav.tsx + mobile-tab-bar.tsx
**Last Updated:** 2026-05-21
**Total Test Cases:** 45
**Automation Framework:** Playwright (planned)

---

## ⚠️ Critical Risk Areas

- 4 nav variants conditionally render based on viewport + mode — high regression surface
- Active tab logic uses prefix matching (must handle nested routes like /fit/challenges/123)
- `?navBack=true` forces Back button on tab root — uncommon edge case
- Auxiliary outlet URLs require `normalizeNavPath()` stripping
- Chromeless routes hide ALL nav — easy regression on new routes
- Standalone vs Embedded mode determines mobile nav variant — config-driven
- More popover and Quick Add popover share Escape handler — coupling risk

---

## 🐛 Bugs Found (Pre-Development)

| # | Description | Related TC | Severity |
|---|-------------|------------|----------|
| BUG_NV_01 | My Activities / My Badges / League Info / Trends / My Health menu rows are inside `<!-- TODO -->` comment blocks in `more-page.component.html` — routes not wired | NAV_011, NAV_012, NAV_013 | P2 |
| BUG_NV_02 | Active pill missing `aria-current="page"` attribute on all nav variants — accessibility gap | NAV_042, NAV_043, NAV_014, NAV_015 | P2 |
| BUG_NV_03 | More menu items have no `aria-label` and no `role="menuitem"` — screen reader gap | NAV_008, NAV_009, NAV_020 | P2 |
| BUG_NV_04 | More trigger button has no `aria-expanded`, no `aria-haspopup="menu"` — ARIA contract incomplete | NAV_006 | P2 |
| BUG_NV_05 | Two `.popover-backdrop` instances exist (More + Quick Add) with no distinguishing `data-testid` — `.first()` is fragile | NAV_007 | P3 |

---

## 🚦 Smoke Test Checklist (P1 only)

- [ ] NAV_001 — Summary tab click navigates to /fit/summary
- [ ] NAV_002 — Challenges tab click navigates to /fit/challenges
- [ ] NAV_003 — Programs tab click navigates to /fit/programs
- [ ] NAV_004 — Community tab click navigates to /fit/community
- [ ] NAV_005 — Active tab updates immediately on navigation
- [ ] NAV_006 — ••• button click opens More popover (desktop)
- [ ] NAV_007 — Backdrop click closes More popover
- [ ] NAV_008 — Download App opens QR modal from More popover
- [ ] NAV_009 — Privacy Policy opens legal modal from More popover
- [ ] NAV_010 — Mobile Pill Nav "More" button navigates to /fit/more
- [ ] NAV_014 — Active tab styled with brand color (desktop)
- [ ] NAV_015 — Active tab brand color on mobile tab bar
- [ ] NAV_018 — Desktop Back button appears on non-tab-root page
- [ ] NAV_019 — Back button absent on tab root pages
- [ ] NAV_026 — Deep link to /fit/challenges/123 highlights Challenges tab
- [ ] NAV_027 — Deep link to /fit/diary shows no tab active, Back button shown
- [ ] NAV_028 — Refresh on /fit/programs keeps Programs tab active
- [ ] NAV_031 — Back button calls window.history.back()
- [ ] NAV_033 — More popover closes automatically on router navigation
- [ ] NAV_034 — Mobile tab bar visible at 767px (standalone mode)
- [ ] NAV_035 — Mobile tab bar hidden at exactly 768px
- [ ] NAV_039 — Embedded mode shows Mobile Pill Nav at mobile viewport
- [ ] NAV_040 — Standalone mode shows Mobile Tab Bar at mobile viewport
- [ ] NAV_041 — Chromeless route /fit/bite-size-content hides all nav
- [ ] NAV_043 — Enter key activates focused tab
- [ ] NAV_044 — Escape key closes More popover

---

## 📋 Full Test Case Table

| TC_ID | Module | Scenario | Pre-condition | Steps | Expected Result | Priority | Type | Automation | Locator Hint | Interaction Type |
|-------|--------|----------|---------------|-------|-----------------|----------|------|------------|--------------|-----------------|
| NAV_001 | Tab Navigation | Summary tab click navigates to /fit/summary | User on /fit/challenges, desktop ≥768px | 1. Click "Summary" pill in `.desktop-nav` | URL becomes `/fit/summary`; Summary pill has `.active` class and brand-color text | P1 | Functional | Yes | `page.getByRole('button', { name: 'Summary' })` scoped inside `.desktop-nav` ⚠️ ADD data-testid="nav-tab-summary" to `<button class="pill">` in top-nav.component.html | click |
| NAV_002 | Tab Navigation | Challenges tab click navigates to /fit/challenges | User on /fit/summary, desktop ≥768px | 1. Click "Challenges" pill | URL becomes `/fit/challenges`; Challenges pill has `.active` class | P1 | Functional | Yes | `page.getByRole('button', { name: 'Challenges' })` scoped inside `.desktop-nav` ⚠️ ADD data-testid="nav-tab-challenges" to `<button class="pill">` | click |
| NAV_003 | Tab Navigation | Programs tab click navigates to /fit/programs | User on /fit/summary, desktop ≥768px | 1. Click "Programs" pill | URL becomes `/fit/programs`; Programs pill has `.active` class | P1 | Functional | Yes | `page.getByRole('button', { name: 'Programs' })` scoped inside `.desktop-nav` ⚠️ ADD data-testid="nav-tab-programs" to `<button class="pill">` | click |
| NAV_004 | Tab Navigation | Community tab click navigates to /fit/community | User on /fit/summary, desktop ≥768px | 1. Click "Community" pill | URL becomes `/fit/community`; Community pill has `.active` class | P1 | Functional | Yes | `page.getByRole('button', { name: 'Community' })` scoped inside `.desktop-nav` ⚠️ ADD data-testid="nav-tab-community" to `<button class="pill">` | click |
| NAV_005 | Tab Navigation | Active tab updates immediately on navigation | User on /fit/summary, desktop | 1. Click "Programs" 2. Observe Summary and Programs pills | Summary pill loses `.active`; Programs pill gains `.active`; no transition where both are active simultaneously | P1 | Functional | Yes | Assert `page.locator('.desktop-nav .pill.active')` has text "Programs"; assert `page.getByRole('button', { name: 'Summary' })` lacks class `.active` ⚠️ ADD aria-current="page" to active `.pill` | click |
| NAV_006 | More Menu | ••• button click opens More popover (desktop) | User on any tab root, desktop ≥768px | 1. Click `.more-trigger` button 2. Observe DOM | `.more-popover` becomes visible; `.popover-backdrop` overlay rendered; ••• button gains `.active` class | P1 | Functional | Yes | `page.locator('.desktop-nav .more-trigger')` → assert `page.locator('.more-popover')` visible ⚠️ ADD aria-label="More menu" to `<button class="more-trigger">` and data-testid="more-popover" to `<div class="more-popover">` in top-nav.component.html | click |
| NAV_007 | More Menu | Backdrop click closes More popover | More popover open, desktop | 1. Click `.popover-backdrop` element | `.more-popover` hidden; `.popover-backdrop` removed; ••• button loses `.active` class | P1 | Functional | Yes | `page.locator('.popover-backdrop').first()` ⚠️ ADD data-testid="more-popover-backdrop" to first `<div class="popover-backdrop">` in top-nav.component.html | click |
| NAV_008 | More Menu | Download App opens QR modal from More popover | More popover open, desktop | 1. Click "Download App" menu item in `.more-popover` | `fit-qr-modal` opens (context=`signin`); More popover closes | P1 | Functional | Yes | `page.locator('.more-popover').getByRole('button', { name: 'Download App' })` ⚠️ ADD aria-label="Download App" to `<button class="menu-item">` Download App entry in top-nav.component.html | click |
| NAV_009 | More Menu | Privacy Policy opens legal modal from More popover | More popover open, desktop | 1. Click "Vantage Fit Privacy Policy" menu item | `fit-legal-document-modal` opens with `kind='privacy'`; More popover closes | P1 | Functional | Yes | `page.locator('.more-popover').getByRole('button', { name: 'Vantage Fit Privacy Policy' })` ✓ button text confirmed in top-nav.component.html | click |
| NAV_010 | More Menu | Mobile Pill Nav "More" button navigates to /fit/more | User on any page, embedded mode, <768px | 1. Click "More" tab in `.pill-nav` | URL becomes `/fit/more`; "More" tab has `.active` class | P1 | Functional | Yes | `page.locator('.pill-nav').getByRole('button', { name: 'More' })` ⚠️ ADD data-testid="nav-tab-more" to `<button class="tab">` More entry in mobile-pill-nav.component.ts inline template | click |
| NAV_011 | More Page | My Activities item navigates to /fit/more/activities | User on /fit/more mobile page | 1. Tap "My Activities" row | URL becomes `/fit/more/activities` | P2 | Navigation | No | `page.locator('.more-page').getByRole('link', { name: 'My Activities' })` ⚠️ BLOCKED — `<a class="menu-row">` for My Activities is inside `<!-- TODO:// Implement -->` comment block in more-page.component.html; not in DOM | click |
| NAV_012 | More Page | My Badges item navigates to /fit/more/badges | User on /fit/more mobile page | 1. Tap "My Badges" row | URL becomes `/fit/more/badges` | P2 | Navigation | No | `page.locator('.more-page').getByRole('link', { name: 'My Badges' })` ⚠️ BLOCKED — same TODO comment block in more-page.component.html | click |
| NAV_013 | More Page | League Info item navigates to /fit/more/league | User on /fit/more mobile page | 1. Tap "League Info" row | URL becomes `/fit/more/league` | P2 | Navigation | No | `page.locator('.more-page').getByRole('link', { name: 'League Info' })` ⚠️ BLOCKED — same TODO comment block in more-page.component.html | click |
| NAV_014 | Active State | Active tab styled with brand color (desktop) | User on /fit/summary, desktop | 1. Inspect active `.pill` computed style | Active pill has `color: var(--fit-color-brand)` and `background: var(--fit-color-surface-muted)`; inactive pills have `color: var(--fit-color-text-secondary)` | P1 | UI | Yes | `page.locator('.desktop-nav .pill.active')` → assert CSS `color` ⚠️ ADD aria-current="page" to active `<button class="pill">` in top-nav.component.html | validate-visible |
| NAV_015 | Active State | Active tab brand color on mobile tab bar | User on /fit/summary, standalone, <768px | 1. Observe Summary `.link` element | `.link.active` has `color: var(--fit-color-brand)`; icon and label text colored accordingly | P1 | UI | Yes | `page.locator('.bar .link.active')` → assert `color` CSS ⚠️ ADD aria-current="page" to active `<button class="link">` in mobile-tab-bar.component.ts inline template | validate-visible |
| NAV_016 | UI — FAB | FAB is center slot (column 3 of 5) in mobile tab bar | User on /fit/summary, standalone, <768px | 1. Observe tab bar grid layout | Tab bar renders 5 columns: Summary, Challenges, FAB slot, Programs, Community; FAB is centered | P1 | UI | Yes | `page.locator('.fab-slot')` ⚠️ ADD data-testid="fab-slot" to `<div class="fab-slot">` in mobile-tab-bar.component.ts inline template | validate-visible |
| NAV_017 | UI — FAB | FAB icon rotates to X when Quick Add sheet is open | FAB visible, standalone, <768px | 1. Click FAB 2. Observe FAB icon | FAB gains `.open` class; `fit-icon` inside rotates 45° (CSS transition); sheet opens | P2 | UI | Yes | `page.locator('.bar .fab')` → assert class `.open` ⚠️ ADD aria-label="Open Quick Add" to `<button class="fab">` in mobile-tab-bar.component.ts inline template | validate-class |
| NAV_018 | UI — Back | Desktop Back button appears on non-tab-root page | User navigates to `/fit/diary`, desktop | 1. Navigate to `/fit/diary` 2. Observe `.desktop-nav` | `.back-area` with "Back" button visible at left of desktop nav; no tab highlighted | P1 | UI | Yes | `page.locator('.desktop-nav').getByRole('button', { name: 'Back' })` ✓ button text "Back" confirmed in top-nav.component.html `.desktop-back` | validate-visible |
| NAV_019 | UI — Back | Back button absent on tab root pages | User on /fit/summary, desktop | 1. Navigate to `/fit/summary` 2. Observe `.desktop-nav` | `.desktop-back` button not rendered; `.back-area` absent from DOM | P1 | UI | Yes | `page.locator('.desktop-back')` → assert count 0 ⚠️ ADD data-testid="desktop-back-btn" to `<button class="desktop-back">` in top-nav.component.html | validate-visible |
| NAV_020 | More Menu | Terms of Usage opens legal modal | More popover open, desktop | 1. Click "Vantage Fit Terms of Usage" menu item | `fit-legal-document-modal` opens with `kind='terms'`; popover closes | P2 | Navigation | Yes | `page.locator('.more-popover').getByRole('button', { name: 'Vantage Fit Terms of Usage' })` ✓ button text confirmed in top-nav.component.html | click |
| NAV_021 | Negative | Rapid tab clicks do not corrupt active state | User on desktop, all 4 tabs visible | 1. Click Summary 2. Immediately click Challenges 3. Immediately click Programs 4. Wait for navigation to settle | Final URL is `/fit/programs`; Programs pill has `.active`; no other pill has `.active`; no JS errors in console | P2 | Negative | No | `page.getByRole('button', { name: 'Programs' })` scoped in `.desktop-nav` → assert `.active` after rapid sequence | click |
| NAV_022 | Negative | Clicking the already-active tab does not break navigation | User on /fit/summary, desktop | 1. Click Summary tab 2. Click Summary tab again | URL remains `/fit/summary`; Summary tab remains active; no duplicate navigation errors | P2 | Negative | Yes | `page.locator('.desktop-nav .pill.active')` → assert text "Summary" unchanged after second click | click |
| NAV_023 | Negative | Browser back on first page in history stack does nothing | Fresh session opened directly to /fit/summary; no previous history | 1. Click "Back" button on desktop (force shown via `?navBack=true`) | Browser history.back() fires; no route change; URL remains `/fit/summary`; no crash | P2 | Negative | No | `page.locator('.desktop-nav').getByRole('button', { name: 'Back' })` → observe URL unchanged after click | click |
| NAV_024 | Negative | Navigating to unknown route shows no tab highlighted | User on desktop | 1. Manually navigate to `/fit/unknown-page` | No `.pill` has `.active` class; no tab is highlighted; Back button visible (non-tab-root) | P2 | Negative | Yes | `page.locator('.desktop-nav .pill.active')` → assert count 0 | navigate |
| NAV_025 | Negative | Opening More popover while Quick Add popover is open closes Quick Add | Desktop, Quick Add popover open | 1. Click "Add" button (opens Quick Add) 2. Click "•••" button (opens More) | Quick Add popover closes; More popover opens; only one popover visible at a time | P2 | Negative | Yes | `page.locator('.quick-add-popover')` → assert hidden; `page.locator('.more-popover')` → assert visible | click |
| NAV_026 | Edge | Deep link to /fit/challenges/123 highlights Challenges tab | Fresh navigation to `/fit/challenges/123` | 1. Navigate directly to `/fit/challenges/123` | Challenges pill has `.active` class; prefix match on `/fit/challenges` matches | P1 | Edge | Yes | `expect(page).toHaveURL(/\/fit\/challenges\/123/)` then `page.locator('.desktop-nav .pill.active')` → assert text "Challenges" | navigate |
| NAV_027 | Edge | Deep link to /fit/diary shows no tab active, Back button shown | Fresh navigation to `/fit/diary` | 1. Navigate directly to `/fit/diary` | No pill has `.active`; `.desktop-back` button visible | P1 | Edge | Yes | `expect(page).toHaveURL(/\/fit\/diary/)` then `page.locator('.desktop-nav .pill.active')` count 0; `page.locator('.desktop-nav').getByRole('button', { name: 'Back' })` visible | navigate |
| NAV_028 | Edge | Refresh on /fit/programs keeps Programs tab active | User on /fit/programs, desktop | 1. Hard-reload page (Ctrl+R) | After reload Programs pill has `.active`; `currentPath` re-initialised from `router.url` in constructor | P1 | Edge | Yes | `expect(page).toHaveURL(/\/fit\/programs/)` then `page.locator('.desktop-nav .pill.active')` → assert text "Programs" | navigate |
| NAV_029 | Edge | Refresh on /fit/more keeps More icon active (mobile pill nav) | User on /fit/more, embedded mode, <768px | 1. `page.setViewportSize({ width: 375, height: 812 })` 2. Navigate to `/fit/more` 3. Reload | `.pill-nav .tab.active` has text "More"; `currentPath.startsWith('/fit/more')` is true | P1 | Edge | Yes | `expect(page).toHaveURL(/\/fit\/more/)` then `page.locator('.pill-nav .tab.active')` → assert text "More" | navigate |
| NAV_030 | Edge | Auxiliary outlet URL keeps Challenges tab active | Navigate to `/fit/challenges/(challengesOutlet:listing)` | 1. Navigate to `/fit/challenges/(challengesOutlet:listing)` 2. Observe active tab | Challenges tab has `.active`; `normalizeNavPath()` strips auxiliary outlet group | P2 | Edge | Yes | `expect(page).toHaveURL(/\/fit\/challenges/)` then `page.locator('.desktop-nav .pill.active')` → assert text "Challenges" | navigate |
| NAV_031 | Navigation | Back button calls window.history.back() | User on /fit/diary (reached from /fit/summary), desktop | 1. Navigate to `/fit/summary` 2. Navigate to `/fit/diary` 3. Click "Back" button | URL reverts to `/fit/summary`; Summary tab becomes active | P1 | Navigation | Yes | `page.locator('.desktop-nav').getByRole('button', { name: 'Back' })` → `expect(page).toHaveURL(/\/fit\/summary/)` | click |
| NAV_032 | Navigation | ?navBack=true on a tab root shows Back button | Navigate to `/fit/summary?navBack=true` | 1. Navigate to `/fit/summary?navBack=true` 2. Observe top-nav | Back button rendered even though Summary is a tab root; both active tab and Back button visible simultaneously | P2 | Navigation | Yes | `expect(page).toHaveURL(/navBack=true/)` then `page.locator('.desktop-nav').getByRole('button', { name: 'Back' })` visible and `page.locator('.desktop-nav .pill.active')` text "Summary" | navigate |
| NAV_033 | Navigation | More popover closes automatically on router navigation | More popover open, desktop | 1. Open More popover 2. Navigate to `/fit/challenges` | More popover closes; Challenges tab becomes active; `NavigationEnd` subscription fires `moreOpen = false` | P1 | Navigation | Yes | Navigate then `expect(page).toHaveURL(/\/fit\/challenges/)` then `page.locator('.more-popover')` → assert hidden | navigate |
| NAV_034 | Responsive | Mobile tab bar visible at 767px (standalone mode) | App in standalone mode | 1. `page.setViewportSize({ width: 767, height: 812 })` first 2. Navigate to `/fit/summary` | `.bar` visible; 5-column grid with FAB slot rendered | P1 | Responsive | Yes | `page.setViewportSize({ width: 767, height: 812 })` first → `page.locator('.bar')` → assert visible ⚠️ ADD data-testid="mobile-tab-bar" to `<nav class="bar">` in mobile-tab-bar.component.ts inline template | viewport |
| NAV_035 | Responsive | Mobile tab bar hidden at exactly 768px | App in standalone mode | 1. `page.setViewportSize({ width: 768, height: 900 })` first 2. Navigate to `/fit/summary` | `.bar` has `display: none` via `@media (min-width: 768px)`; desktop nav (`.desktop-nav`) visible | P1 | Responsive | Yes | `page.setViewportSize({ width: 768, height: 900 })` first → `page.locator('.desktop-nav')` visible; `page.locator('.bar')` not visible | viewport |
| NAV_036 | Responsive | "Add" label hidden below 640px; button icon-only | Desktop embedded mode | 1. `page.setViewportSize({ width: 639, height: 900 })` first 2. Observe Add button | `.quick-add-trigger-label` ("Add" text) has `display: none`; button renders as icon-only circle | P2 | Responsive | Yes | `page.setViewportSize({ width: 639, height: 900 })` first → `page.locator('.quick-add-trigger-label')` → assert not visible ⚠️ ADD data-testid="quick-add-trigger-label" to `<span class="quick-add-trigger-label">` in top-nav.component.html | viewport |
| NAV_037 | Responsive | "Add" label visible at 640px | Desktop embedded mode | 1. `page.setViewportSize({ width: 640, height: 900 })` first 2. Observe Add button | `.quick-add-trigger-label` ("Add" text) is visible; full pill button shown | P2 | Responsive | Yes | `page.setViewportSize({ width: 640, height: 900 })` first → `page.locator('.quick-add-trigger-label')` → assert visible | viewport |
| NAV_038 | Responsive | Viewport resize mid-session from mobile to desktop switches nav variant | Embedded mode, started at 375px | 1. `page.setViewportSize({ width: 375, height: 812 })` first — confirm `.pill-nav` visible 2. `page.setViewportSize({ width: 1280, height: 900 })` | `.pill-nav` hidden; `.desktop-nav` visible; active tab state matches current URL in new variant | P2 | Responsive | Yes | `page.setViewportSize({ width: 375, height: 812 })` first → assert `page.locator('.pill-nav')` visible; then `page.setViewportSize({ width: 1280, height: 900 })` → assert `page.locator('.desktop-nav')` visible | viewport |
| NAV_039 | Mode | Embedded mode shows Mobile Pill Nav at mobile viewport | `navMode = 'embedded'`, viewport <768px | 1. Set viewport 375×812 2. Navigate to `/fit/summary` | `.pill-nav` visible; `.bar` (tab bar) not visible; FAB visible via `app-quick-add-fab` | P1 | Mode | Yes | `page.locator('.pill-nav')` → assert visible; `page.locator('.bar')` → assert not visible ⚠️ ADD data-testid="mobile-pill-nav" to `<nav class="pill-nav">` in mobile-pill-nav.component.ts inline template | validate-visible |
| NAV_040 | Mode | Standalone mode shows Mobile Tab Bar at mobile viewport | `navMode = 'standalone'`, viewport <768px | 1. Set viewport 375×812 2. Navigate to `/fit/summary` | `.bar` visible with 5-column layout; `.pill-nav` not visible | P1 | Mode | Yes | `page.locator('.bar')` → assert visible; `page.locator('.pill-nav')` → assert not visible | validate-visible |
| NAV_041 | Mode | Chromeless route /fit/bite-size-content hides all nav | Navigate to `/fit/bite-size-content` | 1. Navigate to `/fit/bite-size-content` | No `app-top-nav`, no `.pill-nav`, no `.bar`, no FAB, no footer rendered; `.wrapper` has `.chromeless` class | P1 | Mode | Yes | `page.locator('.desktop-nav')` count 0; `page.locator('.pill-nav')` count 0; `page.locator('.bar')` count 0; `page.locator('.wrapper.chromeless')` visible | navigate |
| NAV_042 | Accessibility | Tab key navigates through desktop pill tabs in order | Desktop ≥768px, focus on first nav pill | 1. Focus first `.pill` 2. `page.keyboard.press('Tab')` 3 times | Focus advances through Summary → Challenges → Programs → Community pills in DOM order; `:focus-visible` outline visible on each | P2 | Accessibility | No | `page.keyboard.press('Tab')` then `page.locator('.desktop-nav .pill:focus-visible')` ⚠️ ADD aria-current="page" to active `.pill`; ADD role="tablist" to `.pills` and role="tab" to each `.pill` in top-nav.component.html | keyboard |
| NAV_043 | Accessibility | Enter key activates focused tab | Focus on "Programs" pill, not active | 1. Tab focus to "Programs" pill 2. `page.keyboard.press('Enter')` | URL navigates to `/fit/programs`; Programs pill gains `.active` | P1 | Accessibility | No | `page.keyboard.press('Enter')` after `page.locator('.desktop-nav .pill', { hasText: 'Programs' }).focus()` then `expect(page).toHaveURL(/\/fit\/programs/)` | keyboard |
| NAV_044 | Accessibility | Escape key closes More popover | More popover open, desktop | 1. Open More popover 2. `page.keyboard.press('Escape')` | `.more-popover` closes; `@HostListener('document:keydown.escape')` fires `moreOpen = false` | P1 | Accessibility | Yes | `page.keyboard.press('Escape')` → `page.locator('.more-popover')` → assert hidden | keyboard |
| NAV_045 | Accessibility | Escape also closes Quick Add popover simultaneously | Quick Add open alone | 1. Open Quick Add popover 2. `page.keyboard.press('Escape')` | `.quick-add-popover` closes; same `@HostListener` handler closes both `moreOpen` and `quickAddOpen` | P2 | Accessibility | Yes | `page.keyboard.press('Escape')` → `page.locator('.quick-add-popover')` → assert hidden | keyboard |

---

## 🚧 Testability Gaps

### `projects/fit/src/ui/new-ui/components/top-nav/top-nav.component.html`

| Element | Gap | Suggested Fix |
|---------|-----|---------------|
| `<button class="pill">` (×4) | No `aria-label`, no `data-testid`, no `aria-current="page"` on active state — only text content available; brittle if label changes | ADD `[attr.data-testid]="'nav-tab-' + t.path"` and `[attr.aria-current]="isActive(t) ? 'page' : null"` |
| `<div class="pills">` wrapper | No `role="tablist"` — screen readers cannot identify this as a tab group | ADD `role="tablist"` and `aria-label="Primary navigation"` |
| `<button class="more-trigger">` (desktop) | No `aria-label`, no `aria-expanded`, no `aria-haspopup="menu"` | ADD `aria-label="More menu"` `[attr.aria-expanded]="moreOpen"` `aria-haspopup="menu"` |
| `<div class="more-popover">` | No `role="menu"`, no `data-testid` — automation must target by CSS class only | ADD `role="menu"` `data-testid="more-popover"` |
| `<div class="popover-backdrop">` (×2) | No `data-testid` — two instances exist (one for More, one for Quick Add); `.first()` is fragile | ADD `data-testid="more-popover-backdrop"` to the More one, `data-testid="quick-add-popover-backdrop"` to the other |
| `<button class="menu-item">` (Download App) | No `aria-label`; `role="menuitem"` absent | ADD `aria-label="Download App"` `role="menuitem"` |
| `<button class="menu-item">` (Privacy Policy) | No `aria-label`; `role="menuitem"` absent | ADD `aria-label="Vantage Fit Privacy Policy"` `role="menuitem"` |
| `<button class="menu-item">` (Terms of Usage) | No `aria-label`; `role="menuitem"` absent | ADD `aria-label="Vantage Fit Terms of Usage"` `role="menuitem"` |
| `<button class="more-trigger">` (inside `.mobile-bar`) | No `aria-label` | ADD `aria-label="More menu"` |
| `<span class="quick-add-trigger-label">` | No `data-testid` — responsive hide/show test requires targeting this span | ADD `data-testid="quick-add-trigger-label"` |
| `<div class="desktop-nav">` | No `role="navigation"`, no `aria-label` | ADD `role="navigation"` `aria-label="Primary navigation"` |
| `<div class="mobile-bar">` | No `data-testid` | ADD `data-testid="mobile-title-bar"` |

### `projects/fit/src/ui/new-ui/components/mobile-tab-bar/mobile-tab-bar.component.ts` (inline template)

| Element | Gap | Suggested Fix |
|---------|-----|---------------|
| `<nav class="bar">` | No `aria-label` — `<nav>` is semantic ✓ but unlabelled; multiple `<nav>` elements on the page need distinguishing labels | ADD `aria-label="Main navigation"` and `data-testid="mobile-tab-bar"` |
| `<button class="link">` (×4) | No `aria-label`, no `aria-current="page"` — text label only | ADD `[attr.aria-label]="t.label"` `[attr.aria-current]="isActive(t) ? 'page' : null"` |
| `<button class="fab">` | No `aria-label`, no `data-testid` | ADD `aria-label="Quick Add"` `data-testid="tab-bar-fab"` |
| `<div class="fab-slot">` | No `data-testid` | ADD `data-testid="fab-slot"` |

### `projects/fit/src/ui/new-ui/components/mobile-pill-nav/mobile-pill-nav.component.ts` (inline template)

| Element | Gap | Suggested Fix |
|---------|-----|---------------|
| `<nav class="pill-nav">` | No `aria-label`, no `data-testid` | ADD `aria-label="Main navigation"` `data-testid="mobile-pill-nav"` |
| `<button class="tab">` (×4 + More) | No `aria-label`, no `aria-current="page"` | ADD `[attr.aria-label]="t.label"` `[attr.aria-current]="isActive(t) ? 'page' : null"` |
| `<button class="tab">` (More entry) | No `data-testid` | ADD `data-testid="nav-tab-more"` |

### `projects/fit/src/ui/new-ui/pages/more-page.component.html`

| Element | Gap | Suggested Fix |
|---------|-----|---------------|
| `<div class="more-page">` | No `data-testid`, no landmark role | ADD `data-testid="more-page"` and `role="main"` |
| `<button class="menu-row">` (Download App) | No `aria-label` | ADD `aria-label="Download App"` |
| `<button class="menu-row">` (Privacy Policy) | No `aria-label` | ADD `aria-label="Vantage Fit Privacy Policy"` |
| `<button class="menu-row">` (Terms of Usage) | No `aria-label` | ADD `aria-label="Vantage Fit Terms of Usage"` |
| My Activities, My Badges, Trends, My Health, League Info, Settings | All inside `<!-- TODO:// Implement -->` comment blocks — **not in DOM** | NAV_011, NAV_012, NAV_013 are fully blocked until these comment blocks are removed |
| `<div class="profile-card profile-card-static">` | Static div — not a landmark; no `aria-label` | ADD `aria-label="User profile"` `role="region"` |

### `projects/fit/src/ui/new-ui/app-wrapper.component.ts` (inline template — no separate `.html` file)

| Element | Gap | Suggested Fix |
|---------|-----|---------------|
| `<fit-full-page-loader>` | No `data-testid` | ADD `data-testid="full-page-loader"` to component or its host element |
| `<div class="wrapper">` | No `data-testid` | ADD `data-testid="app-wrapper"` |
| `.chromeless` class | Chromeless state testable via CSS class only — no semantic attribute | ADD `data-testid="app-wrapper"` so `page.locator('[data-testid="app-wrapper"].chromeless')` is stable |

---

## 🎯 Shared Nav Locators (For Reuse Across All Playwright Tests)

These locators should be exported from a future `navigation.page.ts` page object and imported by all feature test files.

| Alias | Playwright Locator | Status | Suggested Fix if Broken |
|-------|--------------------|--------|------------------------|
| `desktopNav` | `page.locator('.desktop-nav')` | ⚠️ CSS only | ADD `data-testid="desktop-nav"` → use `page.getByTestId('desktop-nav')` |
| `mobileTabBar` | `page.locator('.bar')` | ⚠️ CSS only | ADD `data-testid="mobile-tab-bar"` → use `page.getByTestId('mobile-tab-bar')` |
| `mobilePillNav` | `page.locator('.pill-nav')` | ⚠️ CSS only | ADD `data-testid="mobile-pill-nav"` → use `page.getByTestId('mobile-pill-nav')` |
| `activeDesktopTab` | `page.locator('.desktop-nav .pill.active')` | ⚠️ CSS only | ADD `aria-current="page"` → use `page.locator('.desktop-nav [aria-current="page"]')` |
| `activeMobileTabBarTab` | `page.locator('.bar .link.active')` | ⚠️ CSS only | ADD `aria-current="page"` → use `page.locator('.bar [aria-current="page"]')` |
| `activePillNavTab` | `page.locator('.pill-nav .tab.active')` | ⚠️ CSS only | ADD `aria-current="page"` → use `page.locator('.pill-nav [aria-current="page"]')` |
| `moreMenuTrigger` | `page.locator('.desktop-nav .more-trigger')` | ⚠️ No `aria-label` | ADD `aria-label="More menu"` → use `page.locator('.desktop-nav').getByRole('button', { name: 'More menu' })` |
| `morePopover` | `page.locator('.more-popover')` | ⚠️ No `data-testid` | ADD `data-testid="more-popover"` → use `page.getByTestId('more-popover')` |
| `morePopoverBackdrop` | `page.locator('.popover-backdrop').first()` | ⚠️ Fragile — two backdrops in DOM | ADD `data-testid="more-popover-backdrop"` → use `page.getByTestId('more-popover-backdrop')` |
| `tabBarFab` | `page.locator('.bar .fab')` | ⚠️ No `aria-label` | ADD `aria-label="Quick Add"` → use `page.locator('.bar').getByRole('button', { name: 'Quick Add' })` |
| `addButton` (desktop Quick Add) | `page.getByRole('button', { name: 'Quick add' })` | ✅ `aria-label="Quick add"` confirmed | No fix needed |
| `backButtonDesktop` | `page.locator('.desktop-nav').getByRole('button', { name: 'Back' })` | ✅ button text "Back" confirmed | No fix needed |
| `backButtonMobile` | `page.locator('.mobile-bar').getByRole('button', { name: 'Back' })` | ✅ button text "Back" confirmed | No fix needed |
| `morePage` | `page.locator('.more-page')` | ⚠️ No `data-testid` | ADD `data-testid="more-page"` → use `page.getByTestId('more-page')` |

---

## 🤖 Automation Notes

- **Framework:** Playwright + TypeScript
- **Locator priority:** `getByTestId` > `getByRole` > `getByLabel` > `getByText` > CSS
- **Shared nav locators** should be exported from a future `navigation.page.ts` page object that all other test files import

**Viewport setup for responsive tests:**

| Test Scenario | Viewport Config |
|--------------|----------------|
| Mobile default | `{ width: 375, height: 812 }` |
| Tablet lower edge (FAB visible) | `{ width: 767, height: 812 }` |
| Tablet upper edge (FAB hidden) | `{ width: 768, height: 900 }` |
| Sub-640 Add label hide | `{ width: 639, height: 900 }` |
| 640 Add label show | `{ width: 640, height: 900 }` |
| Desktop default | `{ width: 1280, height: 900 }` |

**Mode setup:**
- Mock `/api/v1/configuration` response to control `standalone` / `embedded` navMode
- Alternatively inject via URL param `?navMode=standalone` or `?navMode=embedded` for dev/test environments
- `FIT_SHELL_CONTEXT_TOKEN` is authoritative in production — `setMode()` is a no-op when it is set

**Deep link / refresh tests:**
- Use `page.goto('/fit/challenges/123')` directly (no prior navigation), then assert active tab and Back button presence
- For refresh tests: `page.goto(url)` then `page.reload()`, assert active state survives

**Cross-feature dependency:**
- Quick Add Escape handler is coupled to the More popover Escape handler via a single `@HostListener('document:keydown.escape')` in `TopNavComponent` — changes to one risk breaking the other; regression test both together (NAV_044 + NAV_045)
- Floating Dock visibility shares `TAB_ROOT_PATHS` logic with FAB — nav routing changes that alter tab-root detection will affect both
