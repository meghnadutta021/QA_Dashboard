<#--
================================================================================
  dashboard.ftlh  —  Overview / Dashboard Page
================================================================================
  This file contains ONLY what is unique to the dashboard page.
  The nav bar, sidebar, footer, and <html>/<head> shell all live in
  layout/base.ftlh and are injected automatically via the <@layout.page> macro.

  MODEL ATTRIBUTES AVAILABLE ON THIS PAGE (set by DashboardController):
    summary          — DashboardSummary: totalTestCases, passed, failed,
                       skipped, blocked, totalBugs, openBugs, resolvedBugs, passRate
    testCases        — List<TestCaseView>: all test cases matching active filters
    bugs             — List<BugView>: all bugs matching active filters
    dates            — List<String>: unique run dates derived from testCases
    products         — List<String>: all product folder names (for dropdown)
    platforms        — List<String>: platform names for selected product
    modules          — List<String>: module names for selected product+platform
    selectedProduct  — String or null: the currently active product filter
    selectedPlatform — String or null: the currently active platform filter
    selectedModule   — String or null: the currently active module filter
    selectedDate     — String or null: the currently active date filter

  KEY FREEMARKER CONCEPTS USED IN THIS FILE
  -----------------------------------------
  <#import>          — loads another template file and binds its macros to an alias
  <@alias.macro>     — calls a macro from an imported file
  ${variable}        — outputs a variable value as text
  ${number?string("0.#")}  — formats a number: at most 1 decimal place (e.g. 66.7)
  <#if cond>         — conditional block; ends with </#if>
  <#list seq as x>   — loop over a sequence (list); ends with </#list>
  x?has_content      — true when x is not null AND not empty (string or list)
  x?index            — inside a <#list>, gives the current 0-based position
  x?size             — number of items in a sequence
  x?filter(i -> …)   — returns a new sequence keeping items where the lambda is true
  x?group_by(i -> …) — groups items by the expression; each group has .groupKey
  x!defaultValue     — if x is null, use defaultValue instead (the "!" operator)
  (bool)?then(a, b)  — inline ternary: if bool is true return a, else b
  <#assign name = v> — creates or updates a local variable
  <#break>           — exits a <#list> loop early
================================================================================
-->

<#-- Step 1: Import the base layout file and bind it to the alias "layout".
     After this line, all macros defined in base.ftlh are available as layout.macroName.
     This is like Java's "import com.qa.dashboard.layout.Base" — giving you access
     to the classes (macros) inside without polluting the global namespace. -->
<#import "/layout/base.ftlh" as layout>

<#-- Step 2: Call the page macro from the layout.
     Everything between <@layout.page> and </@layout.page> is the page content.
     The macro wraps it inside the full HTML shell and injects it at <#nested>.

     Parameters:
       title     → shown in the browser tab: "Overview — QA Dashboard"
       activeNav → tells the nav bar which link to highlight in indigo -->
<@layout.page title="Overview" activeNav="overview">

  <#-- ======================================================================
       PAGE HEADER
       Displays the page title and shows active filters as "breadcrumb pills"
       — small coloured chips that remind the user what is currently filtered.
       ====================================================================== -->
  <div class="flex flex-wrap items-center justify-between gap-3">

    <div>
      <h1 class="text-xl font-semibold text-slate-900">QA Dashboard Overview</h1>
      <p class="text-sm text-slate-500 mt-0.5">
        Aggregated results across all loaded test reports
      </p>
    </div>

    <#-- Active filter breadcrumb pills.
         We only show a pill when the filter is actually set (not null/empty).
         "??" is FreeMarker's null-safe check: true when the variable is not null.
         "?has_content" additionally checks it is not an empty string.
         Both checks together prevent errors when the variable is null AND
         prevent empty chips when the controller sends an empty string. -->
    <div class="flex flex-wrap items-center gap-2 text-xs">
      <#if selectedProduct?? && selectedProduct?has_content>
        <span class="inline-flex items-center gap-1 rounded-full bg-indigo-50 px-3 py-1
                     font-medium text-indigo-700 ring-1 ring-inset ring-indigo-700/20">
          <span class="text-indigo-400">Product:</span> ${selectedProduct}
        </span>
      </#if>
      <#if selectedPlatform?? && selectedPlatform?has_content>
        <span class="inline-flex items-center gap-1 rounded-full bg-indigo-50 px-3 py-1
                     font-medium text-indigo-700 ring-1 ring-inset ring-indigo-700/20">
          <span class="text-indigo-400">Platform:</span> ${selectedPlatform}
        </span>
      </#if>
      <#if selectedModule?? && selectedModule?has_content>
        <span class="inline-flex items-center gap-1 rounded-full bg-indigo-50 px-3 py-1
                     font-medium text-indigo-700 ring-1 ring-inset ring-indigo-700/20">
          <span class="text-indigo-400">Module:</span> ${selectedModule}
        </span>
      </#if>
      <#if selectedDate?? && selectedDate?has_content>
        <span class="inline-flex items-center gap-1 rounded-full bg-slate-100 px-3 py-1
                     font-medium text-slate-600 ring-1 ring-inset ring-slate-600/20">
          <span class="text-slate-400">Date:</span> ${selectedDate}
        </span>
      </#if>
    </div>

  </div>

  <#-- ======================================================================
       FILTER BAR
       A horizontal form that lets the user narrow results by product,
       platform, module, and date. Submits as a GET request so the filters
       appear in the URL (bookmarkable + shareable).
       ====================================================================== -->
  <div class="card p-4">
    <#-- method="get" sends values as ?product=x&platform=y in the URL.
         action="/" sends the form to the dashboard URL. -->
    <form method="get" action="/" class="flex flex-wrap items-end gap-3">

      <#-- ---- Product dropdown ---- -->
      <div class="flex flex-col gap-1 min-w-[10rem]">
        <label for="product" class="text-xs font-medium text-slate-600">Product</label>
        <select id="product" name="product"
                class="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-sm
                       text-slate-700 shadow-sm focus:border-indigo-500 focus:outline-none
                       focus:ring-1 focus:ring-indigo-500">
          <option value="">All Products</option>
          <#-- <#list seq as item> loops over every element in the sequence "products".
               Each iteration "item" is one product name string. -->
          <#list products as p>
            <#-- "selected" is added when this option matches the active filter.
                 Pattern: check not-null with "??", then compare with "==". -->
            <option value="${p}" <#if selectedProduct?? && selectedProduct == p>selected</#if>>
              ${p}
            </option>
          </#list>
        </select>
      </div>

      <#-- ---- Platform dropdown ---- -->
      <div class="flex flex-col gap-1 min-w-[10rem]">
        <label for="platform" class="text-xs font-medium text-slate-600">Platform</label>
        <select id="platform" name="platform"
                class="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-sm
                       text-slate-700 shadow-sm focus:border-indigo-500 focus:outline-none
                       focus:ring-1 focus:ring-indigo-500"
                <#-- Disable the dropdown when no product is selected yet.
                     In HTML, any value for the "disabled" attribute disables the element. -->
                <#if !selectedProduct?? || !selectedProduct?has_content>disabled</#if>>
          <option value="">
            <#if selectedProduct?? && selectedProduct?has_content>All Platforms<#else>Select Product first</#if>
          </option>
          <#list platforms as p>
            <option value="${p}" <#if selectedPlatform?? && selectedPlatform == p>selected</#if>>
              ${p}
            </option>
          </#list>
        </select>
      </div>

      <#-- ---- Module dropdown ---- -->
      <div class="flex flex-col gap-1 min-w-[10rem]">
        <label for="module" class="text-xs font-medium text-slate-600">Module</label>
        <select id="module" name="module"
                class="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-sm
                       text-slate-700 shadow-sm focus:border-indigo-500 focus:outline-none
                       focus:ring-1 focus:ring-indigo-500"
                <#if !selectedPlatform?? || !selectedPlatform?has_content>disabled</#if>>
          <option value="">
            <#if selectedPlatform?? && selectedPlatform?has_content>All Modules<#else>Select Platform first</#if>
          </option>
          <#list modules as m>
            <option value="${m}" <#if selectedModule?? && selectedModule == m>selected</#if>>
              ${m}
            </option>
          </#list>
        </select>
      </div>

      <#-- ---- Date dropdown ---- -->
      <#-- The "dates" list is derived from the test cases actually loaded, so it only
           shows dates that have real data — no guessing required. -->
      <div class="flex flex-col gap-1 min-w-[10rem]">
        <label for="date" class="text-xs font-medium text-slate-600">Date</label>
        <select id="date" name="date"
                class="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-sm
                       text-slate-700 shadow-sm focus:border-indigo-500 focus:outline-none
                       focus:ring-1 focus:ring-indigo-500">
          <option value="">All Dates</option>
          <#list dates as d>
            <option value="${d}" <#if selectedDate?? && selectedDate == d>selected</#if>>
              ${d}
            </option>
          </#list>
        </select>
      </div>

      <#-- ---- Buttons ---- -->
      <div class="flex items-center gap-2 pb-0.5">
        <button type="submit"
                class="rounded-md bg-indigo-600 px-4 py-1.5 text-sm font-medium text-white
                       shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2
                       focus:ring-indigo-500 focus:ring-offset-1 transition-colors">
          Apply Filters
        </button>
        <a href="/"
           class="text-sm text-slate-500 hover:text-slate-800 transition-colors">
          Clear
        </a>
      </div>

    </form>
  </div>

  <#-- ======================================================================
       STATS CARDS ROW
       Four summary numbers laid out in a responsive grid.
       "grid-cols-2 sm:grid-cols-4" means 2 columns on mobile, 4 on wider screens.
       ====================================================================== -->
  <div class="grid grid-cols-2 sm:grid-cols-4 gap-4">

    <#-- ---- Card 1: Total Test Cases (blue) ---- -->
    <div class="card p-5">
      <div class="flex items-start gap-3">
        <span class="rounded-lg p-2 bg-blue-50 text-blue-600 shrink-0">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none"
               viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2
                     0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2
                     2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" />
          </svg>
        </span>
        <div class="min-w-0">
          <p class="text-xs text-slate-500 truncate">Total Test Cases</p>
          <#-- ${summary.totalTestCases} reads the totalTestCases field of the DashboardSummary
               object named "summary" in the model. FreeMarker calls getTotalTestCases() for us. -->
          <p class="text-2xl font-semibold text-slate-900 mt-0.5">${summary.totalTestCases}</p>
          <p class="text-xs text-slate-400 mt-1">
            ${summary.skipped} skipped &nbsp;·&nbsp; ${summary.blocked} blocked
          </p>
        </div>
      </div>
    </div>

    <#-- ---- Card 2: Passed + Pass Rate (green) ---- -->
    <div class="card p-5">
      <div class="flex items-start gap-3">
        <span class="rounded-lg p-2 bg-green-50 text-green-600 shrink-0">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none"
               viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
          </svg>
        </span>
        <div class="min-w-0">
          <p class="text-xs text-slate-500 truncate">Passed</p>
          <p class="text-2xl font-semibold text-green-700 mt-0.5">${summary.passed}</p>
          <#-- ?string("0.#") formats a number with at most 1 decimal place.
               Examples: 100.0 → "100", 66.666 → "66.7", 0.0 → "0" -->
          <p class="text-xs text-green-600 font-medium mt-1">
            ${summary.passRate?string("0.#")}% pass rate
          </p>
        </div>
      </div>
    </div>

    <#-- ---- Card 3: Failed (red) — links to filtered test cases ---- -->
    <#-- We wrap this card in an <a> to make the whole card clickable.
         The link carries the current product/platform/module filters forward
         so the test-cases page opens in the same filtered context. -->
    <a href="/test-cases?<#if selectedProduct?? && selectedProduct?has_content>product=${selectedProduct}&</#if><#if selectedPlatform?? && selectedPlatform?has_content>platform=${selectedPlatform}&</#if><#if selectedModule?? && selectedModule?has_content>module=${selectedModule}&</#if>status=FAIL"
       class="card p-5 hover:border-red-300 hover:shadow-md transition-all group block">
      <div class="flex items-start gap-3">
        <span class="rounded-lg p-2 bg-red-50 text-red-600 shrink-0
                     group-hover:bg-red-100 transition-colors">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none"
               viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M6 18L18 6M6 6l12 12" />
          </svg>
        </span>
        <div class="min-w-0">
          <p class="text-xs text-slate-500 truncate">Failed</p>
          <p class="text-2xl font-semibold text-red-700 mt-0.5">${summary.failed}</p>
          <p class="text-xs text-red-400 mt-1">Click to view →</p>
        </div>
      </div>
    </a>

    <#-- ---- Card 4: Open Bugs (orange) — links to open bugs list ---- -->
    <a href="/bugs?<#if selectedProduct?? && selectedProduct?has_content>product=${selectedProduct}&</#if><#if selectedPlatform?? && selectedPlatform?has_content>platform=${selectedPlatform}&</#if><#if selectedModule?? && selectedModule?has_content>module=${selectedModule}&</#if>status=OPEN"
       class="card p-5 hover:border-orange-300 hover:shadow-md transition-all group block">
      <div class="flex items-start gap-3">
        <span class="rounded-lg p-2 bg-orange-50 text-orange-600 shrink-0
                     group-hover:bg-orange-100 transition-colors">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none"
               viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667
                     1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34
                     16c-.77 1.333.192 3 1.732 3z" />
          </svg>
        </span>
        <div class="min-w-0">
          <p class="text-xs text-slate-500 truncate">Open Bugs</p>
          <p class="text-2xl font-semibold text-orange-700 mt-0.5">${summary.openBugs}</p>
          <p class="text-xs text-orange-400 mt-1">
            ${summary.resolvedBugs} resolved &nbsp;·&nbsp; Click to view →
          </p>
        </div>
      </div>
    </a>

  </div>

  <#-- ======================================================================
       MODULE SUMMARY TABLE
       Groups test cases by module and shows counts per module.

       HOW group_by WORKS
       ------------------
       testCases?group_by(tc -> tc.module) takes the flat list of test cases
       and groups them by the "module" field. The result is a list of groups.
       Each "group" is itself a list of test cases sharing the same module name.
       Each group also has a special .groupKey property = the module name.

       Example: if testCases has 3 login TCs and 2 dashboard TCs:
         group_by produces two groups:
           group[0].groupKey = "login",     group[0] = [TC-001, TC-002, TC-003]
           group[1].groupKey = "dashboard", group[1] = [TC-004, TC-005]
       ====================================================================== -->
  <div class="card overflow-hidden">

    <div class="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
      <h2 class="text-sm font-semibold text-slate-800">Results by Module</h2>
      <span class="text-xs text-slate-400">${testCases?size} test case(s) loaded</span>
    </div>

    <#if testCases?has_content>

      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead>
            <tr class="bg-slate-50 text-left text-xs font-semibold text-slate-500 uppercase tracking-wide">
              <th class="px-5 py-3">Module</th>
              <th class="px-4 py-3 text-center">Total</th>
              <th class="px-4 py-3 text-center">Passed</th>
              <th class="px-4 py-3 text-center">Failed</th>
              <th class="px-4 py-3 text-center">Bugs</th>
              <th class="px-4 py-3 text-center">Pass Rate</th>
              <th class="px-4 py-3"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">

            <#-- Loop over module groups.
                 moduleGroups is a TreeMap<String, List<TestCaseView>> built in the controller,
                 so keys are already sorted alphabetically. -->
            <#list moduleGroups?keys?sort as modName>
              <#assign group     = moduleGroups[modName]>
              <#assign modTotal  = group?size>
              <#assign modPassed = group?filter(tc -> tc.status == "PASS")?size>
              <#assign modFailed = group?filter(tc -> tc.status == "FAIL")?size>

              <#-- Count bugs for this module using the top-level bugs list.
                   "bugs" is the List<BugView> added to the model by the controller.
                   b.module is the module name stored in each BugView's context fields. -->
              <#assign modBugs = bugs?filter(b -> b.module! == modName)?size>

              <#-- Pass rate: (passed / total) * 100, safely avoiding division by zero.
                   (modTotal > 0)?then(a, b) is FreeMarker's ternary:
                     if modTotal > 0 → compute the percentage
                     else            → use 0 -->
              <#assign modPassRate = (modTotal > 0)?then((modPassed * 100.0) / modTotal, 0)>

              <tr class="hover:bg-slate-50 transition-colors">

                <td class="px-5 py-3 font-medium text-slate-800">
                  <#-- Each module name links to the same page with that module as a filter -->
                  <a href="/?<#if selectedProduct?? && selectedProduct?has_content>product=${selectedProduct}&</#if><#if selectedPlatform?? && selectedPlatform?has_content>platform=${selectedPlatform}&</#if>module=${modName}"
                     class="hover:text-indigo-600 transition-colors">
                    ${modName}
                  </a>
                </td>

                <td class="px-4 py-3 text-center text-slate-700">${modTotal}</td>

                <td class="px-4 py-3 text-center text-green-700 font-medium">${modPassed}</td>

                <td class="px-4 py-3 text-center">
                  <#if modFailed gt 0>
                    <span class="font-medium text-red-600">${modFailed}</span>
                  <#else>
                    <span class="text-slate-400">0</span>
                  </#if>
                </td>

                <td class="px-4 py-3 text-center">
                  <#if modBugs gt 0>
                    <span class="font-medium text-orange-600">${modBugs}</span>
                  <#else>
                    <span class="text-slate-400">0</span>
                  </#if>
                </td>

                <td class="px-4 py-3 text-center">
                  <#-- Render the pass rate as a small progress bar + percentage text.
                       modPassRate is a number (0–100); we use it to set the bar width. -->
                  <div class="flex items-center justify-center gap-2">
                    <div class="w-16 h-1.5 rounded-full bg-slate-200 overflow-hidden">
                      <div class="h-full rounded-full
                                  <#if (modPassRate >= 80)>bg-green-500<#elseif (modPassRate >= 50)>bg-yellow-400<#else>bg-red-500</#if>"
                           style="width: ${modPassRate?string("0.#")}%">
                      </div>
                    </div>
                    <span class="text-xs font-medium
                                 <#if (modPassRate >= 80)>text-green-700<#elseif (modPassRate >= 50)>text-yellow-700<#else>text-red-700</#if>">
                      ${modPassRate?string("0.#")}%
                    </span>
                  </div>
                </td>

                <td class="px-4 py-3 text-right">
                  <a href="/test-cases?<#if selectedProduct?? && selectedProduct?has_content>product=${selectedProduct}&</#if><#if selectedPlatform?? && selectedPlatform?has_content>platform=${selectedPlatform}&</#if>module=${modName}"
                     class="text-xs text-indigo-500 hover:text-indigo-700 transition-colors whitespace-nowrap">
                    View TCs →
                  </a>
                </td>

              </tr>
            </#list>

          </tbody>
        </table>
      </div>

    <#else>
      <#-- "No data found" state: shown when the list is empty.
           This happens when no JSON files matched the current filters,
           or the qa-data/ folder is empty. -->
      <div class="flex flex-col items-center justify-center py-16 text-slate-400">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 mb-3 text-slate-300" fill="none"
             viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round"
                d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586
                   a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
        <p class="text-sm font-medium">No test cases found</p>
        <p class="text-xs mt-1 text-center max-w-xs">
          <#if selectedProduct?? && selectedProduct?has_content>
            No test cases match the active filters. Try clearing the filters or uploading a report.
          <#else>
            No JSON report files found in qa-data/. Upload a report to get started.
          </#if>
        </p>
        <div class="flex gap-4 mt-4">
          <#if selectedProduct?? && selectedProduct?has_content>
            <a href="/" class="text-xs text-indigo-500 hover:text-indigo-700 transition-colors">
              Clear filters →
            </a>
          </#if>
          <a href="/import" class="text-xs text-indigo-500 hover:text-indigo-700 transition-colors">
            Import a report →
          </a>
        </div>
      </div>
    </#if>

  </div>

  <#-- ======================================================================
       RECENT FAILURES SECTION
       Shows the most recent (up to 5) failed test cases.
       ====================================================================== -->
  <div class="card overflow-hidden">

    <div class="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
      <div class="flex items-center gap-2">
        <span class="inline-block h-2 w-2 rounded-full bg-red-500"></span>
        <h2 class="text-sm font-semibold text-slate-800">Recent Failures</h2>
      </div>
      <a href="/test-cases?<#if selectedProduct?? && selectedProduct?has_content>product=${selectedProduct}&</#if><#if selectedPlatform?? && selectedPlatform?has_content>platform=${selectedPlatform}&</#if><#if selectedModule?? && selectedModule?has_content>module=${selectedModule}&</#if>status=FAIL"
         class="text-xs text-indigo-500 hover:text-indigo-700 transition-colors">
        View all failures →
      </a>
    </div>

    <#-- Filter to only FAIL test cases using ?filter, then iterate.
         We stop after 5 rows using tc?index (0-based loop position) with <#break>. -->
    <#assign failedCases = testCases?filter(tc -> tc.status == "FAIL")>

    <#if failedCases?has_content>

      <ul class="divide-y divide-slate-100">
        <#list failedCases as tc>
          <#-- tc?index is the current 0-based position in the loop.
               When it reaches 5, we have shown items 0,1,2,3,4 — that is 5 rows.
               <#break> exits the loop immediately. -->
          <#if (tc?index >= 5)><#break></#if>

          <li class="flex flex-wrap items-center justify-between gap-3 px-5 py-3
                     hover:bg-slate-50 transition-colors">

            <div class="flex items-center gap-3 min-w-0">
              <#-- TC ID — clickable link to the detail page.
                   The tc.product, tc.platform, tc.module query params let the
                   detail page find the right report file without ambiguity. -->
              <a href="/test-cases/${tc.tcId}?<#if tc.product?has_content>product=${tc.product}&</#if><#if tc.platform?has_content>platform=${tc.platform}&</#if><#if tc.module?has_content>module=${tc.module}</#if>"
                 class="font-mono text-xs font-semibold text-indigo-600 hover:text-indigo-800
                        shrink-0 transition-colors">
                ${tc.tcId}
              </a>

              <#-- Title — truncated if too long ("truncate" clips with ellipsis) -->
              <span class="text-sm text-slate-700 truncate">${tc.title}</span>
            </div>

            <div class="flex items-center gap-2 shrink-0">
              <#-- Module pill -->
              <span class="rounded bg-slate-100 px-2 py-0.5 text-xs text-slate-600">
                ${tc.module!"—"}
              </span>

              <#if tc.priority?? && tc.priority?has_content>
                <@layout.priorityBadge priority=tc.priority />
              </#if>

              <#-- FAIL badge -->
              <@layout.statusBadge status="FAIL" />
            </div>

          </li>
        </#list>
      </ul>

      <#-- Show a "and N more" footer when there are more than 5 failures -->
      <#if failedCases?size gt 5>
        <div class="px-5 py-3 bg-slate-50 border-t border-slate-100">
          <a href="/test-cases?<#if selectedProduct?? && selectedProduct?has_content>product=${selectedProduct}&</#if>status=FAIL"
             class="text-xs text-slate-500 hover:text-indigo-600 transition-colors">
            + ${failedCases?size - 5} more failure(s) — view all →
          </a>
        </div>
      </#if>

    <#else>
      <div class="flex flex-col items-center justify-center py-10 text-slate-400">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 mb-2 text-green-300" fill="none"
             viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round"
                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <p class="text-sm font-medium text-green-600">No failures found</p>
        <p class="text-xs text-slate-400 mt-1">All loaded test cases are passing.</p>
      </div>
    </#if>

  </div>

  <#-- ======================================================================
       RECENT OPEN BUGS SECTION
       Shows the most recent (up to 5) open bugs from recentBugs in the model.
       ====================================================================== -->
  <div class="card overflow-hidden">

    <div class="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
      <div class="flex items-center gap-2">
        <span class="inline-block h-2 w-2 rounded-full bg-orange-500"></span>
        <h2 class="text-sm font-semibold text-slate-800">Recent Open Bugs</h2>
      </div>
      <a href="/bugs?<#if selectedProduct?? && selectedProduct?has_content>product=${selectedProduct}&</#if><#if selectedPlatform?? && selectedPlatform?has_content>platform=${selectedPlatform}&</#if><#if selectedModule?? && selectedModule?has_content>module=${selectedModule}&</#if>status=OPEN"
         class="text-xs text-indigo-500 hover:text-indigo-700 transition-colors">
        View all open bugs →
      </a>
    </div>

    <#if recentBugs?has_content>

      <ul class="divide-y divide-slate-100">
        <#list recentBugs as bug>
          <li class="flex flex-wrap items-center justify-between gap-3 px-5 py-3
                     hover:bg-slate-50 transition-colors">

            <div class="flex items-center gap-3 min-w-0">
              <a href="/bugs/${bug.bugId}?<#if bug.product?has_content>product=${bug.product}&</#if><#if bug.platform?has_content>platform=${bug.platform}&</#if><#if bug.module?has_content>module=${bug.module}</#if>"
                 class="font-mono text-xs font-semibold text-orange-600 hover:text-orange-800
                        shrink-0 transition-colors">
                ${bug.bugId}
              </a>
              <span class="text-sm text-slate-700 truncate">${bug.title}</span>
            </div>

            <div class="flex items-center gap-2 shrink-0">
              <span class="rounded bg-slate-100 px-2 py-0.5 text-xs text-slate-600">
                ${bug.module!"—"}
              </span>
              <#if bug.severity?? && bug.severity?has_content>
                <@layout.severityBadge severity=bug.severity />
              </#if>
              <@layout.bugStatusBadge status="OPEN" />
            </div>

          </li>
        </#list>
      </ul>

      <#assign openBugsTotal = bugs?filter(b -> b.status == "OPEN")?size>
      <#if openBugsTotal gt 5>
        <div class="px-5 py-3 bg-slate-50 border-t border-slate-100">
          <a href="/bugs?<#if selectedProduct?? && selectedProduct?has_content>product=${selectedProduct}&</#if>status=OPEN"
             class="text-xs text-slate-500 hover:text-indigo-600 transition-colors">
            + ${openBugsTotal - 5} more open bug(s) — view all →
          </a>
        </div>
      </#if>

    <#else>
      <div class="flex flex-col items-center justify-center py-10 text-slate-400">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 mb-2 text-green-300" fill="none"
             viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round"
                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <p class="text-sm font-medium text-green-600">No open bugs</p>
        <p class="text-xs text-slate-400 mt-1">No open bugs match the current filters.</p>
      </div>
    </#if>

  </div>

</@layout.page>
