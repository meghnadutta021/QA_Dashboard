<#--
================================================================================
  layout/base.ftlh  —  Master Layout Template
================================================================================

  WHAT IS A LAYOUT TEMPLATE?
  ---------------------------
  Every page on the dashboard (overview, test cases, bugs) shares the same
  outer shell: the same <head>, the same navigation bar, the same sidebar,
  the same footer. Without a layout template you would copy that shell into
  every .ftlh file. Then if you want to change the nav bar, you have to edit
  six files. One typo = one broken page. This approach is called "copy-paste
  inheritance" and it is considered a bad practice in web development.

  A layout template solves this by writing the shared shell ONCE here and
  letting each page "inject" only its unique content into a designated slot.
  Change the nav bar in one place → all pages update instantly.

  HOW IT WORKS IN FREEMARKER
  --------------------------
  FreeMarker uses a feature called "macros" to achieve layouts.

  A macro is like a reusable HTML function:
    <#macro myMacro>
      <p>some html</p>
    </#macro>

    <@myMacro />          ← calling the macro renders its HTML

  A macro can also declare a <#nested> slot — a placeholder where the
  CALLER'S content gets injected:
    <#macro myMacro>
      <div class="wrapper">
        <#nested>         ← content between <@myMacro>...</@myMacro> goes here
      </div>
    </#macro>

    <@myMacro>
      <p>I am injected!</p>
    </@myMacro>

    Renders as:
      <div class="wrapper">
        <p>I am injected!</p>
      </div>

  HOW PAGES USE THIS FILE
  -----------------------
  Each page template (dashboard.ftlh, test-cases.ftlh, etc.) does this:

    <#import "/layout/base.ftlh" as layout>   ← import this file under the alias "layout"

    <@layout.page title="Overview" activeNav="overview">
      <p>This content appears inside the main area.</p>
    </@layout.page>

  That is the ENTIRE content of each page file. The nav, sidebar, and footer
  come from here; the page only writes what is unique to it.

  FREEMARKER SYNTAX QUICK REFERENCE (used in this file)
  -------------------------------------------------------
  ${someVariable}            → outputs the value of a variable from the model
  <#if condition>...</#if>   → conditional block
  <#list items as item>      → loop over a collection
  ??                         → null-check: "someVar??" is true when someVar is not null
  ?has_content               → true when a string/list is not null AND not empty
  ==                         → equality check
  <#nested>                  → slot for caller's content (inside a macro)
  <#macro name params>       → define a reusable block

================================================================================
-->

<#-- ============================================================
     MACRO: statusBadge
     ============================================================
     Renders a coloured pill badge for a test case status value.
     Usage:  <@layout.statusBadge status="PASS" />

     Parameters:
       status  — the status string, e.g. "PASS", "FAIL", "SKIP", "BLOCKED"
     ============================================================ -->
<#macro statusBadge status>
  <#-- Choose a Tailwind colour class based on the status string. -->
  <#-- <#assign> creates a local variable inside the macro.        -->
  <#if status == "PASS">
    <#assign badgeClass = "bg-green-100 text-green-800 ring-green-600/20">
  <#elseif status == "FAIL">
    <#assign badgeClass = "bg-red-100 text-red-800 ring-red-600/20">
  <#elseif status == "SKIP">
    <#assign badgeClass = "bg-yellow-100 text-yellow-800 ring-yellow-600/20">
  <#elseif status == "BLOCKED">
    <#assign badgeClass = "bg-orange-100 text-orange-800 ring-orange-600/20">
  <#else>
    <#assign badgeClass = "bg-slate-100 text-slate-700 ring-slate-600/20">
  </#if>
  <span class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ring-1 ring-inset ${badgeClass}">
    ${status}
  </span>
</#macro>

<#-- ============================================================
     MACRO: severityBadge
     ============================================================
     Renders a coloured pill badge for a bug severity value.
     Usage:  <@layout.severityBadge severity="CRITICAL" />
     ============================================================ -->
<#macro severityBadge severity>
  <#if severity == "CRITICAL">
    <#assign badgeClass = "bg-red-100 text-red-800 ring-red-600/20">
  <#elseif severity == "HIGH">
    <#assign badgeClass = "bg-orange-100 text-orange-800 ring-orange-600/20">
  <#elseif severity == "MEDIUM">
    <#assign badgeClass = "bg-yellow-100 text-yellow-800 ring-yellow-600/20">
  <#elseif severity == "LOW">
    <#assign badgeClass = "bg-blue-100 text-blue-800 ring-blue-600/20">
  <#else>
    <#assign badgeClass = "bg-slate-100 text-slate-700 ring-slate-600/20">
  </#if>
  <span class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ring-1 ring-inset ${badgeClass}">
    ${severity}
  </span>
</#macro>

<#-- ============================================================
     MACRO: bugStatusBadge
     ============================================================
     Renders a coloured pill badge for a bug lifecycle status.
     Usage:  <@layout.bugStatusBadge status="OPEN" />
     ============================================================ -->
<#macro bugStatusBadge status>
  <#if status == "OPEN">
    <#assign badgeClass = "bg-red-100 text-red-800 ring-red-600/20">
  <#elseif status == "IN_PROGRESS">
    <#assign badgeClass = "bg-yellow-100 text-yellow-800 ring-yellow-600/20">
  <#elseif status == "FIXED" || status == "RESOLVED" || status == "CLOSED">
    <#assign badgeClass = "bg-green-100 text-green-800 ring-green-600/20">
  <#else>
    <#assign badgeClass = "bg-slate-100 text-slate-700 ring-slate-600/20">
  </#if>
  <span class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ring-1 ring-inset ${badgeClass}">
    ${status}
  </span>
</#macro>

<#-- ============================================================
     MACRO: priorityBadge
     ============================================================
     Renders a coloured pill badge for a test case priority value.
     Usage:  <@layout.priorityBadge priority="P1" />

     Common priority levels used in QA:
       P1 — Critical / must fix before release
       P2 — High / should fix in this sprint
       P3 — Medium / schedule for next release
       P4 — Low / nice to have / cosmetic
     ============================================================ -->
<#macro priorityBadge priority>
  <#if priority == "P1">
    <#assign badgeClass = "bg-red-100 text-red-800 ring-red-600/20">
  <#elseif priority == "P2">
    <#assign badgeClass = "bg-orange-100 text-orange-800 ring-orange-600/20">
  <#elseif priority == "P3">
    <#assign badgeClass = "bg-yellow-100 text-yellow-800 ring-yellow-600/20">
  <#elseif priority == "P4">
    <#assign badgeClass = "bg-blue-100 text-blue-800 ring-blue-600/20">
  <#else>
    <#assign badgeClass = "bg-slate-100 text-slate-700 ring-slate-600/20">
  </#if>
  <span class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ring-1 ring-inset ${badgeClass}">
    ${priority}
  </span>
</#macro>

<#-- ============================================================
     MACRO: page   ← THE MAIN LAYOUT MACRO
     ============================================================
     Wraps page content in the full HTML shell.

     Parameters:
       title      — goes in the browser <title> tag, e.g. "Overview"
       activeNav  — which nav link to highlight: "overview", "testcases", "bugs"

     Usage in a page template:
       <#import "/layout/base.ftlh" as layout>
       <@layout.page title="Test Cases" activeNav="testcases">
         <h1>My page content here</h1>
       </@layout.page>
     ============================================================ -->
<#macro page title activeNav>
<!DOCTYPE html>
<html lang="en" class="h-full">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <#-- Browser tab title: shows the page name + app name -->
  <title>${title} — QA Dashboard</title>

  <#-- Tailwind CSS via CDN (Play CDN — suitable for development).
       This loads Tailwind directly from the internet; no build step needed.
       For production you would use the Tailwind CLI to generate a minified file,
       but CDN is perfect for this local dashboard. -->
  <script src="https://cdn.tailwindcss.com"></script>

  <#-- Tailwind theme customisation: extend the default palette with our accent colour.
       This makes "indigo-600" and related shades available as utility classes.
       The <script> tag with type="text/tailwindcss" is specific to the Play CDN. -->
  <script>
    tailwind.config = {
      theme: {
        extend: {
          colors: {
            accent: {
              DEFAULT: '#4f46e5', /* indigo-600 */
              hover:   '#4338ca', /* indigo-700 */
            }
          }
        }
      }
    }
  </script>

  <#-- A tiny block of custom CSS that Tailwind's utility classes can't cover.
       We use @layer to hook into Tailwind's processing so our rules have the
       right specificity alongside Tailwind utilities. -->
  <style type="text/tailwindcss">
    @layer base {
      /* Smooth scrolling for anchor links */
      html { scroll-behavior: smooth; }
    }
    @layer components {
      /* Reusable nav link style — active variant is toggled via FreeMarker below */
      .nav-link {
        @apply px-3 py-2 rounded-md text-sm font-medium transition-colors duration-150;
      }
      .nav-link-active {
        @apply bg-indigo-600 text-white;
      }
      .nav-link-inactive {
        @apply text-slate-300 hover:bg-slate-700 hover:text-white;
      }
      /* Card used on every page for content blocks */
      .card {
        @apply bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden;
      }
      /* Sidebar section heading */
      .sidebar-label {
        @apply text-xs font-semibold uppercase tracking-wider text-slate-400 px-3 mb-1;
      }
    }
  </style>
</head>

<#-- h-full + flex column on body fills the full viewport height,
     keeping the footer at the bottom even on short pages. -->
<body class="h-full bg-slate-100 text-slate-900 flex flex-col">

  <#-- ================================================================
       TOP NAVIGATION BAR
       ================================================================
       Uses slate-800 background, sits at the top of every page.
       "sticky top-0 z-40" keeps it visible when the user scrolls down.
       ================================================================ -->
  <header class="bg-slate-800 sticky top-0 z-40 shadow-md">
    <div class="mx-auto max-w-screen-xl px-4 sm:px-6 lg:px-8">
      <div class="flex h-14 items-center justify-between">

        <#-- ---- Left: App logo + name ---- -->
        <a href="/" class="flex items-center gap-2 text-white font-semibold text-base hover:opacity-90 transition-opacity">
          <#-- Clipboard SVG icon (inline SVG so no external image dependency) -->
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-indigo-400" fill="none"
               viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0
                     002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2
                     0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
          </svg>
          QA Dashboard
        </a>

        <#-- ---- Centre/Right: Navigation links ---- -->
        <nav class="flex items-center gap-1">

          <#-- Overview link.
               FreeMarker ?string("trueValue","falseValue") picks between two
               strings based on a boolean expression.
               If activeNav == "overview", use nav-link-active, else nav-link-inactive. -->
          <a href="/"
             class="nav-link ${(activeNav == "overview")?string("nav-link-active","nav-link-inactive")}">
            <#-- Small icon for visual context -->
            <span class="hidden sm:inline">Overview</span>
            <span class="sm:hidden" title="Overview">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none"
                   viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round"
                      d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2
                         2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0
                         011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
              </svg>
            </span>
          </a>

          <a href="/test-cases"
             class="nav-link ${(activeNav == "testcases")?string("nav-link-active","nav-link-inactive")}">
            <span class="hidden sm:inline">Test Cases</span>
            <span class="sm:hidden" title="Test Cases">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none"
                   viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round"
                      d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </span>
          </a>

          <a href="/bugs"
             class="nav-link ${(activeNav == "bugs")?string("nav-link-active","nav-link-inactive")}">
            <span class="hidden sm:inline">Bugs</span>
            <span class="sm:hidden" title="Bugs">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none"
                   viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round"
                      d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </span>
          </a>

          <#-- Import link — separated by a subtle divider to distinguish it
               from the view-only navigation links above.
               activeNav == "import" highlights it when on /import. -->
          <span class="h-5 w-px bg-slate-600 mx-1"></span>
          <a href="/import"
             class="nav-link ${(activeNav == "import")?string("nav-link-active","nav-link-inactive")}">
            <span class="hidden sm:inline">Import</span>
            <span class="sm:hidden" title="Import">
              <#-- Upload / arrow-up-tray icon -->
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none"
                   viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round"
                      d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1M12 12V4m0 0l-3 3m3-3l3 3" />
              </svg>
            </span>
          </a>

          <#-- Schema link — opens the spec doc in a new tab.
               Not a page inside the app, so it never gets activeNav highlighting. -->
          <a href="/schema/schema-spec.md"
             target="_blank"
             rel="noopener noreferrer"
             class="nav-link nav-link-inactive"
             title="Open schema specification in a new tab">
            📋 <span class="hidden sm:inline">Schema</span>
          </a>

        </nav>
      </div>
    </div>
  </header>

  <#-- ================================================================
       BODY: SIDEBAR + MAIN CONTENT  (side-by-side flex layout)
       "flex-1" makes this row grow to fill all remaining vertical space
       between the nav bar and the footer.
       ================================================================ -->
  <div class="flex flex-1 overflow-hidden mx-auto w-full max-w-screen-xl px-4 sm:px-6 lg:px-8 py-6 gap-6">

    <#-- ==============================================================
         LEFT SIDEBAR — Active filter state display
         ==============================================================
         Shows the user what filters are currently applied.
         "w-56 shrink-0" gives it a fixed width that doesn't compress.
         "overflow-y-auto" allows scrolling if the sidebar grows tall.
         ============================================================== -->
    <aside class="w-56 shrink-0">
      <div class="card p-4 space-y-5">

        <#-- Sidebar title -->
        <div class="flex items-center gap-2 text-slate-700 font-semibold text-sm">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-indigo-500" fill="none"
               viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2a1 1 0 01-.293.707L13
                     13.414V19a1 1 0 01-.553.894l-4 2A1 1 0 017
                     21v-7.586L3.293 6.707A1 1 0 013 6V4z" />
          </svg>
          Active Filters
        </div>

        <#-- ---- Product filter chip ----
             "selectedProduct??" is a FreeMarker null-check:
             true when the Java controller set selectedProduct to a non-null value.
             Without the ??, FreeMarker would throw an error when the variable is null. -->
        <div>
          <div class="sidebar-label">Product</div>
          <#if selectedProduct?? && selectedProduct?has_content>
            <#-- A filled chip showing the active value, with a ✕ link to clear it.
                 Clicking ✕ goes to the current page without the product param,
                 which the controller treats as "no filter". -->
            <span class="inline-flex items-center gap-1 rounded-full bg-indigo-50 px-3 py-1
                         text-xs font-medium text-indigo-700 ring-1 ring-inset ring-indigo-700/20">
              ${selectedProduct}
              <a href="?" class="ml-1 text-indigo-400 hover:text-indigo-700" title="Clear filter">✕</a>
            </span>
          <#else>
            <span class="text-xs text-slate-400 px-3">All products</span>
          </#if>
        </div>

        <#-- ---- Platform filter chip ---- -->
        <div>
          <div class="sidebar-label">Platform</div>
          <#if selectedPlatform?? && selectedPlatform?has_content>
            <span class="inline-flex items-center gap-1 rounded-full bg-indigo-50 px-3 py-1
                         text-xs font-medium text-indigo-700 ring-1 ring-inset ring-indigo-700/20">
              ${selectedPlatform}
              <#-- When clearing platform, keep product if it was set -->
              <a href="?<#if selectedProduct?? && selectedProduct?has_content>product=${selectedProduct}</#if>"
                 class="ml-1 text-indigo-400 hover:text-indigo-700" title="Clear filter">✕</a>
            </span>
          <#else>
            <span class="text-xs text-slate-400 px-3">All platforms</span>
          </#if>
        </div>

        <#-- ---- Module filter chip ---- -->
        <div>
          <div class="sidebar-label">Module</div>
          <#if selectedModule?? && selectedModule?has_content>
            <span class="inline-flex items-center gap-1 rounded-full bg-indigo-50 px-3 py-1
                         text-xs font-medium text-indigo-700 ring-1 ring-inset ring-indigo-700/20">
              ${selectedModule}
              <#-- Preserve product+platform when clearing module only -->
              <a href="?<#if selectedProduct?? && selectedProduct?has_content>product=${selectedProduct}&</#if><#if selectedPlatform?? && selectedPlatform?has_content>platform=${selectedPlatform}</#if>"
                 class="ml-1 text-indigo-400 hover:text-indigo-700" title="Clear filter">✕</a>
            </span>
          <#else>
            <span class="text-xs text-slate-400 px-3">All modules</span>
          </#if>
        </div>

        <#-- ---- Date filter chip ---- -->
        <div>
          <div class="sidebar-label">Date</div>
          <#if selectedDate?? && selectedDate?has_content>
            <span class="inline-flex items-center gap-1 rounded-full bg-indigo-50 px-3 py-1
                         text-xs font-medium text-indigo-700 ring-1 ring-inset ring-indigo-700/20">
              ${selectedDate}
              <a href="?<#if selectedProduct?? && selectedProduct?has_content>product=${selectedProduct}&</#if><#if selectedPlatform?? && selectedPlatform?has_content>platform=${selectedPlatform}&</#if><#if selectedModule?? && selectedModule?has_content>module=${selectedModule}</#if>"
                 class="ml-1 text-indigo-400 hover:text-indigo-700" title="Clear filter">✕</a>
            </span>
          <#else>
            <span class="text-xs text-slate-400 px-3">All dates</span>
          </#if>
        </div>

        <#-- ---- Clear all filters link (only shown if any filter is active) ---- -->
        <#if (selectedProduct?? && selectedProduct?has_content)
          || (selectedPlatform?? && selectedPlatform?has_content)
          || (selectedModule?? && selectedModule?has_content)
          || (selectedDate?? && selectedDate?has_content)>
          <div class="pt-1 border-t border-slate-100">
            <a href="?" class="text-xs text-slate-500 hover:text-red-600 transition-colors">
              ✕ Clear all filters
            </a>
          </div>
        </#if>

        <#-- ---- Quick-links to pages ---- -->
        <div class="pt-1 border-t border-slate-100 space-y-1">
          <div class="sidebar-label mb-2">Jump to</div>
          <a href="/"             class="block rounded px-3 py-1.5 text-xs text-slate-600 hover:bg-indigo-50 hover:text-indigo-700 transition-colors">Overview</a>
          <a href="/test-cases"   class="block rounded px-3 py-1.5 text-xs text-slate-600 hover:bg-indigo-50 hover:text-indigo-700 transition-colors">Test Cases</a>
          <a href="/bugs"         class="block rounded px-3 py-1.5 text-xs text-slate-600 hover:bg-indigo-50 hover:text-indigo-700 transition-colors">Bugs</a>
          <a href="/import"       class="block rounded px-3 py-1.5 text-xs text-slate-600 hover:bg-indigo-50 hover:text-indigo-700 transition-colors">Import</a>
          <a href="/schema/schema-spec.md" target="_blank" rel="noopener noreferrer"
             class="block rounded px-3 py-1.5 text-xs text-slate-600 hover:bg-indigo-50 hover:text-indigo-700 transition-colors">📋 Schema</a>
        </div>

      </div>
    </aside>

    <#-- ==============================================================
         MAIN CONTENT AREA
         ==============================================================
         "min-w-0" prevents long content from pushing out of the flex
         container on narrow viewports.

         <#nested> is the FreeMarker keyword that marks the injection
         point — whatever the caller puts between <@layout.page>...</@layout.page>
         is rendered here.
         ============================================================== -->
    <main class="flex-1 min-w-0 space-y-6">

      <#-- ============================================================
           GLOBAL FILTER BREADCRUMB
           ============================================================
           Shown automatically on every page whenever at least the product
           filter is active. Displays the active filter scope as a clickable
           path trail:  vantagefitness  ›  web  ›  login

           WHY RELATIVE URLS?
           Using href="?product=X" (a relative query string) is intentional:
           the browser resolves it against the CURRENT page path. So clicking
           "vantagefitness" on the /test-cases page goes to
           /test-cases?product=vantagefitness — it works correctly on every page
           without needing to know which page we are on.

           The variables selectedProduct / selectedPlatform / selectedModule are
           model attributes set by every controller in the app.
           "selectedProduct??" checks for null; "?has_content" checks not blank.
           ============================================================ -->
      <#if selectedProduct?? && selectedProduct?has_content>
        <nav aria-label="Filter scope"
             class="flex items-center gap-1.5 text-xs px-3 py-2
                    bg-white rounded-lg border border-slate-200 shadow-sm -mb-2">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3 text-slate-400 shrink-0"
               fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2a1 1 0 01-.293.707L13
                     13.414V19a1 1 0 01-.553.894l-4 2A1 1 0 017
                     21v-7.586L3.293 6.707A1 1 0 013 6V4z" />
          </svg>
          <#-- "All Products" clears to no filter (relative "?" keeps current page) -->
          <a href="?" class="text-indigo-500 hover:text-indigo-700 transition-colors font-medium">
            All Products
          </a>
          <span class="text-slate-300 select-none">›</span>

          <#if selectedPlatform?? && selectedPlatform?has_content>
            <#-- Product is a link back to product-only scope -->
            <a href="?product=${selectedProduct}"
               class="text-indigo-500 hover:text-indigo-700 transition-colors">
              ${selectedProduct}
            </a>
            <span class="text-slate-300 select-none">›</span>

            <#if selectedModule?? && selectedModule?has_content>
              <#-- Platform is a link back to product+platform scope -->
              <a href="?product=${selectedProduct}&platform=${selectedPlatform}"
                 class="text-indigo-500 hover:text-indigo-700 transition-colors">
                ${selectedPlatform}
              </a>
              <span class="text-slate-300 select-none">›</span>
              <#-- Module is the current (deepest) level — not a link -->
              <span class="font-semibold text-slate-700">${selectedModule}</span>
            <#else>
              <#-- Platform is the current level — not a link -->
              <span class="font-semibold text-slate-700">${selectedPlatform}</span>
            </#if>

          <#else>
            <#-- Product is the current level — not a link -->
            <span class="font-semibold text-slate-700">${selectedProduct}</span>
          </#if>

        </nav>
      </#if>

      <#nested>
    </main>

  </div>

  <#-- ================================================================
       FOOTER
       ================================================================ -->
  <footer class="bg-slate-800 text-slate-400 text-xs py-3 mt-auto">
    <div class="mx-auto max-w-screen-xl px-4 sm:px-6 lg:px-8 flex items-center justify-between">
      <span>QA Dashboard — Local Mode</span>
      <span class="flex items-center gap-1">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3" fill="none"
             viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round"
                d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955
                   11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824
                   10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133
                   -2.052-.382-3.016z" />
        </svg>
        Reading from local qa-data/
      </span>
    </div>
  </footer>

</body>
</html>
</#macro>
<#-- End of macro page — everything above is the "shell"; pages inject into <#nested> -->
