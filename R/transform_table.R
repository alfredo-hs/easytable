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
    # Fix the greedy regex issue from original code
    # Use word boundaries and more specific patterns to avoid matching
    # variables like "hp" when looking for "h" or "hpq" when looking for "hp"

    # Pattern 1: factor(var)... (e.g., factor(species)Chinstrap)
    # Use word boundaries to ensure exact variable name match
    pattern_factor <- sprintf("^factor\\(%s\\).*", var)
    result$term <- gsub(pattern_factor, var, result$term, perl = TRUE)

    # Pattern 2: log(var) (e.g., log(income))
    pattern_log <- sprintf("^log\\(%s\\)$", var)
    result$term <- gsub(pattern_log, var, result$term, perl = TRUE)

    # Pattern 3: Variable name directly followed by level names (e.g., speciesChinstrap)
    # This is the most common format from broom::tidy()
    # Match var followed by an uppercase letter (factor level)
    pattern_level <- sprintf("^%s[A-Z].*", var)
    result$term <- gsub(pattern_level, var, result$term, perl = TRUE)

    # Pattern 4: Variable name with transformations or interactions
    # Match var at start, followed by non-word character
    # This prevents "hp" from matching "hpq"
    pattern_transform <- sprintf("^%s[^[:alnum:]_].*", var)
    result$term <- gsub(pattern_transform, var, result$term, perl = TRUE)
  }

  return(result)
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

  # For each model column (excluding the term column)
  for (col in names(table)[-1]) {
    # Find rows where term is a control variable and cell is not empty
    replace_indices <- table$term %in% control.var & !is.na(table[[col]])
    table[replace_indices, col] <- "Y"
  }

  return(table)
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
  # Strategy: For each model column, remove duplicates where the value is "Y"
  # Keep the first occurrence of each control variable

  result <- table

  # Process each model column
  for (col in names(result)[-1]) {
    # Identify rows that are duplicated AND have "Y" in this column
    duplicate_mask <- duplicated(result$term) & result[[col]] == "Y"

    # Remove those rows
    result <- result[!duplicate_mask, ]
  }

  return(result)
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
  # Calculate how many "Y"s each row has (indicating control var presence)
  y_count <- apply(table[, -1, drop = FALSE], 1, function(row) sum(row == "Y"))

  # Sort by number of "Y"s (ascending, so regular vars come first)
  table <- table[order(y_count, decreasing = FALSE), ]

  return(table)
}

#' Separate measures from coefficients
#'
#' Splits the table into coefficient rows and measure rows (N, R sq., etc.),
#' removes empty measure rows, then recombines with measures at the bottom.
#'
#' @param table A data frame with regression results
#'
#' @return A data frame with measures at the bottom
#' @keywords internal
separate_measures <- function(table) {
  measure_names <- c("N", "R sq.", "Adj. R sq.", "AIC")

  # Extract measures
  measures <- table %>% dplyr::filter(term %in% measure_names)

  # Remove measure rows with no data (all empty except term)
  measures <- measures[rowSums(measures[-1] != "") > 0, ]

  # Extract coefficients (everything else)
  coefficients <- table %>% dplyr::filter(!term %in% measure_names)

  # Recombine with measures at bottom
  result <- dplyr::bind_rows(coefficients, measures)

  return(result)
}

#' Transform parsed model table
#'
#' Main transformation function that handles control variables, sorting,
#' deduplication, and organization of the results table.
#'
#' @param parsed_table A data frame from parse_models()
#' @param control.var Character vector of control variable names
#'
#' @return A transformed data frame ready for formatting
#' @keywords internal
transform_table <- function(parsed_table, control.var = NULL) {

  result <- parsed_table

  # Handle control variables if specified
  if (!is.null(control.var)) {
    result <- collapse_control_vars(result, control.var)
    result <- mark_control_vars(result, control.var)
    result <- deduplicate_control_vars(result)
  }

  # Replace NA with empty string
  result[is.na(result)] <- ""

  # Sort table (control vars last)
  result <- sort_table(result)

  # Separate measures and put them at the bottom
  result <- separate_measures(result)

  return(result)
}
