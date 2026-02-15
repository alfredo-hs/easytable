# Test term label formatting

test_that("format_term_labels handles polynomial suffixes", {
  terms <- c("financial_prudence.Q", "financial_prudence.L", "var.C")

  result <- format_term_labels(terms)

  # Note: abbreviations are also applied
  expect_equal(result[1], "fin.prud:L1")
  expect_equal(result[2], "fin.prud:L2")
  expect_equal(result[3], "var:L3")
})

test_that("format_term_labels separates factor levels", {
  terms <- c("digital_confidencelow", "occupationno_activity")

  result <- format_term_labels(terms)

  # Note: abbreviations are also applied to digital_confidence
  expect_equal(result[1], "dig_conf:low")
  # This one should separate occupation and no_activity
  expect_equal(result[2], "occupation:no_activity")
})

test_that("format_term_labels converts interaction colons to asterisks", {
  # After polynomial conversion, interactions should use asterisks
  terms <- c("var1.L:var2", "var1:var2")

  result <- format_term_labels(terms)

  # Should have asterisk for interaction
  expect_true(grepl("\\*", result[1]))
  expect_true(grepl("\\*", result[2]))

  # But polynomial :L2 should remain
  expect_true(grepl(":L2", result[1]))
})

test_that("format_term_labels applies abbreviations", {
  terms <- c("financial_prudence", "digital_confidence")

  result <- format_term_labels(terms)

  # Simple variable names get abbreviation applied
  expect_equal(result[1], "fin.prud")
  expect_equal(result[2], "dig_conf")
})

test_that("format_term_labels handles complex combined terms", {
  # Complex example from requirements:
  # financial_prudence.L:digital_confidencelow -> fin.prud:L2 * dig_conf:low
  terms <- c("financial_prudence.L:digital_confidencelow")

  result <- format_term_labels(terms)

  # Should have:
  # - polynomial :L2
  # - factor level :low
  # - interaction *
  # - abbreviations fin.prud and dig_conf
  expect_true(grepl("fin.prud", result[1]))
  expect_true(grepl("dig_conf", result[1]))
  expect_true(grepl(":L2", result[1]))
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
  expect_equal(result[1], "wt")
  expect_equal(result[2], "hp")
  expect_equal(result[3], "qsec")
  expect_equal(result[4], "flipper_length_mm")
})
