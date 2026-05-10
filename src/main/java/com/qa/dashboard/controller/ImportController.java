package com.qa.dashboard.controller;

// =============================================================================
// ImportController.java
// =============================================================================
// PURPOSE
// -------
// Handles two URL patterns:
//
//   GET  /import  → shows the file upload form (upload.ftlh)
//   POST /import  → receives the uploaded JSON file, validates it, saves it
//                   to the correct folder under qa-data/, then redirects back
//                   to /import with either a success message or an error list
//
// WHAT IS MULTIPART FILE UPLOAD IN SPRING BOOT?
// -----------------------------------------------
// When an HTML form uses  enctype="multipart/form-data"  and includes a file
// input, the browser sends the entire request body as a series of "parts" —
// one for each regular text field and one for the binary file bytes.
//
// Spring Boot's  MultipartFile  object wraps the incoming file part:
//   file.isEmpty()              → true when no file was attached
//   file.getOriginalFilename()  → the filename chosen by the user ("report.json")
//   file.getSize()              → byte count
//   file.getBytes()             → the raw bytes of the file
//
// Multipart support is configured in application.properties:
//   spring.servlet.multipart.enabled=true
//   spring.servlet.multipart.max-file-size=10MB
//
// WHAT IS THE POST/REDIRECT/GET (PRG) PATTERN?
// -----------------------------------------------
// After handling a POST request, best practice is to redirect to a GET.
// Why? If the user presses browser Refresh on a POST response, the browser
// asks "re-send this form?" — often not what you want.
// Redirecting to GET solves this: refresh just re-fetches the (safe) GET page.
//
// WHAT ARE FLASH ATTRIBUTES?
// ---------------------------
// Normally, data placed on a Spring Model is only available for the current
// request. But a redirect throws away the model and starts a fresh request.
//
// RedirectAttributes.addFlashAttribute("key", value) saves data to the user's
// HTTP session. Spring copies it into the model automatically on the very next
// request (the GET after the redirect), then removes it from the session.
// This "flash" lasts exactly one round-trip, which is all we need for banners.
// =============================================================================

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;

import com.qa.dashboard.service.QaDataService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Controller
@RequestMapping("/import")
public class ImportController {

    private static final Logger log = LoggerFactory.getLogger(ImportController.class);

    // @Value reads a value from application.properties at application startup.
    // "${qa.data.path}" refers to the key "qa.data.path=./qa-data" we defined there.
    // Spring injects the string "./qa-data" directly into this field.
    @Value("${qa.data.path}")
    private String qaDataPath;

    // Jackson ObjectMapper parses JSON text/bytes into Java objects.
    // Spring Boot creates one ObjectMapper bean automatically; @Autowired injects it.
    @Autowired
    private ObjectMapper objectMapper;

    // Used to load the products list for the datalist hints on the upload form.
    @Autowired
    private QaDataService qaDataService;

    // =========================================================================
    // GET /import  —  show the upload form
    // =========================================================================
    @GetMapping
    public String showUploadForm(Model model) {
        log.info("ImportController: GET /import");

        // Provide known product names so the template can show them as hints.
        model.addAttribute("products", qaDataService.getProducts());
        return "upload";
        // Spring looks for: src/main/resources/templates/upload.ftlh
    }

    // =========================================================================
    // POST /import  —  validate the uploaded file and save it to qa-data/
    // =========================================================================
    @PostMapping
    public String handleUpload(
            // @RequestParam("file") reads the uploaded file from the multipart request.
            // The name "file" must match the name="" attribute on the <input type="file">
            // in the HTML form.
            @RequestParam("file") MultipartFile file,
            // RedirectAttributes lets us attach data to a redirect response.
            // addFlashAttribute() stores data in the session so it survives one redirect.
            RedirectAttributes redirectAttributes) {

        log.info("ImportController: POST /import — filename='{}' size={}",
                file.getOriginalFilename(), file.getSize());

        // ── Guard: reject if no file was attached ──────────────────────────────
        if (file.isEmpty()) {
            redirectAttributes.addFlashAttribute("errors",
                    List.of("No file selected. Please choose a .json file before clicking Upload."));
            return "redirect:/import";
        }

        // ── Step 1: Read the file bytes and parse them as JSON ─────────────────
        // objectMapper.readTree() parses JSON into a tree of JsonNode objects.
        // JsonNode is like an untyped JSON element — it can be an object, array,
        // string, number, etc. We use it here (instead of QaReport.class) because
        // we want to inspect and validate the structure before committing to a full parse.
        JsonNode root;
        try {
            byte[] bytes = file.getBytes();
            root = objectMapper.readTree(bytes);
        } catch (IOException e) {
            log.warn("ImportController: failed to parse uploaded file as JSON — {}", e.getMessage());
            redirectAttributes.addFlashAttribute("errors",
                    List.of("The file could not be read as valid JSON. "
                          + "Make sure the file is a properly formatted .json document."));
            return "redirect:/import";
        }

        // ── Step 2: Validate the required JSON structure ───────────────────────
        // We collect ALL errors before redirecting so the user sees the full
        // list at once, rather than one error at a time.
        List<String> errors = new ArrayList<>();

        // Check for the three required top-level keys.
        if (!root.has("meta"))       errors.add("Missing required top-level key: \"meta\"");
        if (!root.has("test_cases")) errors.add("Missing required top-level key: \"test_cases\"");
        if (!root.has("bugs"))       errors.add("Missing required top-level key: \"bugs\"");

        // Validate the meta sub-fields — these are needed to determine the save path.
        // We only check them if "meta" is present (otherwise we already have an error above).
        if (root.has("meta")) {
            JsonNode meta = root.get("meta");
            checkMetaField(meta, "product",  errors);
            checkMetaField(meta, "platform", errors);
            checkMetaField(meta, "module",   errors);
            checkMetaField(meta, "date",     errors);
        }

        if (!errors.isEmpty()) {
            redirectAttributes.addFlashAttribute("errors", errors);
            return "redirect:/import";
        }

        // ── Step 3: Extract values from meta ──────────────────────────────────
        // JsonNode.get("key").asText() returns the string value of a JSON field.
        // .trim() removes any accidental leading/trailing whitespace.
        JsonNode meta    = root.get("meta");
        String   product  = meta.get("product").asText().trim();
        String   platform = meta.get("platform").asText().trim();
        String   module   = meta.get("module").asText().trim();
        String   date     = meta.get("date").asText().trim();

        // ── Step 4: Generate a unique filename ─────────────────────────────────
        // Pattern: {module}##{8-char-random-id}##{date}.json
        //
        // UUID.randomUUID() generates a random 128-bit identifier, formatted as:
        //   "550e8400-e29b-41d4-a716-446655440000"
        // We take the first 8 characters (before the first hyphen) to keep the
        // filename short while still making collisions astronomically unlikely.
        //
        // Example result: "login##a1b2c3d4##20260510.json"
        String shortId  = UUID.randomUUID().toString().substring(0, 8);
        String filename = module + "##" + shortId + "##" + date + ".json";

        // ── Step 5: Resolve the target directory path ─────────────────────────
        // Paths.get() joins multiple path segments using the OS separator (/ on Mac/Linux).
        // Result example: ./qa-data/vantagefitness/web/login
        Path targetDir = Paths.get(qaDataPath, product, platform, module);

        // Files.createDirectories() creates the full directory chain in one call,
        // including any parent directories that don't exist yet (like "mkdir -p").
        // It is safe to call even if the directory already exists — it does nothing.
        try {
            Files.createDirectories(targetDir);
            log.debug("ImportController: ensured directory exists: {}", targetDir.toAbsolutePath());
        } catch (IOException e) {
            log.error("ImportController: cannot create directory {} — {}", targetDir, e.getMessage());
            redirectAttributes.addFlashAttribute("errors",
                    List.of("Could not create the storage folder on disk. "
                          + "Check that the app has write permission to the qa-data/ directory."));
            return "redirect:/import";
        }

        // ── Step 6: Write pretty-printed JSON to the target file ───────────────
        // writerWithDefaultPrettyPrinter() produces JSON with 2-space indentation
        // so the saved files are human-readable when opened in a text editor.
        //
        // Files.writeString(path, string, charset) writes a String to a file in
        // one call (added in Java 11). It creates the file if it doesn't exist,
        // or overwrites it if it does (filename is unique due to UUID, so overwriting
        // should not happen in practice).
        Path targetFile = targetDir.resolve(filename);
        try {
            ObjectWriter prettyWriter = objectMapper.writerWithDefaultPrettyPrinter();
            String       prettyJson   = prettyWriter.writeValueAsString(root);
            Files.writeString(targetFile, prettyJson, StandardCharsets.UTF_8);
            log.info("ImportController: saved report → {}", targetFile.toAbsolutePath());
        } catch (IOException e) {
            log.error("ImportController: write failed for {} — {}", targetFile, e.getMessage());
            redirectAttributes.addFlashAttribute("errors",
                    List.of("The file passed validation but could not be saved to disk. "
                          + "Check file system permissions."));
            return "redirect:/import";
        }

        // ── Step 7: Redirect with a success flash message ─────────────────────
        // The upload.ftlh template reads ${successMessage} to render the green banner.
        redirectAttributes.addFlashAttribute("successMessage",
                "Saved as " + filename
                + " → " + product + " / " + platform + " / " + module + "/");

        return "redirect:/import";
    }

    // =========================================================================
    // Private helper
    // =========================================================================

    /**
     * Validates one field inside the "meta" JSON object.
     * The field must exist and must not be blank (empty or whitespace-only).
     * If the check fails, a human-readable error message is added to {@code errors}.
     *
     * @param meta      the JsonNode representing the entire "meta" block
     * @param fieldName the key to check (e.g. "product")
     * @param errors    the list to append the error message to if invalid
     */
    private void checkMetaField(JsonNode meta, String fieldName, List<String> errors) {
        if (!meta.has(fieldName) || meta.get(fieldName).asText().isBlank()) {
            errors.add("meta." + fieldName + " is required and must not be empty.");
        }
    }
}
