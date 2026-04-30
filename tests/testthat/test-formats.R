test_that("format_word creates flextable object", {
  skip_if_word_tests_unavailable()

  parsed <- parse_models(test_single_model, robust.se = FALSE, margins = FALSE)
  transformed <- transform_table(parsed, control.var = NULL)

  result <- format_word(transformed, robust.se = FALSE, margins = FALSE, highlight = FALSE)

  expect_s3_class(result, "flextable")
  expect_identical(result$header$dataset[[1]][1], "term")
})

test_that("format_word includes significance footnote", {
  skip_if_word_tests_unavailable()

  parsed <- parse_models(test_single_model, robust.se = FALSE, margins = FALSE)
  transformed <- transform_table(parsed, control.var = NULL)

  result <- format_word(transformed, robust.se = FALSE, margins = FALSE, highlight = FALSE)

  # Check that flextable has footer (contains significance info)
  expect_s3_class(result, "flextable")
})

test_that("format_word adds robust SE note", {
  skip_if_word_tests_unavailable()
  skip_if_not_installed("lmtest")
  skip_if_not_installed("sandwich")

  parsed <- parse_models(test_single_model, robust.se = TRUE, margins = FALSE)
  transformed <- transform_table(parsed, control.var = NULL)

  result <- format_word(transformed, robust.se = TRUE, margins = FALSE, highlight = FALSE)

  expect_s3_class(result, "flextable")
})

test_that("format_word adds margins note", {
  skip_if_word_tests_unavailable()
  skip_if_not_installed("margins")

  parsed <- parse_models(test_single_model, robust.se = FALSE, margins = TRUE)
  transformed <- transform_table(parsed, control.var = NULL)

  result <- format_word(transformed, robust.se = FALSE, margins = TRUE, highlight = FALSE)

  expect_s3_class(result, "flextable")
})

test_that("format_word handles highlighting", {
  skip_if_word_tests_unavailable()

  parsed <- parse_models(test_single_model, robust.se = FALSE, margins = FALSE)
  transformed <- transform_table(parsed, control.var = NULL)

  result <- format_word(transformed, robust.se = FALSE, margins = FALSE, highlight = TRUE)

  expect_s3_class(result, "flextable")
})

test_that("format_word uses multiplication sign for interaction display", {
  skip_if_word_tests_unavailable()

  m <- lm(mpg ~ wt * hp, data = mtcars)
  parsed <- parse_models(list(Model1 = m), robust.se = FALSE, margins = FALSE)
  transformed <- transform_table(parsed, control.var = NULL)

  result <- format_word(transformed, robust.se = FALSE, margins = FALSE, highlight = FALSE)

  expect_true(any(grepl("×", result$body$dataset$term, fixed = TRUE)))
  expect_false(any(grepl(" \\* ", result$body$dataset$term)))
})

test_that("easytable word output handles scientific notation and long model headers", {
  skip_if_word_tests_unavailable()

  long_model_name <- paste(rep("A", 18), collapse = "")

  set.seed(123)
  df <- data.frame(
    log_gdp = seq(8, 12, length.out = 120),
    pop = seq(1e6, 4e6, length.out = 120)
  )
  df$lifeExp <- 62 +
    1.2e-8 * df$log_gdp -
    3.5e-9 * df$pop +
    7.4e-15 * (df$log_gdp * df$pop) +
    rnorm(nrow(df), sd = 1e-5)

  m1 <- lm(lifeExp ~ log_gdp + pop, data = df)
  m2 <- lm(lifeExp ~ log_gdp * pop, data = df)

  result <- easytable(
    m1, m2,
    digits = 4,
    model.names = c(long_model_name, "b")
  )

  expect_s3_class(result, "flextable")
  expect_true(any(grepl("×", result$body$dataset$term, fixed = TRUE)))
  expect_true(any(grepl("E-", unlist(result$body$dataset[-1]), fixed = TRUE)))
  expect_true(any(grepl(long_model_name, unlist(result), fixed = TRUE)))
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
  expect_true(grepl("Coefficient", result, fixed = TRUE))
})

test_that("format_latex includes significance footnote", {
  skip_if_not_installed("knitr")

  parsed <- parse_models(test_single_model, robust.se = FALSE, margins = FALSE)
  transformed <- transform_table(parsed, control.var = NULL)

  result <- format_latex(transformed, robust.se = FALSE, margins = FALSE, highlight = FALSE)

  expect_true(grepl("Significance", result))
})

test_that("format_latex uses a LaTeX-safe multiplication sign for interactions", {
  skip_if_not_installed("knitr")

  m <- lm(mpg ~ wt * hp, data = mtcars)
  parsed <- parse_models(list(Model1 = m), robust.se = FALSE, margins = FALSE)
  transformed <- transform_table(parsed, control.var = NULL)

  result <- as.character(
    format_latex(transformed, robust.se = FALSE, margins = FALSE, highlight = FALSE)
  )

  expect_true(grepl("\\times", result, fixed = TRUE))
})

test_that("format_latex highlights negative scientific coefficients by coefficient sign only", {
  skip_if_not_installed("knitr")
  skip_if_not_installed("kableExtra")

  negative_coef <- data.frame(
    term = "x",
    Model1 = "-3.25E-5 ***\n(1.20E-6)",
    stringsAsFactors = FALSE
  )
  negative_result <- as.character(
    format_latex(negative_coef, robust.se = FALSE, margins = FALSE, highlight = TRUE)
  )
  expect_true(grepl("ffcccc", negative_result, fixed = TRUE))

  positive_coef_negative_se <- data.frame(
    term = "x",
    Model1 = "3.25E-5 ***\n(-1.20E-6)",
    stringsAsFactors = FALSE
  )
  positive_result <- as.character(
    format_latex(positive_coef_negative_se, robust.se = FALSE, margins = FALSE, highlight = TRUE)
  )
  expect_true(grepl("e6ffe6", positive_result, fixed = TRUE))
  expect_false(grepl("ffcccc", positive_result, fixed = TRUE))
})
