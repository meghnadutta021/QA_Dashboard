package com.qa.dashboard.dto;

// =============================================================================
// BugView.java  —  DTO (Data Transfer Object)
// =============================================================================
// PURPOSE
// -------
// This class represents one bug as the VIEW needs to see it — all the raw Bug
// data PLUS report context (product, platform, module, date) PLUS the linked
// test case pre-fetched.
//
// Same reasoning as TestCaseView: the raw Bug model only knows what's in one
// JSON object. The templates need the full picture in one flat object, so the
// service "enriches" each Bug into a BugView before handing it to the controller.
// =============================================================================

import com.qa.dashboard.model.TestCase;
// TestCase is the raw model class. A BugView holds the TestCase that discovered
// this bug (if one exists). We store the raw TestCase because the bug detail
// template only needs basic TC info (id, title, status) and no further nesting.

import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
public class BugView {

    // -------------------------------------------------------------------------
    // Core bug fields — copied directly from Bug (the raw model)
    // -------------------------------------------------------------------------

    // Unique bug identifier, e.g. "BUG-LOGIN-001".
    private String bugId;

    // The test case ID that discovered this bug, e.g. "TC-LOGIN-002".
    // Used to look up the linked test case.
    private String tcId;

    // Short headline describing the bug.
    private String title;

    // Longer explanation of what the bug is and when it occurs.
    private String description;

    // Step-by-step reproduction instructions.
    private List<String> steps;

    // What the app should have done (correct behaviour).
    private String expected;

    // What the app actually did (the buggy behaviour).
    private String actual;

    // Impact level: "LOW", "MEDIUM", "HIGH", or "CRITICAL".
    private String severity;

    // Bug lifecycle state: "OPEN", "IN_PROGRESS", "FIXED", "CLOSED", etc.
    private String status;

    // Free-text observations from the tester.
    private String notes;

    // -------------------------------------------------------------------------
    // Context fields — NOT in the raw JSON; added by QaDataService from "meta"
    // -------------------------------------------------------------------------

    // Product the bug was found in, e.g. "VantageFit".
    private String product;

    // Platform where the bug was found, e.g. "web", "android".
    private String platform;

    // Feature module where the bug was found, e.g. "login".
    private String module;

    // Date of the test run in "yyyyMMdd" format.
    private String reportDate;

    // -------------------------------------------------------------------------
    // Enrichment — pre-fetched by QaDataService
    // -------------------------------------------------------------------------

    // The TestCase whose tcId matches this bug's tcId.
    // null if no matching test case exists in the same report (an orphan bug).
    // Templates check isOrphan() before trying to access this.
    private TestCase linkedTestCase;

    // -------------------------------------------------------------------------
    // Computed helpers
    // -------------------------------------------------------------------------

    /**
     * Returns true if no linked test case was found for this bug's tcId.
     *
     * An orphan bug means the bug references a test case that doesn't exist in
     * the same report — a data quality issue worth flagging on the dashboard.
     *
     * Template usage:
     *   <#if bug.isOrphan()><span class="badge warn">ORPHAN</span></#if>
     */
    public boolean isOrphan() {
        return linkedTestCase == null;
    }

    /**
     * Returns true when the bug status is "OPEN" — not yet fixed.
     * Convenience helper for templates and summary counting.
     */
    public boolean isOpen() {
        return "OPEN".equals(this.status);
    }
}
