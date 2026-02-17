
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

  # Identify where model-stat rows start (before LaTeX-safe term normalization)
  first_measure_row <- get_first_measure_row(table)

  insert_measure_divider <- function(result, table, first_measure_row) {
    if (is.na(first_measure_row) || first_measure_row <= 1) {
      return(result)
    }

    first_measure_term <- table$term[first_measure_row]
    lines <- strsplit(result, "\n", fixed = TRUE)[[1]]
    measure_prefix <- paste0(first_measure_term, " &")
    measure_line_idx <- which(startsWith(lines, measure_prefix))[1]

    if (is.na(measure_line_idx)) {
      return(result)
    }

    # Remove default kable spacing row immediately before the measure block.
    if (measure_line_idx > 1 && identical(lines[measure_line_idx - 1], "\\addlinespace")) {
      lines <- lines[-(measure_line_idx - 1)]
      measure_line_idx <- measure_line_idx - 1
    }

    if (measure_line_idx > 1 && identical(lines[measure_line_idx - 1], "\\midrule")) {
      return(paste(lines, collapse = "\n"))
    }

    lines <- append(lines, "\\midrule", after = measure_line_idx - 1)
    paste(lines, collapse = "\n")
  }

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

  # Determine coefficient rows and zebra parity (controls excluded from stripe count)
  coef_row_indices <- if (!is.na(first_measure_row) && first_measure_row > 1) {
    seq_len(first_measure_row - 1)
  } else {
    seq_len(nrow(table))
  }

  striped_row <- rep(FALSE, nrow(table))
  stripe_count <- 0
  if (length(coef_row_indices) > 0) {
    for (row_idx in coef_row_indices) {
      is_control <- any(grepl("^Y$", table[row_idx, 2:ncol(table)]))
      if (!is_control) {
        stripe_count <- stripe_count + 1
        striped_row[row_idx] <- (stripe_count %% 2 == 0)
      }
    }
  }

  # Use kableExtra if available for better LaTeX formatting
  if (requireNamespace("kableExtra", quietly = TRUE)) {

    # Apply cell-level styling so zebra and highlight can coexist.
    if (length(coef_row_indices) > 0) {
      for (i in coef_row_indices) {
        is_striped <- striped_row[i]

        # Style term column only for zebra rows
        if (is_striped) {
          table[i, 1] <- kableExtra::cell_spec(
            table[i, 1],
            format = "latex",
            background = "#f0f0f0",
            escape = FALSE
          )
        }

        for (j in 2:ncol(table)) {
          cell_value <- table[i, j]
          is_sig <- isTRUE(highlight) && grepl("\\*", cell_value)

          if (!is_striped && !is_sig) {
            next
          }

          bg_color <- if (is_striped) "#f0f0f0" else "white"

          if (is_sig) {
            is_negative <- grepl("-\\d+(\\.\\d+)?\\s*\\*", cell_value)
            bg_color <- if (is_negative) {
              if (is_striped) "#f0b8b8" else "#ffcccc"
            } else {
              if (is_striped) "#cfeacf" else "#e6ffe6"
            }
          }

          table[i, j] <- kableExtra::cell_spec(
            cell_value,
            format = "latex",
            background = bg_color,
            escape = FALSE
          )
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
      longtable = TRUE,
      booktabs = TRUE,
      linesep = "",
      escape = FALSE,
      col.names = names(table),
      align = c("l", rep("c", ncol(table) - 1))
    ) %>%
      kableExtra::kable_styling(
        latex_options = c("repeat_header"),
        font_size = font_size_pt
      )

    # Add footnote
    kbl <- kableExtra::footnote(
      kbl,
      general = footnote_text,
      general_title = "",
      threeparttable = FALSE
    )

    result <- as.character(kbl)

    # Add one clean divider line between coefficient and model-stat blocks
    result <- insert_measure_divider(result, table, first_measure_row)

  } else {
    # Fallback to basic knitr::kable
    result <- knitr::kable(
      table,
      format = "latex",
      longtable = TRUE,
      booktabs = TRUE,
      linesep = "",
      escape = FALSE,
      col.names = names(table),
      align = c("l", rep("c", ncol(table) - 1))
    )

    # Add one divider line between coefficient and model-stat blocks
    result <- insert_measure_divider(result, table, first_measure_row)

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

  return(knitr::asis_output(result))
}
