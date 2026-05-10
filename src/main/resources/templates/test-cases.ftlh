<#--
================================================================================
  test-cases.ftlh  —  Test Cases List Page
================================================================================

  MODEL ATTRIBUTES FROM TestCaseController.listTestCases():
    testCases        — List<TestCaseView>: test cases matching active filters
    products         — List<String>: all known product folder names
    platforms        — List<String>: platforms for the selected product (empty if none)
    modules          — List<String>: modules for selected product+platform (empty if incomplete)
    dates            — List<String>: unique run dates from loaded data (newest first)
    selectedProduct  — active product filter (or null)
    selectedPlatform — active platform filter (or null)
    selectedModule   — active module filter (or null)
    selectedDate     — active date filter (or null)

  FREEMARKER FEATURES USED HERE
  ------------------------------
  testCases?size           → total number of items in the list
  testCases?filter(λ)      → returns a new list with only the matching items
  tc?is_odd_item           → true on rows 1, 3, 5 … (1-based); used for row shading
  tc.linkedBugs?size       → size of the linked bugs list
  <#assign x = y>         → creates a local variable in this template
  x!""                     → if x is null, use "" instead (the "!" default operator)
  x?has_content            → true when x is not null AND not blank/empty

================================================================================
-->
<#import "/layout/base.ftlh" as layout>

<@layout.page title="Test Cases" activeNav="testcases">

  <#-- =========================================================================
       COMPUTE SUMMARY COUNTS ONCE
       These variables are referenced in both the page header and the table footer.
       ========================================================================= -->
  <#assign totalTcs  = testCases?size>
  <#assign failedTcs = testCases?filter(tc -> tc.status == "FAIL")?size>
  <#assign passedTcs = testCases?filter(tc -> tc.status == "PASS")?size>

  <#-- =========================================================================
       BUILD EXPORT QUERY STRING ONCE
       Both export buttons (CSV and JSON) need the same filter params in the URL.
       We build the query string once here and reuse it for both hrefs, rather than
       duplicating the conditional logic twice.

       Logic: start with "?", append each non-null filter, switch separator to "&".
       Result examples:
         No filters active   → qs = ""     → href="/export/csv"
         product only        → qs = "?product=vantagefitness"
         product + date      → qs = "?product=vantagefitness&date=20260510"
       ========================================================================= -->
  <#assign qs   = "">
  <#assign qsep = "?">
  <#if selectedProduct?? && selectedProduct?has_content>
    <#assign qs = qs + qsep + "product=" + selectedProduct>
    <#assign qsep = "&">
  </#if>
  <#if selectedPlatform?? && selectedPlatform?has_content>
    <#assign qs = qs + qsep + "platform=" + selectedPlatform>
    <#assign qsep = "&">
  </#if>
  <#if selectedModule?? && selectedModule?has_content>
    <#assign qs = qs + qsep + "module=" + selectedModule>
    <#assign qsep = "&">
  </#if>
  <#if selectedDate?? && selectedDate?has_content>
    <#assign qs = qs + qsep + "date=" + selectedDate>
    <#assign qsep = "&">
  </#if>

  <#-- =========================================================================
       PAGE HEADER  —  title + counts + filter pills + export buttons
       ========================================================================= -->
  <div class="flex flex-wrap items-start justify-between gap-3">
    <div>
      <h1 class="text-xl font-semibold text-slate-900">Test Cases</h1>
      <p class="text-sm text-slate-500 mt-0.5">
        Showing <span class="font-medium text-slate-700">${totalTcs}</span>
        test case<#if totalTcs != 1>s</#if>
        <#if failedTcs gt 0>
          — <span class="font-medium text-red-600">${failedTcs} failed</span>
        </#if>
        <#if passedTcs gt 0>
          <#if failedTcs gt 0>, <#else>— </#if>
          <span class="font-medium text-green-600">${passedTcs} passed</span>
        </#if>
      </p>
      <#-- Active filter pills — same style as dashboard.ftlh breadcrumb pills -->
      <div class="flex flex-wrap items-center gap-2 text-xs mt-2">
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

    <#-- Export + navigation buttons on the right -->
    <div class="flex items-center gap-2 self-center flex-wrap">

      <#-- CSV Export — downloads a UTF-8 CSV with BOM (Excel-ready) -->
      <a href="/export/csv${qs}"
         class="inline-flex items-center gap-1.5 rounded-md border border-slate-300
                bg-white px-3 py-1.5 text-xs font-medium text-slate-700 shadow-sm
                hover:bg-slate-50 hover:border-slate-400 transition-colors">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5 text-green-600"
             fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round"
                d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
        </svg>
        Export CSV
      </a>

      <#-- JSON Export — downloads all filtered data as pretty-printed JSON -->
      <a href="/export/json${qs}"
         class="inline-flex items-center gap-1.5 rounded-md border border-slate-300
                bg-white px-3 py-1.5 text-xs font-medium text-slate-700 shadow-sm
                hover:bg-slate-50 hover:border-slate-400 transition-colors">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5 text-indigo-500"
             fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round"
                d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
        </svg>
        Export JSON
      </a>

      <a href="/" class="text-sm text-indigo-500 hover:text-indigo-700 transition-colors">
        ← Overview
      </a>
    </div>
  </div>

  <#-- =========================================================================
       FILTER BAR
       Submits as GET so the active filters appear in the URL (bookmarkable/shareable).
       Dropdowns cascade: Platform is disabled until Product is chosen;
       Module is disabled until Platform is chosen.
       ========================================================================= -->
  <div class="card p-4">
    <form method="get" action="/test-cases" class="flex flex-wrap items-end gap-3">

      <#-- Product -->
      <div class="flex flex-col gap-1 min-w-[9rem]">
        <label for="product" class="text-xs font-medium text-slate-600">Product</label>
        <select id="product" name="product"
                class="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-sm
                       text-slate-700 shadow-sm focus:border-indigo-500 focus:outline-none
                       focus:ring-1 focus:ring-indigo-500">
          <option value="">All Products</option>
          <#list products as p>
            <option value="${p}"
                    <#if selectedProduct?? && selectedProduct == p>selected</#if>>${p}</option>
          </#list>
        </select>
      </div>

      <#-- Platform — disabled until a product is selected -->
      <div class="flex flex-col gap-1 min-w-[9rem]">
        <label for="platform" class="text-xs font-medium text-slate-600">Platform</label>
        <select id="platform" name="platform"
                class="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-sm
                       text-slate-700 shadow-sm focus:border-indigo-500 focus:outline-none
                       focus:ring-1 focus:ring-indigo-500"
                <#if !selectedProduct?? || !selectedProduct?has_content>disabled</#if>>
          <option value="">
            <#if selectedProduct?? && selectedProduct?has_content>All Platforms<#else>— select product first —</#if>
          </option>
          <#list platforms as p>
            <option value="${p}"
                    <#if selectedPlatform?? && selectedPlatform == p>selected</#if>>${p}</option>
          </#list>
        </select>
      </div>

      <#-- Module — disabled until a platform is selected -->
      <div class="flex flex-col gap-1 min-w-[9rem]">
        <label for="module" class="text-xs font-medium text-slate-600">Module</label>
        <select id="module" name="module"
                class="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-sm
                       text-slate-700 shadow-sm focus:border-indigo-500 focus:outline-none
                       focus:ring-1 focus:ring-indigo-500"
                <#if !selectedPlatform?? || !selectedPlatform?has_content>disabled</#if>>
          <option value="">
            <#if selectedPlatform?? && selectedPlatform?has_content>All Modules<#else>— select platform first —</#if>
          </option>
          <#list modules as m>
            <option value="${m}"
                    <#if selectedModule?? && selectedModule == m>selected</#if>>${m}</option>
          </#list>
        </select>
      </div>

      <#-- Date — only shows dates that have actual data -->
      <div class="flex flex-col gap-1 min-w-[9rem]">
        <label for="date" class="text-xs font-medium text-slate-600">Date</label>
        <select id="date" name="date"
                class="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-sm
                       text-slate-700 shadow-sm focus:border-indigo-500 focus:outline-none
                       focus:ring-1 focus:ring-indigo-500">
          <option value="">All Dates</option>
          <#list dates as d>
            <option value="${d}" <#if selectedDate?? && selectedDate == d>selected</#if>>${d}</option>
          </#list>
        </select>
      </div>

      <#-- Action buttons -->
      <div class="flex items-center gap-2 pb-0.5">
        <button type="submit"
                class="rounded-md bg-indigo-600 px-4 py-1.5 text-sm font-medium text-white
                       shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2
                       focus:ring-indigo-500 focus:ring-offset-1 transition-colors">
          Apply
        </button>
        <a href="/test-cases"
           class="text-sm text-slate-500 hover:text-slate-800 transition-colors">
          Clear
        </a>
      </div>

    </form>
  </div>

  <#-- =========================================================================
       TEST CASES TABLE
       Columns: TC ID | Scenario | Title | Priority | Status | Module | Date | Bugs
       ========================================================================= -->
  <div class="card overflow-hidden">

    <#if testCases?has_content>

      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead>
            <tr class="bg-slate-50 text-left text-xs font-semibold text-slate-500
                       uppercase tracking-wide border-b border-slate-200">
              <th class="px-4 py-3">TC ID</th>
              <th class="px-4 py-3">Scenario</th>
              <th class="px-4 py-3">Title</th>
              <th class="px-4 py-3 text-center">Priority</th>
              <th class="px-4 py-3 text-center">Status</th>
              <th class="px-4 py-3">Module</th>
              <th class="px-4 py-3">Date</th>
              <th class="px-4 py-3 text-center">Bugs</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">

            <#-- Loop over every test case.
                 "tc" is the current TestCaseView object on each iteration.
                 tc?is_odd_item is true on rows 1, 3, 5 … (1-indexed by FreeMarker)
                 — used here to apply a very subtle alternating row background. -->
            <#list testCases as tc>
              <tr class="hover:bg-indigo-50/40 transition-colors
                         <#if tc?is_odd_item>bg-white<#else>bg-slate-50/50</#if>">

                <#-- TC ID — links to the test case detail page.
                     We pass product/platform/module as query params so the detail
                     controller can find the exact report file without scanning everything. -->
                <td class="px-4 py-3 whitespace-nowrap">
                  <a href="/test-cases/${tc.tcId}?<#if tc.product?has_content>product=${tc.product}&</#if><#if tc.platform?has_content>platform=${tc.platform}&</#if><#if tc.module?has_content>module=${tc.module}</#if>"
                     class="font-mono text-xs font-semibold text-indigo-600
                            hover:text-indigo-800 transition-colors">
                    ${tc.tcId!"—"}
                  </a>
                </td>

                <#-- Scenario — the high-level test scenario label (truncated) -->
                <td class="px-4 py-3 max-w-[9rem]">
                  <span class="block truncate text-xs text-slate-600"
                        title="${tc.scenario!""}">
                    ${tc.scenario!"—"}
                  </span>
                </td>

                <#-- Title — the specific test case name (truncated) -->
                <td class="px-4 py-3 max-w-xs">
                  <span class="block truncate text-slate-800"
                        title="${tc.title!""}">
                    ${tc.title!"—"}
                  </span>
                </td>

                <#-- Priority badge — uses the priorityBadge macro from layout/base.ftlh.
                     Colours: P1=red  P2=orange  P3=yellow  P4=blue -->
                <td class="px-4 py-3 text-center">
                  <#if tc.priority?? && tc.priority?has_content>
                    <@layout.priorityBadge priority=tc.priority />
                  <#else>
                    <span class="text-slate-400 text-xs">—</span>
                  </#if>
                </td>

                <#-- Status badge — uses the statusBadge macro from layout/base.ftlh.
                     Colours: PASS=green  FAIL=red  SKIP=yellow  BLOCKED=orange -->
                <td class="px-4 py-3 text-center">
                  <#if tc.status?? && tc.status?has_content>
                    <@layout.statusBadge status=tc.status />
                  <#else>
                    <span class="text-slate-400 text-xs">—</span>
                  </#if>
                </td>

                <#-- Module chip -->
                <td class="px-4 py-3">
                  <span class="rounded bg-slate-100 px-2 py-0.5 text-xs text-slate-600">
                    ${tc.module!"—"}
                  </span>
                </td>

                <#-- Report date (YYYYMMDD string) -->
                <td class="px-4 py-3 font-mono text-xs text-slate-500 whitespace-nowrap">
                  ${tc.reportDate!"—"}
                </td>

                <#-- Linked bugs count — red badge when any bugs are linked,
                     a dim dash when none.
                     tc.linkedBugs is a List<Bug> initialised to emptyList() in the DTO. -->
                <td class="px-4 py-3 text-center">
                  <#assign bugCount = tc.linkedBugs?size>
                  <#if bugCount gt 0>
                    <span class="inline-flex items-center justify-center rounded-full
                                 bg-red-100 text-red-700 ring-1 ring-inset ring-red-600/20
                                 min-w-[1.5rem] h-6 px-1.5 text-xs font-semibold">
                      ${bugCount}
                    </span>
                  <#else>
                    <span class="text-slate-300 text-xs">—</span>
                  </#if>
                </td>

              </tr>
            </#list>

          </tbody>
        </table>
      </div>

      <#-- Table footer: row count + pass/fail summary -->
      <div class="px-4 py-3 bg-slate-50 border-t border-slate-100 flex items-center
                  justify-between text-xs text-slate-400">
        <span>${totalTcs} test case<#if totalTcs != 1>s</#if> shown</span>
        <span>
          <#if failedTcs gt 0>
            <span class="text-red-500">${failedTcs} failed</span>
          </#if>
          <#if passedTcs gt 0>
            <#if failedTcs gt 0> · </#if>
            <span class="text-green-600">${passedTcs} passed</span>
          </#if>
        </span>
      </div>

    <#else>
      <#-- Empty state — shown when no test cases match the filters -->
      <div class="flex flex-col items-center justify-center py-16 text-slate-400">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 mb-3 text-slate-300"
             fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round"
                d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0
                   00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2
                   2 0 012 2" />
        </svg>
        <p class="text-sm font-medium">No test cases found</p>
        <p class="text-xs mt-1 text-center max-w-xs">
          <#if (selectedProduct?? && selectedProduct?has_content)
            || (selectedPlatform?? && selectedPlatform?has_content)
            || (selectedModule?? && selectedModule?has_content)
            || (selectedDate?? && selectedDate?has_content)>
            No test cases match the active filters. Try clearing one or more filters.
          <#else>
            No JSON report files were found under qa-data/.
            Upload a report to get started.
          </#if>
        </p>
        <div class="flex gap-4 mt-4">
          <a href="/test-cases"
             class="text-xs text-indigo-500 hover:text-indigo-700 transition-colors">
            Clear filters →
          </a>
          <a href="/import"
             class="text-xs text-indigo-500 hover:text-indigo-700 transition-colors">
            Import a report →
          </a>
        </div>
      </div>
    </#if>

  </div>

</@layout.page>
