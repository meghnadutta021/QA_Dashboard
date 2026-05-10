# QA Dashboard

A local Spring Boot web application for managing, viewing, and analysing QA test reports.
Test reports are stored as plain JSON files on your machine — no database required.

---

## Quick Start

### Prerequisites

| Tool | Version | Check |
|------|---------|-------|
| Java | 21 or later | `java -version` |
| Maven | 3.8 or later | `mvn -version` |

### Run the application

```bash
# From the project root directory (where pom.xml lives)
mvn spring-boot:run
```

The first run downloads dependencies from Maven Central (~30 seconds).
Subsequent runs start in under 5 seconds.

### Open the dashboard

Once you see `Started QaDashboardApplication` in the terminal, open:

```
http://localhost:8080
```

To stop the application, press `Ctrl + C` in the terminal.

---

## Sample Data

Three sample report files are included in `qa-data/` so the dashboard has data to display
immediately after launch:

```
qa-data/
└── vantagefitness/
    ├── web/
    │   ├── login/
    │   │   └── login##abc001##20260510.json    (3 TCs: 2 PASS, 1 FAIL; 1 bug)
    │   └── payment/
    │       └── payment##abc002##20260510.json  (4 TCs: 3 PASS, 1 FAIL; 2 bugs)
    └── mobile/
        └── login/
            └── login##abc003##20260508.json    (2 TCs: 1 PASS, 1 SKIP; 0 bugs)
```

---

## Adding Your Own Report Files

### Folder structure

Place JSON files here — the folder path determines the filter dropdowns:

```
qa-data/
└── {product}/
    └── {platform}/
        └── {module}/
            └── {module}##{any-id}##{YYYYMMDD}.json
```

**Example:**

```
qa-data/
└── myapp/
    └── web/
        └── checkout/
            └── checkout##run01##20260515.json
```

This file would appear in the dashboard when you filter:
`Product = myapp` → `Platform = web` → `Module = checkout`

### Filename format

```
{module}##{unique-id}##{date}.json
```

- `{module}` — matches the parent folder name (e.g. `login`, `checkout`)
- `{unique-id}` — any string without `##` or `/` (e.g. `run01`, `abc123`, `sprint-12`)
- `{date}` — exactly 8 digits in `YYYYMMDD` format (e.g. `20260510`)

**Valid examples:**

```
login##sprint14##20260510.json
checkout##run01##20260501.json
dashboard##abc123##20260430.json
```

### Using the Import page

Instead of placing files manually, use the built-in importer:

1. Click **Import** in the top navigation bar
2. Select your `.json` file
3. Click **Upload & Import**

The importer reads `meta.product`, `meta.platform`, `meta.module`, and `meta.date` from the
file and saves it to the correct folder automatically.

---

## JSON Schema

Every report file must be a JSON object with three top-level keys:

```json
{
  "meta": { ... },
  "test_cases": [ ... ],
  "bugs": [ ... ]
}
```

### `meta` object

| Field | Required | Description |
|-------|----------|-------------|
| `product` | **Yes** | Product name, matches the folder name (e.g. `"vantagefitness"`) |
| `platform` | **Yes** | Platform name, matches the sub-folder (e.g. `"web"`, `"android"`) |
| `module` | **Yes** | Module name, matches the deepest folder (e.g. `"login"`) |
| `date` | **Yes** | Run date in `YYYYMMDD` format (e.g. `"20260510"`) |
| `report_id` | No | Auto-generated from the filename if omitted |
| `tester` | No | Name of the tester who executed the run |
| `environment` | No | Environment name (e.g. `"staging"`, `"production"`) |

### `test_cases` array

Each item in the array represents one test case:

```json
{
  "tc_id":        "TC-LOGIN-001",
  "scenario":     "User authentication",
  "title":        "Valid credentials — dashboard loads",
  "priority":     "P1",
  "status":       "PASS",
  "precondition": "A valid account exists",
  "steps":        ["Step 1", "Step 2"],
  "expected":     "User sees the dashboard",
  "actual":       "Dashboard loaded successfully",
  "notes":        "Optional free-text notes"
}
```

| Field | Values |
|-------|--------|
| `priority` | `P1` `P2` `P3` `P4` |
| `status` | `PASS` `FAIL` `SKIP` `BLOCKED` |

### `bugs` array

Each item represents one bug. Link a bug to a test case using `tc_id`:

```json
{
  "bug_id":      "BUG-LOGIN-001",
  "tc_id":       "TC-LOGIN-001",
  "title":       "Login button unresponsive on slow connections",
  "severity":    "HIGH",
  "status":      "OPEN",
  "description": "Optional longer description",
  "steps":       ["Step 1", "Step 2"],
  "expected":    "Loading spinner appears",
  "actual":      "Button freezes",
  "notes":       "Optional notes"
}
```

| Field | Values |
|-------|--------|
| `severity` | `CRITICAL` `HIGH` `MEDIUM` `LOW` |
| `status` | `OPEN` `IN_PROGRESS` `FIXED` `CLOSED` |

A bug whose `tc_id` does not match any test case in the same file is called an **orphan bug**
and is highlighted with a warning banner on the Bugs page.

---

## Features

### Dashboard Overview (`/`)
- Aggregated stats: total test cases, pass count, fail count, open bugs
- Pass rate percentage with colour-coded indicator (green ≥ 80%, yellow ≥ 50%, red < 50%)
- Per-module breakdown table with individual pass rates
- Recent failures list (top 5)
- Filter by product, platform, module, and date

### Test Cases (`/test-cases`)
- Full list of test cases with Priority and Status badges
- Linked bug count per test case
- Export as CSV (Excel-ready with UTF-8 BOM) or JSON
- Filter by product, platform, module, and date

### Test Case Detail (`/test-cases/{tc_id}`)
- Step list, expected vs actual results, notes
- Linked bugs shown inline

### Bugs (`/bugs`)
- Bug list sorted by severity (CRITICAL first)
- Filter by product, platform, module, date, status, and severity
- Orphan bug detection with warning banner
- Export as CSV or JSON

### Bug Detail (`/bugs/{bug_id}`)
- Reproduction steps, expected vs actual
- Linked test case shown inline

### Import (`/import`)
- Upload a JSON report file through the browser
- Automatic schema validation with error messages
- File saved to the correct folder automatically

### Export (`/export/csv` and `/export/json`)
- Downloads respect the active filter parameters
- CSV includes UTF-8 BOM for correct display in Microsoft Excel

---

## Project Structure

```
src/
└── main/
    ├── java/com/qa/dashboard/
    │   ├── controller/
    │   │   ├── DashboardController.java      GET /
    │   │   ├── TestCaseController.java       GET /test-cases, /test-cases/{id}
    │   │   ├── BugController.java            GET /bugs, /bugs/{id}
    │   │   ├── ImportController.java         GET/POST /import
    │   │   ├── ExportController.java         GET /export/json, /export/csv
    │   │   └── GlobalExceptionHandler.java   @ControllerAdvice error handler
    │   ├── service/
    │   │   ├── QaDataService.java            Business logic, data aggregation
    │   │   ├── FileReaderService.java        Scans qa-data/ for .json files
    │   │   └── ReportParserService.java      Parses JSON into Java objects
    │   ├── dto/
    │   │   ├── DashboardSummary.java         Aggregated counts for the overview page
    │   │   ├── TestCaseView.java             Test case + context (product, platform…)
    │   │   └── BugView.java                  Bug + context + linked test case
    │   └── model/
    │       ├── QaReport.java                 Root JSON object
    │       ├── Meta.java                     The "meta" block
    │       ├── TestCase.java                 One item from "test_cases"
    │       └── Bug.java                      One item from "bugs"
    └── resources/
        ├── application.properties            Server port, FreeMarker config
        └── templates/
            ├── layout/
            │   └── base.ftlh                 Shared HTML shell (nav, sidebar, footer)
            ├── dashboard.ftlh                Overview page
            ├── test-cases.ftlh              Test cases list
            ├── test-case-detail.ftlh        Test case detail
            ├── bugs.ftlh                     Bug list
            ├── bug-detail.ftlh              Bug detail
            ├── upload.ftlh                  Import / upload page
            └── error.ftlh                   Global error page

qa-data/                                     ← Your JSON report files go here
└── {product}/{platform}/{module}/
    └── {module}##{id}##{YYYYMMDD}.json
```

---

## Configuration

All settings are in `src/main/resources/application.properties`:

| Property | Default | Description |
|----------|---------|-------------|
| `server.port` | `8080` | HTTP port — change if 8080 is in use |
| `qa.data.path` | `./qa-data` | Path to the reports folder (relative to project root) |
| `spring.freemarker.cache` | `false` | Set to `true` in production for faster template rendering |
| `spring.servlet.multipart.max-file-size` | `10MB` | Maximum upload size per file |

---

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Framework | Spring Boot 3.3.5 |
| Language | Java 21 |
| Template engine | FreeMarker |
| Styling | Tailwind CSS (Play CDN) |
| JSON parsing | Jackson Databind |
| Build tool | Maven |
| Boilerplate reduction | Lombok |

No database. No external services. Runs entirely offline.
