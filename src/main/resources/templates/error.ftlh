<#--
================================================================================
  error.ftlh  —  Global Error Page
================================================================================

  MODEL ATTRIBUTES FROM GlobalExceptionHandler:
    errorTitle    — String: short name for the error, e.g. "File Not Found"
    errorMessage  — String: user-friendly explanation of what went wrong
    errorDetail   — String or null: technical detail (e.g. original exception message)
    errorType     — String: machine-readable type tag used to choose an icon

  IMPORTANT: This template must be defensive about null values.
  GlobalExceptionHandler only sets the four attributes above.
  The usual model attributes (selectedProduct, testCases, etc.) are NOT present.
  Every reference to a potentially-null variable must use the "!" default operator
  or the "??" null-check, otherwise FreeMarker will throw its own exception.

  THE PAGE LAYOUT
  ---------------
  This template uses the same base.ftlh layout as all other pages, so it gets
  the nav bar, sidebar, and footer automatically.
  The sidebar will show "All products / All platforms / All modules" (no active
  filters) because those model attributes are null — which is perfectly fine.

================================================================================
-->
<#import "/layout/base.ftlh" as layout>

<@layout.page title="${errorTitle!'Error'} — Error" activeNav="">

  <#-- Centre the error card vertically in the available space -->
  <div class="flex flex-col items-center justify-center min-h-[60vh] py-12">

    <div class="card w-full max-w-lg p-8 flex flex-col items-center text-center gap-5">

      <#-- ===================================================================
           ERROR ICON — different icon based on errorType
           =================================================================== -->
      <div class="rounded-full p-4
                  <#if (errorType!'') == 'FILE_NOT_FOUND'>bg-amber-50<#elseif (errorType!'') == 'JSON_PARSE_ERROR'>bg-orange-50<#elseif (errorType!'') == 'UPLOAD_TOO_LARGE'>bg-blue-50<#else>bg-red-50</#if>">

        <#if (errorType!'') == 'FILE_NOT_FOUND'>
          <#-- Folder with X icon for missing file -->
          <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 text-amber-500"
               fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M3 7a2 2 0 012-2h4l2 2h6a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0
                     01-2-2V7zm6 4l4 4m0-4l-4 4" />
          </svg>

        <#elseif (errorType!'') == 'JSON_PARSE_ERROR'>
          <#-- Code / braces icon for parse error -->
          <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 text-orange-500"
               fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
          </svg>

        <#elseif (errorType!'') == 'UPLOAD_TOO_LARGE'>
          <#-- Upload arrow icon for size limit error -->
          <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 text-blue-500"
               fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1M12 12V4m0 0l-3 3m3-3l3 3" />
          </svg>

        <#else>
          <#-- Generic warning triangle for unexpected errors -->
          <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 text-red-500"
               fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667
                     1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34
                     16c-.77 1.333.192 3 1.732 3z" />
          </svg>
        </#if>
      </div>

      <#-- ===================================================================
           ERROR TITLE AND MESSAGE
           =================================================================== -->
      <div>
        <h1 class="text-xl font-semibold text-slate-900">
          ${errorTitle!'An Error Occurred'}
        </h1>
        <p class="text-sm text-slate-600 mt-2 leading-relaxed">
          ${errorMessage!'An unexpected error occurred. Please try again.'}
        </p>
      </div>

      <#-- ===================================================================
           TECHNICAL DETAIL  (collapsible <details> element)
           <details> and <summary> are native HTML elements.
           The browser hides the content by default and shows it when clicked.
           No JavaScript needed — it's a built-in browser feature.
           Only rendered when errorDetail is not null and not blank.
           =================================================================== -->
      <#if errorDetail?? && errorDetail?has_content>
        <details class="w-full text-left">
          <summary class="cursor-pointer text-xs text-slate-400 hover:text-slate-600
                          transition-colors select-none">
            Technical details
          </summary>
          <pre class="mt-2 overflow-x-auto rounded-lg bg-slate-900 text-slate-300
                      p-3 text-xs leading-relaxed font-mono whitespace-pre-wrap
                      break-words">${errorDetail}</pre>
        </details>
      </#if>

      <#-- ===================================================================
           ACTION BUTTONS
           =================================================================== -->
      <div class="flex flex-wrap items-center justify-center gap-3 pt-2">

        <a href="/"
           class="inline-flex items-center gap-1.5 rounded-md bg-indigo-600 px-5 py-2
                  text-sm font-medium text-white shadow-sm hover:bg-indigo-700
                  focus:outline-none focus:ring-2 focus:ring-indigo-500
                  focus:ring-offset-1 transition-colors">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none"
               viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round"
                  d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1
                     1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1
                     1 0 001 1m-6 0h6" />
          </svg>
          Go to Overview
        </a>

        <#-- Only show Import button for file/JSON errors where the fix is to re-upload -->
        <#if (errorType!'') == 'FILE_NOT_FOUND'
          || (errorType!'') == 'JSON_PARSE_ERROR'
          || (errorType!'') == 'UPLOAD_TOO_LARGE'>
          <a href="/import"
             class="inline-flex items-center gap-1.5 rounded-md border border-slate-300
                    bg-white px-5 py-2 text-sm font-medium text-slate-700 shadow-sm
                    hover:bg-slate-50 transition-colors">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-indigo-500"
                 fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round"
                    d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1M12 12V4m0 0l-3 3m3-3l3 3" />
            </svg>
            Import Report
          </a>
        </#if>

        <#-- Go back link (uses browser history) -->
        <a href="javascript:history.back()"
           class="text-sm text-slate-500 hover:text-slate-800 transition-colors">
          ← Go back
        </a>

      </div>

    </div>
  </div>

</@layout.page>
