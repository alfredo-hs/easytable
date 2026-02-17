#' Collapse control variable rows
#'
#' Collapses multiple rows for control variables (including factor levels and
#' transformations) into a single row per control variable.
#'
#' @param table A data frame with regression results
#' @param control.var Character vector of control variable names to collapse
#'
#' @return A data frame with collapsed control variables
#' @keywords internal
collapse_control_vars <- function(table, control.var) {
  if (is.null(control.var) || length(control.var) == 0) {
    return(table)
  }

  result <- table

  for (var in control.var) {

    # Pattern 1: factor(var)... (e.g., factor(species)Chinstrap)
    pattern_factor <- sprintf("^factor\\(%s\\).*", var)
    result$term <- gsub(pattern_factor, var, result$term, perl = TRUE)

    # Pattern 2: log(var) (e.g., log(income))
    pattern_log <- sprintf("^log\\(%s\\)$", var)
    result$term <- gsub(pattern_log, var, result$term, perl = TRUE)

    # Pattern 3: Variable name directly followed by level names (e.g., speciesChinstrap)
    pattern_level <- sprintf("^%s[A-Z].*", var)
    result$term <- gsub(pattern_level, var, result$term, perl = TRUE)

    # Pattern 4: Variable name with transformations or interactions
    pattern_transform <- sprintf("^%s[^[:alnum:]_].*", var)
    result$term <- gsub(pattern_transform, var, result$term, perl = TRUE)
  }

  result
}

#' Mark control variables with 'Y' indicator
#'
#' Replaces coefficient values with "Y" for control variables to indicate
#' their presence in the model without showing individual coefficients.
#'
#' @param table A data frame with regression results
#' @param control.var Character vector of control variable names
#'
#' @return A data frame with control variables marked as "Y"
#' @keywords internal
mark_control_vars <- function(table, control.var) {
  if (is.null(control.var) || length(control.var) == 0) {
    return(table)
  }

  for (col in names(table)[-1]) {
    # TRUE only when this row is a control var AND the cell has a value
    replace_indices <- (table$term %in% control.var) & !is.na(table[[col]]) & (table[[col]] != "")
    table[replace_indices, col] <- "Y"
  }

  table
}

#' Remove duplicate control variable rows
#'
#' After collapsing control variables, removes duplicate rows but keeps
#' one representative row per control variable for each model.
#'
#' @param table A data frame with regression results
#'
#' @return A data frame with duplicates removed
#' @keywords internal
deduplicate_control_vars <- function(table) {

  result <- table

  for (col in names(result)[-1]) {
    duplicate_mask <- duplicated(result$term) & result[[col]] == "Y"
    duplicate_mask[is.na(duplicate_mask)] <- FALSE
    result <- result[!duplicate_mask, , drop = FALSE]
  }

  result
}

#' Sort table with control variables last
#'
#' Sorts the table so that control variables (marked with "Y") appear
#' after regular variables, ordered by how many models they appear in.
#'
#' @param table A data frame with regression results
#'
#' @return A sorted data frame
#' @keywords internal
sort_table <- function(table) {
  y_count <- apply(table[, -1, drop = FALSE], 1, function(row) sum(row == "Y"))
  table[order(y_count, decreasing = FALSE), , drop = FALSE]
}

#' Separate model statistics from coefficients
#'
#' Splits the table into coefficient rows and model-stat rows (control indicators,
#' N, R sq., etc.), removes empty stat rows, then recombines with stats at the bottom.
#'
#' @param table A data frame with regression results
#' @param control.var Character vector of control variable names
#'
#' @return A data frame with measures at the bottom
#' @keywords internal
separate_measures <- function(table, control.var = NULL) {
  measure_names <- get_measure_names()
  control_names <- if (is.null(control.var)) character(0) else control.var
  stat_terms <- unique(c(control_names, measure_names))

  stats <- table %>% dplyr::filter(term %in% stat_terms)

  # Remove stat rows with no data (all empty except term)
  stats <- stats[rowSums(stats[-1] != "") > 0, , drop = FALSE]
  if (nrow(stats) > 0) {
    stats_order <- match(stats$term, stat_terms)
    stats <- stats[order(stats_order), , drop = FALSE]
  }

  coefficients <- table %>% dplyr::filter(!term %in% stat_terms)

  result <- dplyr::bind_rows(coefficients, stats)
  attr(result, "stat_terms") <- stat_terms
  result
}

#' Transform parsed model table
#'
#' Main transformation function that handles control variables, sorting,
#' deduplication, organization, and term label formatting.
#'
#' @param parsed_table A data frame from parse_models()
#' @param control.var Character vector of control variable names
#' @param abbreviate Logical. Abbreviate variable names? Default FALSE
#'
#' @return A transformed data frame ready for formatting
#' @keywords internal
transform_table <- function(parsed_table, control.var = NULL, abbreviate = FALSE) {

  result <- parsed_table

  # Pull factor level map carried from parse_models()
  levels_map <- attr(parsed_table, "levels_map")

  # Handle control variables if specified
  if (!is.null(control.var)) {
    result <- collapse_control_vars(result, control.var)
    result <- mark_control_vars(result, control.var)
    result <- deduplicate_control_vars(result)
  }

  # Replace NA with empty string
  result[is.na(result)] <- ""

  # Drop rows that are fully empty artifacts (empty term and no model values)
  is_empty_row <- (result$term == "") &
    (rowSums(result[, -1, drop = FALSE] != "") == 0)
  result <- result[!is_empty_row, , drop = FALSE]

  # Sort table (control vars last)
  result <- sort_table(result)

  # Separate model-stat rows and put them at the bottom
  result <- separate_measures(result, control.var)

  # Format term labels for display (skip model-stat rows)
  stat_terms <- attr(result, "stat_terms")
  if (is.null(stat_terms) || length(stat_terms) == 0) {
    stat_terms <- get_measure_names()
  }
  non_measure_rows <- !result$term %in% stat_terms

  result$term[non_measure_rows] <- format_term_labels(
    result$term[non_measure_rows],
    levels_map = levels_map,
    abbreviate = abbreviate
  )

  attr(result, "stat_terms") <- stat_terms

  result
}
