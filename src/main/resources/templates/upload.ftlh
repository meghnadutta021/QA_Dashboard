<#--
================================================================================
  upload.ftlh  —  JSON Report Import Page
================================================================================

  MODEL ATTRIBUTES FROM ImportController.showUploadForm():
    products         — List<String>: known product names (for the hint chips)

  FLASH ATTRIBUTES set by ImportController.handleUpload() before redirect:
    successMessage   — String: shown in a green banner after a successful import
    errors           — List<String>: shown in a red error list when validation fails

  HOW FLASH ATTRIBUTES WORK IN FREEMARKER
  ----------------------------------------
  Spring's RedirectAttributes.addFlashAttribute("key", value) stores a value in
  the user's HTTP session. After the redirect, Spring copies those flash values
  into the next request's Model automatically. In this template we access them
  just like regular model attributes:  ${successMessage}  or  <#list errors as e>
  They disappear from the session after this one page-load reads them — which is
  why they are called "flash": they flash briefly then vanish.

  FREEMARKER SYNTAX USED HERE
  ----------------------------
  successMessage??        → null-check: true when successMessage is not null
  successMessage?has_content → true when the string is not null AND not empty
  <#list errors as err>   → loops over a List<String>
  ${err}                  → outputs one error string

================================================================================
-->
<#import "/layout/base.ftlh" as layout>

<@layout.page title="Import Report" activeNav="import">

  <#-- Page heading -->
  <div>
    <h1 class="text-xl font-semibold text-slate-900">Import JSON Report</h1>
    <p class="text-sm text-slate-500 mt-0.5">
      Upload a QA report JSON file to add it to the dashboard.
      The product, platform, module, and date are read automatically from the file's
      <code class="font-mono text-xs bg-slate-100 px-1 rounded">meta</code> section —
      no manual path entry required.
    </p>
  </div>

  <#-- =========================================================================
       DOWNLOAD TEMPLATES SECTION
       =========================================================================
       Three static files are served from src/main/resources/static/schema/.
       Spring Boot automatically serves everything in the "static" folder at the
       root URL, so /schema/sample-report.json maps to that file with no
       controller needed.

       The download attribute on an <a> tag tells the browser to save the file
       instead of trying to display it.  target="_blank" opens in a new tab
       (used for the Markdown spec so the user can read it without leaving).
       ========================================================================= -->
  <div class="card p-5">
    <h2 class="text-base font-semibold text-slate-800 mb-1">Download Templates</h2>
    <p class="text-xs text-slate-500 mb-4">
      Give the sample file to your AI assistant (ChatGPT, Claude, etc.) so it generates
      reports in the correct format. The schema spec explains every field in plain English.
    </p>

    <div class="flex flex-wrap gap-3">

      <#-- Download Sample JSON — browser saves the file locally -->
      <a href="/schema/sample-report.json"
         download="sample-report.json"
         class="inline-flex items-center gap-2 rounded-md border border-slate-200
                bg-white px-4 py-2 text-sm font-medium text-slate-700 shadow-sm
                hover:border-indigo-300 hover:bg-indigo-50 hover:text-indigo-700
                transition-colors">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-indigo-500"
             fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round"
                d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1
                   M16 12l-4 4m0 0l-4-4m4 4V4" />
        </svg>
        Download Sample JSON
      </a>

      <#-- View Schema Spec — opens the Markdown file in a new browser tab -->
      <a href="/schema/schema-spec.md"
         target="_blank"
         rel="noopener noreferrer"
         class="inline-flex items-center gap-2 rounded-md border border-slate-200
                bg-white px-4 py-2 text-sm font-medium text-slate-700 shadow-sm
                hover:border-indigo-300 hover:bg-indigo-50 hover:text-indigo-700
                transition-colors">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-indigo-500"
             fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round"
                d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0
                   012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0
                   01.293.707V19a2 2 0 01-2 2z" />
        </svg>
        View Schema Spec
        <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3 text-slate-400"
             fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round"
                d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4
                   M14 4h6m0 0v6m0-6L10 14" />
        </svg>
      </a>

      <#-- Download JSON Schema — machine-readable schema for editor validation -->
      <a href="/schema/schema.json"
         download="schema.json"
         class="inline-flex items-center gap-2 rounded-md border border-slate-200
                bg-white px-4 py-2 text-sm font-medium text-slate-700 shadow-sm
                hover:border-indigo-300 hover:bg-indigo-50 hover:text-indigo-700
                transition-colors">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-indigo-500"
             fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round"
                d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1
                   M16 12l-4 4m0 0l-4-4m4 4V4" />
        </svg>
        Download JSON Schema
      </a>

    </div>

    <#-- One-line tip explaining how to use the sample with an AI assistant -->
    <p class="text-xs text-slate-400 mt-4 flex items-start gap-1.5">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5 shrink-0 text-indigo-400 mt-0.5"
           fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round"
              d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      Give the sample file to your AI assistant so it generates reports in the correct format.
      The Schema Spec page has a ready-to-copy prompt template at the bottom.
    </p>
  </div>

  <#-- =========================================================================
       SUCCESS BANNER
       Rendered only when ImportController sets the "successMessage" flash attribute.
       ========================================================================= -->
  <#if successMessage?? && successMessage?has_content>
    <div class="flex items-start gap-3 rounded-xl border border-green-300 bg-green-50 px-4 py-3">
      <svg xmlns="http://www.w3.org/2000/svg"
           class="h-5 w-5 text-green-500 shrink-0 mt-0.5" fill="none"
           viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round"
              d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <div>
        <p class="text-sm font-semibold text-green-800">Report imported successfully</p>
        <p class="text-xs text-green-700 mt-0.5 font-mono">${successMessage}</p>
        <div class="flex gap-3 mt-2">
          <a href="/test-cases" class="text-xs font-medium text-green-700 underline hover:no-underline">
            View test cases →
          </a>
          <a href="/bugs" class="text-xs font-medium text-green-700 underline hover:no-underline">
            View bugs →
          </a>
        </div>
      </div>
    </div>
  </#if>

  <#-- =========================================================================
       ERROR BANNER
       Rendered only when the "errors" flash attribute is a non-empty list.
       ========================================================================= -->
  <#if errors?? && errors?has_content>
    <div class="rounded-xl border border-red-300 bg-red-50 px-4 py-3">
      <div class="flex items-start gap-3">
        <svg xmlns="http://www.w3.org/2000/svg"
             class="h-5 w-5 text-red-500 shrink-0 mt-0.5" fill="none"
             viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round"
                d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <div>
          <p class="text-sm font-semibold text-red-800">
            Upload failed — please fix the following issue<#if errors?size != 1>s</#if>:
          </p>
          <ul class="mt-1.5 space-y-0.5 list-disc list-inside">
            <#-- <#list> iterates over the List<String> from the flash attribute -->
            <#list errors as err>
              <li class="text-xs text-red-700">${err}</li>
            </#list>
          </ul>
        </div>
      </div>
    </div>
  </#if>

  <#-- =========================================================================
       UPLOAD FORM
       =========================================================================
       Two HTML attributes are essential for file uploads:
         method="post"                — GET cannot carry a file (URLs have size limits)
         enctype="multipart/form-data" — tells the browser to send the file as binary
                                         rather than as URL-encoded text
       Without enctype="multipart/form-data" the file bytes are not sent at all.
       ========================================================================= -->
  <div class="card p-6">
    <h2 class="text-base font-semibold text-slate-800 mb-4">Upload a Report File</h2>

    <form method="post" action="/import" enctype="multipart/form-data" class="space-y-5">

      <#-- ---- File input ---- -->
      <div class="flex flex-col gap-1.5">
        <label for="file" class="text-sm font-medium text-slate-700">
          JSON Report File
          <span class="text-red-500 ml-0.5">*</span>
        </label>

        <#-- accept=".json,application/json" filters the file picker to .json files.
             The user can still bypass this, but our controller validates the content anyway. -->
        <input type="file"
               id="file"
               name="file"
               accept=".json,application/json"
               required
               class="block w-full rounded-md border border-slate-300 bg-white px-3 py-2
                      text-sm text-slate-700 shadow-sm
                      file:mr-4 file:rounded file:border-0
                      file:bg-indigo-50 file:px-3 file:py-1.5
                      file:text-xs file:font-medium file:text-indigo-700
                      hover:file:bg-indigo-100 cursor-pointer
                      focus:border-indigo-500 focus:outline-none focus:ring-1
                      focus:ring-indigo-500 transition-colors">

        <p class="text-xs text-slate-400">
          Accepted format:
          <code class="font-mono bg-slate-100 px-1 rounded">.json</code>.
          Maximum size: 10 MB.
          The file must contain a
          <code class="font-mono bg-slate-100 px-1 rounded">meta</code>,
          <code class="font-mono bg-slate-100 px-1 rounded">test_cases</code>, and
          <code class="font-mono bg-slate-100 px-1 rounded">bugs</code> key at the top level.
        </p>
      </div>

      <#-- ---- Known products hint ----
           Shows the products currently on the dashboard so the user knows
           what to put in meta.product (new products are created automatically). -->
      <#if products?? && products?has_content>
        <div class="rounded-lg bg-slate-50 border border-slate-200 px-4 py-3">
          <p class="text-xs font-semibold text-slate-600 mb-2">
            Products already on this dashboard:
          </p>
          <div class="flex flex-wrap gap-1.5">
            <#list products as p>
              <span class="inline-flex items-center rounded-full bg-white border border-slate-200
                           px-2.5 py-0.5 text-xs font-medium text-slate-700 shadow-sm">
                ${p}
              </span>
            </#list>
          </div>
          <p class="text-xs text-slate-400 mt-2">
            Your file's
            <code class="font-mono bg-slate-100 px-1 rounded">meta.product</code>
            should match one of these to add data to an existing product, or use a new
            name to create a new product folder automatically.
          </p>
        </div>
      </#if>

      <#-- ---- Submit + Cancel ---- -->
      <div class="flex items-center gap-3 pt-1">
        <button type="submit"
                class="inline-flex items-center gap-1.5 rounded-md bg-indigo-600 px-5 py-2
                       text-sm font-medium text-white shadow-sm hover:bg-indigo-700
                       focus:outline-none focus:ring-2 focus:ring-indigo-500
                       focus:ring-offset-1 transition-colors">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none"
               viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1M12 12V4m0 0l-3 3m3-3l3 3" />
          </svg>
          Upload &amp; Import
        </button>
        <a href="/" class="text-sm text-slate-500 hover:text-slate-800 transition-colors">
          Cancel
        </a>
      </div>

    </form>
  </div>

  <#-- =========================================================================
       JSON SCHEMA REFERENCE
       Shows the exact structure the uploaded file must follow.
       <pre><code> renders text in a fixed-width (monospace) font without
       collapsing whitespace, which is perfect for code samples.
       ========================================================================= -->
  <div class="card p-6">
    <h2 class="text-base font-semibold text-slate-800 mb-1">Required JSON Schema</h2>
    <p class="text-xs text-slate-500 mb-4">
      All four
      <code class="font-mono bg-slate-100 px-1 rounded">meta</code> fields are required.
      <code class="font-mono bg-slate-100 px-1 rounded">test_cases</code> and
      <code class="font-mono bg-slate-100 px-1 rounded">bugs</code> may be empty arrays
      <code class="font-mono bg-slate-100 px-1 rounded">[]</code> if there is nothing to report.
    </p>

    <pre class="overflow-x-auto rounded-lg bg-slate-900 text-slate-100 p-4 text-xs
                leading-relaxed font-mono"><code>{
  "meta": {
    "report_id":   "optional — auto-generated from filename if omitted",
    "product":     "required — e.g. \"vantagefitness\"",
    "platform":    "required — e.g. \"web\" or \"android\"",
    "module":      "required — e.g. \"login\"",
    "date":        "required — YYYYMMDD format, e.g. \"20260510\"",
    "tester":      "optional",
    "environment": "optional"
  },
  "test_cases": [
    {
      "tc_id":        "TC-LOGIN-001",
      "scenario":     "User login flow",
      "title":        "Valid credentials — dashboard loads",
      "priority":     "P1",
      "status":       "PASS",
      "expected":     "User is redirected to the dashboard",
      "actual":       "User was redirected to the dashboard",
      "precondition": "A valid user account exists",
      "steps":        ["Open the login page", "Enter valid email and password", "Click Submit"],
      "notes":        "optional free-text field"
    }
  ],
  "bugs": [
    {
      "bug_id":      "BUG-LOGIN-001",
      "tc_id":       "TC-LOGIN-001",
      "title":       "Login button unresponsive on slow connections",
      "severity":    "HIGH",
      "status":      "OPEN",
      "description": "optional longer description",
      "steps":       ["Open login page", "Throttle network to 3G", "Click Submit"],
      "expected":    "A loading spinner appears within 500 ms",
      "actual":      "The button becomes unresponsive with no visual feedback",
      "notes":       "optional"
    }
  ]
}</code></pre>

    <div class="mt-4 flex flex-wrap gap-4 text-xs text-slate-500">
      <div>
        <span class="font-semibold text-slate-700">status</span> values (test cases):
        <code class="font-mono bg-slate-100 px-1 rounded mx-0.5">PASS</code>
        <code class="font-mono bg-slate-100 px-1 rounded mx-0.5">FAIL</code>
        <code class="font-mono bg-slate-100 px-1 rounded mx-0.5">SKIP</code>
        <code class="font-mono bg-slate-100 px-1 rounded mx-0.5">BLOCKED</code>
      </div>
      <div>
        <span class="font-semibold text-slate-700">severity</span> values (bugs):
        <code class="font-mono bg-slate-100 px-1 rounded mx-0.5">CRITICAL</code>
        <code class="font-mono bg-slate-100 px-1 rounded mx-0.5">HIGH</code>
        <code class="font-mono bg-slate-100 px-1 rounded mx-0.5">MEDIUM</code>
        <code class="font-mono bg-slate-100 px-1 rounded mx-0.5">LOW</code>
      </div>
      <div>
        <span class="font-semibold text-slate-700">status</span> values (bugs):
        <code class="font-mono bg-slate-100 px-1 rounded mx-0.5">OPEN</code>
        <code class="font-mono bg-slate-100 px-1 rounded mx-0.5">IN_PROGRESS</code>
        <code class="font-mono bg-slate-100 px-1 rounded mx-0.5">FIXED</code>
        <code class="font-mono bg-slate-100 px-1 rounded mx-0.5">CLOSED</code>
      </div>
      <div>
        <span class="font-semibold text-slate-700">priority</span> values (test cases):
        <code class="font-mono bg-slate-100 px-1 rounded mx-0.5">P1</code>
        <code class="font-mono bg-slate-100 px-1 rounded mx-0.5">P2</code>
        <code class="font-mono bg-slate-100 px-1 rounded mx-0.5">P3</code>
        <code class="font-mono bg-slate-100 px-1 rounded mx-0.5">P4</code>
      </div>
    </div>
  </div>

</@layout.page>
