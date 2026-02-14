test_that("parse_single_model extracts coefficients from lm", {
  result <- parse_single_model(test_m1, robust.se = FALSE, margins = FALSE)

  expect_s3_class(result, "data.frame")
  expect_true("term" %in% names(result))
  expect_true("estimate" %in% names(result))
  expect_true("std.error" %in% names(result))
  expect_true("p.value" %in% names(result))
})

test_that("parse_single_model works with robust SE", {
  skip_if_not_installed("lmtest")
  skip_if_not_installed("sandwich")

  result <- parse_single_model(test_m1, robust.se = TRUE, margins = FALSE)

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("parse_single_model works with margins", {
  skip_if_not_installed("margins")

  result <- parse_single_model(test_m1, robust.se = FALSE, margins = TRUE)

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("parse_single_model works with robust SE and margins", {
  skip_if_not_installed("lmtest")
  skip_if_not_installed("sandwich")
  skip_if_not_installed("margins")

  result <- parse_single_model(test_m2, robust.se = TRUE, margins = TRUE)

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  # Should not have intercept when using margins
  expect_false("(Intercept)" %in% result$term)
})

test_that("format_coefficients adds significance stars", {
  coef_data <- data.frame(
    term = c("x1", "x2", "x3", "x4"),
    estimate = c(1.5, 2.0, 3.0, 0.5),
    std.error = c(0.5, 0.6, 0.7, 0.8),
    p.value = c(0.005, 0.03, 0.08, 0.5)
  )

  result <- format_coefficients(coef_data)

  expect_true("estimate" %in% names(result))
  expect_true(grepl("\\*\\*\\*", result$estimate[1])) # p < 0.01
  expect_true(grepl("\\*\\*", result$estimate[2]))    # p < 0.05
  expect_true(grepl("\\*", result$estimate[3]))       # p < 0.1
  expect_false(grepl("\\*", result$estimate[4]))      # p > 0.1
})

test_that("extract_model_measures returns fit statistics", {
  result <- extract_model_measures(test_m1)

  expect_s3_class(result, "data.frame")
  expect_true("term" %in% names(result))
  expect_true("estimate" %in% names(result))
  expect_true("N" %in% result$term)
  expect_true("R sq." %in% result$term)
  expect_true("Adj. R sq." %in% result$term)
  expect_true("AIC" %in% result$term)
})

test_that("parse_model combines coefficients and measures", {
  result <- parse_model(test_m1, robust.se = FALSE, margins = FALSE)

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 4) # At least intercept, coef, and measures
  expect_true("term" %in% names(result))

  # Check for both coefficients and measures
  expect_true("(Intercept)" %in% result$term)
  expect_true("N" %in% result$term)
})

test_that("parse_models handles multiple models", {
  result <- parse_models(test_models_lm, robust.se = FALSE, margins = FALSE)

  expect_s3_class(result, "data.frame")
  expect_equal(ncol(result), length(test_models_lm) + 1) # term + 3 models
  expect_equal(names(result)[1], "term")
  expect_equal(names(result)[2:4], names(test_models_lm))
})

test_that("parse_models works with single model", {
  result <- parse_models(test_single_model, robust.se = FALSE, margins = FALSE)

  expect_s3_class(result, "data.frame")
  expect_equal(ncol(result), 2) # term + 1 model
})

test_that("parse_models handles GLM models", {
  result <- parse_models(test_models_glm, robust.se = FALSE, margins = FALSE)

  expect_s3_class(result, "data.frame")
  expect_equal(ncol(result), length(test_models_glm) + 1)
})
