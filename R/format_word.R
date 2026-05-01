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
  table$term <- wrap_interaction_terms(table$term, output = "word")

  row_types <- table$row_type
  table$row_type <- NULL

  wrap_model_header <- function(x, chunk = 11L) {
    if (is.na(x) || !nzchar(x) || grepl("\\s", x)) {
      return(x)
    }

    if (nchar(x) <= chunk + 1L) {
      return(x)
    }

    starts <- seq.int(1L, nchar(x), by = chunk)
    pieces <- substring(x, starts, pmin(starts + chunk - 1L, nchar(x)))
    paste(pieces, collapse = "\n")
  }

  set_word_widths <- function(ft, n_model_cols) {
    term_width <- if (n_model_cols <= 2) {
      1.91
    } else if (n_model_cols <= 4) {
      1.75
    } else {
      1.62
    }

    model_width <- if (n_model_cols <= 1) {
      1.70
    } else if (n_model_cols <= 2) {
      1.49
    } else if (n_model_cols <= 4) {
      1.30
    } else {
      1.05
    }

    ft <- flextable::width(ft, j = 1, width = term_width)

    if (n_model_cols > 0) {
      ft <- flextable::width(
        ft,
        j = seq.int(2L, n_model_cols + 1L),
        width = model_width
      )
    }

    flextable::set_table_properties(ft, layout = "fixed")
  }

  first_measure_row <- get_first_measure_row(table)
  display_headers <- names(table)
  display_headers[1] <- "Coefficient"
  if (length(display_headers) > 1) {
    display_headers[-1] <- vapply(
      display_headers[-1],
      wrap_model_header,
      character(1),
      USE.NAMES = FALSE
    )
  }

  # Create base flextable
  ft <- flextable::flextable(table) %>%
    flextable::add_footer_lines("Significance: ***p < .01; **p < .05; *p < .1 ")

  ft <- do.call(
    flextable::set_header_labels,
    c(list(x = ft), as.list(stats::setNames(display_headers, names(table))))
  )

  # Add zebra striping for coefficient rows only (skip control rows)
  if (!is.na(first_measure_row) && first_measure_row > 1) {
    stripe_count <- 0
    stripe_rows <- integer(0)

    for (row_idx in 1:(first_measure_row - 1)) {
      is_control <- !is.null(row_types) && row_types[row_idx] == "control"
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
    coefficient_line <- function(x) sub("\n.*$", "", x)

    # Highlight positive significant coefficients (green)
    for (i in 2:ncol(table)) {
      coef_lines <- coefficient_line(table[[i]])
      p_values <- grepl("\\*", coef_lines)
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
      coef_lines <- coefficient_line(table[[i]])
      p_values <- grepl("\\*", coef_lines) & grepl("^-", coef_lines)
      ft <- ft %>%
        flextable::bg(
          j = i,
          i = p_values,
          part = "body",
          bg = "#ffcccc"
      )
    }
  }

  ft <- set_word_widths(ft, ncol(table) - 1L)

  return(ft)
}
