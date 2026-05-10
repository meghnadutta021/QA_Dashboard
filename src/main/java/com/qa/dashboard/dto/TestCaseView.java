package com.qa.dashboard.dto;

// =============================================================================
// TestCaseView.java  —  DTO (Data Transfer Object)
// =============================================================================
// PURPOSE
// -------
// This class represents one test case exactly as the VIEW (FreeMarker template)
// needs to see it — all the raw TestCase data PLUS the report context it came
// from (product, platform, module, date) PLUS its linked bugs pre-fetched.
//
// WHY NOT JUST PASS TestCase TO THE TEMPLATE?
// --------------------------------------------
// TestCase only knows what's in one JSON object. It has no idea what product
// or platform it belongs to — those live in the report's "meta" block.
// A template showing a test-cases table needs all of this at once:
//
//   TC ID      | Title                | Product    | Platform | Status
//   TC-001     | Valid login          | VantageFit | web      | PASS
//
// Rather than forcing the template to navigate report.meta.product every row,
// QaDataService "flattens" everything into one TestCaseView per test case.
// The template stays simple; the complexity lives in the service layer.
// =============================================================================

import com.qa.dashboard.model.Bug;
// Bug is the raw model class. We embed a List<Bug> here rather than List<BugView>
// because templates only need basic bug info (id, title, severity) as children
// of a test case — using the raw Bug model is simpler and avoids circular design.

import lombok.Data;
import lombok.NoArgsConstructor;
// @Data → generates getters, setters, toString, equals, hashCode
// @NoArgsConstructor → generates public TestCaseView() {} that the service uses

import java.util.Collections;
import java.util.List;

@Data
@NoArgsConstructor
public class TestCaseView {

    // -------------------------------------------------------------------------
    // Core test-case fields — copied directly from TestCase (the raw model)
    // -------------------------------------------------------------------------

    // Unique identifier for this test case (e.g. "TC-LOGIN-001").
    private String tcId;

    // Broad feature area grouping, e.g. "Login", "Registration".
    private String scenario;

    // Short human-readable name describing what is being tested.
    private String title;

    // Required application state before steps are executed.
    private String precondition;

    // Ordered list of actions the tester performs.
    private List<String> steps;

    // What the app should do if it is working correctly.
    private String expected;

    // What the app actually did during the test run.
    private String actual;

    // Urgency level: "LOW", "MEDIUM", "HIGH", or "CRITICAL".
    private String priority;

    // Test outcome: "PASS", "FAIL", "SKIP", or "BLOCKED".
    private String status;

    // Free-text observations from the tester (may be empty).
    private String notes;

    // -------------------------------------------------------------------------
    // Context fields — NOT in the raw JSON; added by QaDataService from "meta"
    // -------------------------------------------------------------------------

    // The product this test belongs to, e.g. "VantageFit".
    private String product;

    // The platform under test, e.g. "web", "android", "ios".
    private String platform;

    // The feature module, e.g. "login", "dashboard".
    private String module;

    // Date this test run was executed, in "yyyyMMdd" format, e.g. "20260510".
    private String reportDate;

    // -------------------------------------------------------------------------
    // Enrichment — pre-fetched by QaDataService so templates need no lookups
    // -------------------------------------------------------------------------

    // All bugs in the same report whose tcId matches this test case's tcId.
    // Initialized to an empty list so templates can always safely iterate it
    // without checking for null first.
    private List<Bug> linkedBugs = Collections.emptyList();

    // -------------------------------------------------------------------------
    // Computed helpers — derived from the data above; not stored in JSON
    // -------------------------------------------------------------------------

    /**
     * Returns true if this test case has at least one linked bug.
     *
     * Used in templates to show a "BUG" badge conditionally:
     *   <#if tc.hasLinkedBugs()><span class="badge">BUG</span></#if>
     */
    public boolean hasLinkedBugs() {
        return linkedBugs != null && !linkedBugs.isEmpty();
    }

    /**
     * Returns true when status is exactly "FAIL".
     * Mirrors the same helper on TestCase for consistency.
     */
    public boolean isFailure() {
        return "FAIL".equals(this.status);
    }
}
