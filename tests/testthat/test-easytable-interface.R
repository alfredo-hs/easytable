# Test the easytable() interface

test_that("easytable accepts model objects through dots", {
  # Simple models
  m1 <- lm(mpg ~ wt, data = mtcars)
  m2 <- lm(mpg ~ wt + hp, data = mtcars)

  # Should work without error
  expect_no_error(
    easytable(m1, m2, output = "latex")
  )
})

test_that("easytable uses default Model N naming", {
  m1 <- lm(mpg ~ wt, data = mtcars)
  m2 <- lm(mpg ~ wt + hp, data = mtcars)
  m3 <- lm(mpg ~ wt + hp + qsec, data = mtcars)

  result <- easytable(m1, m2, m3, output = "latex")

  # Check that result contains "Model 1", "Model 2", "Model 3"
  expect_true(grepl("Model 1", result))
  expect_true(grepl("Model 2", result))
  expect_true(grepl("Model 3", result))
})

test_that("easytable respects custom model.names", {
  m1 <- lm(mpg ~ wt, data = mtcars)
  m2 <- lm(mpg ~ wt + hp, data = mtcars)

  result <- easytable(m1, m2,
                      model.names = c("Baseline", "Full"),
                      output = "latex")

  # Check that custom names appear in output
  expect_true(grepl("Baseline", result))
  expect_true(grepl("Full", result))

  # Check that default names do NOT appear
  expect_false(grepl("Model 1", result))
  expect_false(grepl("Model 2", result))
})

test_that("easytable validates model.names length", {
  m1 <- lm(mpg ~ wt, data = mtcars)
  m2 <- lm(mpg ~ wt + hp, data = mtcars)

  # Should error when length mismatch
  expect_error(
    easytable(m1, m2, model.names = c("Only One")),
    "Length of model.names.*must match"
  )

  expect_error(
    easytable(m1, m2, model.names = c("One", "Two", "Three")),
    "Length of model.names.*must match"
  )
})

test_that("easytable ignores named arguments in dots", {
  m1 <- lm(mpg ~ wt, data = mtcars)
  m2 <- lm(mpg ~ wt + hp, data = mtcars)

  # Even with named arguments, should use default Model N naming
  result <- easytable(Logit = m1, Probit = m2, output = "latex")

  # Should still use Model 1, Model 2
  expect_true(grepl("Model 1", result))
  expect_true(grepl("Model 2", result))

  # Named arguments should NOT appear
  expect_false(grepl("Logit", result))
  expect_false(grepl("Probit", result))
})

test_that("easytable errors with no models", {
  expect_error(
    easytable(output = "latex"),
    "No models provided"
  )
})

test_that("easytable works with single model", {
  m1 <- lm(mpg ~ wt, data = mtcars)

  result <- easytable(m1, output = "latex")

  expect_true(grepl("Model 1", result))
})

test_that("easytable works with lm models", {
  m1 <- lm(mpg ~ wt, data = mtcars)
  m2 <- lm(mpg ~ wt + hp, data = mtcars)

  expect_no_error(
    easytable(m1, m2, output = "latex")
  )
})

test_that("easytable works with glm models", {
  # Binary outcome for glm
  mtcars_bin <- mtcars
  mtcars_bin$am_binary <- mtcars_bin$am

  m1 <- glm(am_binary ~ wt, data = mtcars_bin, family = binomial)
  m2 <- glm(am_binary ~ wt + hp, data = mtcars_bin, family = binomial)

  expect_no_error(
    easytable(m1, m2, output = "latex")
  )
})

# Test factor level formatting with synthetic data
test_that("factor terms display as var:level not varlevel", {
  # Create synthetic data with factor that has levels low, mid, high
  set.seed(123)
  test_data <- data.frame(
    y = rnorm(100),
    x = rnorm(100),
    advisor_confidence = factor(rep(c("low", "mid", "high"), length.out = 100))
  )

  m1 <- lm(y ~ x + advisor_confidence, data = test_data)
  result <- easytable(m1, output = "latex")

  # Should contain "adv_conf:low" or "advisor_confidence:low" (depending on abbreviation)
  # but NOT "advisor_confidencelow" (concatenated)
  expect_true(grepl(":low", result))
  expect_true(grepl(":mid", result))

  # Should NOT contain concatenated form
  expect_false(grepl("advisor_confidencelow", result, fixed = TRUE))
  expect_false(grepl("advisor_confidencemid", result, fixed = TRUE))
})

test_that("interaction with contrast and factor displays as var:L2 * other:level", {
  # Create data with ordered factor (to get polynomial contrasts) and regular factor
  set.seed(123)
  test_data <- data.frame(
    y = rnorm(100),
    financial_prudence = factor(rep(1:4, length.out = 100), ordered = TRUE),
    digital_confidence = factor(rep(c("low", "high"), length.out = 100))
  )

  m1 <- lm(y ~ financial_prudence * digital_confidence, data = test_data)
  result <- easytable(m1, output = "latex")

  # Should have polynomial contrast terms like fin.prud:L1 or fin.prud:L2
  expect_true(grepl(":L[12]", result))

  # Should have interaction with asterisk
  expect_true(grepl("\\*", result))

  # Should have factor level separated
  expect_true(grepl(":low|:high", result))
})
