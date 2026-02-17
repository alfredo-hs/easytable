
#' Format table for LaTeX/PDF output
#'
#' Creates a LaTeX table suitable for PDF documents. Uses booktabs styling
#' and includes significance footnotes via threeparttable package.
#'
#' @param table A transformed data frame from transform_table()
#' @param robust.se Logical indicating if robust standard errors were used
#' @param margins Logical indicating if marginal effects were computed
#' @param highlight Logical indicating whether to highlight significant results
#' @param table_size LaTeX size command: "tiny", "small", "normalsize", "scriptsize"
#'
#' @return A character string containing the LaTeX table code
#' @export
format_latex <- function(table,
                         robust.se = FALSE,
                         margins = FALSE,
                         highlight = FALSE,
                         table_size = "normalsize") {

  # Check that knitr is available
  if (!requireNamespace("knitr", quietly = TRUE)) {
    stop(
      "Package 'knitr' is required for LaTeX output.\n",
      "  Install it with: install.packages('knitr')",
      call. = FALSE
    )
  }

  table <- as.data.frame(table, stringsAsFactors = FALSE)
  table$term <- wrap_interaction_terms(table$term)

  # Replace underscores with periods for LaTeX compatibility
  # Periods don't need escaping and avoid LaTeX special character issues
  for (col in names(table)) {
    if (is.character(table[[col]])) {
      table[[col]] <- gsub("_", ".", table[[col]], fixed = TRUE)
    }
  }

  # Convert newlines in table cells to LaTeX line breaks
  for (j in 1:ncol(table)) {
    for (i in 1:nrow(table)) {
      cell <- table[i, j]
      # Check if cell contains a newline character (from parsing stage)
      if (grepl("\n", cell, fixed = TRUE)) {
        # Replace \n with \\ for LaTeX line break and wrap in shortstack
        cell <- gsub("\n", " \\\\\\\\ ", cell, fixed = TRUE)
        table[i, j] <- paste0("\\shortstack{", cell, "}")
      }
    }
  }

  # Identify where measures start (for horizontal line)
  first_measure_row <- get_first_measure_row(table)

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

    # Map LaTeX size commands to font sizes (in points)
    size_mapping <- c(
      "tiny" = 5,
      "scriptsize" = 7,
      "small" = 9,
      "normalsize" = 10
    )
    font_size_pt <- size_mapping[table_size]

    kbl <- kableExtra::kbl(
      table,
      format = "latex",
      booktabs = TRUE,
      escape = FALSE,
      col.names = names(table),
      align = c("l", rep("c", ncol(table) - 1))
    ) %>%
      kableExtra::kable_styling(
        latex_options = "hold_position",
        font_size = font_size_pt
      )

    # Add zebra striping for coefficient rows only (skip control variable rows)
    if (!is.na(first_measure_row) && first_measure_row > 1) {
      stripe_count <- 0
      for (row_idx in 1:(first_measure_row - 1)) {
        # Check if this is a control row (contains "Y" in any model column)
        is_control <- any(grepl("^Y$", table[row_idx, 2:ncol(table)]))

        if (!is_control) {
          stripe_count <- stripe_count + 1
          # Apply gray background to every other coefficient row
          if (stripe_count %% 2 == 0) {
            kbl <- kableExtra::row_spec(
              kbl,
              row_idx,
              background = "#f0f0f0"  # light gray
            )
          }
        }
      }
    }

    # Add horizontal line before measures
    if (!is.na(first_measure_row) && first_measure_row > 1) {
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

    # Add one divider line between coefficient and model-stat blocks
    if (!is.na(first_measure_row) && first_measure_row > 1) {
      lines <- strsplit(result, "\n", fixed = TRUE)[[1]]
      midrule_idx <- which(grepl("\\\\midrule", lines))[1]

      if (!is.na(midrule_idx)) {
        insert_after <- midrule_idx + (first_measure_row - 1)
        lines <- append(lines, "\\midrule", after = insert_after)
        result <- paste(lines, collapse = "\n")
      }
    }

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
