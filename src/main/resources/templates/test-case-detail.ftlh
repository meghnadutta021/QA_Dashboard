<#--
================================================================================
  test-case-detail.ftlh  —  Single Test Case Detail Page
================================================================================
  MODEL ATTRIBUTES FROM TestCaseController.testCaseDetail():
    testCase  — one TestCaseView object containing:
                  tcId, scenario, title, precondition
                  steps        — List<String> (may be empty)
                  expected, actual, priority, status, notes
                  product, platform, module, reportDate  (from report meta)
                  linkedBugs   — List<Bug> raw model, always non-null (may be empty)
                helper methods:
                  testCase.hasLinkedBugs()  — true when linkedBugs is not empty
                  testCase.isFailure()      — true when status == "FAIL"

  FREEMARKER NOTES
  ----------------
  testCase.linkedBugs?has_content    — checks list is non-null AND non-empty
  testCase.linkedBugs?size           — number of items in the linked-bugs list
  step?counter                       — 1-based loop position (used for step numbers)
  bug.bugId, bug.title, bug.severity, bug.status  — fields on the raw Bug model
  <#if (x >= y)>                     — parentheses required so > isn't parsed as
                                       the FreeMarker directive-close character
================================================================================
-->
<#import "/layout/base.ftlh" as layout>

<@layout.page title="${testCase.tcId} — Test Case" activeNav="testcases">

  <#-- =========================================================================
       BREADCRUMB NAVIGATION
       Each level links to the test-cases list with that filter pre-applied,
       so the user can quickly scope the list to the same product/module.
       ========================================================================= -->
  <nav class="flex items-center gap-1.5 text-xs text-slate-500 flex-wrap">
    <a href="/test-cases" class="hover:text-indigo-600 transition-colors">Test Cases</a>
    <#if testCase.product?? && testCase.product?has_content>
      <span class="text-slate-300">/</span>
      <a href="/test-cases?product=${testCase.product}"
         class="hover:text-indigo-600 transition-colors">${testCase.product}</a>
    </#if>
    <#if testCase.platform?? && testCase.platform?has_content>
      <span class="text-slate-300">/</span>
      <a href="/test-cases?<#if testCase.product?has_content>product=${testCase.product}&</#if>platform=${testCase.platform}"
         class="hover:text-indigo-600 transition-colors">${testCase.platform}</a>
    </#if>
    <#if testCase.module?? && testCase.module?has_content>
      <span class="text-slate-300">/</span>
      <a href="/test-cases?<#if testCase.product?has_content>product=${testCase.product}&</#if><#if testCase.platform?has_content>platform=${testCase.platform}&</#if>module=${testCase.module}"
         class="hover:text-indigo-600 transition-colors">${testCase.module}</a>
    </#if>
    <span class="text-slate-300">/</span>
    <span class="font-mono font-semibold text-slate-700">${testCase.tcId}</span>
  </nav>

  <#-- =========================================================================
       HEADER CARD
       Shows the TC ID chip, priority badge, status badge, and the title.
       The scenario (if present) appears as a muted subtitle under the title.
       ========================================================================= -->
  <div class="card p-5">
    <div class="flex flex-wrap items-start justify-between gap-4">
      <div class="min-w-0 flex-1">

        <div class="flex items-center gap-2 flex-wrap mb-1">
          <#-- TC ID — monospace chip, visually distinct from the title -->
          <span class="font-mono text-xs font-bold text-slate-400 bg-slate-100
                       px-2 py-0.5 rounded">${testCase.tcId}</span>
          <#-- Priority badge: P1/P2/P3/P4 coloured pill -->
          <#if testCase.priority?? && testCase.priority?has_content>
            <@layout.priorityBadge priority=testCase.priority />
          </#if>
          <#-- Status badge: PASS / FAIL / SKIP / BLOCKED -->
          <#if testCase.status?? && testCase.status?has_content>
            <@layout.statusBadge status=testCase.status />
          </#if>
        </div>

        <h1 class="text-lg font-semibold text-slate-900 leading-snug mt-2">
          ${testCase.title!"(no title)"}
        </h1>

        <#-- Scenario is the broad feature area this TC belongs to, e.g. "Login Flow" -->
        <#if testCase.scenario?? && testCase.scenario?has_content>
          <p class="text-sm text-slate-500 mt-1">${testCase.scenario}</p>
        </#if>

      </div>
    </div>
  </div>

  <#-- =========================================================================
       TWO-COLUMN LAYOUT
         Left  (flex-1)  — steps, expected vs actual, tester notes
         Right (w-72)    — info grid, linked bugs, back button
       ========================================================================= -->
  <div class="flex flex-col lg:flex-row gap-6 items-start">

    <#-- -----------------------------------------------------------------------
         LEFT COLUMN
         ----------------------------------------------------------------------- -->
    <div class="flex-1 min-w-0 space-y-5">

      <#-- ==================================================================
           TEST STEPS
           Numbered list of actions the tester performs.
           step?counter gives the 1-based position in the loop.
           ================================================================== -->
      <div class="card p-5">
        <h2 class="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-3">
          Test Steps
        </h2>
        <#if testCase.steps?? && testCase.steps?has_content>
          <ol class="space-y-2">
            <#list testCase.steps as step>
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
          <p class="text-sm text-slate-400 italic">No steps provided.</p>
        </#if>
      </div>

      <#-- ==================================================================
           EXPECTED vs ACTUAL
           Side-by-side panels.
           Expected is always green (the desired state).
           Actual border/label colour is red when FAIL, green when PASS/SKIP.
           ================================================================== -->
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">

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
            ${testCase.expected!"Not specified."}
          </p>
        </div>

        <#-- The Actual panel is red when the test failed, green otherwise -->
        <#assign actualBorder = testCase.isFailure()?then("border-red-400",  "border-green-400")>
        <#assign actualLabel  = testCase.isFailure()?then("text-red-600",    "text-green-600")>
        <div class="card p-4 border-l-4 ${actualBorder}">
          <h3 class="text-xs font-semibold uppercase tracking-wider ${actualLabel} mb-2
                     flex items-center gap-1.5">
            <#if testCase.isFailure()>
              <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none"
                   viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                <path stroke-linecap="round" stroke-linejoin="round"
                      d="M6 18L18 6M6 6l12 12" />
              </svg>
            <#else>
              <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none"
                   viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
              </svg>
            </#if>
            Actual
          </h3>
          <p class="text-sm text-slate-700 leading-relaxed">
            ${testCase.actual!"Not specified."}
          </p>
        </div>

      </div>

      <#-- ==================================================================
           TESTER NOTES — only shown when the notes field has content
           ================================================================== -->
      <#if testCase.notes?? && testCase.notes?has_content>
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
          <p class="text-sm text-slate-700 leading-relaxed italic">${testCase.notes}</p>
        </div>
      </#if>

    </div>
    <#-- end left column -->

    <#-- -----------------------------------------------------------------------
         RIGHT COLUMN
         ----------------------------------------------------------------------- -->
    <div class="w-full lg:w-72 shrink-0 space-y-5">

      <#-- ==================================================================
           INFO GRID
           Key/value pairs summarising where and when this TC was run.
           ================================================================== -->
      <div class="card p-5">
        <h2 class="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-4">
          Test Case Info
        </h2>
        <dl class="space-y-3 text-sm">

          <div class="flex justify-between gap-2">
            <dt class="text-slate-500 shrink-0">Module</dt>
            <dd class="font-medium text-slate-800 text-right truncate">
              ${testCase.module!"—"}
            </dd>
          </div>

          <div class="flex justify-between gap-2">
            <dt class="text-slate-500 shrink-0">Platform</dt>
            <dd class="font-medium text-slate-800 text-right">${testCase.platform!"—"}</dd>
          </div>

          <div class="flex justify-between gap-2">
            <dt class="text-slate-500 shrink-0">Product</dt>
            <dd class="font-medium text-slate-800 text-right truncate">
              ${testCase.product!"—"}
            </dd>
          </div>

          <#-- Precondition is only shown when it has a value -->
          <#if testCase.precondition?? && testCase.precondition?has_content>
            <div class="flex justify-between gap-2 border-t border-slate-100 pt-3">
              <dt class="text-slate-500 shrink-0">Precondition</dt>
              <dd class="text-slate-700 text-right text-xs leading-snug">
                ${testCase.precondition}
              </dd>
            </div>
          </#if>

          <div class="flex justify-between gap-2 border-t border-slate-100 pt-3">
            <dt class="text-slate-500 shrink-0">Run Date</dt>
            <dd class="font-mono text-slate-700 text-right">${testCase.reportDate!"—"}</dd>
          </div>

          <div class="flex justify-between gap-2">
            <dt class="text-slate-500 shrink-0">Priority</dt>
            <dd class="text-right">
              <#if testCase.priority?? && testCase.priority?has_content>
                <@layout.priorityBadge priority=testCase.priority />
              <#else>
                <span class="text-slate-400">—</span>
              </#if>
            </dd>
          </div>

          <div class="flex justify-between gap-2">
            <dt class="text-slate-500 shrink-0">Status</dt>
            <dd class="text-right">
              <#if testCase.status?? && testCase.status?has_content>
                <@layout.statusBadge status=testCase.status />
              <#else>
                <span class="text-slate-400">—</span>
              </#if>
            </dd>
          </div>

        </dl>
      </div>

      <#-- ==================================================================
           LINKED BUGS
           testCase.linkedBugs is a List<Bug> (the raw Bug model, not BugView).
           Bug fields: bugId, title, severity, status.
           Each card links to the bug detail page with context filters.
           ================================================================== -->
      <div class="card p-5">
        <h2 class="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-3
                   flex items-center gap-1.5">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none"
               viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          Linked Bugs
          <#-- Bug count badge — only shown when there are bugs to count -->
          <#if testCase.linkedBugs?has_content>
            <span class="ml-auto inline-flex items-center justify-center h-4 min-w-[1rem]
                         rounded-full bg-red-100 text-xs font-bold text-red-700 px-1">
              ${testCase.linkedBugs?size}
            </span>
          </#if>
        </h2>

        <#if testCase.linkedBugs?has_content>

          <div class="space-y-2">
            <#list testCase.linkedBugs as bug>
              <#-- Each bug is a clickable card linking to its detail page.
                   We pass product/platform/module so BugController can narrow
                   the report search scope. -->
              <a href="/bugs/${bug.bugId}?<#if testCase.product?has_content>product=${testCase.product}&</#if><#if testCase.platform?has_content>platform=${testCase.platform}&</#if><#if testCase.module?has_content>module=${testCase.module}</#if>"
                 class="block rounded-lg border border-slate-200 bg-slate-50 p-3
                        hover:border-red-300 hover:bg-red-50 transition-all group">

                <div class="flex items-start justify-between gap-2 mb-1">
                  <span class="font-mono text-xs font-bold text-red-600
                               group-hover:text-red-800 transition-colors">
                    ${bug.bugId!"—"}
                  </span>
                  <#if bug.severity?? && bug.severity?has_content>
                    <@layout.severityBadge severity=bug.severity />
                  </#if>
                </div>

                <p class="text-xs text-slate-700 leading-snug line-clamp-2">
                  ${bug.title!"(no title)"}
                </p>

                <#if bug.status?? && bug.status?has_content>
                  <div class="mt-2">
                    <@layout.bugStatusBadge status=bug.status />
                  </div>
                </#if>

                <p class="text-xs text-red-400 group-hover:text-red-600 mt-2
                          transition-colors text-right">
                  View bug →
                </p>

              </a>
            </#list>
          </div>

        <#else>

          <#-- No linked bugs — green success state -->
          <div class="flex items-center gap-2 rounded-lg border border-green-200
                      bg-green-50 p-3">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-green-500 shrink-0"
                 fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round"
                    d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <p class="text-xs font-medium text-green-700">No bugs linked to this test case.</p>
          </div>

        </#if>

      </div>

      <#-- BACK BUTTON — returns to the test-cases list with product filter preserved -->
      <a href="/test-cases<#if testCase.product?has_content>?product=${testCase.product}<#if testCase.platform?has_content>&platform=${testCase.platform}</#if></#if>"
         class="flex items-center gap-2 text-sm text-slate-500 hover:text-slate-800
                transition-colors">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none"
             viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round"
                d="M10 19l-7-7m0 0l7-7m-7 7h18" />
        </svg>
        Back to test cases
      </a>

    </div>
    <#-- end right column -->

  </div>
  <#-- end two-column layout -->

</@layout.page>
