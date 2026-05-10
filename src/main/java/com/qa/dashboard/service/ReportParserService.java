package com.qa.dashboard.service;

// =============================================================================
// ReportParserService.java
// =============================================================================
// PURPOSE
// -------
// This service owns one job: turning a file on disk into a QaReport Java object.
//
// It does NOT find which files to read — that is FileReaderService's job.
// It does NOT decide what to display — that is the Controller's job.
// It does ONE thing: take a Path, read the bytes, ask Jackson to parse the JSON,
// and return the result safely.
//
// POSITION IN THE PIPELINE
// -------------------------
//   FileReaderService → gives us a List<Path>
//          ↓
//   ReportParserService  ← THIS FILE — turns each Path into a QaReport
//          ↓
//   Controller → passes QaReport(s) to FreeMarker template
// =============================================================================

import com.fasterxml.jackson.databind.ObjectMapper;
// ObjectMapper is Jackson's main class. It knows how to:
//   - Read JSON text/bytes → create Java objects  (deserialization)
//   - Take Java objects    → produce JSON text     (serialization)
// We use it here only for deserialization (JSON → QaReport).

import com.qa.dashboard.model.Meta;
import com.qa.dashboard.model.QaReport;
// The model classes created earlier. ObjectMapper will fill these
// with data from the JSON file.

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
// SLF4J logger — writes diagnostic messages to the console.
// (More detail in the explanation section at the bottom of this file.)

import org.springframework.beans.factory.annotation.Autowired;
// @Autowired tells Spring: "find the existing ObjectMapper bean in the application
// context and inject it here." We don't write  new ObjectMapper()  ourselves;
// Spring Boot already creates one with sensible defaults.

import org.springframework.stereotype.Service;
// @Service marks this class as a Spring-managed service bean.
// Spring creates exactly one instance and reuses it everywhere.

import java.io.IOException;
// Thrown when file I/O fails (file missing, permission denied, disk error, etc.)

import java.nio.file.Files;
// Files.readAllBytes(path) — reads every byte of a file into memory at once.
// Fine for JSON report files (typically small); would need streaming for huge files.

import java.nio.file.Path;
// A rich representation of a file-system location.

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
// Optional<T> — a container that either holds a value or holds nothing.
// It is the safe alternative to returning null.
// (Full explanation in the section at the bottom of this file.)

@Service
public class ReportParserService {

    // -------------------------------------------------------------------------
    // Logger
    // -------------------------------------------------------------------------
    private static final Logger log = LoggerFactory.getLogger(ReportParserService.class);

    // -------------------------------------------------------------------------
    // Jackson ObjectMapper — injected by Spring
    // -------------------------------------------------------------------------
    // Spring Boot auto-configures an ObjectMapper bean. @Autowired asks Spring
    // to hand us that pre-built instance rather than us creating our own.
    //
    // Why not just write  private ObjectMapper mapper = new ObjectMapper() ?
    //   1. Spring's auto-configured instance is tuned for Spring Boot
    //      (e.g. it understands Java 8 date types, handles unknown properties, etc.)
    //   2. Sharing one instance is more efficient — ObjectMapper is thread-safe
    //      and expensive to construct; reusing avoids recreating it on every call.
    @Autowired
    private ObjectMapper objectMapper;

    // =========================================================================
    // PUBLIC METHODS
    // =========================================================================

    /**
     * Parses a single JSON file into a QaReport object.
     *
     * Returns Optional.of(qaReport)  if parsing succeeded.
     * Returns Optional.empty()       if the file is missing, unreadable, or
     *                                contains invalid JSON.
     *
     * The caller checks: if (result.isPresent()) { ... use result.get() ... }
     * This forces the caller to think about the "nothing here" case — much safer
     * than returning null, which callers often forget to check.
     *
     * @param filePath  the path to a JSON report file (from FileReaderService)
     * @return          an Optional wrapping the parsed QaReport, or empty on failure
     */
    public Optional<QaReport> parseFile(Path filePath) {

        // Guard: reject null input before trying anything else.
        if (filePath == null) {
            log.warn("ReportParserService.parseFile: received a null filePath — skipping");
            return Optional.empty();
        }

        log.debug("ReportParserService: parsing file → {}", filePath);

        try {
            // Step 1 — Read the raw file bytes into memory.
            // Files.readAllBytes() loads the entire file as a byte array.
            // It throws IOException if the file doesn't exist or can't be read.
            byte[] fileBytes = Files.readAllBytes(filePath);

            // Step 2 — Ask Jackson to convert the bytes into a QaReport object.
            // objectMapper.readValue(bytes, TargetClass.class) does the whole job:
            //   a) Parses the JSON text from the bytes.
            //   b) Creates a new QaReport (using its @NoArgsConstructor).
            //   c) Fills each field by matching JSON keys to @JsonProperty annotations.
            //   d) Recursively does the same for nested objects (Meta, TestCase, Bug).
            // Throws JsonProcessingException if the JSON is malformed or a key can't be mapped.
            QaReport report = objectMapper.readValue(fileBytes, QaReport.class);

            // Step 3 — Fallback: fill in reportId from the filename if the JSON didn't have it.
            // Some older report files may be missing "report_id" in the "meta" block.
            // Rather than showing a blank ID on the dashboard, we derive it from the filename.
            ensureReportId(report, filePath);

            // Step 4 — Wrap the successful result in Optional.of() and return it.
            // Optional.of(x) means: "I have a value; here it is."
            return Optional.of(report);

        } catch (IOException e) {
            // IOException covers: file not found, permission denied, disk read error.
            // We log the problem clearly and return empty — the app keeps running.
            log.error("ReportParserService: could not read file '{}': {}", filePath, e.getMessage());
            return Optional.empty();

        } catch (Exception e) {
            // A broader catch for anything unexpected (e.g. malformed JSON, mapping errors).
            // We log the full stack trace here because unexpected errors need investigation.
            log.error("ReportParserService: unexpected error parsing '{}': {}", filePath, e.getMessage(), e);
            return Optional.empty();
        }
    }

    /**
     * Parses a list of file paths into QaReport objects, silently skipping any
     * file that fails to parse.
     *
     * This is the main entry point when the Controller asks:
     *   "Give me all reports for product=X, platform=Y."
     *
     * FileReaderService finds the paths → this method turns them into QaReports.
     * Files that are corrupt or unreadable are logged and quietly dropped,
     * so one bad file never prevents the rest from loading.
     *
     * @param filePaths  a list of Paths (typically from FileReaderService.filterFiles())
     * @return           a list of successfully parsed QaReport objects
     */
    public List<QaReport> parseFiles(List<Path> filePaths) {

        if (filePaths == null || filePaths.isEmpty()) {
            log.info("ReportParserService.parseFiles: received empty file list — nothing to parse");
            return Collections.emptyList();
        }

        log.info("ReportParserService: parsing {} file(s)…", filePaths.size());

        List<QaReport> results = new ArrayList<>();

        for (Path path : filePaths) {
            // parseFile() returns an Optional. We call .ifPresent() to add the report
            // to our list only when parsing actually succeeded.
            // If it returned Optional.empty() (failure), ifPresent() does nothing —
            // no null checks, no if-statements needed on our part.
            parseFile(path).ifPresent(results::add);
            // results::add is a method reference — shorthand for:
            //   report -> results.add(report)
        }

        int failed = filePaths.size() - results.size();
        if (failed > 0) {
            log.warn("ReportParserService: {} file(s) failed to parse and were skipped", failed);
        }

        log.info("ReportParserService: successfully parsed {}/{} file(s)", results.size(), filePaths.size());
        return results;
    }

    /**
     * Extracts the "report ID" portion from a file name.
     *
     * File name format:  login##abc123##20260510.json
     * Returned value:    login##abc123##20260510   (no extension)
     *
     * The logic:
     *   1. Strip the ".json" extension.
     *   2. Confirm the remainder matches the expected ##-pattern (3 parts).
     *   3. Return the whole stripped name — it is already the report ID.
     *
     * Returns an empty String if the filename doesn't match the expected pattern,
     * so callers always get a String (never null).
     *
     * @param filename  just the file name, e.g. "login##abc123##20260510.json"
     * @return          the report ID string, e.g. "login##abc123##20260510", or ""
     */
    public String extractReportIdFromFilename(String filename) {

        if (filename == null || filename.isBlank()) {
            return "";
        }

        // Remove the ".json" suffix (case-insensitive, just to be safe).
        String withoutExtension = filename.replaceAll("(?i)\\.json$", "");
        // (?i)    → case-insensitive match
        // \\.json → literal ".json"  (\\ escapes the dot so it isn't a "any char" wildcard)
        // $       → anchored to the end of the string

        // Validate: we expect exactly 3 parts separated by "##"
        // e.g. ["login", "abc123", "20260510"]
        String[] parts = withoutExtension.split("##");
        if (parts.length != 3) {
            log.warn("ReportParserService.extractReportIdFromFilename: " +
                     "unexpected filename format '{}' — expected name##id##date", filename);
            return "";
        }

        // The entire stripped filename IS the report ID.
        return withoutExtension;
    }

    // =========================================================================
    // PRIVATE HELPERS
    // =========================================================================

    /**
     * If the parsed report is missing a reportId in its meta block, derive one
     * from the filename and set it. This keeps the dashboard from showing blank IDs
     * for reports where the JSON author omitted "report_id".
     *
     * @param report    the QaReport object just parsed by Jackson
     * @param filePath  the source file path (used to read the filename)
     */
    private void ensureReportId(QaReport report, Path filePath) {

        // Nothing to do if meta is missing entirely — we can't safely set anything.
        Meta meta = report.getMeta();
        if (meta == null) {
            log.warn("ReportParserService: report from '{}' has no meta block", filePath.getFileName());
            return;
        }

        // If reportId is already populated, trust the JSON — nothing to fix.
        if (meta.getReportId() != null && !meta.getReportId().isBlank()) {
            return;
        }

        // reportId is blank — derive it from the filename.
        String derivedId = extractReportIdFromFilename(filePath.getFileName().toString());
        if (!derivedId.isBlank()) {
            meta.setReportId(derivedId);
            log.debug("ReportParserService: set reportId='{}' from filename (was missing in JSON)", derivedId);
        }
    }
}
