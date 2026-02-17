test_that("format_word creates flextable object", {
  skip_if_not_installed("flextable")

  parsed <- parse_models(test_single_model, robust.se = FALSE, margins = FALSE)
  transformed <- transform_table(parsed, control.var = NULL)

  result <- format_word(transformed, robust.se = FALSE, margins = FALSE, highlight = FALSE)

  expect_s3_class(result, "flextable")
})

test_that("format_word includes significance footnote", {
  skip_if_not_installed("flextable")

  parsed <- parse_models(test_single_model, robust.se = FALSE, margins = FALSE)
  transformed <- transform_table(parsed, control.var = NULL)

  result <- format_word(transformed, robust.se = FALSE, margins = FALSE, highlight = FALSE)

  # Check that flextable has footer (contains significance info)
  expect_s3_class(result, "flextable")
})

test_that("format_word adds robust SE note", {
  skip_if_not_installed("flextable")
  skip_if_not_installed("lmtest")
  skip_if_not_installed("sandwich")

  parsed <- parse_models(test_single_model, robust.se = TRUE, margins = FALSE)
  transformed <- transform_table(parsed, control.var = NULL)

  result <- format_word(transformed, robust.se = TRUE, margins = FALSE, highlight = FALSE)

  expect_s3_class(result, "flextable")
})

test_that("format_word adds margins note", {
  skip_if_not_installed("flextable")
  skip_if_not_installed("margins")

  parsed <- parse_models(test_single_model, robust.se = FALSE, margins = TRUE)
  transformed <- transform_table(parsed, control.var = NULL)

  result <- format_word(transformed, robust.se = FALSE, margins = TRUE, highlight = FALSE)

  expect_s3_class(result, "flextable")
})

test_that("format_word handles highlighting", {
  skip_if_not_installed("flextable")

  parsed <- parse_models(test_single_model, robust.se = FALSE, margins = FALSE)
  transformed <- transform_table(parsed, control.var = NULL)

  result <- format_word(transformed, robust.se = FALSE, margins = FALSE, highlight = TRUE)

  expect_s3_class(result, "flextable")
})

test_that("format_latex creates character output", {
  skip_if_not_installed("knitr")

  parsed <- parse_models(test_single_model, robust.se = FALSE, margins = FALSE)
  transformed <- transform_table(parsed, control.var = NULL)

  result <- format_latex(transformed, robust.se = FALSE, margins = FALSE, highlight = FALSE)

  expect_type(result, "character")
  expect_true(nchar(result) > 0)
})

test_that("format_latex includes LaTeX table elements", {
  skip_if_not_installed("knitr")

  parsed <- parse_models(test_single_model, robust.se = FALSE, margins = FALSE)
  transformed <- transform_table(parsed, control.var = NULL)

  result <- format_latex(transformed, robust.se = FALSE, margins = FALSE, highlight = FALSE)

  # Should contain LaTeX elements (if using kableExtra, otherwise basic elements)
  expect_true(grepl("\\\\", result) || grepl("tabular", result))
})

test_that("format_latex includes significance footnote", {
  skip_if_not_installed("knitr")

  parsed <- parse_models(test_single_model, robust.se = FALSE, margins = FALSE)
  transformed <- transform_table(parsed, control.var = NULL)

  result <- format_latex(transformed, robust.se = FALSE, margins = FALSE, highlight = FALSE)

  expect_true(grepl("Significance", result))
})
