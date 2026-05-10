package com.qa.dashboard.controller;

// =============================================================================
// BugController.java
// =============================================================================
// PURPOSE
// -------
// Handles two URL patterns:
//
//   GET /bugs           → filterable list of all bugs
//   GET /bugs/{bugId}   → detail page for one specific bug
//
// The /bugs list page supports an extra "status" filter (e.g. OPEN / FIXED)
// that the test-cases page doesn't need, so this controller has a slightly
// wider set of query parameters.
// =============================================================================

import com.qa.dashboard.dto.BugView;
import com.qa.dashboard.service.QaDataService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/bugs")
public class BugController {

    private static final Logger log = LoggerFactory.getLogger(BugController.class);

    @Autowired
    private QaDataService qaDataService;

    /**
     * Renders the bugs list page with optional filter support.
     *
     * URL examples:
     *   /bugs
     *   /bugs?product=vantagefitness&status=OPEN
     *   /bugs?product=vantagefitness&platform=web&module=login&date=20260510
     *
     * Template receives:
     *   bugs             — List<BugView> matching the active filters
     *   products         — all product names for the "Product" dropdown
     *   platforms        — platform names for the selected product
     *   modules          — module names for selected product+platform
     *   bugStatuses      — fixed list of known bug statuses for the "Status" dropdown
     *   selectedProduct  — active product filter (or null)
     *   selectedPlatform — active platform filter (or null)
     *   selectedModule   — active module filter (or null)
     *   selectedDate     — active date filter (or null)
     *   selectedStatus   — active status filter (or null)
     */
    @GetMapping
    public String listBugs(
            @RequestParam(required = false) String product,
            @RequestParam(required = false) String platform,
            @RequestParam(required = false) String module,
            @RequestParam(required = false) String date,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String severity,
            Model model) {

        log.info("BugController: GET /bugs — product={} platform={} module={} date={} status={} severity={}",
                product, platform, module, date, status, severity);

        // Fetch bugs matching all active filters (nulls = no filter on that field).
        List<BugView> bugs = qaDataService.getBugs(product, platform, module, date, status, severity);
        model.addAttribute("bugs", bugs);

        // Populate cascading filter dropdowns.
        model.addAttribute("products", qaDataService.getProducts());
        model.addAttribute("platforms",
                product != null ? qaDataService.getPlatforms(product) : List.of());
        model.addAttribute("modules",
                product != null && platform != null
                        ? qaDataService.getModules(product, platform)
                        : List.of());

        // Derive available run dates from the bugs actually loaded.
        // Sorted newest-first so the most recent date appears first in the dropdown.
        List<String> dates = bugs.stream()
                .map(BugView::getReportDate)
                .filter(d -> d != null && !d.isBlank())
                .distinct()
                .sorted(Comparator.reverseOrder())
                .collect(Collectors.toList());
        model.addAttribute("dates", dates);

        model.addAttribute("bugStatuses",
                List.of("OPEN", "IN_PROGRESS", "FIXED", "CLOSED"));
        model.addAttribute("bugSeverities",
                List.of("CRITICAL", "HIGH", "MEDIUM", "LOW"));

        // Active filter state — keeps all dropdowns in sync with the current URL.
        model.addAttribute("selectedProduct",  product);
        model.addAttribute("selectedPlatform", platform);
        model.addAttribute("selectedModule",   module);
        model.addAttribute("selectedDate",     date);
        model.addAttribute("selectedStatus",   status);
        model.addAttribute("selectedSeverity", severity);

        return "bugs";
    }

    /**
     * Renders the detail page for a single bug.
     *
     * URL examples:
     *   /bugs/BUG-LOGIN-001
     *   /bugs/BUG-LOGIN-001?product=vantagefitness&platform=web
     *
     * Redirects to /bugs if the bugId is not found.
     *
     * Template receives:
     *   bug  — a single BugView with linkedTestCase pre-populated
     *          (linkedTestCase is null when bug.isOrphan() is true)
     */
    @GetMapping("/{bugId}")
    public String bugDetail(
            @PathVariable String bugId,
            @RequestParam(required = false) String product,
            @RequestParam(required = false) String platform,
            @RequestParam(required = false) String module,
            Model model) {

        log.info("BugController: GET /bugs/{} — product={} platform={} module={}",
                bugId, product, platform, module);

        BugView bug = qaDataService.getBugById(bugId, product, platform, module);

        if (bug == null) {
            log.warn("BugController: bugId='{}' not found — redirecting to list", bugId);
            return "redirect:/bugs";
        }

        model.addAttribute("bug", bug);
        // Template can use:
        //   ${bug.bugId}
        //   ${bug.severity}
        //   <#if bug.isOrphan()>...</#if>
        //   <#if bug.linkedTestCase??>${bug.linkedTestCase.title}</#if>
        //   (In FreeMarker, "??" is the null-check operator)

        return "bug-detail";
        // Spring looks for: src/main/resources/templates/bug-detail.ftlh
    }
}
