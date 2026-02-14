#' Create publication-ready regression tables in multiple formats
#'
#' Takes a named list of regression models and creates formatted tables for
#' Word, Markdown, or LaTeX/PDF output. Supports robust standard errors,
#' marginal effects, and control variable grouping.
#'
#' @param model_list A named list of statistical models (lm or glm objects).
#'   Example: \code{list(Model1 = m1, Model2 = m2)}
#' @param output Character string specifying output format. One of:
#'   \itemize{
#'     \item \code{"word"} - Microsoft Word via flextable (default)
#'     \item \code{"markdown"} - Markdown for Quarto/RMarkdown
#'     \item \code{"latex"} - LaTeX for PDF output
#'   }
#' @param csv Character string for CSV file export (without .csv extension).
#'   If NULL (default), no CSV is created.
#' @param robust.se Logical. Use robust standard errors (HC type)? Default FALSE.
#'   Requires packages: lmtest, sandwich
#' @param control.var Character vector of variable names to group as "control
#'   variables". These will be collapsed into single rows showing "Y" for
#'   presence instead of individual coefficients. Default NULL.
#' @param margins Logical. Compute average marginal effects (AME)? Default FALSE.
#'   Requires package: margins
#' @param highlight Logical. Highlight significant coefficients (positive in green,
#'   negative in red)? Default FALSE. Works best with Word output.
#'
#' @return
#' Depends on \code{output}:
#' \itemize{
#'   \item \code{"word"} - A flextable object
#'   \item \code{"markdown"} - Character string with markdown table
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
#' @section Dependencies:
#' \itemize{
#'   \item Always required: broom, dplyr
#'   \item Word output: flextable
#'   \item Markdown/LaTeX: knitr, optionally kableExtra for enhanced formatting
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
#' models <- list(Model1 = m1, Model2 = m2, Model3 = m3)
#'
#' # Word output (default)
#' easy_table(models)
#'
#' # Markdown for Quarto/RMarkdown
#' easy_table(models, output = "markdown")
#'
#' # LaTeX for PDF
#' easy_table(models, output = "latex")
#'
#' # With robust standard errors
#' easy_table(models, output = "word", robust.se = TRUE)
#'
#' # Group species and island as control variables
#' easy_table(models, output = "markdown", control.var = c("species", "island"))
#'
#' # Highlight significant results
#' easy_table(models, output = "word", highlight = TRUE)
#'
#' # Export to CSV as well
#' easy_table(models, output = "latex", csv = "regression_results")
#' }
#'
#' @export
easy_table <- function(model_list,
                       output = "word",
                       csv = NULL,
                       robust.se = FALSE,
                       control.var = NULL,
                       margins = FALSE,
                       highlight = FALSE) {

  # Validate output parameter
  output <- match.arg(output, choices = c("word", "markdown", "latex"))

  # Validate inputs
  validate_model_list(model_list)
  validate_model_types(model_list)
  validate_control_vars(model_list, control.var)
  validate_parameters(robust.se, margins, highlight, csv)

  # Check feature dependencies
  check_robust_dependencies(robust.se)
  check_margins_dependencies(margins)
  check_format_dependencies(output)

  # Parse models (extract coefficients, SE, p-values)
  parsed <- parse_models(model_list, robust.se, margins)

  # Transform table (handle control vars, sort, organize)
  transformed <- transform_table(parsed, control.var)

  # Export to CSV if requested
  if (!is.null(csv)) {
    write.csv(
      transformed,
      file = paste0(csv, ".csv"),
      row.names = FALSE
    )
  }

  # Format based on output type
  result <- switch(
    output,
    word = format_word(transformed, robust.se, margins, highlight),
    markdown = format_markdown(transformed, robust.se, margins, highlight),
    latex = format_latex(transformed, robust.se, margins, highlight)
  )

  return(result)
}
