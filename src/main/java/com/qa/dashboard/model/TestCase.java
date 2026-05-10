package com.qa.dashboard.model;

// --- What is this file? ---
// TestCase.java maps to a single item inside the "test_cases" array in the QA report JSON.
//
// Each test case describes ONE thing that was tested: what the steps were, what was expected,
// what actually happened, and whether it passed or failed.
//
// Example of one item this class maps to:
//   {
//     "tc_id":        "TC-LOGIN-001",
//     "scenario":     "Login",
//     "title":        "Valid login with correct credentials",
//     "precondition": "User account exists in the system",
//     "steps":        ["Navigate to /login", "Enter valid email", ...],
//     "expected":     "User is redirected to dashboard",
//     "actual":       "User is redirected to dashboard",
//     "priority":     "HIGH",
//     "status":       "PASS",
//     "notes":        ""
//   }

import com.fasterxml.jackson.annotation.JsonProperty;
// Maps snake_case JSON keys → camelCase Java field names.

import lombok.Data;
import lombok.NoArgsConstructor;
// @Data generates getters, setters, toString, equals, hashCode.
// @NoArgsConstructor generates an empty constructor Jackson needs.

import java.util.List;
// List<String> is Java's way of holding an ordered collection of Strings.
// The "steps" field is an array of strings in JSON; List<String> is its Java equivalent.

@Data
@NoArgsConstructor
public class TestCase {

    // Unique identifier for this test case (e.g. "TC-LOGIN-001").
    @JsonProperty("tc_id")
    private String tcId;

    // The broader feature area this test belongs to (e.g. "Login", "Registration").
    // Groups related test cases together on the dashboard.
    @JsonProperty("scenario")
    private String scenario;

    // A short human-readable name describing what this test checks.
    @JsonProperty("title")
    private String title;

    // The state the app must be in BEFORE the test steps are executed
    // (e.g. "User account exists in the system").
    @JsonProperty("precondition")
    private String precondition;

    // An ordered list of actions the tester performs to run this test
    // (e.g. ["Navigate to /login", "Enter valid email", "Click Submit"]).
    // JSON array of strings → Java List<String>.
    @JsonProperty("steps")
    private List<String> steps;

    // What the app SHOULD do if it behaves correctly.
    @JsonProperty("expected")
    private String expected;

    // What the app ACTUALLY did during the test run.
    // Comparing expected vs actual tells us if the test passed or failed.
    @JsonProperty("actual")
    private String actual;

    // How important this test case is: "LOW", "MEDIUM", "HIGH", or "CRITICAL".
    // Higher priority failures need to be fixed sooner.
    @JsonProperty("priority")
    private String priority;

    // The outcome of running this test: "PASS", "FAIL", "SKIP", etc.
    @JsonProperty("status")
    private String status;

    // Any extra observations the tester wants to record (can be empty "").
    @JsonProperty("notes")
    private String notes;

    // --- Helper method ---
    // isFailure() is a convenience method used by templates and the QaReport class.
    // Instead of writing  testCase.getStatus().equals("FAIL")  everywhere,
    // you can just write  testCase.isFailure()  — cleaner and less error-prone.
    //
    // Returns: true  → this test case has status "FAIL"
    //          false → anything else (PASS, SKIP, BLOCKED, etc.)
    public boolean isFailure() {
        return "FAIL".equals(this.status);
        // Note: we write "FAIL".equals(status) rather than status.equals("FAIL")
        // to avoid a NullPointerException if status is somehow null.
    }
}
