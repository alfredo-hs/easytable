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

  # Calculate where to draw the horizontal line (before measures)
  measure_names <- c("N", "R sq.", "Adj. R sq.", "AIC")
  measure_rows <- sum(table$term %in% measure_names)
  hline_position <- nrow(table) - measure_rows

  # Create base flextable
  ft <- flextable::flextable(table) %>%
    flextable::add_footer_lines("Significance: ***p < .01; **p < .05; *p < .1 ") %>%
    flextable::hline(j = 1:ncol(table), i = hline_position)

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
