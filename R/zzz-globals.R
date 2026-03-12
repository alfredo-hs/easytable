# Declare global variables used in dplyr/tidy evaluation to satisfy R CMD check
# These are used in NSE contexts within dplyr pipelines

utils::globalVariables(c(
  "term",
  "estimate",
  "std.error",
  "p.value",
  "significance"
))
