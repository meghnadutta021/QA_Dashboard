package com.qa.dashboard.model;

// --- What is this file? ---
// QaReport.java is the "root" model class — it represents an entire QA report JSON file.
//
// The full JSON file has three top-level keys:
//   {
//     "meta":       { ... },         ← one Meta object
//     "test_cases": [ {...}, {...} ], ← a list of TestCase objects
//     "bugs":       [ {...} ]         ← a list of Bug objects
//   }
//
// When Jackson reads a JSON file, it first creates a QaReport object,
// then fills meta, testCases, and bugs by delegating to their own model classes.
// The result is one neat Java object that represents the whole file.

import com.fasterxml.jackson.annotation.JsonProperty;
// Maps "test_cases" (JSON) → testCases (Java field).
// "meta" and "bugs" match exactly, but we add @JsonProperty anyway for consistency.

import lombok.Data;
import lombok.NoArgsConstructor;
// @Data generates getters, setters, toString, equals, hashCode.
// @NoArgsConstructor generates the empty constructor Jackson requires.

import java.util.List;
// List is used for the testCases and bugs collections.

import java.util.stream.Collectors;
// Collectors is a helper used with Java Streams to gather filtered results into a List.
// Think of Streams as a pipeline: source → filter → collect.

@Data
@NoArgsConstructor
public class QaReport {

    // The report metadata (id, product, date, tester, etc.).
    // Jackson will create a Meta object from the "meta" block in JSON and put it here.
    @JsonProperty("meta")
    private Meta meta;

    // All test cases in this report.
    // Jackson will parse the "test_cases" JSON array and create a List of TestCase objects.
    @JsonProperty("test_cases")
    private List<TestCase> testCases;

    // All bugs filed in this report.
    // Jackson will parse the "bugs" JSON array and create a List of Bug objects.
    @JsonProperty("bugs")
    private List<Bug> bugs;

    // -------------------------------------------------------------------------
    // Helper methods
    // These are "computed" values — not stored in JSON, but derived from the data.
    // They keep filtering logic in one place so controllers and templates stay clean.
    // -------------------------------------------------------------------------

    /**
     * Returns all test cases whose status is exactly "FAIL".
     *
     * How it works (step by step for beginners):
     *   1. testCases.stream()   — opens a pipeline over the list
     *   2. .filter(tc -> tc.isFailure())  — keeps only items where isFailure() is true
     *   3. .collect(Collectors.toList())  — gathers the survivors into a new List
     *
     * Returns an empty list (not null) if testCases is empty or none have failed,
     * so callers never have to do a null-check.
     */
    public List<TestCase> getFailedTestCases() {
        if (testCases == null) {
            return List.of(); // return an immutable empty list; nothing to filter
        }
        return testCases.stream()
                .filter(TestCase::isFailure)   // same as: tc -> tc.isFailure()
                .collect(Collectors.toList());
    }

    /**
     * Returns all bugs that are linked to the given test case ID.
     *
     * Example: getBugsForTestCase("TC-LOGIN-002")
     *   → returns every Bug whose tcId equals "TC-LOGIN-002"
     *
     * @param tcId  The test case ID to search for (e.g. "TC-LOGIN-002")
     * @return      A list of matching Bug objects, or an empty list if none found
     */
    public List<Bug> getBugsForTestCase(String tcId) {
        if (bugs == null || tcId == null) {
            return List.of();
        }
        return bugs.stream()
                .filter(bug -> tcId.equals(bug.getTcId()))
                // tcId.equals(bug.getTcId()) rather than bug.getTcId().equals(tcId)
                // avoids NullPointerException if a bug's tcId is missing in the JSON.
                .collect(Collectors.toList());
    }

    /**
     * Returns true if ANY bug in this report references a tcId that does NOT
     * exist in the testCases list.
     *
     * An "orphan bug" means someone filed a bug but the corresponding test case
     * is missing — a data quality problem worth flagging on the dashboard.
     *
     * How it works:
     *   1. Collect all known test case IDs into a Set (fast lookup, no duplicates).
     *   2. Stream over bugs and check: does any bug's tcId fall outside that Set?
     *   3. anyMatch() stops as soon as it finds the first match → efficient.
     */
    public boolean hasOrphanBugs() {
        if (bugs == null || bugs.isEmpty() || testCases == null) {
            return false; // nothing to check
        }

        // Build a Set of every tc_id that exists in the test_cases list.
        // A Set is like a List but has no duplicates and checks membership in O(1) time.
        java.util.Set<String> knownTcIds = testCases.stream()
                .map(TestCase::getTcId)   // extract just the ID string from each TestCase
                .collect(Collectors.toSet());

        // Return true if at least one bug's tcId is NOT in the known set.
        return bugs.stream()
                .anyMatch(bug -> !knownTcIds.contains(bug.getTcId()));
    }
}
