test_that("easy_table works with Word output (default)", {
  skip_if_not_installed("flextable")

  result <- easy_table(test_single_model)

  expect_s3_class(result, "flextable")
})

test_that("easy_table works with markdown output", {
  skip_if_not_installed("knitr")

  result <- easy_table(test_single_model, output = "markdown")

  expect_type(result, "character")
  expect_true(grepl("\\|", result))
})

test_that("easy_table works with latex output", {
  skip_if_not_installed("knitr")

  result <- easy_table(test_single_model, output = "latex")

  expect_type(result, "character")
  expect_true(nchar(result) > 0)
})

test_that("easy_table handles multiple lm models", {
  skip_if_not_installed("flextable")

  result <- easy_table(test_models_lm, output = "word")

  expect_s3_class(result, "flextable")
})

test_that("easy_table handles glm models", {
  skip_if_not_installed("flextable")

  result <- easy_table(test_models_glm, output = "word")

  expect_s3_class(result, "flextable")
})

test_that("easy_table with robust standard errors", {
  skip_if_not_installed("flextable")
  skip_if_not_installed("lmtest")
  skip_if_not_installed("sandwich")

  result <- easy_table(test_single_model, output = "word", robust.se = TRUE)

  expect_s3_class(result, "flextable")
})

test_that("easy_table with marginal effects", {
  skip_if_not_installed("flextable")
  skip_if_not_installed("margins")

  result <- easy_table(test_single_model, output = "word", margins = TRUE)

  expect_s3_class(result, "flextable")
})

test_that("easy_table with robust SE and margins", {
  skip_if_not_installed("flextable")
  skip_if_not_installed("lmtest")
  skip_if_not_installed("sandwich")
  skip_if_not_installed("margins")

  result <- easy_table(test_models_lm[2:3], output = "word", robust.se = TRUE, margins = TRUE)

  expect_s3_class(result, "flextable")
})

test_that("easy_table with control variables", {
  skip_if_not_installed("flextable")

  result <- easy_table(
    test_models_lm,
    output = "word",
    control.var = c("species", "island")
  )

  expect_s3_class(result, "flextable")
})

test_that("easy_table with highlighting", {
  skip_if_not_installed("flextable")

  result <- easy_table(test_single_model, output = "word", highlight = TRUE)

  expect_s3_class(result, "flextable")
})

test_that("easy_table exports CSV file", {
  skip_if_not_installed("flextable")

  temp_csv <- tempfile()
  result <- easy_table(test_single_model, output = "word", csv = temp_csv)

  expect_true(file.exists(paste0(temp_csv, ".csv")))

  # Clean up
  unlink(paste0(temp_csv, ".csv"))
})

test_that("easy_table full pipeline with all features", {
  skip_if_not_installed("flextable")
  skip_if_not_installed("lmtest")
  skip_if_not_installed("sandwich")

  temp_csv <- tempfile()

  result <- easy_table(
    test_models_lm,
    output = "word",
    csv = temp_csv,
    robust.se = TRUE,
    control.var = c("species", "island"),
    highlight = TRUE
  )

  expect_s3_class(result, "flextable")
  expect_true(file.exists(paste0(temp_csv, ".csv")))

  # Clean up
  unlink(paste0(temp_csv, ".csv"))
})

test_that("easy_table markdown pipeline with control vars", {
  skip_if_not_installed("knitr")

  result <- easy_table(
    test_models_lm,
    output = "markdown",
    control.var = c("species", "island")
  )

  expect_type(result, "character")
  expect_true(grepl("species", result))
  expect_true(grepl("Y", result))
})

test_that("easy_table latex pipeline with robust SE", {
  skip_if_not_installed("knitr")
  skip_if_not_installed("lmtest")
  skip_if_not_installed("sandwich")

  result <- easy_table(
    test_single_model,
    output = "latex",
    robust.se = TRUE
  )

  expect_type(result, "character")
  expect_true(grepl("Robust", result))
})

test_that("easy_table catches invalid model list", {
  expect_error(
    easy_table("not a list"),
    "model_list must be a list"
  )

  expect_error(
    easy_table(list(test_m1)),
    "must be a named list"
  )
})

test_that("easy_table catches invalid output format", {
  expect_error(
    easy_table(test_single_model, output = "pdf"),
    "'arg' should be one of"
  )
})

test_that("easy_table catches invalid parameters", {
  expect_error(
    easy_table(test_single_model, robust.se = "yes"),
    "robust.se must be TRUE or FALSE"
  )

  expect_error(
    easy_table(test_single_model, margins = 1),
    "margins must be TRUE or FALSE"
  )
})

test_that("backward compatibility - default is Word output", {
  skip_if_not_installed("flextable")

  # Calling without output parameter should default to Word
  result <- easy_table(test_single_model)

  expect_s3_class(result, "flextable")
})

test_that("all three output formats work with same input", {
  skip_if_not_installed("flextable")
  skip_if_not_installed("knitr")

  word_result <- easy_table(test_models_lm, output = "word")
  md_result <- easy_table(test_models_lm, output = "markdown")
  latex_result <- easy_table(test_models_lm, output = "latex")

  expect_s3_class(word_result, "flextable")
  expect_type(md_result, "character")
  expect_type(latex_result, "character")

  # All should contain model names
  expect_true(grepl("Model1", md_result))
  expect_true(grepl("Model1", latex_result))
})

test_that("penguins dataset end-to-end test", {
  skip_if_not_installed("flextable")

  # This mimics the exact use case from the plan
  m1 <- lm(body_mass_g ~ flipper_length_mm, data = penguins)
  m2 <- lm(body_mass_g ~ flipper_length_mm + species, data = penguins)
  m3 <- lm(body_mass_g ~ flipper_length_mm + species + island, data = penguins)
  models <- list(Model1 = m1, Model2 = m2, Model3 = m3)

  # Basic table
  result1 <- easy_table(models)
  expect_s3_class(result1, "flextable")

  # With control variables
  result2 <- easy_table(models, control.var = c("species", "island"))
  expect_s3_class(result2, "flextable")

  # With highlighting
  result3 <- easy_table(models, highlight = TRUE)
  expect_s3_class(result3, "flextable")
})
