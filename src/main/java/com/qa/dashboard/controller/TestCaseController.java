package com.qa.dashboard.controller;

// =============================================================================
// TestCaseController.java
// =============================================================================
// PURPOSE
// -------
// Handles two URL patterns:
//
//   GET /test-cases              → shows a filterable list of test cases
//   GET /test-cases/{tcId}       → shows details for one specific test case
//
// Both handler methods follow the same pattern:
//   1. Read parameters from the URL (query params or path variable)
//   2. Ask QaDataService for the data
//   3. Put the data into the Spring Model
//   4. Return the template name to render
// =============================================================================

import com.qa.dashboard.dto.TestCaseView;
import com.qa.dashboard.service.QaDataService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
// @PathVariable reads a value from inside the URL path itself (not the query string).
// For a URL like  /test-cases/TC-LOGIN-001
//   @PathVariable String tcId   →   tcId = "TC-LOGIN-001"
// The {tcId} placeholder in @GetMapping("/{tcId}") must match the variable name.

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/test-cases")
// @RequestMapping("/test-cases") applies the prefix "/test-cases" to all mappings
// in this class. So:
//   @GetMapping          → handles GET /test-cases
//   @GetMapping("/{tcId}") → handles GET /test-cases/TC-LOGIN-001
public class TestCaseController {

    private static final Logger log = LoggerFactory.getLogger(TestCaseController.class);

    @Autowired
    private QaDataService qaDataService;

    /**
     * Renders the test-cases list page with optional filter support.
     *
     * URL examples:
     *   /test-cases
     *   /test-cases?product=vantagefitness&platform=web
     *   /test-cases?product=vantagefitness&module=login&date=20260510
     *
     * Template receives:
     *   testCases        — List<TestCaseView> matching the active filters
     *   products         — all product names for the "Product" dropdown
     *   platforms        — platform names for the selected product (empty if none selected)
     *   modules          — module names for selected product+platform (empty if incomplete)
     *   selectedProduct  — the currently active product filter (or null)
     *   selectedPlatform — the currently active platform filter (or null)
     *   selectedModule   — the currently active module filter (or null)
     *   selectedDate     — the currently active date filter (or null)
     */
    @GetMapping
    public String listTestCases(
            @RequestParam(required = false) String product,
            @RequestParam(required = false) String platform,
            @RequestParam(required = false) String module,
            @RequestParam(required = false) String date,
            Model model) {

        log.info("TestCaseController: GET /test-cases — product={} platform={} module={} date={}",
                product, platform, module, date);

        // Fetch the filtered list of test case DTOs.
        List<TestCaseView> testCases = qaDataService.getTestCases(product, platform, module, date);
        model.addAttribute("testCases", testCases);

        // Populate filter dropdowns.
        // products is always the full list; platforms and modules are contextual.
        model.addAttribute("products", qaDataService.getProducts());
        model.addAttribute("platforms",
                product != null ? qaDataService.getPlatforms(product) : List.of());
        model.addAttribute("modules",
                product != null && platform != null
                        ? qaDataService.getModules(product, platform)
                        : List.of());

        // Derive available run dates from the loaded test cases.
        // Same approach used in DashboardController and BugController:
        // collect unique, non-blank reportDate strings and sort newest-first
        // so the most recent date appears first in the Date dropdown.
        List<String> dates = testCases.stream()
                .map(TestCaseView::getReportDate)
                .filter(d -> d != null && !d.isBlank())
                .distinct()
                .sorted(Comparator.reverseOrder())
                .collect(Collectors.toList());
        model.addAttribute("dates", dates);

        // Active filter values — used by the template to keep dropdowns in sync
        // with whatever the user selected, so the UI doesn't reset on each reload.
        model.addAttribute("selectedProduct",  product);
        model.addAttribute("selectedPlatform", platform);
        model.addAttribute("selectedModule",   module);
        model.addAttribute("selectedDate",     date);

        return "test-cases";
        // Spring looks for: src/main/resources/templates/test-cases.ftlh
    }

    /**
     * Renders the detail page for a single test case.
     *
     * URL examples:
     *   /test-cases/TC-LOGIN-001
     *   /test-cases/TC-LOGIN-001?product=vantagefitness&platform=web
     *
     * The product/platform/module query params narrow the search scope when
     * the same tcId might theoretically appear in multiple products.
     * They are optional — omitting them searches across everything.
     *
     * Redirects back to /test-cases if the tcId is not found, rather than
     * showing a blank or error page.
     *
     * Template receives:
     *   testCase  — a single TestCaseView with linkedBugs pre-populated
     */
    @GetMapping("/{tcId}")
    public String testCaseDetail(
            @PathVariable String tcId,
            @RequestParam(required = false) String product,
            @RequestParam(required = false) String platform,
            @RequestParam(required = false) String module,
            Model model) {

        log.info("TestCaseController: GET /test-cases/{} — product={} platform={} module={}",
                tcId, product, platform, module);

        TestCaseView testCase = qaDataService.getTestCaseById(tcId, product, platform, module);

        if (testCase == null) {
            log.warn("TestCaseController: tcId='{}' not found — rendering error page", tcId);
            model.addAttribute("errorTitle",   "Test Case Not Found");
            model.addAttribute("errorMessage", "Test case \"" + tcId + "\" was not found.");
            model.addAttribute("errorDetail",
                    "No report file containing TC ID '" + tcId + "' was found. "
                    + "Check the product, platform, and module values in the URL, "
                    + "or verify the ID exists in your qa-data/ reports.");
            model.addAttribute("errorType", "NOT_FOUND");
            return "error";
        }

        model.addAttribute("testCase", testCase);
        // The template can now use:
        //   ${testCase.tcId}
        //   ${testCase.title}
        //   <#list testCase.linkedBugs as bug>...</#list>
        //   <#if testCase.isFailure()>...</#if>

        return "test-case-detail";
        // Spring looks for: src/main/resources/templates/test-case-detail.ftlh
    }
}
