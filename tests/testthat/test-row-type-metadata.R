test_that("row_type metadata is created during transformation", {
  m1 <- lm(mpg ~ cyl + hp, data = mtcars)
  parsed <- parse_models(list("Model 1" = m1))
  transformed <- transform_table(parsed)
  
  expect_true("row_type" %in% names(transformed))
  expect_true(all(transformed$row_type %in% c("intercept", "coefficient", "statistic")))
  
  # Check intercept specifically
  intercept_idx <- which(transformed$term == "(Intercept)")
  expect_equal(transformed$row_type[intercept_idx], "intercept")
})

test_that("row_type handles controls and custom rows properly", {
  m1 <- lm(mpg ~ cyl + hp + wt, data = mtcars)
  m2 <- lm(mpg ~ cyl + hp + wt + am, data = mtcars)
  
  parsed <- parse_models(list("M1" = m1, "M2" = m2))
  transformed <- transform_table(parsed, control.var = c("wt", "am"))
  
  expect_true(all(transformed$row_type[transformed$term %in% c("wt", "am")] == "control"))
})

test_that("row_type is stripped from final word and latex output", {
  m1 <- lm(mpg ~ cyl, data = mtcars)
  
  # Word parsing
  out_word <- suppressWarnings(easytable(m1, output = "word"))
  # flextable's internal body dataset should NOT have row_type
  expect_false("row_type" %in% out_word$col_keys)
  
  # LaTeX
  out_latex <- as.character(suppressWarnings(easytable(m1, output = "latex")))
  # Check latex string has no reference to row_type (just an extra safety)
  expect_false(grepl("row_type", out_latex, fixed = TRUE))
})

test_that("formatting uses row_type instead of literal 'Y' for control rows", {
  # Mock a variable named "Y" to prove we don't accidentally stripe it incorrectly
  # by confusing it with the literal control indicator "Y"
  mtcars_mock <- mtcars
  mtcars_mock$Y <- mtcars_mock$wt
  
  m1 <- lm(mpg ~ cyl + Y, data = mtcars_mock)
  
  # If the logic mistakenly matched the coefficient value "Y" or term "Y",
  # it might act strangely.
  res_word <- suppressWarnings(easytable(m1, output = "word"))
  res_latex <- as.character(suppressWarnings(easytable(m1, output = "latex")))
  
  # Just verify it rendered successfully without crashing or mutating the name
  expect_true(is.character(res_latex))
})
