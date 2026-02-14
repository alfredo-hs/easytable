#' Format table for Markdown output
#'
#' Creates a markdown table suitable for Quarto and RMarkdown documents.
#' Includes significance footnotes and optional highlighting via kableExtra.
#'
#' @param table A transformed data frame from transform_table()
#' @param robust.se Logical indicating if robust standard errors were used
#' @param margins Logical indicating if marginal effects were computed
#' @param highlight Logical indicating whether to highlight significant results
#'
#' @return A character string containing the markdown table
#' @export
format_markdown <- function(table,
                             robust.se = FALSE,
                             margins = FALSE,
                             highlight = FALSE) {

  # Check that knitr is available
  if (!requireNamespace("knitr", quietly = TRUE)) {
    stop(
      "Package 'knitr' is required for Markdown output.\n",
      "  Install it with: install.packages('knitr')",
      call. = FALSE
    )
  }

  # Identify where measures start (for horizontal line)
  measure_names <- c("N", "R sq.", "Adj. R sq.", "AIC")
  first_measure_row <- which(table$term %in% measure_names)[1]

  # Create base markdown table
  if (requireNamespace("kableExtra", quietly = TRUE) && highlight) {
    # Use kableExtra for enhanced formatting with highlighting
    kbl <- kableExtra::kbl(
      table,
      format = "markdown",
      col.names = names(table),
      align = c("l", rep("c", ncol(table) - 1))
    )

    # Add horizontal line before measures
    if (!is.na(first_measure_row)) {
      kbl <- kableExtra::row_spec(
        kbl,
        first_measure_row - 1,
        extra_css = "border-bottom: 2px solid #000;"
      )
    }

    # Highlight significant positive coefficients (green)
    for (i in 2:ncol(table)) {
      sig_rows <- which(grepl("\\*", table[[i]]) & !grepl("-\\d+(\\.\\d+)? \\*", table[[i]]))
      if (length(sig_rows) > 0) {
        kbl <- kableExtra::column_spec(
          kbl,
          column = i,
          background = ifelse(
            seq_len(nrow(table)) %in% sig_rows,
            "#e6ffe6",
            "white"
          )
        )
      }
    }

    # Highlight significant negative coefficients (red)
    for (i in 2:ncol(table)) {
      neg_sig_rows <- which(grepl("-\\d+(\\.\\d+)? \\*", table[[i]]))
      if (length(neg_sig_rows) > 0) {
        kbl <- kableExtra::column_spec(
          kbl,
          column = i,
          background = ifelse(
            seq_len(nrow(table)) %in% neg_sig_rows,
            "#ffcccc",
            "white"
          )
        )
      }
    }

    result <- kbl

  } else {
    # Use basic knitr::kable for simple markdown
    result <- knitr::kable(
      table,
      format = "markdown",
      col.names = names(table),
      align = c("l", rep("c", ncol(table) - 1))
    )
  }

  # Build footnote text
  footnote_lines <- c()
  footnote_lines <- c(footnote_lines, "\n*Significance: ***p < .01; **p < .05; *p < .1*")

  if (robust.se == TRUE & margins == FALSE) {
    footnote_lines <- c(footnote_lines, "*Note: Robust Standard Errors*")
  }

  if (robust.se == FALSE & margins == TRUE) {
    footnote_lines <- c(footnote_lines, "*Note: Average Marginal Effects (AME)*")
  }

  if (robust.se == TRUE & margins == TRUE) {
    footnote_lines <- c(footnote_lines, "*Note: Marginal Effects and Robust Standard Errors*")
  }

  if (highlight && !requireNamespace("kableExtra", quietly = TRUE)) {
    footnote_lines <- c(
      footnote_lines,
      "*Note: Install 'kableExtra' package for highlighted output*"
    )
  }

  # Combine table and footnotes
  result <- paste(c(result, "", footnote_lines), collapse = "\n")

  return(result)
}
