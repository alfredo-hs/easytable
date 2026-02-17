test_that("coefficient cells use two-line estimate + SE format", {
  parsed <- parse_models(test_single_model, robust.se = FALSE, margins = FALSE)
  transformed <- transform_table(parsed, control.var = NULL, abbreviate = FALSE)

  first_cell <- transformed[[2]][1]
  expect_true(grepl("\n", first_cell, fixed = TRUE))
  expect_true(grepl("\\([0-9]", first_cell))
})

test_that("control indicators are placed in the model-stat block", {
  parsed <- parse_models(test_models_lm, robust.se = FALSE, margins = FALSE)
  transformed <- transform_table(parsed, control.var = "am", abbreviate = FALSE)

  first_stat_row <- get_first_measure_row(transformed)
  expect_true(first_stat_row > 1)
  expect_identical(transformed$term[first_stat_row], "am")
  expect_true(any(transformed$term %in% c("N", "R sq.", "Adj. R sq.")))
})

test_that("latex output keeps exactly one body divider before model-stat rows", {
  skip_if_not_installed("knitr")
  latex <- as.character(easytable(test_m1, test_m2, output = "latex", control.var = "hp"))

  expect_true(grepl("\\\\midrule\nhp &", latex))
  expect_false(grepl("\\\\midrule\n\\\\addlinespace\n", latex))
})

test_that("latex zebra is limited to coefficient rows", {
  skip_if_not_installed("knitr")
  latex <- as.character(easytable(test_m1, test_m2, output = "latex", highlight = TRUE, control.var = "hp"))

  n_line <- regmatches(latex, regexpr("\nN &[^\n]*", latex))
  control_line <- regmatches(latex, regexpr("\nhp &[^\n]*", latex))

  expect_true(length(n_line) == 1 && nzchar(n_line))
  expect_true(length(control_line) == 1 && nzchar(control_line))

  expect_false(grepl("f0f0f0", n_line, fixed = TRUE))
  expect_false(grepl("f0f0f0", control_line, fixed = TRUE))
})

test_that("csv export keeps estimate and SE in the same cell", {
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)

  invisible(easytable(test_m1, output = "latex", export.csv = tmp))
  csv_lines <- readLines(tmp, warn = FALSE)

  # One line per row in CSV; coefficient cell should include estimate and (SE)
  expect_true(any(grepl("\\(Intercept\\).*\\([0-9]", csv_lines)))
})

test_that("interaction terms wrap after asterisk in the term column", {
  m <- lm(mpg ~ wt * hp, data = mtcars)
  parsed <- parse_models(list(Model1 = m), robust.se = FALSE, margins = FALSE)
  transformed <- transform_table(parsed, control.var = NULL, abbreviate = FALSE)
  wrapped <- wrap_interaction_terms(transformed$term)

  expect_true(any(grepl(" \\*\\n", wrapped)))
})
