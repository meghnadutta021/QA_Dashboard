# Workflow Prompts — Test Case Generation from Dev Codebase

This document describes the 7-prompt pattern used to generate structured test cases from a live React codebase using Claude Code. Follow these prompts in order on any new feature. No external help needed — each step feeds the next.

---

## P1 — Lock Scope

**Purpose:** Constrain Claude to a specific folder so it does not hallucinate files or pull context from unrelated parts of the codebase.

**Prompt template:**

> I am doing QA analysis on the Vantage Fit web platform. For this session, only look at files inside `<folder-path>`. Do not reference anything outside this folder unless I explicitly ask. Confirm the folder path and list all files you can see inside it.

**Placeholders:**
- `<folder-path>` — e.g. `fit-prototype/src/pages/Dashboard/` or `src/features/challenges/`

**Save or send:** Neither — this is a setup step only. Wait for Claude to confirm the file list before proceeding.

**Estimated time:** 1–2 minutes

---

## P2 — Get Feature List

**Purpose:** Produce a high-level inventory of all distinct features and sub-features within the scoped folder. This becomes your test planning checklist.

**Prompt template:**

> Based only on the files inside `<folder-path>`, list every distinct user-facing feature and sub-feature you can identify. Group them by logical area (e.g. data display, user actions, empty states, error states). Do not write test cases yet — just list the features.

**Placeholders:**
- `<folder-path>` — same folder locked in P1

**Save or send:** Save the output locally as a scratch note. You will use it to pick which features go into P3.

**Estimated time:** 2–3 minutes

---

## P3 — Deep Scan a Single Feature

**Purpose:** Get a thorough technical understanding of one feature — its components, props, state, API calls, conditions, and UI branches — before writing any test cases.

**Prompt template:**

> Focus only on the `<feature-name>` feature within `<folder-path>`. Read the relevant files: `<file-paths>`. For this feature, tell me:
> 1. What does it render and under what conditions?
> 2. What user actions does it support?
> 3. What state or props drive its behaviour?
> 4. What API calls does it make and what are the expected responses?
> 5. What empty states, loading states, or error states exist?
> Do not write test cases yet.

**Placeholders:**
- `<feature-name>` — e.g. `Activity Ring`, `Challenge Card`, `Quick Add Modal`
- `<folder-path>` — same as P1
- `<file-paths>` — comma-separated list of the most relevant files from P2 output

**Save or send:** Save the output locally. This is your feature spec reference for P4 and P5.

**Estimated time:** 3–5 minutes

---

## P4 — Extract Validations and Edge Cases

**Purpose:** Surface all validation rules, boundary conditions, and edge cases that must be covered in test cases. This step prevents gaps that arise when test cases are generated directly from happy-path code.

**Prompt template:**

> Based on your analysis of `<feature-name>` from P3, now extract:
> 1. All input validation rules (required fields, character limits, format checks, numeric ranges)
> 2. All boundary and edge cases (zero state, max value, missing data, API failure, slow network)
> 3. Any role-based or permission-based differences in behaviour
> 4. Any known UI bugs or inconsistencies visible in the code
> List these as bullet points grouped by category. Do not write test cases yet.

**Placeholders:**
- `<feature-name>` — same feature as P3

**Save or send:** Save locally. Paste this output into P5 alongside the P3 output.

**Estimated time:** 2–3 minutes

---

## P5 — Generate Test Cases as Markdown Table

**Purpose:** Produce the full test case table for the feature in a standard format ready to paste into the final MD file.

**Prompt template:**

> Using your analysis from P3 and the validations from P4 for `<feature-name>`, generate a complete test case table in markdown. Use these exact columns:
>
> | TC ID | Title | Precondition | Steps | Expected Result | Priority | Type | Locator Hint |
>
> Rules:
> - TC IDs: `<PREFIX>-001`, `<PREFIX>-002`, etc.
> - Priority: P0 (smoke), P1 (critical), P2 (standard), P3 (edge case)
> - Type: Functional / Visual / Negative / Boundary / Accessibility
> - Locator Hint: React component name, data-testid if visible in code, or a plain-English description of the element
> - Cover happy path, negative cases, boundary values, empty states, and error states
> - Aim for completeness over brevity

**Placeholders:**
- `<feature-name>` — same feature
- `<PREFIX>` — short uppercase code for this feature, e.g. `SD` for Summary Dashboard, `CP` for Challenges Page

**Save or send:** Save locally as a draft. Do not send to reviewer yet — run P6 first to improve locators.

**Estimated time:** 5–8 minutes

---

## P6 — Improve Locators for Playwright

**Purpose:** Refine the Locator Hint column so that each entry is actionable for a Playwright engineer, referencing real attributes, component names, or aria roles visible in the codebase.

**Prompt template:**

> Review the Locator Hint column in the test case table you just generated for `<feature-name>`. For each row, improve the hint to be as specific as possible using what you can see in the source files. Prefer in this order:
> 1. `data-testid` attribute (if present in the code)
> 2. `aria-label` or `role` attribute
> 3. React component name + prop (e.g. `ActivityRing completed prop`)
> 4. CSS class name (only if stable and not auto-generated)
> 5. Plain-English fallback with element type (e.g. `button labelled "Log Activity"`)
>
> Output the full updated table only — do not add commentary.

**Placeholders:**
- `<feature-name>` — same feature

**Save or send:** Save the updated table locally. This replaces the P5 draft.

**Estimated time:** 3–5 minutes

---

## P7 — Save Final MD File

**Purpose:** Assemble everything into the final feature test case file in the standard format used across this repo. This is the file that goes into `qa-docs/web/test-cases/`.

**Prompt template:**

> Now write the complete final markdown file for `<feature-name>`. Use this exact structure:
>
> 1. `# <Feature Name> — Test Cases` (H1 title)
> 2. One-line description of the feature
> 3. `## 🚦 Smoke Test Checklist` — 5–8 checkbox items covering P0 cases only, written as plain one-line actions
> 4. `## 📋 Full Test Case Table` — the improved table from P6
> 5. `## 🐛 Bugs Observed` — any bugs or inconsistencies spotted in the code during analysis (bullet list; write "None observed" if clean)
> 6. `## 🚧 Testability Gaps` — things devs need to add (data-testids, aria labels, stable selectors) before Playwright automation can run cleanly
> 7. `## 🤖 Automation Notes` — which test cases are highest priority to automate first, and any tricky interactions to be aware of
>
> Output the full markdown file content only. I will save it to `qa-docs/web/test-cases/<feature-name-kebab>.md`.

**Placeholders:**
- `<feature-name>` — full display name, e.g. `Summary Dashboard`
- `<feature-name-kebab>` — lowercase hyphenated filename, e.g. `summary-dashboard`

**Save or send:** This is the main deliverable. Save to `qa-docs/web/test-cases/` and send for reviewer sign-off.

**Estimated time:** 3–5 minutes

---

## 📊 Status Tracker

| Prompt | Output type | Save locally | Send to reviewer | Feeds into |
|---|---|---|---|---|
| P1 — Lock Scope | Confirmation only | No | No | P2 |
| P2 — Feature List | Scratch inventory | Yes | No | P3 |
| P3 — Deep Scan | Feature spec notes | Yes | No | P4, P5 |
| P4 — Validations & Edge Cases | Bullet list | Yes | No | P5 |
| P5 — Test Case Table (draft) | Markdown table | Yes (draft) | No | P6 |
| P6 — Improved Locators | Updated markdown table | Yes (replaces P5 draft) | No | P7 |
| P7 — Final MD File | Complete feature file | Yes → `qa-docs/web/test-cases/` | **Yes** | — |

---

## Tips for New QAs

- Always run P1 first. Skipping it causes Claude to guess file paths and produce inaccurate locators.
- P3 and P4 are the most important steps. The quality of your test cases depends entirely on how well the feature is understood before P5 runs.
- If a feature has sub-features (e.g. Summary Dashboard has Activity Ring, Points Card, Leaderboard), run P3–P6 separately for each sub-feature, then combine into one P7 file.
- Keep your P3 and P4 scratch notes until the final file is reviewed and merged — they are useful if a reviewer asks why a particular edge case was included or excluded.
- The smoke checklist in P7 should be usable by anyone on the team, not just QA. Write it in plain language, no jargon.
