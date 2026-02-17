#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
profile <- if (length(args) >= 1) args[[1]] else "core"

cat("easytable test runner\n")
cat("Profile:", profile, "\n")

run_core <- function() {
  if (!requireNamespace("devtools", quietly = TRUE)) {
    stop("Package 'devtools' is required to run tests. Install with install.packages('devtools').")
  }
  devtools::test()
}

run_xtest <- function() {
  run_xtest <- tolower(Sys.getenv("EASYTABLE_RUN_XTEST", "false")) %in% c("1", "true", "yes", "y")
  if (!run_xtest) {
    cat("Skipping tests/xtest (set EASYTABLE_RUN_XTEST=true to enable).\n")
    return(invisible(NULL))
  }
  script <- file.path("tests", "xtest", "test-api-and-layout.R")
  if (!file.exists(script)) {
    stop("Expected xtest script not found: ", script)
  }
  source(script, local = TRUE)
}

if (identical(profile, "core")) {
  run_core()
} else if (identical(profile, "full")) {
  run_core()
  run_xtest()
} else {
  stop("Unknown profile '", profile, "'. Use 'core' or 'full'.")
}

cat("All requested test layers completed.\n")
