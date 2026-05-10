package com.qa.dashboard.dto;

// =============================================================================
// DashboardSummary.java  —  DTO (Data Transfer Object)
// =============================================================================
// PURPOSE
// -------
// This class carries all the numbers and dropdown options needed to render
// the main dashboard page in one neat bundle.
//
// QaDataService builds one of these objects by counting test cases and bugs
// across all the loaded reports, then hands it to the Controller.
// The Controller puts it in the model and FreeMarker reads the fields.
//
// WHY A SEPARATE CLASS AND NOT JUST A MAP?
// ----------------------------------------
// A Java Map<String, Object> would also work, but:
//   - You'd have to remember magic key strings like "totalTestCases"
//   - The template would crash at runtime if you mistyped a key
//   - There's no IDE autocomplete for keys
// A typed class gives you compile-time safety and autocomplete everywhere.
// (More detail in the DTO vs Model explanation at the end of this session.)
// =============================================================================

import lombok.Data;
import lombok.NoArgsConstructor;
// @Data generates: getters, setters, toString(), equals(), hashCode()
// @NoArgsConstructor generates: public DashboardSummary() {}
// Together they give the service code full read/write access via setters,
// and give FreeMarker full read access via getters.

import java.util.List;

@Data
@NoArgsConstructor
public class DashboardSummary {

    // -------------------------------------------------------------------------
    // TEST CASE COUNTS
    // -------------------------------------------------------------------------

    // Total number of test cases across all loaded reports.
    private int totalTestCases;

    // Number of test cases whose status == "PASS".
    private int passed;

    // Number of test cases whose status == "FAIL".
    private int failed;

    // Number of test cases whose status == "SKIP".
    // A skipped test was intentionally not run (e.g. feature not yet built).
    private int skipped;

    // Number of test cases whose status == "BLOCKED".
    // A blocked test couldn't run due to an external dependency or environment issue.
    private int blocked;

    // -------------------------------------------------------------------------
    // BUG COUNTS
    // -------------------------------------------------------------------------

    // Total number of bugs across all loaded reports.
    private int totalBugs;

    // Bugs whose status == "OPEN" — not yet fixed.
    private int openBugs;

    // Bugs whose status == "FIXED" or "CLOSED" — work is done.
    private int resolvedBugs;

    // -------------------------------------------------------------------------
    // PASS RATE
    // -------------------------------------------------------------------------

    // Percentage of test cases that passed, rounded to one decimal place.
    // Formula: (passed / totalTestCases) * 100
    // Example: 8 passed out of 10 → passRate = 80.0
    // Stored as double so the template can show "80.0%" with a decimal.
    // Value is 0.0 when there are no test cases (avoids division by zero).
    private double passRate;

    // -------------------------------------------------------------------------
    // FILTER DROPDOWN OPTIONS
    // -------------------------------------------------------------------------
    // These three lists power the dropdowns on the dashboard filter bar.
    // They are populated from the folder structure, not from individual JSON files.

    // All product folder names found under qa-data/ (e.g. ["vantagefitness", "vantagerewards"]).
    private List<String> products;

    // Platform folder names under the currently selected product
    // (e.g. ["android", "ios", "web"]).
    // Empty if no product is selected yet.
    private List<String> platforms;

    // Module folder names under the currently selected product + platform
    // (e.g. ["dashboard", "login", "profile"]).
    // Empty if product or platform is not yet selected.
    private List<String> modules;
}
