#' Check if a package is available
#'
#' @param pkg Character string with package name
#' @return Logical indicating if package is installed
#' @keywords internal
is_package_available <- function(pkg) {
  requireNamespace(pkg, quietly = TRUE)
}

#' Get measure row names
#'
#' Returns the standard names used for model fit measures
#'
#' @return Character vector of measure names
#' @keywords internal
get_measure_names <- function() {
  c("N", "R sq.", "Adj. R sq.", "AIC")
}

#' Format term labels for display
#'
#' Applies formatting transformations to term labels:
#' 1. Convert polynomial suffixes to L indices (e.g., .Q -> :L1, .L -> :L2)
#' 2. Separate factor levels with colon (e.g., digital_confidencelow -> digital_confidence:low)
#' 3. Convert interaction colons to asterisks (e.g., varA:varB -> varA * varB)
#' 4. Abbreviate long variable names using a predefined mapping
#'
#' @param terms Character vector of term labels from models
#' @return Character vector of formatted term labels
#' @keywords internal
format_term_labels <- function(terms) {
  # Variable abbreviation mapping - minimal and conservative
  abbrev_map <- c(
    "financial_prudence" = "fin.prud",
    "digital_confidence" = "dig_conf"
  )

  formatted <- terms

  # Step 1: Convert polynomial contrast suffixes to L indices
  # Map: .Q -> :L1, .L -> :L2, .C -> :L3
  # Do this first before handling interactions
  formatted <- gsub("\\.Q", ":L1", formatted, fixed = FALSE)
  formatted <- gsub("\\.L", ":L2", formatted, fixed = FALSE)
  formatted <- gsub("\\.C", ":L3", formatted, fixed = FALSE)

  # Step 2: Convert interaction colons to asterisks
  # But NOT the colons we just added for polynomial terms (:L1, :L2, etc.)
  # Pattern: colon NOT followed by L and a digit
  formatted <- gsub(":(?!L[0-9])", " * ", formatted, perl = TRUE)

  # Step 3: Separate factor levels with colon
  # After interaction conversion, some terms may have asterisks
  # We need to handle both standalone terms and parts of interactions
  # IMPORTANT: Only do this for known factor variables, not generic variables
  # This prevents false matches like flipper_length_mm -> flipper_length:mm

  # List of known factor variables that get levels appended
  factor_vars <- c("digital_confidence", "occupation", "financial_prudence")

  for (i in seq_along(formatted)) {
    term <- formatted[i]

    # Check if this is an interaction (has asterisk)
    if (grepl("\\*", term)) {
      # Split by asterisk and process each part
      parts <- strsplit(term, " \\* ")[[1]]
      for (j in seq_along(parts)) {
        part <- parts[j]
        # For each part, check if it needs factor level separation
        for (var_name in factor_vars) {
          # Skip if part already has colon (except for polynomial :L markers)
          if (grepl(paste0(var_name, ":L[0-9]"), part)) {
            next  # This is a polynomial, keep it as-is
          }
          if (startsWith(part, var_name) && nchar(part) > nchar(var_name)) {
            # Extract what comes after the variable name
            remainder <- substring(part, nchar(var_name) + 1)
            # If remainder is lowercase letters (possibly with underscores), it's a level
            if (nchar(remainder) > 0 && grepl("^[a-z_]+$", remainder)) {
              parts[j] <- paste0(var_name, ":", remainder)
              break
            }
          }
        }
      }
      # Rejoin with asterisk
      formatted[i] <- paste(parts, collapse = " * ")
    } else {
      # Not an interaction, process the whole term
      # Skip if already has colon
      if (grepl(":", term)) {
        next
      }

      # Check if the term matches a known factor variable with something appended
      for (var_name in factor_vars) {
        if (startsWith(term, var_name) && nchar(term) > nchar(var_name)) {
          # Extract what comes after the variable name
          remainder <- substring(term, nchar(var_name) + 1)
          # If remainder is lowercase letters (possibly with underscores), it's a level
          if (nchar(remainder) > 0 && grepl("^[a-z_]+$", remainder)) {
            formatted[i] <- paste0(var_name, ":", remainder)
            break
          }
        }
      }
    }
  }

  # Step 4: Apply variable abbreviations
  # Do this last so abbreviations are applied to all variable occurrences
  for (old_name in names(abbrev_map)) {
    new_name <- abbrev_map[[old_name]]
    # Replace the variable name wherever it appears
    # Be careful to do whole-word replacement
    formatted <- gsub(old_name, new_name, formatted, fixed = TRUE)
  }

  return(formatted)
}

#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @return The result of calling `rhs(lhs)`.
NULL
