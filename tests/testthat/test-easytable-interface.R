# Test the new easytable() dots interface

test_that("easytable accepts model objects through dots", {
  # Simple models
  m1 <- lm(mpg ~ wt, data = mtcars)
  m2 <- lm(mpg ~ wt + hp, data = mtcars)

  # Should work without error
  expect_no_error(
    easytable(m1, m2, output = "markdown")
  )
})

test_that("easytable uses default Model N naming", {
  m1 <- lm(mpg ~ wt, data = mtcars)
  m2 <- lm(mpg ~ wt + hp, data = mtcars)
  m3 <- lm(mpg ~ wt + hp + qsec, data = mtcars)

  result <- easytable(m1, m2, m3, output = "markdown")

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
                      output = "markdown")

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
  result <- easytable(Logit = m1, Probit = m2, output = "markdown")

  # Should still use Model 1, Model 2
  expect_true(grepl("Model 1", result))
  expect_true(grepl("Model 2", result))

  # Named arguments should NOT appear
  expect_false(grepl("Logit", result))
  expect_false(grepl("Probit", result))
})

test_that("easytable errors with no models", {
  expect_error(
    easytable(output = "markdown"),
    "No models provided"
  )
})

test_that("easytable works with single model", {
  m1 <- lm(mpg ~ wt, data = mtcars)

  result <- easytable(m1, output = "markdown")

  expect_true(grepl("Model 1", result))
})

test_that("easy_table backward compatibility maintained", {
  m1 <- lm(mpg ~ wt, data = mtcars)
  m2 <- lm(mpg ~ wt + hp, data = mtcars)

  models <- list(Model1 = m1, Model2 = m2)

  # Old interface should still work
  expect_no_error(
    easy_table(models, output = "markdown")
  )

  result <- easy_table(models, output = "markdown")

  # Should use the list names
  expect_true(grepl("Model1", result))
  expect_true(grepl("Model2", result))
})
