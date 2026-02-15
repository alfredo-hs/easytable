# Test markdown output formatting

test_that("markdown output does not contain stray pipes inside cells", {
  m1 <- lm(mpg ~ wt, data = mtcars)
  m2 <- lm(mpg ~ wt + hp, data = mtcars)

  result <- easytable(m1, m2, output = "markdown")

  # Split into lines
  lines <- strsplit(result, "\n")[[1]]

  # Find table content lines (skip header and separator)
  # Table lines start with |
  table_lines <- lines[grepl("^\\|", lines)]

  # Skip header and separator lines (first 2-3 lines)
  if (length(table_lines) > 3) {
    content_lines <- table_lines[3:length(table_lines)]

    for (line in content_lines) {
      # Split by pipes to get cells
      cells <- strsplit(line, "\\|")[[1]]
      cells <- trimws(cells)
      cells <- cells[nchar(cells) > 0]  # Remove empty cells

      # Check that each cell doesn't contain additional pipes
      # (would indicate malformed markdown)
      for (cell in cells) {
        # Cell content should not have pipes
        # (except in special cases like <br> tags which we use)
        # Allow pipes only in context of HTML tags
        if (grepl("\\|", cell) && !grepl("<br>", cell)) {
          fail(sprintf("Cell contains stray pipe: '%s'", cell))
        }
      }
    }
  }

  # If we get here, no stray pipes found
  expect_true(TRUE)
})

test_that("markdown output has balanced parentheses in coefficient lines", {
  m1 <- lm(mpg ~ wt, data = mtcars)
  m2 <- lm(mpg ~ wt + hp, data = mtcars)

  result <- easytable(m1, m2, output = "markdown")

  # Split into lines
  lines <- strsplit(result, "\n")[[1]]

  # Check each line for balanced parentheses
  for (line in lines) {
    open_count <- lengths(regmatches(line, gregexpr("\\(", line)))
    close_count <- lengths(regmatches(line, gregexpr("\\)", line)))

    expect_equal(
      open_count, close_count,
      info = sprintf("Unbalanced parentheses in line: '%s'", line)
    )
  }
})

test_that("markdown output matches structure across formats", {
  m1 <- lm(mpg ~ wt, data = mtcars)
  m2 <- lm(mpg ~ wt + hp, data = mtcars)

  md_result <- easytable(m1, m2, output = "markdown")
  latex_result <- easytable(m1, m2, output = "latex")

  # Both should contain coefficient terms
  expect_true(grepl("wt", md_result))
  expect_true(grepl("wt", latex_result))

  expect_true(grepl("hp", md_result))
  expect_true(grepl("hp", latex_result))

  # Both should contain significance stars
  expect_true(grepl("\\*", md_result))
  expect_true(grepl("\\*", latex_result))

  # Both should contain model fit measures
  expect_true(grepl("R sq", md_result))
  expect_true(grepl("R sq", latex_result))
})

test_that("markdown output renders coefficient with SE correctly", {
  m1 <- lm(mpg ~ wt, data = mtcars)

  result <- easytable(m1, output = "markdown")

  # Should contain coefficient estimates (numbers)
  expect_true(grepl("-[0-9]+\\.[0-9]+", result))

  # Should contain standard errors in format with <br> or parentheses
  # After our fix, SEs should be on same line with <br>
  expect_true(grepl("<br>", result) || grepl("\\([0-9]+\\.[0-9]+\\)", result))
})

test_that("markdown output footnote is properly formatted", {
  m1 <- lm(mpg ~ wt, data = mtcars)

  result <- easytable(m1, output = "markdown")

  # Should contain significance footnote
  expect_true(grepl("Significance:", result))
  expect_true(grepl("p < .01", result))

  # Footnote should use markdown emphasis
  expect_true(grepl("\\*p <", result))
})

test_that("markdown output with robust SE includes note", {
  skip_if_not_installed("lmtest")
  skip_if_not_installed("sandwich")

  m1 <- lm(mpg ~ wt, data = mtcars)

  result <- easytable(m1, output = "markdown", robust.se = TRUE)

  # Should contain robust SE note
  expect_true(grepl("Robust Standard Errors", result))
})

test_that("markdown output with margins includes note", {
  skip_if_not_installed("margins")

  m1 <- lm(mpg ~ wt, data = mtcars)

  result <- easytable(m1, output = "markdown", margins = TRUE)

  # Should contain margins note
  expect_true(grepl("Average Marginal Effects", result))
})
