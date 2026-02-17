is_true_env <- function(name, default = "false") {
  tolower(Sys.getenv(name, default)) %in% c("1", "true", "yes", "y")
}

skip_if_word_tests_unavailable <- function() {
  skip_if_not_installed("flextable")
  if (is_true_env("EASYTABLE_SKIP_WORD_TESTS")) {
    skip("Word/flextable tests skipped by EASYTABLE_SKIP_WORD_TESTS.")
  }
}

skip_if_xtest_disabled <- function() {
  if (!is_true_env("EASYTABLE_RUN_XTEST")) {
    skip("Extended sandbox tests are disabled (set EASYTABLE_RUN_XTEST=true).")
  }
}
