#' Validate model list input
#'
#' @param model_list A named list of models
#' @return Invisible TRUE if valid, otherwise stops with error
#' @keywords internal
validate_model_list <- function(model_list) {
  if (!is.list(model_list)) {
    stop(
      "model_list must be a list of statistical models.\n",
      "  You provided: ", class(model_list)[1],
      call. = FALSE
    )
  }

  if (length(model_list) == 0) {
    stop("model_list cannot be empty.", call. = FALSE)
  }

  if (is.null(names(model_list)) || any(names(model_list) == "")) {
    stop(
      "model_list must be a named list.\n",
      "  Example: list(Model1 = m1, Model2 = m2)",
      call. = FALSE
    )
  }

  invisible(TRUE)
}

#' Check if model is supported type
#'
#' @param model A statistical model object
#' @return Logical indicating if model type is supported
#' @keywords internal
is_supported_model <- function(model) {
  inherits(model, c("lm", "glm"))
}

#' Validate all models in list are supported types
#'
#' @param model_list A named list of models
#' @return Invisible TRUE if valid, otherwise stops with error
#' @keywords internal
validate_model_types <- function(model_list) {
  for (i in seq_along(model_list)) {
    model <- model_list[[i]]
    model_name <- names(model_list)[i]

    if (!is_supported_model(model)) {
      stop(
        "Model '", model_name, "' is not a supported type.\n",
        "  Model class: ", paste(class(model), collapse = ", "), "\n",
        "  Supported types: lm, glm",
        call. = FALSE
      )
    }
  }

  invisible(TRUE)
}

#' Validate control variables exist in models
#'
#' @param model_list A named list of models
#' @param control.var Character vector of control variable names
#' @return Invisible TRUE if valid, otherwise stops with error
#' @keywords internal
validate_control_vars <- function(model_list, control.var) {
  if (is.null(control.var)) {
    return(invisible(TRUE))
  }

  if (!is.character(control.var)) {
    stop(
      "control.var must be a character vector.\n",
      "  You provided: ", class(control.var)[1],
      call. = FALSE
    )
  }

  # Check at least one model contains the control variables
  for (var in control.var) {
    var_found <- FALSE

    for (i in seq_along(model_list)) {
      model <- model_list[[i]]
      model_terms <- attr(stats::terms(model), "term.labels")

      # Check if variable appears in model (as is, or in transformations)
      if (any(grepl(var, model_terms, fixed = TRUE))) {
        var_found <- TRUE
        break
      }
    }

    if (!var_found) {
      warning(
        "Control variable '", var, "' not found in any model.\n",
        "  This variable will be ignored.",
        call. = FALSE,
        immediate. = TRUE
      )
    }
  }

  invisible(TRUE)
}

#' Validate parameter types
#'
#' @param robust.se Logical for robust standard errors
#' @param margins Logical for marginal effects
#' @param highlight Logical for highlighting
#' @param export.word Character or NULL for Word export path
#' @param export.csv Character or NULL for CSV export path
#' @param output Character string specifying output format
#' @return Invisible TRUE if valid, otherwise stops with error
#' @keywords internal
validate_parameters <- function(robust.se, margins, highlight, export.word, export.csv, output) {
  if (!is.logical(robust.se) || length(robust.se) != 1) {
    stop("robust.se must be TRUE or FALSE.", call. = FALSE)
  }

  if (!is.logical(margins) || length(margins) != 1) {
    stop("margins must be TRUE or FALSE.", call. = FALSE)
  }

  if (!is.logical(highlight) || length(highlight) != 1) {
    stop("highlight must be TRUE or FALSE.", call. = FALSE)
  }

  if (!is.null(export.word)) {
    if (!is.character(export.word) || length(export.word) != 1 || !nzchar(export.word)) {
      stop("export.word must be a non-empty character string or NULL.", call. = FALSE)
    }
    if (!grepl("\\.docx$", export.word, ignore.case = TRUE)) {
      stop("export.word must end in '.docx'.", call. = FALSE)
    }
    if (output != "word") {
      stop("export.word is only supported when output = \"word\".", call. = FALSE)
    }
  }

  if (!is.null(export.csv)) {
    if (!is.character(export.csv) || length(export.csv) != 1 || !nzchar(export.csv)) {
      stop("export.csv must be a non-empty character string or NULL.", call. = FALSE)
    }
    if (!grepl("\\.csv$", export.csv, ignore.case = TRUE)) {
      stop("export.csv must end in '.csv'.", call. = FALSE)
    }
  }

  invisible(TRUE)
}

#' Check format-specific dependencies
#'
#' @param output Output format ("word" or "latex")
#' @return Invisible TRUE if dependencies available, otherwise stops with error
#' @keywords internal
check_format_dependencies <- function(output) {
  if (output == "word") {
    if (!requireNamespace("flextable", quietly = TRUE)) {
      stop(
        "Package 'flextable' is required for Word output.\n",
        "  Install it with: install.packages('flextable')",
        call. = FALSE
      )
    }
  }

  if (output == "latex") {
    if (!requireNamespace("knitr", quietly = TRUE)) {
      stop(
        "Package 'knitr' is required for latex output.\n",
        "  Install it with: install.packages('knitr')",
        call. = FALSE
      )
    }
  }

  invisible(TRUE)
}

#' Check robust SE dependencies
#'
#' @param robust.se Logical indicating if robust SEs are requested
#' @return Invisible TRUE if dependencies available, otherwise stops with error
#' @keywords internal
check_robust_dependencies <- function(robust.se) {
  if (robust.se) {
    missing_pkgs <- c()

    if (!requireNamespace("lmtest", quietly = TRUE)) {
      missing_pkgs <- c(missing_pkgs, "lmtest")
    }

    if (!requireNamespace("sandwich", quietly = TRUE)) {
      missing_pkgs <- c(missing_pkgs, "sandwich")
    }

    if (length(missing_pkgs) > 0) {
      stop(
        "Packages required for robust standard errors are missing: ",
        paste(missing_pkgs, collapse = ", "), "\n",
        "  Install them with: install.packages(c('",
        paste(missing_pkgs, collapse = "', '"), "'))",
        call. = FALSE
      )
    }
  }

  invisible(TRUE)
}

#' Check margins dependencies
#'
#' @param margins Logical indicating if marginal effects are requested
#' @return Invisible TRUE if dependencies available, otherwise stops with error
#' @keywords internal
check_margins_dependencies <- function(margins) {
  if (margins) {
    if (!requireNamespace("margins", quietly = TRUE)) {
      stop(
        "Package 'margins' is required for marginal effects.\n",
        "  Install it with: install.packages('margins')",
        call. = FALSE
      )
    }
  }

  invisible(TRUE)
}

#' Validate table_size parameter
#'
#' @param table_size Character string specifying LaTeX table size
#' @param output Character string specifying output format
#' @return Invisible TRUE if valid, otherwise stops with error
#' @keywords internal
validate_table_size <- function(table_size, output) {
  valid_sizes <- c("tiny", "small", "normalsize", "scriptsize")

  if (!table_size %in% valid_sizes) {
    stop(
      "'table_size' must be one of: ", paste(valid_sizes, collapse = ", "), "\n",
      "  You provided: ", table_size,
      call. = FALSE
    )
  }

  if (table_size != "normalsize" && output != "latex") {
    stop(
      "The 'table_size' parameter only works for LaTeX output.\n",
      "  Current output format: ", output, "\n",
      "  To use 'table_size', set output = \"latex\"",
      call. = FALSE
    )
  }

  invisible(TRUE)
}
