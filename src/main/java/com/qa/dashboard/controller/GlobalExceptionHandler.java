package com.qa.dashboard.controller;

// =============================================================================
// GlobalExceptionHandler.java
// =============================================================================
// PURPOSE
// -------
// Catches unhandled exceptions thrown by any @Controller in the application
// and renders a friendly error page instead of a raw Spring "Whitelabel Error"
// screen or a stack trace visible to the user.
//
// WHAT IS @ControllerAdvice?
// ---------------------------
// @ControllerAdvice is a Spring annotation that marks a class as a global
// supplement to all @Controller classes. Any method annotated with
// @ExceptionHandler inside a @ControllerAdvice class will intercept matching
// exceptions from ALL controllers — you only have to write the error logic once.
//
// Think of it like a global catch block that wraps the entire web layer.
//
// WHAT IS @ExceptionHandler?
// ---------------------------
// @ExceptionHandler(SomeException.class) marks a method as the handler for
// that specific exception type. When that exception propagates out of any
// controller method, Spring calls this handler instead of returning a 500 page.
//
// You can specify multiple exception types:
//   @ExceptionHandler({IOException.class, NoSuchFileException.class})
//
// The method can accept the exception itself, an optional HttpServletRequest,
// and a Spring Model as parameters.
//
// EXCEPTION HIERARCHY (relevant to this class)
// ----------------------------------------------
//   Exception
//   └── IOException
//       ├── FileNotFoundException        (java.io — classic Java file API)
//       └── NoSuchFileException         (java.nio.file — modern Java NIO API)
//   └── RuntimeException
//       └── MaxUploadSizeExceededException  (Spring — file too large)
//   JsonParseException extends JsonProcessingException extends IOException
// =============================================================================

import com.fasterxml.jackson.core.JsonParseException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

import java.io.FileNotFoundException;
import java.nio.file.NoSuchFileException;

@ControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    // =========================================================================
    // Handler: File not found
    // =========================================================================
    // Triggered when a report file referenced in qa-data/ no longer exists on disk
    // (e.g. it was manually deleted between the directory scan and the file read).
    // Covers both java.io.FileNotFoundException and java.nio.file.NoSuchFileException
    // because the app uses both the classic Java file API and modern NIO.
    @ExceptionHandler({FileNotFoundException.class, NoSuchFileException.class})
    public String handleFileNotFound(Exception ex, Model model) {
        log.error("GlobalExceptionHandler: file not found — {}", ex.getMessage());

        model.addAttribute("errorTitle",   "Report File Not Found");
        model.addAttribute("errorMessage",
                "A report file that was expected on disk could not be found. "
              + "It may have been moved, renamed, or deleted since the dashboard last scanned "
              + "the qa-data/ folder.");
        model.addAttribute("errorDetail",  ex.getMessage());
        model.addAttribute("errorType",    "FILE_NOT_FOUND");
        return "error";
    }

    // =========================================================================
    // Handler: JSON parse error
    // =========================================================================
    // Triggered when a .json file in qa-data/ cannot be parsed because its
    // content is not valid JSON (e.g. a syntax error, a truncated file, or
    // a non-JSON file that happens to have a .json extension).
    @ExceptionHandler(JsonParseException.class)
    public String handleJsonParseError(JsonParseException ex, Model model) {
        log.error("GlobalExceptionHandler: JSON parse error — {}", ex.getOriginalMessage());

        model.addAttribute("errorTitle",   "Malformed Report File");
        model.addAttribute("errorMessage",
                "A report file in qa-data/ could not be parsed because it contains "
              + "invalid JSON. Check the file for syntax errors — missing commas, "
              + "unmatched brackets, or unquoted strings are common causes.");
        // getOriginalMessage() gives the Jackson error without the full path context,
        // which is cleaner for display to a non-developer user.
        model.addAttribute("errorDetail",  ex.getOriginalMessage());
        model.addAttribute("errorType",    "JSON_PARSE_ERROR");
        return "error";
    }

    // =========================================================================
    // Handler: File upload too large
    // =========================================================================
    // Triggered when a user uploads a file larger than the limit configured in
    // application.properties (spring.servlet.multipart.max-file-size=10MB).
    // Without this handler, Spring returns an ugly 500 error for oversized uploads.
    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public String handleFileTooLarge(MaxUploadSizeExceededException ex, Model model) {
        log.warn("GlobalExceptionHandler: upload too large — {}", ex.getMessage());

        model.addAttribute("errorTitle",   "File Too Large");
        model.addAttribute("errorMessage",
                "The uploaded file exceeds the maximum allowed size of 10 MB. "
              + "QA report JSON files should typically be a few kilobytes. "
              + "If this is a valid report, check whether it accidentally contains "
              + "binary attachments or very long step descriptions.");
        model.addAttribute("errorDetail",  "Maximum size: 10 MB");
        model.addAttribute("errorType",    "UPLOAD_TOO_LARGE");
        return "error";
    }

    // =========================================================================
    // Handler: Catch-all for unexpected errors
    // =========================================================================
    // This is a safety net. If an exception is thrown that is not matched by any
    // of the more specific handlers above, it falls through to here.
    // We log the full stack trace (log.error with the exception as 3rd argument)
    // but only show a generic message to the user — never expose stack traces.
    @ExceptionHandler(Exception.class)
    public String handleGenericError(Exception ex, Model model) {
        log.error("GlobalExceptionHandler: unhandled exception — {}", ex.getMessage(), ex);

        model.addAttribute("errorTitle",   "Unexpected Error");
        model.addAttribute("errorMessage",
                "Something unexpected went wrong while processing your request. "
              + "The error has been logged. "
              + "Try refreshing the page, or go back to the overview.");
        model.addAttribute("errorDetail",  ex.getMessage());
        model.addAttribute("errorType",    "GENERAL_ERROR");
        return "error";
        // Spring looks for: src/main/resources/templates/error.ftlh
    }
}
