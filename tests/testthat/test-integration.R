test_that("easytable works with Word output (default)", {
  skip_if_not_installed("flextable")

  result <- easytable(test_m1)

  expect_s3_class(result, "flextable")
})

test_that("easytable rejects markdown output", {
  expect_error(
    easytable(test_m1, output = "markdown"),
    "arg should be one of"
  )
})

test_that("easytable works with latex output", {
  skip_if_not_installed("knitr")

  result <- easytable(test_m1, output = "latex")

  expect_type(result, "character")
  expect_true(nchar(result) > 0)
})

test_that("easytable handles multiple lm models", {
  skip_if_not_installed("flextable")

  result <- easytable(test_m1, test_m2, test_m3, output = "word")

  expect_s3_class(result, "flextable")
})

test_that("easytable handles glm models", {
  skip_if_not_installed("flextable")

  result <- easytable(test_g1, test_g2, output = "word")

  expect_s3_class(result, "flextable")
})

test_that("easytable with robust standard errors", {
  skip_if_not_installed("flextable")
  skip_if_not_installed("lmtest")
  skip_if_not_installed("sandwich")

  result <- easytable(test_m1, output = "word", robust.se = TRUE)

  expect_s3_class(result, "flextable")
})

test_that("easytable with marginal effects", {
  skip_if_not_installed("flextable")
  skip_if_not_installed("margins")

  result <- easytable(test_m1, output = "word", margins = TRUE)

  expect_s3_class(result, "flextable")
})

test_that("easytable with robust SE and margins", {
  skip_if_not_installed("flextable")
  skip_if_not_installed("lmtest")
  skip_if_not_installed("sandwich")
  skip_if_not_installed("margins")

  result <- easytable(test_m2, test_m3, output = "word", robust.se = TRUE, margins = TRUE)

  expect_s3_class(result, "flextable")
})

test_that("easytable with control variables", {
  skip_if_not_installed("flextable")

  result <- easytable(
    test_m1, test_m2, test_m3,
    output = "word",
    control.var = c("hp", "am")
  )

  expect_s3_class(result, "flextable")
})

test_that("easytable full pipeline with all features", {
  skip_if_not_installed("flextable")
  skip_if_not_installed("lmtest")
  skip_if_not_installed("sandwich")

  temp_csv <- tempfile()

  result <- easytable(
    test_m1, test_m2, test_m3,
    output = "word",
    export.csv = paste0(temp_csv, ".csv"),
    robust.se = TRUE,
    control.var = c("hp", "am"),
    highlight = TRUE
  )

  expect_s3_class(result, "flextable")
  expect_true(file.exists(paste0(temp_csv, ".csv")))

  unlink(paste0(temp_csv, ".csv"))
})

test_that("easytable latex pipeline with control vars", {
  skip_if_not_installed("knitr")

  result <- easytable(
    test_m1, test_m2, test_m3,
    output = "latex",
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

  result1 <- easytable(m1, m2, m3)
  expect_s3_class(result1, "flextable")

  result2 <- easytable(m1, m2, m3, control.var = c("species", "island"))
  expect_s3_class(result2, "flextable")

  result3 <- easytable(m1, m2, m3, highlight = TRUE)
  expect_s3_class(result3, "flextable")
})
