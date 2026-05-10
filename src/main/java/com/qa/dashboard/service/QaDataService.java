package com.qa.dashboard.service;

// =============================================================================
// QaDataService.java  —  Main Business Logic Service
// =============================================================================
// PURPOSE
// -------
// This is the "brain" of the application. It is the only service the controllers
// ever talk to. Everything else (file finding, JSON parsing) happens behind the
// scenes here.
//
// Think of it this way:
//   FileReaderService  — the filing clerk: finds the right folders and files
//   ReportParserService — the translator: turns JSON bytes into Java objects
//   QaDataService      — the analyst: combines, enriches, filters, and counts
//
// WHAT IT DOES
// ------------
// 1. Calls FileReaderService to get file paths matching the given filters.
// 2. Calls ReportParserService to turn those paths into QaReport objects.
// 3. Loops over every report, every test case, every bug and "enriches" each
//    raw model object into a DTO (TestCaseView or BugView) by adding context
//    from the report's "meta" block and linking related objects together.
// 4. Counts things (passed, failed, open bugs, etc.) for the dashboard summary.
// 5. Returns clean DTOs that controllers can put straight into the model.
//
// POSITION IN THE PIPELINE
// -------------------------
//   Files on disk
//        ↓ FileReaderService.filterFiles()
//   List<Path>
//        ↓ ReportParserService.parseFiles()
//   List<QaReport>
//        ↓ QaDataService (this file)
//   List<TestCaseView> / List<BugView> / DashboardSummary
//        ↓ Controller
//   FreeMarker template → HTML
// =============================================================================

import com.qa.dashboard.dto.BugView;
import com.qa.dashboard.dto.DashboardSummary;
import com.qa.dashboard.dto.TestCaseView;
// The three DTO classes that this service builds and returns.

import com.qa.dashboard.model.Bug;
import com.qa.dashboard.model.Meta;
import com.qa.dashboard.model.QaReport;
import com.qa.dashboard.model.TestCase;
// The raw model classes produced by Jackson / ReportParserService.

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.beans.factory.annotation.Autowired;
// @Autowired tells Spring to inject the named service bean automatically.

import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

@Service
public class QaDataService {

    private static final Logger log = LoggerFactory.getLogger(QaDataService.class);

    // Maps severity strings to sort-order integers so we can sort CRITICAL first.
    // Map.of() creates an immutable map — the values never change at runtime.
    // Any severity not in the map (null, unknown) falls back to 99 → sorts last.
    private static final Map<String, Integer> SEVERITY_ORDER = Map.of(
            "CRITICAL", 0,
            "HIGH",     1,
            "MEDIUM",   2,
            "LOW",      3
    );

    // -------------------------------------------------------------------------
    // Injected collaborator services
    // -------------------------------------------------------------------------
    // Spring creates FileReaderService and ReportParserService as @Service beans.
    // @Autowired injects the already-created instances here — we never write
    // "new FileReaderService()" ourselves.

    @Autowired
    private FileReaderService fileReaderService;

    @Autowired
    private ReportParserService reportParserService;

    // =========================================================================
    // PRIVATE HELPERS — shared building blocks used by every public method
    // =========================================================================

    /**
     * Loads and parses all report files that match the given filter combination.
     * Passing null for any parameter means "no filter on that field".
     *
     * This is the common first step in every public method:
     *   1. Ask FileReaderService for the relevant file paths.
     *   2. Ask ReportParserService to parse them into QaReport objects.
     *
     * @param product   folder-level filter, e.g. "vantagefitness" or null
     * @param platform  folder-level filter, e.g. "web" or null
     * @param module    folder-level filter, e.g. "login" or null
     * @param date      file-name date segment, e.g. "20260510" or null
     * @return          list of successfully parsed QaReport objects
     */
    private List<QaReport> loadReports(String product, String platform,
                                       String module,  String date) {
        return reportParserService.parseFiles(
                fileReaderService.filterFiles(product, platform, module, date)
        );
    }

    /**
     * Converts one raw TestCase model object into a TestCaseView DTO.
     *
     * Enrichment steps:
     *   a) Copy all fields from the TestCase (id, title, status, steps, …)
     *   b) Copy context from the report's "meta" block (product, platform, module, date)
     *   c) Pre-fetch all bugs from the same report whose tcId matches this test case
     *
     * @param tc      the raw TestCase from the parsed JSON
     * @param report  the QaReport it came from (needed for meta + bug lookup)
     * @return        a fully enriched TestCaseView ready for the template
     */
    private TestCaseView toTestCaseView(TestCase tc, QaReport report) {
        TestCaseView view = new TestCaseView();

        // --- Copy the raw TestCase fields ---
        view.setTcId(tc.getTcId());
        view.setScenario(tc.getScenario());
        view.setTitle(tc.getTitle());
        view.setPrecondition(tc.getPrecondition());
        view.setSteps(tc.getSteps());
        view.setExpected(tc.getExpected());
        view.setActual(tc.getActual());
        view.setPriority(tc.getPriority());
        view.setStatus(tc.getStatus());
        view.setNotes(tc.getNotes());

        // --- Add context from "meta" ---
        // meta can theoretically be null if the JSON file was badly formed;
        // we guard against that with a null check so we still return a partial view
        // rather than crashing the entire page.
        Meta meta = report.getMeta();
        if (meta != null) {
            view.setProduct(meta.getProduct());
            view.setPlatform(meta.getPlatform());
            view.setModule(meta.getModule());
            view.setReportDate(meta.getDate());
        }

        // --- Pre-fetch linked bugs ---
        // QaReport.getBugsForTestCase() already handles null safety and returns
        // an empty list when nothing is found — so we can assign directly.
        view.setLinkedBugs(report.getBugsForTestCase(tc.getTcId()));

        return view;
    }

    /**
     * Converts one raw Bug model object into a BugView DTO.
     *
     * Enrichment steps:
     *   a) Copy all fields from the Bug (id, title, severity, status, …)
     *   b) Copy context from "meta"
     *   c) Look up the test case in the same report whose tcId matches this bug
     *      (sets linkedTestCase to null — "orphan" — if not found)
     *
     * @param bug     the raw Bug from the parsed JSON
     * @param report  the QaReport it came from
     * @return        a fully enriched BugView ready for the template
     */
    private BugView toBugView(Bug bug, QaReport report) {
        BugView view = new BugView();

        // --- Copy the raw Bug fields ---
        view.setBugId(bug.getBugId());
        view.setTcId(bug.getTcId());
        view.setTitle(bug.getTitle());
        view.setDescription(bug.getDescription());
        view.setSteps(bug.getSteps());
        view.setExpected(bug.getExpected());
        view.setActual(bug.getActual());
        view.setSeverity(bug.getSeverity());
        view.setStatus(bug.getStatus());
        view.setNotes(bug.getNotes());

        // --- Add context from "meta" ---
        Meta meta = report.getMeta();
        if (meta != null) {
            view.setProduct(meta.getProduct());
            view.setPlatform(meta.getPlatform());
            view.setModule(meta.getModule());
            view.setReportDate(meta.getDate());
        }

        // --- Look up the linked TestCase ---
        // We search the same report's test case list for a TC whose tcId
        // matches this bug's tcId. Stream.findFirst() returns an Optional,
        // and .orElse(null) gives us null when no match exists — which is
        // exactly what BugView.isOrphan() checks for.
        TestCase linked = null;
        if (bug.getTcId() != null && report.getTestCases() != null) {
            linked = report.getTestCases().stream()
                    .filter(tc -> bug.getTcId().equals(tc.getTcId()))
                    .findFirst()
                    .orElse(null);
        }
        view.setLinkedTestCase(linked);

        return view;
    }

    // =========================================================================
    // PUBLIC METHODS — called by controllers
    // =========================================================================

    // -------------------------------------------------------------------------
    // Dashboard summary
    // -------------------------------------------------------------------------

    /**
     * Builds a complete DashboardSummary for the given filter combination.
     *
     * The summary includes:
     *   - Test case counts by status (passed, failed, skipped, blocked)
     *   - Bug counts (total, open, resolved)
     *   - Pass rate percentage
     *   - Lists of products / platforms / modules for the filter dropdowns
     *
     * @param product   optional folder filter
     * @param platform  optional folder filter
     * @param module    optional folder filter
     * @param date      optional date filter
     * @return          a populated DashboardSummary
     */
    public DashboardSummary getDashboardSummary(String product, String platform,
                                                String module,  String date) {

        // Reuse the public methods so we don't duplicate looping logic.
        List<TestCaseView> testCases = getTestCases(product, platform, module, date);
        List<BugView>      bugs      = getBugs(product, platform, module, date, null, null);

        DashboardSummary summary = new DashboardSummary();

        // --- Test case counts ---
        int total   = testCases.size();
        int passed  = countTcsByStatus(testCases, "PASS");
        int failed  = countTcsByStatus(testCases, "FAIL");
        int skipped = countTcsByStatus(testCases, "SKIP");
        int blocked = countTcsByStatus(testCases, "BLOCKED");

        summary.setTotalTestCases(total);
        summary.setPassed(passed);
        summary.setFailed(failed);
        summary.setSkipped(skipped);
        summary.setBlocked(blocked);

        // --- Bug counts ---
        summary.setTotalBugs(bugs.size());
        summary.setOpenBugs(countBugsByStatus(bugs, "OPEN"));
        // "resolved" means FIXED or CLOSED
        int resolved = (int) bugs.stream()
                .filter(b -> "FIXED".equals(b.getStatus()) || "CLOSED".equals(b.getStatus()))
                .count();
        summary.setResolvedBugs(resolved);

        // --- Pass rate ---
        // Formula: (passed / total) * 100, rounded to 1 decimal place.
        // Math.round(x * 10.0) / 10.0 is the standard Java trick for 1-decimal rounding:
        //   e.g. 66.666… → round(666.6) = 667 → 667 / 10.0 = 66.7
        // Guard: if total is 0, passRate stays 0.0 to avoid division-by-zero.
        double passRate = total > 0
                ? Math.round((double) passed / total * 1000.0) / 10.0
                : 0.0;
        summary.setPassRate(passRate);

        // --- Filter dropdown lists ---
        // These populate the <select> boxes in the UI.
        // Platforms/modules are contextual: only shown when a parent is selected.
        summary.setProducts(fileReaderService.getAvailableProducts());
        summary.setPlatforms(product != null
                ? fileReaderService.getAvailablePlatforms(product)
                : Collections.emptyList());
        summary.setModules(product != null && platform != null
                ? fileReaderService.getAvailableModules(product, platform)
                : Collections.emptyList());

        log.info("QaDataService.getDashboardSummary: total={} passed={} failed={} passRate={}%",
                total, passed, failed, passRate);

        return summary;
    }

    // -------------------------------------------------------------------------
    // Test cases
    // -------------------------------------------------------------------------

    /**
     * Returns a list of TestCaseViews matching the given filters.
     * All parameters are optional (null = no filter).
     *
     * Internally: loads all matching reports, then converts every test case in
     * every report into a TestCaseView via toTestCaseView().
     */
    public List<TestCaseView> getTestCases(String product, String platform,
                                           String module,  String date) {

        List<QaReport> reports = loadReports(product, platform, module, date);
        List<TestCaseView> views = new ArrayList<>();

        for (QaReport report : reports) {
            if (report.getTestCases() == null) continue;
            for (TestCase tc : report.getTestCases()) {
                views.add(toTestCaseView(tc, report));
            }
        }

        log.info("QaDataService.getTestCases: returned {} test case(s)", views.size());
        return views;
    }

    /**
     * Finds and returns a single TestCaseView by its tcId.
     *
     * Searches across all reports for the given product / platform / module
     * (no date filter — we want to find the TC regardless of run date).
     * Returns the first match found. Returns null if no match exists.
     *
     * The controller redirects to the list page when this returns null.
     *
     * @param tcId      the test case ID to look up, e.g. "TC-LOGIN-001"
     * @param product   optional scope filter
     * @param platform  optional scope filter
     * @param module    optional scope filter
     */
    public TestCaseView getTestCaseById(String tcId, String product,
                                        String platform, String module) {

        if (tcId == null || tcId.isBlank()) {
            log.warn("QaDataService.getTestCaseById: called with blank tcId");
            return null;
        }

        // Pass null for date so we search across all run dates.
        List<QaReport> reports = loadReports(product, platform, module, null);

        for (QaReport report : reports) {
            if (report.getTestCases() == null) continue;
            for (TestCase tc : report.getTestCases()) {
                if (tcId.equals(tc.getTcId())) {
                    log.debug("QaDataService.getTestCaseById: found {} in {}", tcId, report.getMeta() != null ? report.getMeta().getReportId() : "unknown report");
                    return toTestCaseView(tc, report);
                }
            }
        }

        log.warn("QaDataService.getTestCaseById: no test case found with tcId='{}'", tcId);
        return null;
    }

    // -------------------------------------------------------------------------
    // Bugs
    // -------------------------------------------------------------------------

    /**
     * Returns a list of BugViews matching the given filters, sorted CRITICAL-first.
     * All parameters are optional (null = no filter on that field).
     *
     * @param product   optional folder filter
     * @param platform  optional folder filter
     * @param module    optional folder filter
     * @param date      optional date filter
     * @param status    optional lifecycle filter, e.g. "OPEN" or null
     * @param severity  optional severity filter, e.g. "CRITICAL" or null
     */
    public List<BugView> getBugs(String product,   String platform,
                                 String module,    String date,
                                 String status,    String severity) {

        List<QaReport> reports = loadReports(product, platform, module, date);
        List<BugView> views = new ArrayList<>();

        for (QaReport report : reports) {
            if (report.getBugs() == null) continue;
            for (Bug bug : report.getBugs()) {
                BugView view = toBugView(bug, report);
                // Each "continue" skips this bug when a filter doesn't match.
                // null means "no filter" — pass everything through.
                if (status   != null && !status.equalsIgnoreCase(view.getStatus()))     continue;
                if (severity != null && !severity.equalsIgnoreCase(view.getSeverity())) continue;
                views.add(view);
            }
        }

        // Sort by severity priority: CRITICAL (0) → HIGH (1) → MEDIUM (2) → LOW (3) → other (99).
        // Comparator.comparingInt extracts an int key from each item and sorts ascending by it.
        // The explicit (BugView b) cast is needed so Java can infer the generic type correctly.
        views.sort(Comparator.comparingInt(
                (BugView b) -> SEVERITY_ORDER.getOrDefault(b.getSeverity(), 99)
        ));

        log.info("QaDataService.getBugs: returned {} bug(s)", views.size());
        return views;
    }

    /**
     * Finds and returns a single BugView by its bugId.
     *
     * Same approach as getTestCaseById: searches all reports for the given
     * scope filters (no date), returns the first match, null if not found.
     *
     * @param bugId     the bug ID to look up, e.g. "BUG-LOGIN-001"
     * @param product   optional scope filter
     * @param platform  optional scope filter
     * @param module    optional scope filter
     */
    public BugView getBugById(String bugId, String product,
                              String platform, String module) {

        if (bugId == null || bugId.isBlank()) {
            log.warn("QaDataService.getBugById: called with blank bugId");
            return null;
        }

        List<QaReport> reports = loadReports(product, platform, module, null);

        for (QaReport report : reports) {
            if (report.getBugs() == null) continue;
            for (Bug bug : report.getBugs()) {
                if (bugId.equals(bug.getBugId())) {
                    return toBugView(bug, report);
                }
            }
        }

        log.warn("QaDataService.getBugById: no bug found with bugId='{}'", bugId);
        return null;
    }

    // -------------------------------------------------------------------------
    // Navigation / dropdown helpers — thin wrappers around FileReaderService
    // -------------------------------------------------------------------------

    /**
     * Returns all product folder names under the base qa-data path.
     * Used to populate the "Product" dropdown on every page.
     */
    public List<String> getProducts() {
        return fileReaderService.getAvailableProducts();
    }

    /**
     * Returns platform folder names for the given product.
     * Used to populate the "Platform" dropdown after a product is selected.
     */
    public List<String> getPlatforms(String product) {
        return fileReaderService.getAvailablePlatforms(product);
    }

    /**
     * Returns module folder names for the given product and platform.
     * Used to populate the "Module" dropdown after both parent filters are selected.
     */
    public List<String> getModules(String product, String platform) {
        return fileReaderService.getAvailableModules(product, platform);
    }

    // =========================================================================
    // PRIVATE COUNTING HELPERS
    // =========================================================================

    /**
     * Counts TestCaseView items whose status equals the given value (case-sensitive).
     * Extracted into a helper to avoid repeating the same stream expression four times.
     *
     * WHY NOT USE METHOD OVERLOADING HERE?
     * Java generics use "type erasure": at runtime, List<TestCaseView> and List<BugView>
     * both become a plain List, so the compiler can't tell two methods of the same name
     * apart when only the generic type differs. We use different method names instead.
     */
    private int countTcsByStatus(List<TestCaseView> items, String targetStatus) {
        return (int) items.stream()
                .filter(tc -> targetStatus.equals(tc.getStatus()))
                .count();
    }

    /**
     * Counts BugView items whose status equals the given value (case-sensitive).
     * Must have a distinct name from countTcsByStatus — see note above.
     */
    private int countBugsByStatus(List<BugView> items, String targetStatus) {
        return (int) items.stream()
                .filter(b -> targetStatus.equals(b.getStatus()))
                .count();
    }
}
