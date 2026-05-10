package com.qa.dashboard.controller;

// =============================================================================
// DashboardController.java
// =============================================================================
// PURPOSE
// -------
// Handles HTTP GET requests to the root URL "/".
// Asks QaDataService for a DashboardSummary and passes it to the FreeMarker
// template "dashboard.ftlh" so it can render the overview page.
//
// This controller is intentionally thin. It does not contain business logic —
// it only:
//   1. Reads filter values from the URL query string
//   2. Asks QaDataService for the right data
//   3. Puts the data into the Spring Model
//   4. Tells Spring which template to render
//
// (The @Controller vs @RestController explanation is at the bottom of this file.)
// =============================================================================

import com.qa.dashboard.dto.BugView;
import com.qa.dashboard.dto.DashboardSummary;
import com.qa.dashboard.dto.TestCaseView;
import com.qa.dashboard.service.QaDataService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.beans.factory.annotation.Autowired;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.stream.Collectors;

import org.springframework.stereotype.Controller;
// @Controller marks this class as a Spring MVC controller.
// Spring scans for it at startup and registers its @GetMapping methods
// as handlers for specific URL paths.

import org.springframework.ui.Model;
// Model is Spring MVC's data-carrier between the controller and the template.
// You add key-value pairs to it; FreeMarker reads them as template variables.
// (Full explanation at the bottom of this file.)

import org.springframework.web.bind.annotation.GetMapping;
// @GetMapping registers a method as the handler for an HTTP GET request
// at the specified URL path.


import org.springframework.web.bind.annotation.RequestParam;
// @RequestParam reads one value from the URL query string.
// Example URL: /?product=vantagefitness&platform=web
//   → product = "vantagefitness"
//   → platform = "web"
// required = false means the parameter is optional; Spring sets it to null
// when the user doesn't include it in the URL.

@Controller
public class DashboardController {

    private static final Logger log = LoggerFactory.getLogger(DashboardController.class);

    // QaDataService is the single point of contact for all data operations.
    // Spring injects the already-created bean via @Autowired.
    @Autowired
    private QaDataService qaDataService;

    /**
     * Renders the main dashboard page.
     *
     * URL examples:
     *   /                                       → all products, all dates
     *   /?product=vantagefitness               → filter by product
     *   /?product=vantagefitness&platform=web  → filter by product + platform
     *   /?date=20260510                        → filter by date only
     *
     * @param product   optional — filters reports to this product folder name
     * @param platform  optional — filters to this platform (requires product)
     * @param module    optional — filters to this module
     * @param date      optional — filters to this exact run date (yyyyMMdd)
     * @param model     Spring's data carrier; we add attributes the template will read
     * @return          the template name (without extension) to render
     */
    @GetMapping({"/", "/overview", "/dashboard"})
    public String dashboard(
            @RequestParam(required = false) String product,
            @RequestParam(required = false) String platform,
            @RequestParam(required = false) String module,
            @RequestParam(required = false) String date,
            Model model) {

        log.info("DashboardController: GET / — product={} platform={} module={} date={}",
                product, platform, module, date);

        // Load aggregated counts (pass rate, bug totals, etc.)
        DashboardSummary summary = qaDataService.getDashboardSummary(product, platform, module, date);

        // Load individual test cases and bugs so the template can build
        // the per-module breakdown table and the recent failures list.
        List<TestCaseView> testCases = qaDataService.getTestCases(product, platform, module, date);
        List<BugView>      bugs      = qaDataService.getBugs(product, platform, module, date, null, null);

        // Derive the list of available run dates from the loaded test cases.
        // We collect unique, non-blank reportDate values and sort newest-first
        // so the most recent date appears first in the Date dropdown.
        List<String> dates = testCases.stream()
                .map(TestCaseView::getReportDate)
                .filter(d -> d != null && !d.isBlank())
                .distinct()
                .sorted(Comparator.reverseOrder())
                .collect(Collectors.toList());

        // Group test cases by module for the module summary table.
        // TreeMap keeps keys sorted alphabetically so the table rows are predictable.
        Map<String, List<TestCaseView>> moduleGroups = testCases.stream()
                .collect(Collectors.groupingBy(
                        tc -> (tc.getModule() != null && !tc.getModule().isBlank())
                              ? tc.getModule() : "(unknown)",
                        TreeMap::new,
                        Collectors.toList()
                ));

        List<TestCaseView> recentFailures = testCases.stream()
                .filter(tc -> "FAIL".equals(tc.getStatus()))
                .limit(5)
                .collect(Collectors.toList());

        List<BugView> recentBugs = bugs.stream()
                .filter(b -> "OPEN".equals(b.getStatus()))
                .limit(5)
                .collect(Collectors.toList());

        model.addAttribute("summary",        summary);
        model.addAttribute("testCases",      testCases);
        model.addAttribute("bugs",           bugs);
        model.addAttribute("dates",          dates);
        model.addAttribute("moduleGroups",   moduleGroups);
        model.addAttribute("recentFailures", recentFailures);
        model.addAttribute("recentBugs",     recentBugs);

        // Expose dropdown lists as top-level attributes so the template can
        // write ${products} directly instead of ${summary.products}.
        model.addAttribute("products",  summary.getProducts());
        model.addAttribute("platforms", summary.getPlatforms());
        model.addAttribute("modules",   summary.getModules());

        model.addAttribute("selectedProduct",  product);
        model.addAttribute("selectedPlatform", platform);
        model.addAttribute("selectedModule",   module);
        model.addAttribute("selectedDate",     date);

        // Return the template name. Spring Boot + FreeMarker will look for:
        //   src/main/resources/templates/dashboard.ftlh
        return "dashboard";
    }
}
