#' Check if a package is available
#' @keywords internal
is_package_available <- function(pkg) {
  requireNamespace(pkg, quietly = TRUE)
}

#' Get measure row names
#' @keywords internal
get_measure_names <- function() {
  c("N", "R sq.", "Adj. R sq.", "AIC")
}

#' Abbreviate variable name
#'
#' Deterministic abbreviation rules:
#' - Short readable names remain unchanged
#' - "_" and "." treated as token separators
#' - Tokens shortened and joined with "."
#' - Long single tokens truncated to stable prefix
#' - Mixed alphanumeric IDs collapse to short prefix
#'
#' @keywords internal
abbreviate_var_name <- function(var_name,
                                min_keep_len = 8,
                                token_chars = 3,
                                max_tokens = 2,
                                id_prefix_chars = 4) {

  if (is.na(var_name) || !nzchar(var_name)) return(var_name)

  n <- nchar(var_name)

  # Keep short names unchanged
  if (n <= min_keep_len) return(var_name)

  take <- function(x, k) {
    if (nchar(x) <= k) x else substring(x, 1, k)
  }

  # Tokenised names: snake_case or dot.case
  if (grepl("[_.]", var_name, perl = TRUE)) {

    tokens <- unlist(strsplit(var_name, "[_.]", perl = TRUE))
    tokens <- tokens[tokens != ""]

    if (length(tokens) == 0) return(var_name)

    k <- min(length(tokens), max_tokens)

    out_tokens <- vapply(tokens[seq_len(k)], take, character(1), k = token_chars)

    return(paste(out_tokens, collapse = "."))
  }

  # Mixed alphanumeric IDs
  if (grepl("[0-9]", var_name)) {
    return(take(var_name, id_prefix_chars))
  }

  # Long single alphabetic token
  take(var_name, 9)
}

#' Ensure labels are unique via numeric suffix
#' @keywords internal
make_unique_labels <- function(labels) {

  if (!anyDuplicated(labels)) return(labels)

  out <- labels
  tab <- table(labels)
  dup_names <- names(tab[tab > 1])

  for (nm in dup_names) {
    idx <- which(labels == nm)
    if (length(idx) > 1) {
      out[idx[-1]] <- paste0(nm, seq_along(idx)[-1])
    }
  }

  out
}

#' Detect and split factor level suffix using model metadata
#' @keywords internal
split_factor_level <- function(term, levels_map = NULL) {

  if (is.null(levels_map) || length(levels_map) == 0) return(term)
  if (!nzchar(term) || is.na(term)) return(term)
  if (grepl(":", term, fixed = TRUE)) return(term)

  for (var in names(levels_map)) {

    levs <- levels_map[[var]]
    if (is.null(levs) || length(levs) == 0) next

    if (!startsWith(term, var)) next

    suffix <- substring(term, nchar(var) + 1)

    if (suffix %in% levs) {
      return(paste0(var, ":", suffix))
    }
  }

  term
}

#' Format term labels for display
#'
#' Transformations:
#' - Preserve polynomial suffixes (.L, .Q, .C, etc.)
#' - Split factor levels using levels_map
#' - Abbreviate only variable portion
#' - Ensure uniqueness after abbreviation
#'
#' @keywords internal
format_term_labels <- function(terms, levels_map = NULL) {

  formatted <- terms

  # ---- Step 1: Split factor levels ----
  for (i in seq_along(formatted)) {

    term <- formatted[i]

    if (grepl("\\*", term)) {

      parts <- strsplit(term, " \\* ")[[1]]

      for (j in seq_along(parts)) {

        part <- trimws(parts[j])

        if (!grepl(":", part, fixed = TRUE)) {
          parts[j] <- split_factor_level(part, levels_map)
        }
      }

      formatted[i] <- paste(parts, collapse = " * ")

    } else {

      if (!grepl(":", term, fixed = TRUE)) {
        formatted[i] <- split_factor_level(term, levels_map)
      }
    }
  }

  # ---- Helper: abbreviate variable portion only ----
  abbrev_piece <- function(piece) {

    piece <- trimws(piece)

    # Preserve polynomial suffixes like ".L", ".Q", ".^4"
    if (grepl("\\.[A-Za-z^0-9]+$", piece)) {

      base <- sub("(\\.[A-Za-z^0-9]+)$", "", piece)
      suffix <- sub("^.*(\\.[A-Za-z^0-9]+)$", "\\1", piece)

      return(paste0(abbreviate_var_name(base), suffix))
    }

    # Preserve factor level suffix after colon
    if (grepl(":", piece, fixed = TRUE)) {

      parts <- strsplit(piece, ":", fixed = TRUE)[[1]]
      var_name <- parts[1]
      rest <- paste(parts[-1], collapse = ":")

      return(paste0(abbreviate_var_name(var_name), ":", rest))
    }

    abbreviate_var_name(piece)
  }

  # ---- Step 2: Apply abbreviations ----
  for (i in seq_along(formatted)) {

    term <- formatted[i]

    if (grepl("\\*", term)) {

      parts <- strsplit(term, " \\* ")[[1]]
      parts <- vapply(parts, abbrev_piece, character(1))
      formatted[i] <- paste(parts, collapse = " * ")

    } else {

      formatted[i] <- abbrev_piece(term)
    }
  }

  # ---- Step 3: Ensure uniqueness ----
  formatted <- make_unique_labels(formatted)

  formatted
}

build_levels_map <- function(model_list) {
  out <- list()

  for (m in model_list) {
    xl <- m$xlevels
    if (is.null(xl) || length(xl) == 0) next

    for (nm in names(xl)) {
      out[[nm]] <- unique(c(out[[nm]], xl[[nm]]))
    }
  }

  out
}

#' Pipe operator import
#' @keywords internal
#' @importFrom magrittr %>%
NULL
