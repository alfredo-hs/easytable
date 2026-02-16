
#' Format table for LaTeX/PDF output
#'
#' Creates a LaTeX table suitable for PDF documents. Uses booktabs styling
#' and includes significance footnotes via threeparttable package.
#'
#' @param table A transformed data frame from transform_table()
#' @param robust.se Logical indicating if robust standard errors were used
#' @param margins Logical indicating if marginal effects were computed
#' @param highlight Logical indicating whether to highlight significant results
#'
#' @return A character string containing the LaTeX table code
#' @export
format_latex <- function(table,
                         robust.se = FALSE,
                         margins = FALSE,
                         highlight = FALSE) {

  # Check that knitr is available
  if (!requireNamespace("knitr", quietly = TRUE)) {
    stop(
      "Package 'knitr' is required for LaTeX output.\n",
      "  Install it with: install.packages('knitr')",
      call. = FALSE
    )
  }

  # Replace underscores with periods for LaTeX compatibility
  # Periods don't need escaping and avoid LaTeX special character issues
  for (col in names(table)) {
    if (is.character(table[[col]])) {
      table[[col]] <- gsub("_", ".", table[[col]], fixed = TRUE)
    }
  }

  # Identify where measures start (for horizontal line)
  measure_names <- c("N", "R sq.", "Adj. R sq.", "AIC")
  first_measure_row <- which(table$term %in% measure_names)[1]

  # Build footnote text
  footnote_text <- "Significance: ***p < .01; **p < .05; *p < .1"

  if (robust.se == TRUE & margins == FALSE) {
    footnote_text <- paste0(footnote_text, ". Note: Robust Standard Errors")
  }

  if (robust.se == FALSE & margins == TRUE) {
    footnote_text <- paste0(footnote_text, ". Note: Average Marginal Effects (AME)")
  }

  if (robust.se == TRUE & margins == TRUE) {
    footnote_text <- paste0(footnote_text, ". Note: Marginal Effects and Robust Standard Errors")
  }

  # Use kableExtra if available for better LaTeX formatting
  if (requireNamespace("kableExtra", quietly = TRUE)) {

    # Apply cell-level highlighting if requested (before creating kbl)
    if (highlight) {
      # Only color coefficient columns (2+), not term column
      for (j in 2:ncol(table)) {
        for (i in 1:nrow(table)) {
          cell_value <- table[i, j]
          # Check if cell contains significance stars
          if (grepl("\\*", cell_value)) {
            # Check if negative (has minus sign before digits)
            if (grepl("-\\d+(\\.\\d+)?\\s*\\*", cell_value)) {
              # Negative significant: red background
              table[i, j] <- kableExtra::cell_spec(
                cell_value,
                format = "latex",
                background = "#ffcccc",
                escape = FALSE
              )
            } else {
              # Positive significant: green background
              table[i, j] <- kableExtra::cell_spec(
                cell_value,
                format = "latex",
                background = "#e6ffe6",
                escape = FALSE
              )
            }
          }
        }
      }
    }

    kbl <- kableExtra::kbl(
      table,
      format = "latex",
      booktabs = TRUE,
      escape = FALSE,
      col.names = names(table),
      align = c("l", rep("c", ncol(table) - 1))
    ) %>%
      kableExtra::kable_styling(
        latex_options = "hold_position"
      )

    # Add horizontal line before measures
    if (!is.na(first_measure_row)) {
      kbl <- kableExtra::row_spec(
        kbl,
        first_measure_row - 1,
        hline_after = TRUE
      )
    }

    # Add footnote
    kbl <- kableExtra::footnote(
      kbl,
      general = footnote_text,
      general_title = "",
      threeparttable = TRUE
    )

    result <- kbl

  } else {
    # Fallback to basic knitr::kable
    result <- knitr::kable(
      table,
      format = "latex",
      booktabs = TRUE,
      escape = FALSE,
      col.names = names(table),
      align = c("l", rep("c", ncol(table) - 1))
    )

    # Add footnote manually
    result <- paste0(
      result,
      "\n\\\\",
      "\n\\multicolumn{", ncol(table), "}{l}{\\textit{", footnote_text, "}}",
      "\n"
    )

    if (!requireNamespace("kableExtra", quietly = TRUE)) {
      result <- paste0(
        result,
        "\n% Note: Install 'kableExtra' for enhanced LaTeX formatting\n"
      )
    }
  }

  return(result)
}
