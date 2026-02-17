#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
profile <- if (length(args) >= 1) args[[1]] else "core"

cat("easytable test runner\n")
cat("Profile:", profile, "\n")

# During R CMD check, tests are already executed via tests/testthat.R.
# Skip here to avoid duplicate execution and check-layout path issues.
if (nzchar(Sys.getenv("_R_CHECK_PACKAGE_NAME_"))) {
  cat("Detected R CMD check environment; skipping tests/run-tests.R.\n")
  cat("All requested test layers completed.\n")
  quit(save = "no", status = 0)
}

# Keep runtime deterministic in constrained/headless environments.
Sys.setenv(
  OMP_NUM_THREADS = "1",
  OPENBLAS_NUM_THREADS = "1",
  MKL_NUM_THREADS = "1",
  VECLIB_MAXIMUM_THREADS = "1",
  NUMEXPR_NUM_THREADS = "1"
)

find_package_root <- function(start = getwd()) {
  dir <- normalizePath(start, winslash = "/", mustWork = TRUE)
  initial <- dir

  repeat {
    if (file.exists(file.path(dir, "DESCRIPTION"))) {
      return(dir)
    }

    parent <- dirname(dir)
    if (identical(parent, dir)) {
      break
    }
    dir <- parent
  }

  # R CMD check layout fallback:
  # <tmp>/easytable.Rcheck/tests (wd) and package source at
  # <tmp>/easytable.Rcheck/<pkg>/DESCRIPTION.
  pkg_name <- Sys.getenv("_R_CHECK_PACKAGE_NAME_", "easytable")
  rcheck_root <- dirname(initial)
  sibling_pkg_root <- file.path(rcheck_root, pkg_name)
  if (file.exists(file.path(sibling_pkg_root, "DESCRIPTION"))) {
    return(sibling_pkg_root)
  }

  stop("Could not locate package root from: ", start, call. = FALSE)
}

run_core <- function(pkg_root) {
  if (!requireNamespace("testthat", quietly = TRUE)) {
    stop("Package 'testthat' is required to run tests. Install with install.packages('testthat').")
  }

  testthat::test_local(
    path = pkg_root,
    stop_on_failure = TRUE
  )
}

run_xtest <- function(pkg_root) {
  run_xtest <- tolower(Sys.getenv("EASYTABLE_RUN_XTEST", "false")) %in% c("1", "true", "yes", "y")
  if (!run_xtest) {
    cat("Skipping tests/xtest (set EASYTABLE_RUN_XTEST=true to enable).\n")
    return(invisible(NULL))
  }

  script <- file.path(pkg_root, "tests", "xtest", "test-api-and-layout.R")
  if (!file.exists(script)) {
    stop("Expected xtest script not found: ", script)
  }
  source(script, local = TRUE)
}

pkg_root <- find_package_root()
cat("Package root:", pkg_root, "\n")

if (identical(profile, "core")) {
  run_core(pkg_root)
} else if (identical(profile, "full")) {
  run_core(pkg_root)
  run_xtest(pkg_root)
} else {
  stop("Unknown profile '", profile, "'. Use 'core' or 'full'.")
}

cat("All requested test layers completed.\n")
