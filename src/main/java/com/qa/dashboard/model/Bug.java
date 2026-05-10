package com.qa.dashboard.model;

// --- What is this file? ---
// Bug.java maps to a single item inside the "bugs" array in the QA report JSON.
//
// When a test case fails, a tester usually files a bug to track what went wrong.
// This class holds all the details about one such bug.
//
// Example of one item this class maps to:
//   {
//     "bug_id":      "BUG-LOGIN-001",
//     "tc_id":       "TC-LOGIN-002",
//     "title":       "App crashes on wrong password entry",
//     "description": "When user enters incorrect password, app shows 500 error ...",
//     "steps":       ["Go to /login", "Enter wrong password", "Click Submit"],
//     "expected":    "Validation error message shown",
//     "actual":      "500 Internal Server Error page shown",
//     "severity":    "CRITICAL",
//     "status":      "OPEN",
//     "notes":       "Reproducible 100% of the time"
//   }

import com.fasterxml.jackson.annotation.JsonProperty;
// Maps snake_case JSON keys (e.g. "bug_id") → camelCase Java fields (e.g. bugId).

import lombok.Data;
import lombok.NoArgsConstructor;
// @Data auto-generates getters, setters, toString, equals, hashCode.
// @NoArgsConstructor generates the empty constructor Jackson requires.

import java.util.List;
// Used for the "steps" field, which is a JSON array of strings.

@Data
@NoArgsConstructor
public class Bug {

    // Unique identifier for this bug (e.g. "BUG-LOGIN-001").
    @JsonProperty("bug_id")
    private String bugId;

    // The test case ID that discovered this bug (e.g. "TC-LOGIN-002").
    // This links a bug back to the test case that uncovered it.
    // Used by QaReport.getBugsForTestCase() to find all bugs for a given test.
    @JsonProperty("tc_id")
    private String tcId;

    // A short headline describing the bug (e.g. "App crashes on wrong password entry").
    @JsonProperty("title")
    private String title;

    // A longer explanation of what the bug is and when it occurs.
    @JsonProperty("description")
    private String description;

    // Step-by-step instructions to reproduce the bug.
    // JSON array of strings → Java List<String>.
    @JsonProperty("steps")
    private List<String> steps;

    // What the app should have done (correct behaviour).
    @JsonProperty("expected")
    private String expected;

    // What the app actually did (the buggy behaviour).
    @JsonProperty("actual")
    private String actual;

    // How bad the bug is: "LOW", "MEDIUM", "HIGH", or "CRITICAL".
    // Severity is about impact; priority (on TestCase) is about urgency to fix.
    @JsonProperty("severity")
    private String severity;

    // Current lifecycle state of the bug: "OPEN", "IN_PROGRESS", "FIXED", "CLOSED", etc.
    @JsonProperty("status")
    private String status;

    // Any extra observations or context from the tester.
    @JsonProperty("notes")
    private String notes;
}
