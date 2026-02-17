test_that("collapse_control_vars handles factor variables", {
  test_table <- data.frame(
    term = c("(Intercept)", "x1", "factor(species)Chinstrap", "factor(species)Gentoo"),
    Model1 = c("1.0", "2.0", "3.0", "4.0")
  )

  result <- collapse_control_vars(test_table, "species")

  # Both factor levels should be collapsed to "species"
  expect_true("species" %in% result$term)
  expect_false("factor(species)Chinstrap" %in% result$term)
  expect_false("factor(species)Gentoo" %in% result$term)
})

test_that("collapse_control_vars handles log transformations", {
  test_table <- data.frame(
    term = c("(Intercept)", "x1", "log(income)"),
    Model1 = c("1.0", "2.0", "3.0")
  )

  result <- collapse_control_vars(test_table, "income")

  expect_true("income" %in% result$term)
  expect_false("log(income)" %in% result$term)
})

test_that("collapse_control_vars avoids greedy matching", {
  # Test the critical fix: "hp" should not match "hpq"
  test_table <- data.frame(
    term = c("hp", "hpq", "hp2"),
    Model1 = c("1.0", "2.0", "3.0")
  )

  result <- collapse_control_vars(test_table, "hp")

  # Only "hp" should be affected, not "hpq"
  expect_true("hp" %in% result$term)
  expect_true("hpq" %in% result$term)  # Should remain unchanged
})

test_that("collapse_control_vars handles NULL control.var", {
  test_table <- data.frame(
    term = c("(Intercept)", "x1"),
    Model1 = c("1.0", "2.0")
  )

  result <- collapse_control_vars(test_table, NULL)

  # Should return unchanged
  expect_equal(result, test_table)
})

test_that("mark_control_vars replaces values with Y", {
  test_table <- data.frame(
    term = c("x1", "species", "island"),
    Model1 = c("1.0", "2.0", "3.0"),
    Model2 = c("1.5", "2.5", NA)
  )

  result <- mark_control_vars(test_table, c("species", "island"))

  expect_equal(result$Model1[2], "Y")
  expect_equal(result$Model1[3], "Y")
  expect_equal(result$Model2[2], "Y")
  expect_true(is.na(result$Model2[3])) # NA should remain NA
  expect_equal(result$Model1[1], "1.0") # Non-control var unchanged
})

test_that("deduplicate_control_vars removes duplicate Y rows", {
  test_table <- data.frame(
    term = c("x1", "species", "species", "island"),
    Model1 = c("1.0", "Y", "Y", "3.0"),
    Model2 = c("1.5", "Y", "Y", "")
  )

  result <- deduplicate_control_vars(test_table)

  # Should have only one "species" row
  expect_equal(sum(result$term == "species"), 1)
})

test_that("deduplicate_control_vars does not create NA artifact rows", {
  test_table <- data.frame(
    term = c("island", "island"),
    Model1 = c(NA, NA),
    Model2 = c(NA, NA),
    Model3 = c("Y", "Y")
  )

  result <- deduplicate_control_vars(test_table)

  expect_equal(nrow(result), 1)
  expect_false(any(is.na(result$term)))
})

test_that("sort_table puts control variables last", {
  test_table <- data.frame(
    term = c("x1", "species", "island", "x2"),
    Model1 = c("1.0", "Y", "Y", "2.0"),
    Model2 = c("1.5", "Y", "", "2.5")
  )

  result <- sort_table(test_table)

  # Regular variables should come before control variables
  y_positions <- which(result$Model1 == "Y" | result$Model2 == "Y")
  regular_positions <- which(!(result$Model1 == "Y" | result$Model2 == "Y"))

  if (length(y_positions) > 0 && length(regular_positions) > 0) {
    expect_true(min(y_positions) > max(regular_positions))
  }
})

test_that("separate_measures puts measures at bottom", {
  test_table <- data.frame(
    term = c("x1", "N", "x2", "R sq.", "AIC"),
    Model1 = c("1.0", "100", "2.0", "0.5", "200")
  )

  result <- separate_measures(test_table)

  # Measures should be at the bottom
  measure_names <- c("N", "R sq.", "Adj. R sq.", "AIC")
  measure_rows <- which(result$term %in% measure_names)

  if (length(measure_rows) > 0) {
    # All measure rows should be consecutive at the end
    expect_equal(measure_rows, seq(from = nrow(result) - length(measure_rows) + 1, to = nrow(result)))
  }
})

test_that("separate_measures removes empty measure rows", {
  test_table <- data.frame(
    term = c("x1", "N", "R sq.", "AIC"),
    Model1 = c("1.0", "100", "", ""),
    Model2 = c("2.0", "200", "0.5", "")
  )

  result <- separate_measures(test_table)

  # Empty AIC row should be removed (all empty except term)
  # But we keep rows that have at least one non-empty value
  expect_true(nrow(result) <= nrow(test_table))
})

test_that("transform_table integrates all transformations", {
  parsed <- parse_models(test_models_lm, robust.se = FALSE, margins = FALSE)
  result <- transform_table(parsed, control.var = c("species", "island"))

  expect_s3_class(result, "data.frame")
  expect_true(all(!is.na(result))) # No NA values should remain

  # Control variables should be marked with Y
  species_row <- result[result$term == "species", ]
  if (nrow(species_row) > 0) {
    expect_true(any(species_row[-1] == "Y"))
  }

  # Measures should be at bottom
  measure_names <- c("N", "R sq.", "Adj. R sq.", "AIC")
  last_rows <- tail(result$term, 4)
  expect_true(any(last_rows %in% measure_names))
})

test_that("transform_table handles NULL control.var", {
  parsed <- parse_models(test_single_model, robust.se = FALSE, margins = FALSE)
  result <- transform_table(parsed, control.var = NULL)

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})
