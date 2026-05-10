<#--
================================================================================
  bugs.ftlh  —  Bug List Page
================================================================================
  MODEL ATTRIBUTES FROM BugController.listBugs():
    bugs             — List<BugView>: bugs matching all active filters (CRITICAL-first)
    products         — List<String>: all product folder names
    platforms        — List<String>: platforms for selected product (empty if none)
    modules          — List<String>: modules for selected product+platform (empty if none)
    dates            — List<String>: unique run dates derived from loaded bugs
    bugStatuses      — List<String>: ["OPEN","IN_PROGRESS","FIXED","CLOSED"]
    bugSeverities    — List<String>: ["CRITICAL","HIGH","MEDIUM","LOW"]
    selectedProduct  — active product filter or null
    selectedPlatform — active platform filter or null
    selectedModule   — active module filter or null
    selectedDate     — active date filter or null
    selectedStatus   — active status filter or null
    selectedSeverity — active severity filter or null

  FREEMARKER FEATURES USED HERE
  ------------------------------
  bug.isOrphan()       — calls BugView.isOrphan(); true when linkedTestCase is null
  bugs?filter(…)       — returns a new sequence filtered by the lambda condition
  bugs?size            — total count of items in the sequence
  b?index              — 0-based row position inside <#list>; used for alternating row shading
  b?is_odd_item        — true on rows 1, 3, 5 … (1-based); easier than ?index % 2
  x!"fallback"         — if x is null, use "fallback" instead (the "!" default operator)
  <#assign x = y>     — creates a local template variable
================================================================================
-->
<#import "/layout/base.ftlh" as layout>

<@layout.page title="Bugs" activeNav="bugs">

  <#-- =========================================================================
       COMPUTE COUNTS ONCE at the top so we can reference them in multiple places.
       <#assign> creates local variables scoped to this template file.
       ========================================================================= -->
  <#assign totalBugs  = bugs?size>
  <#assign openBugs   = bugs?filter(b -> b.status == "OPEN")?size>
  <#assign orphanBugs = bugs?filter(b -> b.isOrphan())?size>

  <#-- Build the export query string once for both download buttons.
       Export only uses product/platform/module/date — status and severity are
       always exported in full (no subset filtering on status/severity for exports).
       Same building pattern used in test-cases.ftlh. -->
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
       PAGE HEADER
       ========================================================================= -->
  <div class="flex flex-wrap items-start justify-between gap-3">
    <div>
      <h1 class="text-xl font-semibold text-slate-900">Bug Reports</h1>
      <p class="text-sm text-slate-500 mt-0.5">
        Showing <span class="font-medium text-slate-700">${totalBugs}</span> bug<#if totalBugs != 1>s</#if>
        <#if openBugs gt 0>
          (<span class="font-medium text-red-600">${openBugs} open</span>)
        <#else>
          (none open)
        </#if>
      </p>
      <#-- Active filter pills — consistent with dashboard.ftlh and test-cases.ftlh -->
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
        <#if selectedStatus?? && selectedStatus?has_content>
          <span class="inline-flex items-center gap-1 rounded-full bg-slate-100 px-3 py-1
                       font-medium text-slate-600 ring-1 ring-inset ring-slate-600/20">
            <span class="text-slate-400">Status:</span> ${selectedStatus}
          </span>
        </#if>
        <#if selectedSeverity?? && selectedSeverity?has_content>
          <span class="inline-flex items-center gap-1 rounded-full bg-slate-100 px-3 py-1
                       font-medium text-slate-600 ring-1 ring-inset ring-slate-600/20">
            <span class="text-slate-400">Severity:</span> ${selectedSeverity}
          </span>
        </#if>
      </div>
    </div>
    <div class="flex items-center gap-2 self-center flex-wrap">
      <#-- CSV Export — downloads bugs as a UTF-8 CSV for spreadsheets.
           Note: the CSV endpoint only exports test cases, so this downloads
           the test cases scoped to the same product/platform/module/date. -->
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
      <#-- JSON Export — downloads both test cases and bugs as JSON -->
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
       ORPHAN WARNING BANNER
       Shown only when at least one bug has no matching test case in its report.
       An "orphan" bug is a data quality problem — the tcId in the bug doesn't
       match any TC in the same JSON file.
       ========================================================================= -->
  <#if orphanBugs gt 0>
    <div class="flex items-start gap-3 rounded-xl border border-amber-300 bg-amber-50 px-4 py-3">
      <svg xmlns="http://www.w3.org/2000/svg"
           class="h-5 w-5 text-amber-500 shrink-0 mt-0.5" fill="none"
           viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round"
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667
                 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34
                 16c-.77 1.333.192 3 1.732 3z" />
      </svg>
      <div>
        <p class="text-sm font-semibold text-amber-800">
          ${orphanBugs} orphan bug<#if orphanBugs != 1>s</#if> detected
        </p>
        <p class="text-xs text-amber-700 mt-0.5">
          <#-- Explain what "orphan" means without jargon -->
          These bugs reference a test case ID that was not found in the same report file.
          This usually means the <code class="font-mono bg-amber-100 px-1 rounded">tc_id</code>
          in the JSON was mistyped or the corresponding test case was removed.
          Orphan rows are marked with <span class="font-bold">⚠</span> in the table below.
        </p>
      </div>
    </div>
  </#if>

  <#-- =========================================================================
       FILTER BAR
       Six filters: Product | Platform | Module | Date | Status | Severity
       Submits as GET so filters are visible in the URL (bookmarkable).
       ========================================================================= -->
  <div class="card p-4">
    <form method="get" action="/bugs" class="flex flex-wrap items-end gap-3">

      <#-- Product -->
      <div class="flex flex-col gap-1 min-w-[9rem]">
        <label for="product" class="text-xs font-medium text-slate-600">Product</label>
        <select id="product" name="product"
                class="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-sm
                       text-slate-700 shadow-sm focus:border-indigo-500 focus:outline-none
                       focus:ring-1 focus:ring-indigo-500">
          <option value="">All Products</option>
          <#list products as p>
            <option value="${p}" <#if selectedProduct?? && selectedProduct == p>selected</#if>>${p}</option>
          </#list>
        </select>
      </div>

      <#-- Platform — disabled until product is chosen -->
      <div class="flex flex-col gap-1 min-w-[9rem]">
        <label for="platform" class="text-xs font-medium text-slate-600">Platform</label>
        <select id="platform" name="platform"
                class="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-sm
                       text-slate-700 shadow-sm focus:border-indigo-500 focus:outline-none
                       focus:ring-1 focus:ring-indigo-500"
                <#if !selectedProduct?? || !selectedProduct?has_content>disabled</#if>>
          <option value=""><#if selectedProduct?? && selectedProduct?has_content>All Platforms<#else>— select product first —</#if></option>
          <#list platforms as p>
            <option value="${p}" <#if selectedPlatform?? && selectedPlatform == p>selected</#if>>${p}</option>
          </#list>
        </select>
      </div>

      <#-- Module — disabled until platform is chosen -->
      <div class="flex flex-col gap-1 min-w-[9rem]">
        <label for="module" class="text-xs font-medium text-slate-600">Module</label>
        <select id="module" name="module"
                class="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-sm
                       text-slate-700 shadow-sm focus:border-indigo-500 focus:outline-none
                       focus:ring-1 focus:ring-indigo-500"
                <#if !selectedPlatform?? || !selectedPlatform?has_content>disabled</#if>>
          <option value=""><#if selectedPlatform?? && selectedPlatform?has_content>All Modules<#else>— select platform first —</#if></option>
          <#list modules as m>
            <option value="${m}" <#if selectedModule?? && selectedModule == m>selected</#if>>${m}</option>
          </#list>
        </select>
      </div>

      <#-- Date -->
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

      <#-- Status (bug lifecycle) -->
      <div class="flex flex-col gap-1 min-w-[9rem]">
        <label for="status" class="text-xs font-medium text-slate-600">Status</label>
        <select id="status" name="status"
                class="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-sm
                       text-slate-700 shadow-sm focus:border-indigo-500 focus:outline-none
                       focus:ring-1 focus:ring-indigo-500">
          <option value="">All Statuses</option>
          <#-- bugStatuses is the hard-coded list ["OPEN","IN_PROGRESS","FIXED","CLOSED"]
               added by the controller. -->
          <#list bugStatuses as s>
            <option value="${s}" <#if selectedStatus?? && selectedStatus == s>selected</#if>>${s}</option>
          </#list>
        </select>
      </div>

      <#-- Severity -->
      <div class="flex flex-col gap-1 min-w-[9rem]">
        <label for="severity" class="text-xs font-medium text-slate-600">Severity</label>
        <select id="severity" name="severity"
                class="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-sm
                       text-slate-700 shadow-sm focus:border-indigo-500 focus:outline-none
                       focus:ring-1 focus:ring-indigo-500">
          <option value="">All Severities</option>
          <#list bugSeverities as sev>
            <option value="${sev}" <#if selectedSeverity?? && selectedSeverity == sev>selected</#if>>${sev}</option>
          </#list>
        </select>
      </div>

      <#-- Buttons -->
      <div class="flex items-center gap-2 pb-0.5">
        <button type="submit"
                class="rounded-md bg-indigo-600 px-4 py-1.5 text-sm font-medium text-white
                       shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2
                       focus:ring-indigo-500 focus:ring-offset-1 transition-colors">
          Apply
        </button>
        <a href="/bugs" class="text-sm text-slate-500 hover:text-slate-800 transition-colors">
          Clear
        </a>
      </div>

    </form>
  </div>

  <#-- =========================================================================
       BUG TABLE
       Columns: Bug ID | Title | TC ID | Severity | Status | Module | Date
       Bugs arrive pre-sorted CRITICAL-first from QaDataService.
       ========================================================================= -->
  <div class="card overflow-hidden">

    <#if bugs?has_content>

      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead>
            <tr class="bg-slate-50 text-left text-xs font-semibold text-slate-500
                       uppercase tracking-wide border-b border-slate-200">
              <th class="px-4 py-3">Bug ID</th>
              <th class="px-4 py-3">Title</th>
              <th class="px-4 py-3">TC ID</th>
              <th class="px-4 py-3 text-center">Severity</th>
              <th class="px-4 py-3 text-center">Status</th>
              <th class="px-4 py-3">Module</th>
              <th class="px-4 py-3">Date</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">

            <#-- Loop over every bug in the list.
                 "b" is the current BugView object on each iteration.
                 b?is_odd_item is true for rows 1, 3, 5 … (1-indexed by FreeMarker)
                 — we use it to give alternating rows a very light background. -->
            <#list bugs as b>
              <tr class="hover:bg-indigo-50/40 transition-colors
                         <#if b?is_odd_item>bg-white<#else>bg-slate-50/50</#if>">

                <#-- Bug ID — links to detail page, passing scope params so the
                     detail page can find the right report file -->
                <td class="px-4 py-3 whitespace-nowrap">
                  <a href="/bugs/${b.bugId}?<#if b.product?has_content>product=${b.product}&</#if><#if b.platform?has_content>platform=${b.platform}&</#if><#if b.module?has_content>module=${b.module}</#if>"
                     class="font-mono text-xs font-semibold text-indigo-600
                            hover:text-indigo-800 transition-colors">
                    ${b.bugId}
                  </a>
                </td>

                <#-- Title — truncated with CSS, full text on hover via title attribute -->
                <td class="px-4 py-3 max-w-xs">
                  <span class="block truncate text-slate-800" title="${b.title!""}">
                    ${b.title!"—"}
                  </span>
                </td>

                <#-- TC ID column — shows a link when the test case was found,
                     or an orphan warning when it wasn't.
                     b.isOrphan() calls the isOrphan() method on BugView.
                     In FreeMarker, method calls look the same as property access:
                       b.isOrphan()  is identical to  b.orphan  -->
                <td class="px-4 py-3 whitespace-nowrap">
                  <#if b.isOrphan()>
                    <#-- ⚠ icon + raw tcId shown in amber when orphaned -->
                    <span class="inline-flex items-center gap-1 text-amber-600 font-mono text-xs"
                          title="No matching test case found for this TC ID">
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5 shrink-0"
                           fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                        <path stroke-linecap="round" stroke-linejoin="round"
                              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667
                                 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34
                                 16c-.77 1.333.192 3 1.732 3z" />
                      </svg>
                      ${b.tcId!"—"}
                    </span>
                  <#else>
                    <#-- Normal case: TC found — link to the test case detail page -->
                    <a href="/test-cases/${b.tcId}?<#if b.product?has_content>product=${b.product}&</#if><#if b.platform?has_content>platform=${b.platform}&</#if><#if b.module?has_content>module=${b.module}</#if>"
                       class="font-mono text-xs text-indigo-500 hover:text-indigo-700
                              transition-colors">
                      ${b.tcId!"—"}
                    </a>
                  </#if>
                </td>

                <#-- Severity badge — calls the macro from layout/base.ftlh.
                     <@layout.severityBadge severity=b.severity /> is a macro call
                     where "severity" is the parameter name and b.severity is its value. -->
                <td class="px-4 py-3 text-center">
                  <#if b.severity?? && b.severity?has_content>
                    <@layout.severityBadge severity=b.severity />
                  <#else>
                    <span class="text-slate-400 text-xs">—</span>
                  </#if>
                </td>

                <#-- Bug status badge -->
                <td class="px-4 py-3 text-center">
                  <#if b.status?? && b.status?has_content>
                    <@layout.bugStatusBadge status=b.status />
                  <#else>
                    <span class="text-slate-400 text-xs">—</span>
                  </#if>
                </td>

                <#-- Module -->
                <td class="px-4 py-3">
                  <span class="rounded bg-slate-100 px-2 py-0.5 text-xs text-slate-600">
                    ${b.module!"—"}
                  </span>
                </td>

                <#-- Report date -->
                <td class="px-4 py-3 font-mono text-xs text-slate-500 whitespace-nowrap">
                  ${b.reportDate!"—"}
                </td>

              </tr>
            </#list>

          </tbody>
        </table>
      </div>

      <#-- Table footer: total count + filter hint -->
      <div class="px-4 py-3 bg-slate-50 border-t border-slate-100 flex items-center
                  justify-between text-xs text-slate-400">
        <span>${totalBugs} bug<#if totalBugs != 1>s</#if> shown</span>
        <#if orphanBugs gt 0>
          <span class="text-amber-500">${orphanBugs} orphan<#if orphanBugs != 1>s</#if></span>
        </#if>
      </div>

    <#else>
      <#-- Empty state — shown when no bugs match the filters or the folder is empty -->
      <div class="flex flex-col items-center justify-center py-16 text-slate-400">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 mb-3 text-slate-300"
             fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round"
                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <p class="text-sm font-medium">No bugs found</p>
        <p class="text-xs mt-1 text-center max-w-xs">
          <#if (selectedStatus?? && selectedStatus?has_content)
            || (selectedSeverity?? && selectedSeverity?has_content)
            || (selectedProduct?? && selectedProduct?has_content)>
            No bugs match the active filters. Try clearing one or more filters.
          <#else>
            No bug report files were found. Upload a JSON report to get started.
          </#if>
        </p>
        <div class="flex gap-4 mt-4">
          <a href="/bugs" class="text-xs text-indigo-500 hover:text-indigo-700 transition-colors">
            Clear filters →
          </a>
          <a href="/import" class="text-xs text-indigo-500 hover:text-indigo-700 transition-colors">
            Import a report →
          </a>
        </div>
      </div>
    </#if>

  </div>

</@layout.page>
