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

#' Abbreviate variable name
#'
#' Abbreviates long variable names using either explicit mapping or
#' a deterministic algorithm based on underscore-separated tokens.
#'
#' @param var_name Character string with variable name
#' @return Abbreviated variable name
#' @keywords internal
abbreviate_var_name <- function(var_name) {
  # Explicit mapping for known variables
  abbrev_map <- c(
    "financial_prudence" = "fin.prud",
    "digital_confidence" = "dig_conf",
    "advisor_confidence" = "adv_conf"
  )

  # Check if variable is in explicit mapping
  if (var_name %in% names(abbrev_map)) {
    return(abbrev_map[[var_name]])
  }

  # For unmapped names, apply deterministic abbreviation
  # Only abbreviate if variable name is long enough (>15 chars) and has underscores
  if (nchar(var_name) > 15 && grepl("_", var_name)) {
    # Split on underscore, take prefix of each token, join with underscore
    tokens <- strsplit(var_name, "_")[[1]]
    # Take first 3-4 characters of each token
    abbreviated <- vapply(tokens, function(token) {
      if (nchar(token) <= 4) {
        return(token)
      } else {
        return(substring(token, 1, 4))
      }
    }, character(1))
    return(paste(abbreviated, collapse = "_"))
  }

  # Return original name if no abbreviation applies
  return(var_name)
}

#' Detect and split factor level suffix
#'
#' Detects if a term has a factor level concatenated directly to variable name
#' and splits it using a colon. Works for common factor levels and any
#' lowercase alphabetic suffix.
#'
#' @param term Character string with potential factor level concatenation
#' @return Character string with variable and level separated by colon
#' @keywords internal
split_factor_level <- function(term) {
  # Common factor level patterns (not exhaustive, but covers typical cases)
  # These are lowercase alphabetic strings that commonly appear as factor levels
  common_levels <- c("low", "mid", "high", "yes", "no", "male", "female",
                     "true", "false", "small", "medium", "large",
                     "never", "sometimes", "always", "rarely", "often")

  # Check if term ends with a common level (without underscore before it)
  for (level in common_levels) {
    # Pattern: variable name + level directly concatenated
    # Example: digital_confidencelow -> digital_confidence + low
    #          occupationno -> occupation + no
    # Important: level must NOT be preceded by underscore
    pattern <- paste0("^(.+[^_])(", level, ")$")
    if (grepl(pattern, term, perl = TRUE)) {
      var_part <- gsub(pattern, "\\1", term, perl = TRUE)
      # Split if either:
      # 1. Variable part has underscores (e.g., advisor_confidencelow), OR
      # 2. Variable part is reasonably long (>= 5 chars) to avoid splitting "varno"
      if (grepl("_", var_part) || nchar(var_part) >= 5) {
        replacement <- paste0(var_part, ":", level)
        return(replacement)
      }
    }
  }

  # Return unchanged if no pattern matches
  return(term)
}

#' Format term labels for display
#'
#' Applies formatting transformations to term labels:
#' 1. Convert polynomial suffixes to L indices (e.g., .Q -> :L1, .L -> :L2)
#' 2. Convert interaction colons to asterisks (e.g., varA:varB -> varA * varB)
#' 3. Separate factor levels with colon (e.g., advisor_confidencelow -> advisor_confidence:low)
#' 4. Abbreviate long variable names
#'
#' @param terms Character vector of term labels from models
#' @return Character vector of formatted term labels
#' @keywords internal
format_term_labels <- function(terms) {
  formatted <- terms

  # Step 1: Convert polynomial contrast suffixes to L indices
  # Map: .Q -> :L1, .L -> :L2, .C -> :L3
  formatted <- gsub("\\.Q", ":L1", formatted, fixed = FALSE)
  formatted <- gsub("\\.L", ":L2", formatted, fixed = FALSE)
  formatted <- gsub("\\.C", ":L3", formatted, fixed = FALSE)

  # Step 2: Convert interaction colons to asterisks with spaces
  # But NOT the colons we just added for polynomial terms (:L1, :L2, etc.)
  # Pattern: colon NOT followed by L and a digit
  formatted <- gsub(":(?!L[0-9])", " * ", formatted, perl = TRUE)

  # Step 3: Separate factor levels with colon
  # Process both standalone terms and parts within interactions
  for (i in seq_along(formatted)) {
    term <- formatted[i]

    # Check if this is an interaction (contains asterisk)
    if (grepl("\\*", term)) {
      # Split by asterisk, process each part, then rejoin
      parts <- strsplit(term, " \\* ")[[1]]
      for (j in seq_along(parts)) {
        part <- trimws(parts[j])
        # Skip if already has colon (polynomial or already split level)
        if (!grepl(":", part)) {
          parts[j] <- split_factor_level(part)
        }
      }
      formatted[i] <- paste(parts, collapse = " * ")
    } else {
      # Not an interaction, process the whole term
      # Skip if already has colon (polynomial or already split level)
      if (!grepl(":", term)) {
        formatted[i] <- split_factor_level(term)
      }
    }
  }

  # Step 4: Apply variable name abbreviations
  # Do this last so abbreviations are applied consistently everywhere
  for (i in seq_along(formatted)) {
    term <- formatted[i]

    # Extract all variable names from the term (before colons, around asterisks)
    # Split by special markers to identify variable names
    if (grepl("\\*", term)) {
      # Has interaction - process each part
      parts <- strsplit(term, " \\* ")[[1]]
      for (j in seq_along(parts)) {
        part <- trimws(parts[j])
        # Get variable name (before colon if present)
        if (grepl(":", part)) {
          var_level <- strsplit(part, ":")[[1]]
          var_name <- var_level[1]
          rest <- paste(var_level[-1], collapse = ":")
          abbrev <- abbreviate_var_name(var_name)
          parts[j] <- paste0(abbrev, ":", rest)
        } else {
          # No colon, just abbreviate the whole thing
          parts[j] <- abbreviate_var_name(part)
        }
      }
      formatted[i] <- paste(parts, collapse = " * ")
    } else if (grepl(":", term)) {
      # Has colon but no asterisk - likely var:level or var:L1
      var_rest <- strsplit(term, ":")[[1]]
      var_name <- var_rest[1]
      rest <- paste(var_rest[-1], collapse = ":")
      abbrev <- abbreviate_var_name(var_name)
      formatted[i] <- paste0(abbrev, ":", rest)
    } else {
      # Simple term, no special characters
      formatted[i] <- abbreviate_var_name(term)
    }
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
