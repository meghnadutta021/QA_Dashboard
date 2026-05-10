package com.qa.dashboard.controller;

// =============================================================================
// ExportController.java
// =============================================================================
// PURPOSE
// -------
// Handles two file-download endpoints:
//
//   GET /export/json  → downloads filtered test cases + bugs as a .json file
//   GET /export/csv   → downloads filtered test cases as a .csv file (Excel-ready)
//
// Both endpoints accept the same optional filter params as the list pages:
//   ?product=vantagefitness&platform=web&module=login&date=20260510
//
// WHAT IS ResponseEntity<byte[]>?
// --------------------------------
// Normally a @Controller method returns a template name (a String like "bugs").
// For file downloads we need to return raw bytes AND control the HTTP headers,
// so we use ResponseEntity<byte[]> instead.
//
// ResponseEntity<T> lets you specify three things in one object:
//   1. The response body  — byte[] for binary/text file content
//   2. The HTTP status    — e.g. 200 OK
//   3. The HTTP headers   — e.g. Content-Type, Content-Disposition
//
// WHAT IS Content-Disposition?
// ----------------------------
// The Content-Disposition HTTP response header tells the browser what to do
// with the bytes it receives:
//   "inline"                         → display in the browser window
//   "attachment; filename=\"x.csv\"" → open the Save-As dialog (download)
//
// We use "attachment" so clicking the export button always triggers a download.
//
// WHAT IS THE UTF-8 BOM?
// -----------------------
// A BOM (Byte Order Mark) is 3 invisible bytes at the very start of a file:
//   0xEF  0xBB  0xBF
// They signal to programs "this file is encoded in UTF-8".
// Without a BOM, Microsoft Excel may misread non-ASCII characters (é, ü, ₹ …)
// and show garbled text when opening a UTF-8 CSV. Prefixing the 3 BOM bytes
// makes Excel open the file correctly on all platforms.
//
// WHAT IS RFC 4180 CSV ESCAPING?
// --------------------------------
// RFC 4180 is the published standard for CSV files. Its escaping rule:
//   • If a cell value contains a comma, a double-quote, or a newline,
//     wrap the entire value in double-quotes.
//   • If the value itself contains a double-quote, write it as "" (two quotes).
//
//   Examples:
//     hello           → hello           (no special characters, no wrapping)
//     hello, world    → "hello, world"  (comma inside → wrap)
//     say "hi"        → "say ""hi"""    (quote inside → double it, then wrap)
//     line1\nline2    → "line1\nline2"  (newline inside → wrap)
// =============================================================================

import com.fasterxml.jackson.databind.ObjectMapper;

import com.qa.dashboard.dto.BugView;
import com.qa.dashboard.dto.TestCaseView;
import com.qa.dashboard.service.QaDataService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/export")
public class ExportController {

    private static final Logger log = LoggerFactory.getLogger(ExportController.class);

    @Autowired
    private QaDataService qaDataService;

    @Autowired
    private ObjectMapper objectMapper;

    // =========================================================================
    // GET /export/json  —  download filtered data as a JSON file
    // =========================================================================

    /**
     * Returns a JSON file containing all test cases and bugs that match the
     * active filter parameters. The file is delivered as a download attachment.
     *
     * URL examples:
     *   /export/json
     *   /export/json?product=vantagefitness&platform=web&date=20260510
     *
     * @throws Exception if Jackson cannot serialise the payload (extremely unlikely)
     */
    @GetMapping("/json")
    public ResponseEntity<byte[]> exportJson(
            @RequestParam(required = false) String product,
            @RequestParam(required = false) String platform,
            @RequestParam(required = false) String module,
            @RequestParam(required = false) String date) throws Exception {

        log.info("ExportController: GET /export/json — product={} platform={} module={} date={}",
                product, platform, module, date);

        // Load the filtered data sets (null params → no filter on that field)
        List<TestCaseView> testCases = qaDataService.getTestCases(product, platform, module, date);
        List<BugView>      bugs      = qaDataService.getBugs(product, platform, module, date, null, null);

        // Build the export envelope as a LinkedHashMap.
        // LinkedHashMap preserves insertion order, so keys appear in the output
        // JSON in the same order we add them here (meta-info first, data last).
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("exportedAt",     LocalDateTime.now().toString());
        payload.put("filters",        buildFiltersMap(product, platform, module, date));
        payload.put("testCasesCount", testCases.size());
        payload.put("bugsCount",      bugs.size());
        payload.put("testCases",      testCases);
        payload.put("bugs",           bugs);

        // Serialise to pretty-printed JSON bytes.
        // writerWithDefaultPrettyPrinter() adds newlines and 2-space indentation
        // so the downloaded file is readable in any text editor.
        byte[] jsonBytes = objectMapper
                .writerWithDefaultPrettyPrinter()
                .writeValueAsBytes(payload);

        // Build a descriptive filename, e.g. "qa-export-vantagefitness-web-20260510.json"
        String filename = buildFilename("qa-export", product, platform, module, date) + ".json";

        // ResponseEntity.ok()           → HTTP 200 status
        // .header(Content-Disposition)  → instructs browser to save as a file
        // .contentType(JSON)            → declares the MIME type
        // .body(jsonBytes)              → the actual bytes to send
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=\"" + filename + "\"")
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonBytes);
    }

    // =========================================================================
    // GET /export/csv  —  download filtered test cases as a CSV file
    // =========================================================================

    /**
     * Returns a UTF-8 CSV file of the filtered test cases, ready for Excel.
     *
     * Columns: TC ID, Title, Scenario, Priority, Status, Expected, Actual,
     *          Linked Bugs Count
     *
     * A UTF-8 BOM is prepended so Excel opens the file without garbled text.
     * Line endings are CRLF (\r\n) as required by RFC 4180.
     *
     * URL examples:
     *   /export/csv
     *   /export/csv?product=vantagefitness&module=login
     */
    @GetMapping("/csv")
    public ResponseEntity<byte[]> exportCsv(
            @RequestParam(required = false) String product,
            @RequestParam(required = false) String platform,
            @RequestParam(required = false) String module,
            @RequestParam(required = false) String date) {

        log.info("ExportController: GET /export/csv — product={} platform={} module={} date={}",
                product, platform, module, date);

        List<TestCaseView> testCases = qaDataService.getTestCases(product, platform, module, date);

        // ── Build the CSV content ──────────────────────────────────────────────
        // StringBuilder builds the string incrementally in memory without creating
        // many temporary String objects (more efficient than repeated concatenation).
        StringBuilder csv = new StringBuilder();

        // Header row — these become the column names in Excel row 1
        csv.append("TC ID,Title,Scenario,Priority,Status,Expected,Actual,Linked Bugs Count\r\n");
        // Note: RFC 4180 specifies \r\n (CRLF) line endings, not just \n.
        // CRLF ensures compatibility with Excel on Windows and other spreadsheet apps.

        for (TestCaseView tc : testCases) {
            csv.append(csvCell(tc.getTcId())).append(",");
            csv.append(csvCell(tc.getTitle())).append(",");
            csv.append(csvCell(tc.getScenario())).append(",");
            csv.append(csvCell(tc.getPriority())).append(",");
            csv.append(csvCell(tc.getStatus())).append(",");
            csv.append(csvCell(tc.getExpected())).append(",");
            csv.append(csvCell(tc.getActual())).append(",");
            // linkedBugs is initialised to Collections.emptyList() in TestCaseView
            // so it is never null — the null guard here is just extra safety.
            csv.append(tc.getLinkedBugs() != null ? tc.getLinkedBugs().size() : 0);
            csv.append("\r\n");
        }

        // ── Prepend the UTF-8 BOM ──────────────────────────────────────────────
        // BOM = 3 bytes: 0xEF 0xBB 0xBF.
        // We concatenate: [3 BOM bytes] + [CSV bytes] into one byte array.
        byte[] bom     = { (byte) 0xEF, (byte) 0xBB, (byte) 0xBF };
        byte[] content = csv.toString().getBytes(StandardCharsets.UTF_8);
        byte[] full    = new byte[bom.length + content.length];
        System.arraycopy(bom,     0, full, 0,          bom.length);
        System.arraycopy(content, 0, full, bom.length, content.length);

        String filename = buildFilename("test-cases", product, platform, module, date) + ".csv";

        // "text/csv" MIME type; charset UTF-8 included in the Content-Type header
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=\"" + filename + "\"")
                .contentType(new MediaType("text", "csv", StandardCharsets.UTF_8))
                .body(full);
    }

    // =========================================================================
    // Private helpers
    // =========================================================================

    /**
     * RFC 4180 CSV cell escaping.
     *
     * Rules applied in order:
     *   1. null → empty string
     *   2. every " inside the value becomes "" (double it)
     *   3. if the (now-escaped) value contains a comma, quote, \r, or \n,
     *      wrap the whole thing in outer double-quotes
     */
    private String csvCell(String value) {
        if (value == null) return "";
        String escaped = value.replace("\"", "\"\"");
        if (escaped.contains(",")
                || escaped.contains("\"")
                || escaped.contains("\n")
                || escaped.contains("\r")) {
            return "\"" + escaped + "\"";
        }
        return escaped;
    }

    /**
     * Builds a descriptive download filename from the active filter values.
     *
     * Example:
     *   buildFilename("qa-export", "vantagefitness", "web", null, "20260510")
     *   → "qa-export-vantagefitness-web-20260510"
     */
    private String buildFilename(String prefix, String product,
                                 String platform, String module, String date) {
        StringBuilder sb = new StringBuilder(prefix);
        if (product  != null && !product.isBlank())  sb.append("-").append(product);
        if (platform != null && !platform.isBlank()) sb.append("-").append(platform);
        if (module   != null && !module.isBlank())   sb.append("-").append(module);
        if (date     != null && !date.isBlank())     sb.append("-").append(date);
        return sb.toString();
    }

    /**
     * Builds a small ordered map of the active filter values for inclusion as
     * metadata in the JSON export payload. Only non-null values are included.
     */
    private Map<String, String> buildFiltersMap(String product, String platform,
                                                String module, String date) {
        Map<String, String> m = new LinkedHashMap<>();
        if (product  != null) m.put("product",  product);
        if (platform != null) m.put("platform", platform);
        if (module   != null) m.put("module",   module);
        if (date     != null) m.put("date",     date);
        return m;
    }
}
