test_that("validate_model_list catches invalid inputs", {
  # Not a list
  expect_error(
    validate_model_list("not a list"),
    "model_list must be a list"
  )

  # Unnamed list
  expect_error(
    validate_model_list(list(test_m1, test_m2)),
    "model_list must be a named list"
  )

  # Empty list
  expect_error(
    validate_model_list(list()),
    "model_list cannot be empty"
  )

  # Valid list passes
  expect_invisible(validate_model_list(test_models_lm))
})

test_that("validate_model_types catches unsupported models", {
  # Invalid model type
  bad_model <- structure(list(), class = "unsupported_model")
  expect_error(
    validate_model_types(list(BadModel = bad_model)),
    "not a supported type"
  )

  # Valid models pass
  expect_invisible(validate_model_types(test_models_lm))
  expect_invisible(validate_model_types(test_models_glm))
})

test_that("validate_control_vars warns about missing variables", {
  # Should warn for non-existent variable
  expect_warning(
    validate_control_vars(test_models_lm, "nonexistent_var"),
    "not found in any model"
  )

  # Should not warn for existing variable (hp exists in test_m2 and test_m3)
  expect_silent(
    validate_control_vars(test_models_lm, "hp")
  )

  # Should warn for another missing variable
  expect_warning(
    validate_control_vars(test_models_lm, "not_a_var"),
    "not found in any model"
  )

  # NULL control.var is valid
  expect_invisible(validate_control_vars(test_models_lm, NULL))
})

test_that("validate_parameters checks parameter types", {
  # Invalid robust.se
  expect_error(
    validate_parameters("yes", FALSE, FALSE, NULL),
    "robust.se must be TRUE or FALSE"
  )

  # Invalid margins
  expect_error(
    validate_parameters(FALSE, "yes", FALSE, NULL),
    "margins must be TRUE or FALSE"
  )

  # Invalid highlight
  expect_error(
    validate_parameters(FALSE, FALSE, 1, NULL),
    "highlight must be TRUE or FALSE"
  )

  # Invalid csv
  expect_error(
    validate_parameters(FALSE, FALSE, FALSE, 123),
    "csv must be a character string or NULL"
  )

  # Valid parameters pass
  expect_invisible(
    validate_parameters(TRUE, TRUE, TRUE, "output")
  )
})

test_that("check_format_dependencies detects missing packages", {
  # Word format needs flextable
  skip_if_not_installed("flextable")
  expect_invisible(check_format_dependencies("word"))

  # Markdown needs knitr
  skip_if_not_installed("knitr")
  expect_invisible(check_format_dependencies("markdown"))

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
