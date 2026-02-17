#' Format table for Word output
#'
#' Creates a flextable object formatted for Microsoft Word documents.
#' Includes significance footnotes, optional highlighting, and notes about
#' robust standard errors or marginal effects.
#'
#' @param table A transformed data frame from transform_table()
#' @param robust.se Logical indicating if robust standard errors were used
#' @param margins Logical indicating if marginal effects were computed
#' @param highlight Logical indicating whether to highlight significant results
#'
#' @return A flextable object ready for export to Word
#' @export
format_word <- function(table,
                        robust.se = FALSE,
                        margins = FALSE,
                        highlight = FALSE) {

  # Check that flextable is available
  if (!requireNamespace("flextable", quietly = TRUE)) {
    stop(
      "Package 'flextable' is required for Word output.\n",
      "  Install it with: install.packages('flextable')",
      call. = FALSE
    )
  }

  table <- as.data.frame(table, stringsAsFactors = FALSE)
  table$term <- wrap_interaction_terms(table$term)

  first_measure_row <- get_first_measure_row(table)

  # Create base flextable
  ft <- flextable::flextable(table) %>%
    flextable::add_footer_lines("Significance: ***p < .01; **p < .05; *p < .1 ")

  # Add zebra striping for coefficient rows only (skip control rows)
  if (!is.na(first_measure_row) && first_measure_row > 1) {
    stripe_count <- 0
    stripe_rows <- integer(0)

    for (row_idx in 1:(first_measure_row - 1)) {
      is_control <- any(table[row_idx, 2:ncol(table), drop = TRUE] == "Y")
      if (!is_control) {
        stripe_count <- stripe_count + 1
        if (stripe_count %% 2 == 0) {
          stripe_rows <- c(stripe_rows, row_idx)
        }
      }
    }

    if (length(stripe_rows) > 0) {
      ft <- ft %>%
        flextable::bg(
          i = stripe_rows,
          j = 1:ncol(table),
          part = "body",
          bg = "#f0f0f0"
        )
    }
  }

  # Draw one divider between coefficient and model-stat blocks
  if (!is.na(first_measure_row) && first_measure_row > 1) {
    ft <- ft %>%
      flextable::hline(j = 1:ncol(table), i = first_measure_row - 1, part = "body")
  }

  # Add notes about estimation method
  if (robust.se == TRUE & margins == FALSE) {
    ft <- ft %>%
      flextable::add_footer_lines("Note: Robust Standard Errors")
  }

  if (robust.se == FALSE & margins == TRUE) {
    ft <- ft %>%
      flextable::add_footer_lines("Note: Average Marginal Effects (AME)")
  }

  if (robust.se == TRUE & margins == TRUE) {
    ft <- ft %>%
      flextable::add_footer_lines("Note: Marginal Effects and Robust Standard Errors")
  }

  # Apply highlighting if requested
  if (highlight) {
    # Highlight positive significant coefficients (green)
    for (i in 2:ncol(table)) {
      p_values <- grepl("\\*", table[[i]])
      ft <- ft %>%
        flextable::bg(
          j = i,
          i = p_values,
          part = "body",
          bg = "#e6ffe6"
        )
    }

    # Highlight negative significant coefficients (red)
    for (i in 2:ncol(table)) {
      p_values <- grepl("-\\d+(\\.\\d+)? \\*", table[[i]])
      ft <- ft %>%
        flextable::bg(
          j = i,
          i = p_values,
          part = "body",
          bg = "#ffcccc"
        )
    }
  }

  return(ft)
}
