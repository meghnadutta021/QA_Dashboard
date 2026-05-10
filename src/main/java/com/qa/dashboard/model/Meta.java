package com.qa.dashboard.model;

// --- What is this file? ---
// Meta.java is a "model class" — it is a Java blueprint that represents the "meta" block
// inside each QA report JSON file. Every field here corresponds to one key in that JSON block.
//
// Example of the JSON block this class maps to:
//   "meta": {
//     "report_id": "login##abc123##20260510",
//     "product":   "VantageFit",
//     "platform":  "web",
//     ...
//   }
//
// When Jackson (the library that reads JSON) sees that block, it creates one Meta object
// and fills each field automatically — no manual parsing needed.

import com.fasterxml.jackson.annotation.JsonProperty;
// @JsonProperty lets us tell Jackson:
//   "The JSON key is snake_case (e.g. report_id) but the Java field is camelCase (reportId)."
// Without this, Jackson would look for a JSON key called "reportId" and find nothing.

import lombok.Data;
// @Data is a Lombok shortcut. It auto-generates:
//   - getters (getReportId(), getProduct(), ...)
//   - setters (setReportId(), setProduct(), ...)
//   - toString(), equals(), hashCode()
// Writing these by hand for every field would be tedious; Lombok does it at compile time.

import lombok.NoArgsConstructor;
// @NoArgsConstructor tells Lombok to generate a constructor with NO arguments:
//   public Meta() {}
// Jackson needs this empty constructor to create a Meta object before filling the fields.

@Data
@NoArgsConstructor
public class Meta {

    // Unique identifier for this report.
    // JSON key: "report_id"  →  format: module##runId##date  (e.g. "login##abc123##20260510")
    @JsonProperty("report_id")
    private String reportId;

    // The product being tested (e.g. "VantageFit").
    // JSON key: "product"  — same name in JSON so no @JsonProperty needed here,
    // but we add it anyway for consistency and clarity.
    @JsonProperty("product")
    private String product;

    // The platform under test: "web", "android", "ios", etc.
    @JsonProperty("platform")
    private String platform;

    // The feature area / module being tested (e.g. "login", "dashboard").
    @JsonProperty("module")
    private String module;

    // The date the test run was executed, stored as a String in "yyyyMMdd" format (e.g. "20260510").
    // We keep it as String because we don't need to do date arithmetic here;
    // a plain String is simpler to read and display.
    @JsonProperty("date")
    private String date;

    // The name of the QA tester who ran the tests.
    @JsonProperty("tester")
    private String tester;

    // The environment where tests were run: "staging", "production", "dev", etc.
    @JsonProperty("environment")
    private String environment;
}
