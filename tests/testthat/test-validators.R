test_that("validate_model_list catches invalid inputs", {
  # Not a list
  expect_error(
    validate_model_list("not a list"),
    "provide models as a list"
  )

  # Unnamed list
  expect_error(
    validate_model_list(list(test_m1, test_m2)),
    "needs a name"
  )

  # Empty list
  expect_error(
    validate_model_list(list()),
    "No models were found"
  )

  # Valid list passes
  expect_invisible(validate_model_list(test_models_lm))
})

test_that("validate_model_types catches unsupported models", {
  # Invalid model type
  bad_model <- structure(list(), class = "unsupported_model")
  expect_error(
    validate_model_types(list(BadModel = bad_model)),
    "not supported yet"
  )

  # Valid models pass
  expect_invisible(validate_model_types(test_models_lm))
  expect_invisible(validate_model_types(test_models_glm))
})

test_that("validate_control_vars warns about missing variables", {
  # Should warn for non-existent variable
  expect_warning(
    validate_control_vars(test_models_lm, "nonexistent_var"),
    "was not found"
  )

  # Should not warn for existing variable (hp exists in test_m2 and test_m3)
  expect_silent(
    validate_control_vars(test_models_lm, "hp")
  )

  # Should warn for another missing variable
  expect_warning(
    validate_control_vars(test_models_lm, "not_a_var"),
    "was not found"
  )

  # NULL control.var is valid
  expect_invisible(validate_control_vars(test_models_lm, NULL))
})

test_that("validate_parameters checks parameter types", {
  # Invalid robust.se
  expect_error(
    validate_parameters("yes", FALSE, FALSE, NULL, NULL, "word"),
    "robust.se.*TRUE or FALSE"
  )

  # Invalid margins
  expect_error(
    validate_parameters(FALSE, "yes", FALSE, NULL, NULL, "word"),
    "margins.*TRUE or FALSE"
  )

  # Invalid highlight
  expect_error(
    validate_parameters(FALSE, FALSE, 1, NULL, NULL, "word"),
    "highlight.*TRUE or FALSE"
  )

  # Invalid export.csv
  expect_error(
    validate_parameters(FALSE, FALSE, FALSE, NULL, 123, "word"),
    "export.csv.*file path string"
  )

  # Invalid export.word extension
  expect_error(
    validate_parameters(FALSE, FALSE, FALSE, "table.txt", NULL, "word"),
    "must end in '.docx'"
  )

  # export.word only with word output
  expect_error(
    validate_parameters(FALSE, FALSE, FALSE, "table.docx", NULL, "latex"),
    "available only when output = \"word\""
  )

  # Valid parameters pass
  expect_invisible(
    validate_parameters(TRUE, TRUE, TRUE, "table.docx", "table.csv", "word")
  )
})

test_that("check_format_dependencies detects missing packages", {
  # Word format needs flextable
  skip_if_word_tests_unavailable()
  expect_invisible(check_format_dependencies("word"))

  # LaTeX needs knitr
  skip_if_not_installed("knitr")
  expect_invisible(check_format_dependencies("latex"))
})

test_that("check_robust_dependencies detects missing packages", {
  skip_if_not_installed("lmtest")
  skip_if_not_installed("sandwich")
  expect_invisible(check_robust_dependencies(TRUE))

  # FALSE should always pass
  expect_invisible(check_robust_dependencies(FALSE))
})

test_that("check_margins_dependencies detects missing packages", {
  skip_if_not_installed("margins")
  expect_invisible(check_margins_dependencies(TRUE))

  # FALSE should always pass
  expect_invisible(check_margins_dependencies(FALSE))
})

test_that("validate_output_format normalizes and validates output strings", {
  expect_identical(validate_output_format("word"), "word")
  expect_identical(validate_output_format("LaTeX"), "latex")

  expect_error(
    validate_output_format("markdown"),
    "Unknown output format"
  )

  expect_error(
    validate_output_format(c("word", "latex")),
    "must be one value"
  )
})

test_that("validate_custom_row accepts NULL", {
  expect_invisible(validate_custom_row(NULL, 2L))
})

test_that("validate_custom_row accepts correct length vector", {
  expect_invisible(validate_custom_row(c("F. Statistic", ".004", ".3"), 2L))
  expect_invisible(validate_custom_row(c("F. Statistic", ".004"), 1L))
})

test_that("validate_custom_row errors when too few elements", {
  expect_error(
    validate_custom_row(c("F. Statistic", ".004"), 2L),
    "must have 3 elements"
  )
})

test_that("validate_custom_row errors when too many elements", {
  expect_error(
    validate_custom_row(c("F. Statistic", ".004", ".3", ".5"), 2L),
    "must have 3 elements"
  )
})

test_that("validate_custom_row error message contains example", {
  expect_error(
    validate_custom_row(c("F. Statistic"), 2L),
    "Example:"
  )
})

test_that("validate_custom_row errors on non-character input", {
  expect_error(
    validate_custom_row(c(1, 2, 3), 2L),
    "character vector"
  )
})

test_that("validate_digits accepts valid integers", {
  expect_invisible(validate_digits(2))
  expect_invisible(validate_digits(0))
  expect_invisible(validate_digits(4))
})

test_that("validate_digits rejects non-integer and negative values", {
  expect_error(validate_digits(1.5),  "non-negative integer")
  expect_error(validate_digits(-1),   "non-negative integer")
  expect_error(validate_digits("2"),  "non-negative integer")
  expect_error(validate_digits(NA),   "non-negative integer")
  expect_error(validate_digits(c(2, 3)), "non-negative integer")
})
