<#--
================================================================================
  bug-detail.ftlh  —  Single Bug Detail Page
================================================================================
  MODEL ATTRIBUTES FROM BugController.bugDetail():
    bug  — one BugView object containing:
             bugId, tcId, title, description, steps, expected, actual,
             severity, status, notes
             product, platform, module, reportDate  (from meta)
             linkedTestCase  — the TestCase object, or null if orphan
           helper methods:
             bug.isOrphan()  — true when linkedTestCase is null
             bug.isOpen()    — true when status == "OPEN"

  FREEMARKER PATTERNS USED HERE
  ------------------------------
  bug.linkedTestCase??           — ?? is null-safe check: true when not null
  bug.linkedTestCase.title       — access nested property (only after null check)
  <#list bug.steps as step>      — loop over a List<String>
  step?counter                   — 1-based position in the current loop (used for numbering)
  bug.notes?has_content          — true when notes is not null AND not an empty string
  (condition)?then("yes","no")   — FreeMarker ternary: pick between two values
================================================================================
-->
<#import "/layout/base.ftlh" as layout>

<@layout.page title="Bug Detail" activeNav="bugs">

  <#-- =========================================================================
       BREADCRUMB NAVIGATION
       Gives the user a sense of where they are in the data hierarchy.
       Each level is a clickable link that applies that filter.
       ========================================================================= -->
  <nav class="flex items-center gap-1.5 text-xs text-slate-500 flex-wrap">
    <a href="/bugs" class="hover:text-indigo-600 transition-colors">Bugs</a>
    <#if bug.product?? && bug.product?has_content>
      <span class="text-slate-300">/</span>
      <a href="/bugs?product=${bug.product}"
         class="hover:text-indigo-600 transition-colors">${bug.product}</a>
    </#if>
    <#if bug.platform?? && bug.platform?has_content>
      <span class="text-slate-300">/</span>
      <a href="/bugs?<#if bug.product?has_content>product=${bug.product}&</#if>platform=${bug.platform}"
         class="hover:text-indigo-600 transition-colors">${bug.platform}</a>
    </#if>
    <#if bug.module?? && bug.module?has_content>
      <span class="text-slate-300">/</span>
      <a href="/bugs?<#if bug.product?has_content>product=${bug.product}&</#if><#if bug.platform?has_content>platform=${bug.platform}&</#if>module=${bug.module}"
         class="hover:text-indigo-600 transition-colors">${bug.module}</a>
    </#if>
    <span class="text-slate-300">/</span>
    <span class="font-mono font-semibold text-slate-700">${bug.bugId}</span>
  </nav>

  <#-- =========================================================================
       HEADER CARD: Bug ID, Title, and status/severity badges
       ========================================================================= -->
  <div class="card p-5">
    <div class="flex flex-wrap items-start justify-between gap-4">

      <div class="min-w-0 flex-1">
        <div class="flex items-center gap-2 flex-wrap mb-1">
          <#-- Bug ID in monospace — visually distinct from the title -->
          <span class="font-mono text-xs font-bold text-slate-400 bg-slate-100
                       px-2 py-0.5 rounded">${bug.bugId}</span>
          <#-- Severity badge using macro from base.ftlh -->
          <#if bug.severity?? && bug.severity?has_content>
            <@layout.severityBadge severity=bug.severity />
          </#if>
          <#-- Bug lifecycle status badge -->
          <#if bug.status?? && bug.status?has_content>
            <@layout.bugStatusBadge status=bug.status />
          </#if>
          <#-- Orphan indicator in the header itself -->
          <#if bug.isOrphan()>
            <span class="inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs
                         font-medium bg-amber-100 text-amber-800 ring-1 ring-inset ring-amber-600/20">
              ⚠ Orphan
            </span>
          </#if>
        </div>

        <h1 class="text-lg font-semibold text-slate-900 leading-snug mt-2">
          ${bug.title!"(no title)"}
        </h1>
      </div>

    </div>
  </div>

  <#-- =========================================================================
       TWO-COLUMN LAYOUT for the rest of the page content:
         left column  (2/3 width) — description, steps, expected/actual, notes
         right column (1/3 width) — metadata grid and linked TC card
       ========================================================================= -->
  <div class="flex flex-col lg:flex-row gap-6 items-start">

    <#-- -----------------------------------------------------------------------
         LEFT COLUMN
         ----------------------------------------------------------------------- -->
    <div class="flex-1 min-w-0 space-y-5">

      <#-- Description -->
      <#if bug.description?? && bug.description?has_content>
        <div class="card p-5">
          <h2 class="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-3">
            Description
          </h2>
          <p class="text-sm text-slate-700 leading-relaxed">${bug.description}</p>
        </div>
      </#if>

      <#-- Steps to Reproduce — numbered list -->
      <div class="card p-5">
        <h2 class="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-3">
          Steps to Reproduce
        </h2>
        <#if bug.steps?? && bug.steps?has_content>
          <ol class="space-y-2">
            <#-- <#list seq as item> loops over every element in the steps List<String>.
                 step?counter gives the 1-based iteration number (1, 2, 3, …).
                 This is more natural for numbered steps than step?index (which is 0-based). -->
            <#list bug.steps as step>
              <li class="flex items-start gap-3 text-sm text-slate-700">
                <span class="flex h-5 w-5 shrink-0 items-center justify-center rounded-full
                             bg-indigo-100 text-xs font-semibold text-indigo-700 mt-0.5">
                  ${step?counter}
                </span>
                <span class="leading-snug">${step}</span>
              </li>
            </#list>
          </ol>
        <#else>
          <p class="text-sm text-slate-400 italic">No reproduction steps provided.</p>
        </#if>
      </div>

      <#-- Expected vs Actual — side-by-side comparison -->
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">

        <#-- Expected behaviour (green-tinted = "the good state") -->
        <div class="card p-4 border-l-4 border-green-400">
          <h3 class="text-xs font-semibold uppercase tracking-wider text-green-600 mb-2
                     flex items-center gap-1.5">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none"
                 viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
            </svg>
            Expected
          </h3>
          <p class="text-sm text-slate-700 leading-relaxed">
            ${bug.expected!"Not specified."}
          </p>
        </div>

        <#-- Actual behaviour (red-tinted = "the broken state") -->
        <div class="card p-4 border-l-4 border-red-400">
          <h3 class="text-xs font-semibold uppercase tracking-wider text-red-600 mb-2
                     flex items-center gap-1.5">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none"
                 viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
              <path stroke-linecap="round" stroke-linejoin="round"
                    d="M6 18L18 6M6 6l12 12" />
            </svg>
            Actual
          </h3>
          <p class="text-sm text-slate-700 leading-relaxed">
            ${bug.actual!"Not specified."}
          </p>
        </div>

      </div>

      <#-- Notes section — only rendered when notes is not null and not empty.
           ?has_content checks both conditions at once, so we never show an empty card. -->
      <#if bug.notes?? && bug.notes?has_content>
        <div class="card p-5">
          <h2 class="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-3
                     flex items-center gap-1.5">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5 text-slate-400"
                 fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round"
                    d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0
                       012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z" />
            </svg>
            Tester Notes
          </h2>
          <p class="text-sm text-slate-700 leading-relaxed italic">${bug.notes}</p>
        </div>
      </#if>

    </div>

    <#-- -----------------------------------------------------------------------
         RIGHT COLUMN — metadata + linked test case
         ----------------------------------------------------------------------- -->
    <div class="w-full lg:w-72 shrink-0 space-y-5">

      <#-- INFO GRID: key/value pairs about where and when this bug was found -->
      <div class="card p-5">
        <h2 class="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-4">
          Bug Info
        </h2>
        <dl class="space-y-3 text-sm">

          <div class="flex justify-between gap-2">
            <dt class="text-slate-500 shrink-0">Module</dt>
            <dd class="font-medium text-slate-800 text-right truncate">${bug.module!"—"}</dd>
          </div>

          <div class="flex justify-between gap-2">
            <dt class="text-slate-500 shrink-0">Platform</dt>
            <dd class="font-medium text-slate-800 text-right">${bug.platform!"—"}</dd>
          </div>

          <div class="flex justify-between gap-2">
            <dt class="text-slate-500 shrink-0">Product</dt>
            <dd class="font-medium text-slate-800 text-right truncate">${bug.product!"—"}</dd>
          </div>

          <div class="flex justify-between gap-2 border-t border-slate-100 pt-3">
            <dt class="text-slate-500 shrink-0">Run Date</dt>
            <dd class="font-mono text-slate-700 text-right">${bug.reportDate!"—"}</dd>
          </div>

          <div class="flex justify-between gap-2">
            <dt class="text-slate-500 shrink-0">Severity</dt>
            <dd class="text-right">
              <#if bug.severity?? && bug.severity?has_content>
                <@layout.severityBadge severity=bug.severity />
              <#else>
                <span class="text-slate-400">—</span>
              </#if>
            </dd>
          </div>

          <div class="flex justify-between gap-2">
            <dt class="text-slate-500 shrink-0">Status</dt>
            <dd class="text-right">
              <#if bug.status?? && bug.status?has_content>
                <@layout.bugStatusBadge status=bug.status />
              <#else>
                <span class="text-slate-400">—</span>
              </#if>
            </dd>
          </div>

        </dl>
      </div>

      <#-- =====================================================================
           LINKED TEST CASE SECTION
           Two possible states:
             1. Orphan: bug.tcId doesn't match any TC → show a warning
             2. Found:  bug.linkedTestCase is set → show a clickable TC card

           bug.isOrphan() returns true when linkedTestCase == null.
           bug.linkedTestCase?? is the FreeMarker null-check on the Java object.
           Both checks are equivalent here; we use isOrphan() for readability.
           ===================================================================== -->
      <div class="card p-5">
        <h2 class="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-3
                   flex items-center gap-1.5">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none"
               viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656
                     5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0
                     00-5.656-5.656l-1.1 1.1" />
          </svg>
          Linked Test Case
        </h2>

        <#if bug.isOrphan()>

          <#-- ORPHAN STATE: No matching test case -->
          <div class="rounded-lg border border-amber-200 bg-amber-50 p-3">
            <div class="flex items-start gap-2">
              <svg xmlns="http://www.w3.org/2000/svg"
                   class="h-4 w-4 text-amber-500 shrink-0 mt-0.5" fill="none"
                   viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round"
                      d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667
                         1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34
                         16c-.77 1.333.192 3 1.732 3z" />
              </svg>
              <div>
                <p class="text-xs font-semibold text-amber-800">No matching test case found</p>
                <#-- Show what TC ID the bug was looking for, using the "!" default operator
                     in case tcId is somehow null: bug.tcId!"(none)" -->
                <p class="text-xs text-amber-700 mt-1">
                  Looking for TC ID:
                  <code class="font-mono bg-amber-100 px-1 rounded">${bug.tcId!"(none)"}</code>
                </p>
                <p class="text-xs text-amber-600 mt-1">
                  This test case ID was not found in the same report file.
                  Check that the <code class="font-mono bg-amber-100 px-1 rounded">tc_id</code>
                  in the JSON is correct.
                </p>
              </div>
            </div>
          </div>

        <#else>

          <#-- FOUND STATE: Linked test case exists — show a clickable card.
               bug.linkedTestCase is the TestCase model object (not a DTO).
               We access its fields directly: linkedTestCase.tcId, .title, .status -->
          <a href="/test-cases/${bug.linkedTestCase.tcId}?<#if bug.product?has_content>product=${bug.product}&</#if><#if bug.platform?has_content>platform=${bug.platform}&</#if><#if bug.module?has_content>module=${bug.module}</#if>"
             class="block rounded-lg border border-slate-200 bg-slate-50 p-3
                    hover:border-indigo-300 hover:bg-indigo-50 transition-all group">

            <div class="flex items-start justify-between gap-2 mb-2">
              <span class="font-mono text-xs font-bold text-indigo-600
                           group-hover:text-indigo-800 transition-colors">
                ${bug.linkedTestCase.tcId}
              </span>
              <#-- Status badge for the linked test case — uses statusBadge (PASS/FAIL/SKIP) -->
              <#if bug.linkedTestCase.status?? && bug.linkedTestCase.status?has_content>
                <@layout.statusBadge status=bug.linkedTestCase.status />
              </#if>
            </div>

            <p class="text-xs text-slate-700 leading-snug line-clamp-2">
              ${bug.linkedTestCase.title!"(no title)"}
            </p>

            <#if bug.linkedTestCase.scenario?? && bug.linkedTestCase.scenario?has_content>
              <p class="text-xs text-slate-400 mt-2">
                ${bug.linkedTestCase.scenario}
              </p>
            </#if>

            <p class="text-xs text-indigo-400 group-hover:text-indigo-600 mt-2
                      transition-colors text-right">
              View test case →
            </p>

          </a>

        </#if>

      </div>

      <#-- BACK BUTTON -->
      <a href="/bugs<#if bug.product?has_content>?product=${bug.product}<#if bug.platform?has_content>&platform=${bug.platform}</#if></#if>"
         class="flex items-center gap-2 text-sm text-slate-500 hover:text-slate-800
                transition-colors">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none"
             viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round"
                d="M10 19l-7-7m0 0l7-7m-7 7h18" />
        </svg>
        Back to bugs list
      </a>

    </div>
    <#-- end right column -->

  </div>
  <#-- end two-column layout -->

</@layout.page>
