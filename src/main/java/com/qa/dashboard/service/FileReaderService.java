package com.qa.dashboard.service;

// =============================================================================
// FileReaderService.java
// =============================================================================
// PURPOSE
// -------
// This service is responsible for one thing: finding QA report JSON files on
// disk and returning their locations as Java Path objects.
//
// It knows about the folder structure:
//   {base}/{product}/{platform}/{module}/name##uniqueId##YYYYMMDD.json
//
// and lets callers ask questions like:
//   - "Give me every JSON file you can find."
//   - "Give me only files for product=vantagefitness, platform=web."
//   - "What products exist under the base folder?"
//
// This class does NOT read the contents of the files — that is a different
// service's job. Here we only deal with paths and names.
// =============================================================================

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
// Logger / LoggerFactory come from SLF4J, the standard Java logging API.
// Spring Boot automatically wires SLF4J to its own logging back-end (Logback).
// We use it to write messages like "WARNING: folder not found" to the console
// instead of throwing an exception that crashes the app.

import org.springframework.beans.factory.annotation.Value;
// @Value("${some.property}") reads a value from application.properties at startup
// and injects it directly into a field. We use it to read qa.data.path.

import org.springframework.stereotype.Service;
// @Service marks this class as a Spring "bean" — a managed object that Spring
// creates once, keeps alive for the life of the app, and injects wherever needed.
// (More on this at the bottom of the file.)

import java.io.IOException;
// IOException is thrown when a file operation fails — e.g. permission denied,
// disk not mounted, path doesn't exist. We catch it and log gracefully.

import java.nio.file.Files;
// Files is the Swiss-army knife of Java NIO file operations.
// Files.walk()  → recursively lists every path under a directory
// Files.list()  → lists the direct children of a directory (one level only)
// Files.isDirectory() → checks whether a path is a folder

import java.nio.file.Path;
// Path represents a file-system location (like a string "/qa-data/web/login/…")
// but as a rich object with helper methods like .getFileName(), .getParent(), etc.
// It replaces the older java.io.File class.

import java.nio.file.Paths;
// Paths.get("some/string") converts a plain String into a Path object.

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
// Standard Java collections.
// ArrayList  — a resizable list we build up and return.
// Collections.emptyList() — a convenient immutable empty list to return on error.

import java.util.regex.Pattern;
// Pattern compiles a regular expression once so it can be reused efficiently.
// We use it to validate the file-name format: name##id##YYYYMMDD.json

import java.util.stream.Collectors;
import java.util.stream.Stream;
// Stream / Collectors are used to filter and transform lists with a pipeline style:
//   source.stream() → .filter() → .map() → .collect(Collectors.toList())

@Service
public class FileReaderService {

    // -------------------------------------------------------------------------
    // Logger
    // -------------------------------------------------------------------------
    // getLogger(FileReaderService.class) creates a logger whose messages are
    // prefixed with this class's name, making log output easy to trace.
    private static final Logger log = LoggerFactory.getLogger(FileReaderService.class);

    // -------------------------------------------------------------------------
    // File-name pattern
    // -------------------------------------------------------------------------
    // A valid report file looks like:  login##abc123##20260510.json
    // The regex below breaks that down:
    //
    //   [^#]+    → one or more characters that are NOT '#'  (the module name)
    //   ##       → literal double-hash separator
    //   [^#]+    → the unique run ID  (letters, numbers, anything except '#')
    //   ##       → another separator
    //   \d{8}    → exactly 8 digits  (the date, e.g. 20260510)
    //   \.json   → literal ".json" extension  (\. escapes the dot in regex)
    //   $        → end of string
    //
    // Pattern.compile() builds the regex once; we reuse it for every file name.
    private static final Pattern REPORT_FILE_PATTERN =
            Pattern.compile("^[^#]+##[^#]+##\\d{8}\\.json$");

    // -------------------------------------------------------------------------
    // Injected configuration
    // -------------------------------------------------------------------------
    // Spring reads "qa.data.path" from application.properties and puts the value
    // into this field before any method in this class runs.
    // Example value: "./qa-data"
    @Value("${qa.data.path}")
    private String qaDataPath;

    // =========================================================================
    // PRIVATE UTILITY
    // =========================================================================

    /**
     * Converts qaDataPath (String) to a resolved, absolute Path object.
     *
     * Why do we need this?
     *   Paths.get("./qa-data") gives us a relative path.
     *   .toAbsolutePath() turns it into e.g. /Users/apple/Documents/.../qa-data
     *   .normalize()       removes redundant parts like "/foo/../bar" → "/foo/bar"
     *
     * Doing this once in a helper keeps the other methods clean.
     */
    private Path basePath() {
        return Paths.get(qaDataPath).toAbsolutePath().normalize();
    }

    /**
     * Returns true if the given Path points to a valid, readable directory.
     * Logs a warning and returns false if it does not exist or is not a folder.
     *
     * @param dir    the path to check
     * @param label  a human-readable name used in the warning message
     */
    private boolean directoryExists(Path dir, String label) {
        if (!Files.isDirectory(dir)) {
            log.warn("FileReaderService: {} does not exist or is not a directory: {}", label, dir);
            return false;
        }
        return true;
    }

    /**
     * Returns true if fileName matches the expected report naming pattern:
     *   module##uniqueId##YYYYMMDD.json
     */
    private boolean matchesReportPattern(String fileName) {
        return REPORT_FILE_PATTERN.matcher(fileName).matches();
    }

    // =========================================================================
    // PUBLIC METHODS
    // =========================================================================

    /**
     * Returns ALL valid JSON report files found anywhere under the base path.
     *
     * Walk order: base → product folders → platform folders → module folders → files
     *
     * Files.walk() visits every path in the entire tree recursively.
     * We then keep only:
     *   - paths that are regular files (not folders)
     *   - whose name matches the ##-pattern (ignores random .json files)
     *
     * @return list of matching Path objects; empty list if base folder missing
     */
    public List<Path> getAllJsonFiles() {
        Path base = basePath();
        if (!directoryExists(base, "base qa.data.path")) {
            return Collections.emptyList();
        }

        // Files.walk() returns a Stream<Path>. We MUST close it when done,
        // so we use try-with-resources: the stream is closed automatically
        // even if an exception is thrown inside the block.
        try (Stream<Path> stream = Files.walk(base)) {
            return stream
                    .filter(Files::isRegularFile)
                    // Files::isRegularFile is a method reference — shorthand for:
                    //   path -> Files.isRegularFile(path)
                    .filter(p -> matchesReportPattern(p.getFileName().toString()))
                    // p.getFileName() returns the last segment of the path (the file name).
                    // .toString() converts it from Path to String so we can regex-match it.
                    .collect(Collectors.toList());

        } catch (IOException e) {
            log.error("FileReaderService: error walking base directory {}: {}", base, e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Returns files that match ALL of the supplied filters.
     * Pass null for any filter you don't want to apply.
     *
     * Examples:
     *   filterFiles("vantagefitness", "web", null, null)
     *     → all files for product=vantagefitness on platform=web, any module, any date
     *
     *   filterFiles(null, null, null, "20260510")
     *     → all files whose date segment equals 20260510, regardless of product/platform/module
     *
     * How the folder structure maps to parameters:
     *   base / product / platform / module / module##id##date.json
     *   [0]    [1]        [2]        [3]      [4 = file]
     *
     * For the folder filters we compare the folder NAME (not the full path).
     * For the date we extract it from the file name: split("##")[2] → "20260510.json"
     * then strip ".json".
     *
     * @param product   e.g. "vantagefitness"  — or null to skip
     * @param platform  e.g. "web"             — or null to skip
     * @param module    e.g. "login"           — or null to skip
     * @param date      e.g. "20260510"        — or null to skip
     * @return filtered list of Path objects
     */
    public List<Path> filterFiles(String product, String platform, String module, String date) {
        List<Path> allFiles = getAllJsonFiles();
        // If getAllJsonFiles already returned empty (e.g. base folder missing),
        // there is nothing to filter — return fast.
        if (allFiles.isEmpty()) {
            return allFiles;
        }

        Path base = basePath();

        List<Path> result = new ArrayList<>();

        for (Path filePath : allFiles) {
            // relativize() removes the base prefix so we are left with:
            //   vantagefitness/web/login/login##abc123##20260510.json
            Path relative = base.relativize(filePath);

            // relative.getNameCount() tells us how many segments the relative path has.
            // We expect exactly 4: product(0) / platform(1) / module(2) / file(3)
            // If a file is at a different depth, skip it — it doesn't fit our convention.
            if (relative.getNameCount() != 4) {
                continue;
            }

            // Extract each segment as a plain String for easy comparison.
            String fileProduct  = relative.getName(0).toString();
            String filePlatform = relative.getName(1).toString();
            String fileModule   = relative.getName(2).toString();
            String fileName     = relative.getName(3).toString(); // e.g. login##abc123##20260510.json

            // Extract the date from the file name.
            // File name format: module##uniqueId##YYYYMMDD.json
            // split("##") gives: ["login", "abc123", "20260510.json"]
            // Index [2] → "20260510.json" → replace(".json","") → "20260510"
            String fileDateRaw = fileName.split("##")[2];                     // "20260510.json"
            String fileDate    = fileDateRaw.replace(".json", "").trim();     // "20260510"

            // Apply each filter only if the caller supplied a non-null value.
            // If the caller passed null for a filter, we treat it as "any" — no restriction.
            if (product  != null && !product.equalsIgnoreCase(fileProduct))   continue;
            if (platform != null && !platform.equalsIgnoreCase(filePlatform)) continue;
            if (module   != null && !module.equalsIgnoreCase(fileModule))     continue;
            if (date     != null && !date.equals(fileDate))                   continue;

            // All applied filters matched — keep this file.
            result.add(filePath);
        }

        return result;
    }

    /**
     * Returns the names of all product folders directly under the base path.
     *
     * Folder structure:
     *   qa-data/              ← base
     *     vantagefitness/     ← product  ← what this method returns
     *     vantagerewards/
     *
     * Files.list() (unlike Files.walk) lists ONLY the direct children — one level deep.
     * We then keep only entries that are directories (skip stray files).
     *
     * @return sorted list of product names; empty list if base folder missing
     */
    public List<String> getAvailableProducts() {
        Path base = basePath();
        if (!directoryExists(base, "base qa.data.path")) {
            return Collections.emptyList();
        }

        try (Stream<Path> stream = Files.list(base)) {
            List<String> products = stream
                    .filter(Files::isDirectory)
                    .map(p -> p.getFileName().toString())
                    // .map() transforms each Path into a String (just the folder name).
                    .sorted()
                    // .sorted() puts them in alphabetical order — nicer for dropdowns.
                    .collect(Collectors.toList());

            log.info("FileReaderService: found {} product(s) under {}", products.size(), base);
            return products;

        } catch (IOException e) {
            log.error("FileReaderService: error listing products: {}", e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Returns platform folder names for the given product.
     *
     * Folder structure:
     *   qa-data/vantagefitness/     ← product folder (input)
     *     web/                      ← platform  ← what this method returns
     *     android/
     *
     * @param product  e.g. "vantagefitness"
     * @return sorted list of platform names; empty list if folder missing
     */
    public List<String> getAvailablePlatforms(String product) {
        if (product == null || product.isBlank()) {
            log.warn("FileReaderService: getAvailablePlatforms called with null/blank product");
            return Collections.emptyList();
        }

        // Build the path:  base / product
        Path productDir = basePath().resolve(product);
        // Path.resolve() appends a segment to an existing path — cleaner than string concatenation.

        if (!directoryExists(productDir, "product directory '" + product + "'")) {
            return Collections.emptyList();
        }

        try (Stream<Path> stream = Files.list(productDir)) {
            return stream
                    .filter(Files::isDirectory)
                    .map(p -> p.getFileName().toString())
                    .sorted()
                    .collect(Collectors.toList());

        } catch (IOException e) {
            log.error("FileReaderService: error listing platforms for product '{}': {}", product, e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Returns module folder names for the given product and platform.
     *
     * Folder structure:
     *   qa-data/vantagefitness/web/   ← product + platform folders (input)
     *     login/                      ← module  ← what this method returns
     *     dashboard/
     *
     * @param product   e.g. "vantagefitness"
     * @param platform  e.g. "web"
     * @return sorted list of module names; empty list if folder missing
     */
    public List<String> getAvailableModules(String product, String platform) {
        if (product == null || product.isBlank() || platform == null || platform.isBlank()) {
            log.warn("FileReaderService: getAvailableModules called with null/blank product or platform");
            return Collections.emptyList();
        }

        // Build the path:  base / product / platform
        Path platformDir = basePath().resolve(product).resolve(platform);

        if (!directoryExists(platformDir, "platform directory '" + product + "/" + platform + "'")) {
            return Collections.emptyList();
        }

        try (Stream<Path> stream = Files.list(platformDir)) {
            return stream
                    .filter(Files::isDirectory)
                    .map(p -> p.getFileName().toString())
                    .sorted()
                    .collect(Collectors.toList());

        } catch (IOException e) {
            log.error("FileReaderService: error listing modules for '{}/{}': {}", product, platform, e.getMessage());
            return Collections.emptyList();
        }
    }
}
