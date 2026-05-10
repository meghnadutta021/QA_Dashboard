# QA Dashboard — Report Schema Specification

This document describes the exact format that every JSON report file must follow
before it can be imported into the QA Dashboard. Read it top-to-bottom before
writing or generating a report.

---

## 1. Overview

Each report is a single `.json` file. Its top level must have exactly three keys:

```json
{
  "meta":       { ... },
  "test_cases": [ ... ],
  "bugs":       [ ... ]
}
```

| Key          | Type   | Required | Description                              |
|--------------|--------|----------|------------------------------------------|
| `meta`       | object | Yes      | Who, what, where, and when for this run  |
| `test_cases` | array  | Yes      | All test cases executed in this run      |
| `bugs`       | array  | Yes      | All bugs found during this run           |

`test_cases` and `bugs` may be empty arrays `[]` when there is nothing to report,
but the keys themselves must always be present.

---

## 2. File Naming Convention

```
{module}##{unique-string}##{YYYYMMDD}.json
```

**Examples:**
```
login##abc001##20260510.json
payment##xyz99##20260512.json
checkout##run7##20260601.json
```

| Part            | Description                                               |
|-----------------|-----------------------------------------------------------|
| `{module}`      | Lowercase module name — must match `meta.module` exactly  |
| `##`            | Literal double-hash separator (not a single `#`)          |
| `{unique-string}` | Any short alphanumeric string to prevent filename clashes |
| `{YYYYMMDD}`    | Run date in year-month-day format — must match `meta.date`|

---

## 3. Folder Placement

Place the file in:

```
qa-data/{product}/{platform}/{module}/
```

**Example** — for `meta.product = "vantagefitness"`, `meta.platform = "web"`, `meta.module = "login"`:

```
qa-data/
  vantagefitness/
    web/
      login/
        login##abc001##20260510.json   ← place the file here
```

The dashboard reads every `.json` file it finds under `qa-data/` recursively, so
subfolders are created automatically on first upload via the Import page.

---

## 4. Field Reference

### 4.1 `meta` object

| Field         | Type   | Required | Allowed Values / Pattern     | Example              | Description                                             |
|---------------|--------|----------|------------------------------|----------------------|---------------------------------------------------------|
| `report_id`   | string | No       | Any string                   | `"login-web-20260510"` | A unique label for this run. Auto-generated if omitted. |
| `product`     | string | Yes      | **lowercase**, `a-z 0-9 _ -` | `"vantagefitness"`   | Must exactly match the first folder level under `qa-data/` |
| `platform`    | string | Yes      | **lowercase**, `a-z 0-9 _ -` | `"web"`, `"android"`, `"ios"` | Must exactly match the second folder level |
| `module`      | string | Yes      | **lowercase**, `a-z 0-9 _ -` | `"login"`, `"payment"` | Must exactly match the third folder level and the file prefix |
| `date`        | string | Yes      | `YYYYMMDD` (8 digits)        | `"20260510"`         | The date the tests were run |
| `environment` | string | No       | Any string                   | `"staging"`, `"production"` | The environment under test |
| `tester`      | string | No       | Any string                   | `"Meghna Dutta"`     | Name of the person who ran the tests |

---

### 4.2 `test_cases` array items

Each item in the `test_cases` array is one test case object.

| Field          | Type           | Required | Allowed Values           | Example                                      | Description                                           |
|----------------|----------------|----------|--------------------------|----------------------------------------------|-------------------------------------------------------|
| `tc_id`        | string         | Yes      | Any unique string        | `"TC-LOGIN-001"`                             | Unique ID for this test case within the file          |
| `scenario`     | string         | No       | Any string               | `"User Authentication"`                      | Broad feature area this test belongs to               |
| `title`        | string         | Yes      | Any string               | `"Successful login with valid credentials"`  | Short description of what this test checks            |
| `precondition` | string         | No       | Any string               | `"User account exists"`                      | Required state before executing the steps             |
| `steps`        | array (string) | Yes      | List of step strings     | `["Open /login", "Enter credentials"]`       | Ordered list of tester actions                        |
| `expected`     | string         | Yes      | Any string               | `"Dashboard loads"`                          | What the app should do if working correctly           |
| `actual`       | string         | Yes      | Any string               | `"Dashboard loaded"`                         | What the app actually did during the test run         |
| `priority`     | string         | Yes      | `P1` `P2` `P3` `P4`     | `"P1"`                                       | Urgency: P1 = highest, P4 = lowest                   |
| `status`       | string         | Yes      | `PASS` `FAIL` `SKIP` `BLOCKED` | `"PASS"`                               | The outcome of this test run                          |
| `notes`        | string         | No       | Any string               | `"Flaky on Safari"`                          | Free-text observations from the tester                |

**Priority key:**

| Value | Meaning           |
|-------|-------------------|
| `P1`  | Critical — must fix before release |
| `P2`  | High — fix in current sprint        |
| `P3`  | Medium — schedule for next release  |
| `P4`  | Low — cosmetic / nice-to-have       |

---

### 4.3 `bugs` array items

Each item in the `bugs` array is one bug object.

| Field         | Type           | Required | Allowed Values                          | Example                                | Description                                            |
|---------------|----------------|----------|-----------------------------------------|----------------------------------------|--------------------------------------------------------|
| `bug_id`      | string         | Yes      | Any unique string                       | `"BUG-LOGIN-001"`                      | Unique ID for this bug within the file                 |
| `tc_id`       | string         | Yes      | Should match a `tc_id` in this file     | `"TC-LOGIN-002"`                       | The test case that discovered this bug                 |
| `title`       | string         | Yes      | Any string                              | `"Login returns HTTP 500 on bad password"` | Short headline describing the bug                  |
| `description` | string         | No       | Any string                              | `"When user enters wrong password..."` | Longer explanation of the bug                          |
| `steps`       | array (string) | Yes      | List of step strings                    | `["Go to /login", "Enter wrong pass"]` | Steps to reproduce                                     |
| `expected`    | string         | Yes      | Any string                              | `"HTTP 401 with error message"`        | What the app should have done                          |
| `actual`      | string         | Yes      | Any string                              | `"HTTP 500 with stack trace"`          | What the app actually did (the broken behaviour)       |
| `severity`    | string         | Yes      | `LOW` `MEDIUM` `HIGH` `CRITICAL`        | `"CRITICAL"`                           | Business impact of the bug                             |
| `status`      | string         | Yes      | `OPEN` `IN_PROGRESS` `RESOLVED` `CLOSED` | `"OPEN"`                             | Current lifecycle state                                |
| `notes`       | string         | No       | Any string                              | `"Regression since v2.4.1"`           | Workarounds, PR links, extra context                   |

**Severity key:**

| Value      | Meaning                                       |
|------------|-----------------------------------------------|
| `CRITICAL` | App unusable / data loss / security risk      |
| `HIGH`     | Major feature broken, no workaround           |
| `MEDIUM`   | Feature degraded, workaround exists           |
| `LOW`      | Minor / cosmetic, does not block usage        |

**Bug status key:**

| Value        | Meaning                              |
|--------------|--------------------------------------|
| `OPEN`       | Not yet assigned or started          |
| `IN_PROGRESS`| Being actively worked on             |
| `RESOLVED`   | Fix implemented, pending verification|
| `CLOSED`     | Verified fixed and closed out        |

---

## 5. Critical Rules

These rules are enforced by the dashboard. Violating them causes import errors
or silently broken links between bugs and test cases.

1. **Lowercase product / platform / module.**
   `meta.product`, `meta.platform`, and `meta.module` must be entirely lowercase
   and contain only letters, digits, hyphens, or underscores.
   `"VantageFit"` is invalid. `"vantagefitness"` is correct.

2. **Values must match the folder path exactly.**
   If the file is placed in `qa-data/vantagefitness/web/login/`, then:
   - `meta.product` must be `"vantagefitness"` (not `"VantageFit"`, not `"vantage_fitness"`)
   - `meta.platform` must be `"web"`
   - `meta.module` must be `"login"`

3. **Each `tc_id` must be unique within a file.**
   Having two test cases with the same `tc_id` in one file will cause the second
   one to overwrite the first in the dashboard UI.

4. **`bug.tc_id` should reference an existing `tc_id` in the same file.**
   If a bug's `tc_id` does not match any test case in the file, the bug will be
   shown on the dashboard as an "Orphan Bug" with a warning badge. This is
   allowed but indicates a data quality issue.

5. **`meta.date` must be exactly 8 digits in `YYYYMMDD` format.**
   `"2026-05-10"` (with dashes) is invalid. `"20260510"` is correct.

6. **The file must be valid JSON.**
   Trailing commas, comments (except `_comment` keys), and single-quoted strings
   are not valid JSON and will cause the upload to fail.

---

## 6. Prompt Template for AI

Copy the block below and paste it into ChatGPT, Claude, or any AI assistant.
Replace the `{...}` placeholders with your own test session notes.

```
You are a QA analyst generating a structured JSON test report.

Follow this EXACT schema — do not add or rename any keys:

{
  "meta": {
    "report_id":   "<module>-<platform>-<YYYYMMDD>",
    "product":     "<product — MUST be lowercase>",
    "platform":    "<platform — MUST be lowercase: web | android | ios>",
    "module":      "<module — MUST be lowercase>",
    "date":        "<YYYYMMDD>",
    "environment": "<staging | production | dev>",
    "tester":      "<tester name>"
  },
  "test_cases": [
    {
      "tc_id":        "TC-<MODULE>-<NNN>",
      "scenario":     "<broad feature area>",
      "title":        "<what this test checks>",
      "precondition": "<required state before steps>",
      "steps":        ["<step 1>", "<step 2>", "..."],
      "expected":     "<what the app should do>",
      "actual":       "<what the app actually did>",
      "priority":     "<P1 | P2 | P3 | P4>",
      "status":       "<PASS | FAIL | SKIP | BLOCKED>",
      "notes":        "<optional tester observations>"
    }
  ],
  "bugs": [
    {
      "bug_id":      "BUG-<MODULE>-<NNN>",
      "tc_id":       "<must match a tc_id above>",
      "title":       "<short bug headline>",
      "description": "<what the bug is and when it occurs>",
      "steps":       ["<step 1>", "<step 2>", "..."],
      "expected":    "<correct behaviour>",
      "actual":      "<broken behaviour>",
      "severity":    "<LOW | MEDIUM | HIGH | CRITICAL>",
      "status":      "<OPEN | IN_PROGRESS | RESOLVED | CLOSED>",
      "notes":       "<workarounds, PR links, extra context>"
    }
  ]
}

CRITICAL RULES:
- product, platform, and module MUST be fully lowercase
- Each tc_id must be unique within the file
- Each bug.tc_id must reference an existing tc_id in the same file
- date must be exactly 8 digits: YYYYMMDD (no dashes)
- status for test cases: PASS | FAIL | SKIP | BLOCKED
- priority for test cases: P1 | P2 | P3 | P4
- severity for bugs: LOW | MEDIUM | HIGH | CRITICAL
- status for bugs: OPEN | IN_PROGRESS | RESOLVED | CLOSED

Generate a complete JSON report for the following test session:

Product:  {product name}
Platform: {web / android / ios}
Module:   {module name}
Date:     {YYYYMMDD}
Tester:   {your name}

My test notes:
{paste your test session notes here — what you tested, what passed, what failed,
 any bugs you found, steps to reproduce, expected vs actual results}
```
