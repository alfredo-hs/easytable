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
    control.var = c("hp", "am")
  )

  expect_s3_class(result, "flextable")
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
    control.var = c("hp", "am"),
    highlight = TRUE
  )

  expect_s3_class(result, "flextable")
  expect_true(file.exists(paste0(temp_csv, ".csv")))

  unlink(paste0(temp_csv, ".csv"))
})

test_that("easy_table markdown pipeline with control vars", {
  skip_if_not_installed("knitr")

  result <- easy_table(
    test_models_lm,
    output = "markdown",
    control.var = c("hp", "am")
  )

  expect_type(result, "character")
  expect_true(grepl("hp", result))
  expect_true(grepl("am", result))
})

test_that("penguins dataset end-to-end test", {
  skip_if_not_installed("flextable")
  skip_if_not_installed("palmerpenguins")

  penguins <- palmerpenguins::penguins

  m1 <- lm(body_mass_g ~ flipper_length_mm, data = penguins)
  m2 <- lm(body_mass_g ~ flipper_length_mm + species, data = penguins)
  m3 <- lm(body_mass_g ~ flipper_length_mm + species + island, data = penguins)
  models <- list(Model1 = m1, Model2 = m2, Model3 = m3)

  result1 <- easy_table(models)
  expect_s3_class(result1, "flextable")

  result2 <- easy_table(models, control.var = c("species", "island"))
  expect_s3_class(result2, "flextable")

  result3 <- easy_table(models, highlight = TRUE)
  expect_s3_class(result3, "flextable")
})
