# Test term label formatting

test_that("format_term_labels handles polynomial suffixes", {
  terms <- c("financial_prudence.Q", "financial_prudence.L", "var.C")

  result <- format_term_labels(terms, abbreviate = TRUE)

  # Polynomial suffixes should be preserved
  expect_true(grepl("\\.Q$", result[1]))
  expect_true(grepl("\\.L$", result[2]))
  expect_true(grepl("\\.C$", result[3]))
})

test_that("format_term_labels separates factor levels", {
  levels_map <- list(
    digital_confidence = c("low", "mid", "high"),
    advisor_confidence = c("low", "mid", "high"),
    occupation = c("no", "yes")
  )
  terms <- c("digital_confidencelow", "advisor_confidencelow", "occupationno")

  result <- format_term_labels(terms, levels_map = levels_map, abbreviate = TRUE)

  expect_equal(result[1], "digi.conf:low")
  expect_equal(result[2], "advi.conf:low")
  expect_equal(result[3], "occupa:no")
})

test_that("format_term_labels converts interaction colons to asterisks", {
  # After polynomial conversion, interactions should use asterisks
  terms <- c("var1.L:var2", "var1:var2")

  result <- format_term_labels(terms)

  # Should have asterisk for interaction
  expect_true(grepl("\\*", result[1]))
  expect_true(grepl("\\*", result[2]))

  # Polynomial suffix should remain
  expect_true(grepl("\\.L", result[1]))
})

test_that("format_term_labels applies abbreviations", {
  terms <- c("financial_prudence", "digital_confidence", "advisor_confidence")

  result <- format_term_labels(terms, abbreviate = TRUE)

  expect_equal(result[1], "fina.prud")
  expect_equal(result[2], "digi.conf")
  expect_equal(result[3], "advi.conf")
})

test_that("format_term_labels handles complex combined terms", {
  levels_map <- list(
    digital_confidence = c("low", "mid", "high")
  )
  terms <- c("financial_prudence.L:digital_confidencelow")

  result <- format_term_labels(terms, levels_map = levels_map, abbreviate = TRUE)

  expect_true(grepl("fina.prud", result[1]))
  expect_true(grepl("digi.conf", result[1]))
  expect_true(grepl("\\.L", result[1]))
  expect_true(grepl(":low", result[1]))
  expect_true(grepl("\\*", result[1]))
})

test_that("format_term_labels doesn't modify measure names", {
  # Measure names should pass through unchanged
  terms <- c("N", "R sq.", "AIC", "Adj. R sq.")

  result <- format_term_labels(terms)

  expect_equal(result, terms)
})

test_that("format_term_labels handles intercept", {
  terms <- c("(Intercept)")

  result <- format_term_labels(terms)

  # Intercept should be unchanged
  expect_equal(result, terms)
})

test_that("format_term_labels handles simple variable names", {
  terms <- c("wt", "hp", "qsec", "flipper_length_mm")

  result <- format_term_labels(terms)

  # Simple names without special patterns should be unchanged
  # unless they match abbreviation patterns
  expect_equal(result[1], "wt")
  expect_equal(result[2], "hp")
  expect_equal(result[3], "qsec")
  # flipper_length_mm is 17 chars, should be abbreviated (but stays same if not in mapping)
  expect_true(nchar(result[4]) <= nchar(terms[4]))
})

test_that("split_factor_level recognizes common levels", {
  levels_map <- list(
    advisor_confidence = c("low", "mid", "high"),
    var = c("yes", "no")
  )
  terms <- c("advisor_confidencelow", "advisor_confidencemid",
             "advisor_confidencehigh", "varyes", "varno")

  result <- vapply(
    terms,
    split_factor_level,
    character(1),
    levels_map = levels_map,
    USE.NAMES = FALSE
  )

  expect_equal(result[1], "advisor_confidence:low")
  expect_equal(result[2], "advisor_confidence:mid")
  expect_equal(result[3], "advisor_confidence:high")
  expect_equal(result[4], "var:yes")
  expect_equal(result[5], "var:no")
})

test_that("abbreviate_var_name handles long names", {
  expect_equal(abbreviate_var_name("financial_prudence"), "fina.prud")
  expect_equal(abbreviate_var_name("digital_confidence"), "digi.conf")
  expect_equal(abbreviate_var_name("advisor_confidence"), "advi.conf")

  # Test generic abbreviation for long unmapped names
  long_name <- "very_long_variable_name"
  result <- abbreviate_var_name(long_name)
  # Should be shorter than original
  expect_true(nchar(result) < nchar(long_name))

  # Short names should be unchanged
  expect_equal(abbreviate_var_name("short"), "short")
  expect_equal(abbreviate_var_name("wt"), "wt")
})
