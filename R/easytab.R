#' Create publication-ready regression tables
#'
#' Takes model objects as arguments and creates formatted tables for
#' Word or LaTeX/PDF output. Supports robust standard errors,
#' marginal effects, and control variable grouping.
#'
#' @param ... Statistical model objects (lm or glm). Pass models directly
#'   like \code{easytable(m1, m2, m3)}.
#' @param model.names Character vector of custom names for model columns.
#'   If NULL (default), columns are named "Model 1", "Model 2", etc.
#'   Length must match number of models.
#' @param output Character string specifying output format. One of:
#'   \itemize{
#'     \item \code{"word"} - Microsoft Word via flextable (default)
#'     \item \code{"latex"} - LaTeX for PDF output
#'   }
#' @param export.word Character string ending in \code{.docx} for Word file export.
#'   Only supported when \code{output = "word"}. If NULL (default), no file is written.
#' @param export.csv Character string ending in \code{.csv} for CSV export.
#'   If NULL (default), no CSV file is written.
#' @param robust.se Logical. Use robust standard errors (HC type)? Default FALSE.
#'   Requires packages: lmtest, sandwich
#' @param control.var Character vector of variable names to group as "control
#'   variables". These will be collapsed into single rows showing "Y" for
#'   presence instead of individual coefficients. Default NULL.
#' @param margins Logical. Compute average marginal effects (AME)? Default FALSE.
#'   Requires package: margins
#' @param highlight Logical. Highlight significant coefficients (positive in green,
#'   negative in red)? Default FALSE. Works best with Word output.
#' @param abbreviate Logical. Abbreviate variable names for readability? Default FALSE.
#'   When TRUE, long variable names are shortened using deterministic rules.
#' @param table_size Character string specifying LaTeX table size. Only works with
#'   \code{output = "latex"}. Options: "tiny", "small", "normalsize", "scriptsize".
#'   Default "normalsize". Error if used with Word output.
#'
#' @return
#' Depends on \code{output}:
#' \itemize{
#'   \item \code{"word"} - A flextable object
#'   \item \code{"latex"} - Character string with LaTeX table code
#' }
#'
#' @details
#' The function extracts coefficients, standard errors, and p-values from each
#' model, adds significance stars (*** p<.01, ** p<.05, * p<.1), and includes
#' model fit statistics (N, R-squared, Adjusted R-squared, AIC).
#'
#' Control variables can be grouped to show presence/absence rather than
#' individual coefficients for each factor level or transformation.
#'
#' Term labels are automatically formatted for readability:
#' \itemize{
#'   \item Factor levels separated with colon (e.g., \code{advisor_confidence:low})
#'   \item Interactions shown with asterisk (e.g., \code{var1 * var2})
#'   \item Polynomial contrasts as L indices (e.g., \code{var:L1}, \code{var:L2})
#'   \item Long variable names abbreviated for clarity
#' }
#'
#' @section Dependencies:
#' \itemize{
#'   \item Always required: broom, dplyr
#'   \item Word output: flextable
#'   \item LaTeX output: knitr, optionally kableExtra for enhanced formatting
#'   \item Robust SE: lmtest, sandwich
#'   \item Marginal effects: margins
#' }
#'
#' @examples
#' \dontrun{
#' # Load example data
#' library(palmerpenguins)
#' data(penguins)
#'
#' # Fit models
#' m1 <- lm(body_mass_g ~ flipper_length_mm, data = penguins)
#' m2 <- lm(body_mass_g ~ flipper_length_mm + species, data = penguins)
#' m3 <- lm(body_mass_g ~ flipper_length_mm + species + island, data = penguins)
#'
#' # Create table with default names (Model 1, Model 2, Model 3)
#' easytable(m1, m2, m3)
#'
#' # Custom model names
#' easytable(m1, m2, m3, model.names = c("Baseline", "With Species", "Full"))
#'
#' # LaTeX output
#' easytable(m1, m2, output = "latex")
#'
#' # With robust standard errors
#' easytable(m1, m2, robust.se = TRUE)
#'
#' # Group species and island as control variables
#' easytable(m1, m2, m3, control.var = c("species", "island"))
#'
#' # Export to Word and CSV
#' easytable(m1, m2, export.word = "mytable.docx", export.csv = "mytable.csv")
#' }
#'
#' @export
easytable <- function(...,
                      model.names = NULL,
                      output = "word",
                      export.word = NULL,
                      export.csv = NULL,
                      robust.se = FALSE,
                      control.var = NULL,
                      margins = FALSE,
                      highlight = FALSE,
                      abbreviate = FALSE,
                      table_size = "normalsize") {

  # Capture models from dots
  models <- list(...)

  # Validate that we have at least one model
  if (length(models) == 0) {
    stop("No models provided. Pass model objects like: easytable(m1, m2, m3)",
         call. = FALSE)
  }

  # Build model names
  if (is.null(model.names)) {
    # Default: "Model 1", "Model 2", etc.
    model_names <- paste("Model", seq_along(models))
  } else {
    # Validate user-provided names
    if (!is.character(model.names)) {
      stop("model.names must be a character vector", call. = FALSE)
    }
    if (length(model.names) != length(models)) {
      stop(
        sprintf(
          "Length of model.names (%d) must match number of models (%d)",
          length(model.names), length(models)
        ),
        call. = FALSE
      )
    }
    model_names <- model.names
  }

  # Create named list
  names(models) <- model_names
  model_list <- models

  # Validate output parameter
  output <- match.arg(output, choices = c("word", "latex"))

  # Validate inputs
  validate_model_list(model_list)
  validate_model_types(model_list)
  validate_control_vars(model_list, control.var)
  validate_parameters(robust.se, margins, highlight, export.word, export.csv, output)
  validate_table_size(table_size, output)

  # Check feature dependencies
  check_robust_dependencies(robust.se)
  check_margins_dependencies(margins)
  check_format_dependencies(output)

  # Parse models (extract coefficients, SE, p-values)
  parsed <- parse_models(model_list, robust.se, margins)

  # Transform table (handle control vars, sort, organize)
  transformed <- transform_table(parsed, control.var, abbreviate)

  # Export to CSV if requested
  if (!is.null(export.csv)) {
    write.csv(
      transformed,
      file = export.csv,
      row.names = FALSE
    )
  }

  # Format based on output type
  result <- switch(
    output,
    word = format_word(transformed, robust.se, margins, highlight),
    latex = format_latex(transformed, robust.se, margins, highlight, table_size)
  )

  # Export Word file if requested
  if (!is.null(export.word)) {
    flextable::save_as_docx(`Regression Table` = result, path = export.word)
  }

  return(result)
}
