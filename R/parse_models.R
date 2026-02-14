#' Parse a single statistical model
#'
#' Extracts coefficients, standard errors, and p-values from a statistical model.
#' Supports options for robust standard errors and marginal effects.
#'
#' @param model A statistical model object (lm or glm)
#' @param robust.se Logical indicating whether to use robust standard errors
#' @param margins Logical indicating whether to compute marginal effects
#'
#' @return A data frame with columns: term, estimate, std.error, p.value
#' @keywords internal
parse_single_model <- function(model, robust.se = FALSE, margins = FALSE) {

  # Extract coefficients based on options
  if (robust.se == TRUE & margins == FALSE) {
    m <- lmtest::coeftest(model, vcov = sandwich::vcovHC(model, type = "HC")) %>%
      broom::tidy()
  }

  if (robust.se == FALSE & margins == TRUE) {
    m <- margins::margins(model) %>% broom::tidy()
  }

  if (robust.se == TRUE & margins == TRUE) {
    m1 <- lmtest::coeftest(model, vcov = sandwich::vcovHC(model, type = "HC")) %>%
      broom::tidy() %>%
      dplyr::filter(term != "(Intercept)") %>%
      dplyr::select(-estimate)

    m2 <- margins::margins(model) %>%
      broom::tidy() %>%
      dplyr::select(term, estimate)

    m <- dplyr::left_join(m1, m2, by = "term")
  }

  if (robust.se == FALSE & margins == FALSE) {
    m <- model %>% broom::tidy()
  }

  return(m)
}

#' Format coefficients with significance stars and standard errors
#'
#' @param coef_data A data frame with columns: term, estimate, std.error, p.value
#'
#' @return A data frame with formatted coefficient strings
#' @keywords internal
format_coefficients <- function(coef_data) {
  coef_data %>%
    dplyr::select(term, estimate, std.error, p.value) %>%
    dplyr::mutate(
      significance = dplyr::case_when(
        p.value < 0.01 ~ "***",
        p.value >= 0.01 & p.value <= 0.05 ~ "** ",
        p.value > 0.05 & p.value <= 0.1  ~ "*  ",
        TRUE ~ "   "
      )
    ) %>%
    dplyr::mutate(dplyr::across(dplyr::where(is.numeric), \(x) round(x, digits = 2))) %>%
    dplyr::mutate(
      estimate = paste0(
        estimate, " ",
        significance, "\n", "(",
        std.error, ")"
      )
    ) %>%
    dplyr::select(term, estimate)
}

#' Extract goodness-of-fit measures from a model
#'
#' @param model A statistical model object (lm or glm)
#'
#' @return A data frame with model fit statistics
#' @keywords internal
extract_model_measures <- function(model) {
  measures <- data.frame(
    term = c("N", "R sq.", "Adj. R sq.", "AIC"),
    estimate = c(
      stats::nobs(model),
      ifelse(!is.null(summary(model)$r.squared),
             summary(model)$r.squared,
             NA),
      ifelse(!is.null(summary(model)$adj.r.squared),
             summary(model)$adj.r.squared,
             NA),
      ifelse(!is.null(summary(model)$aic),
             summary(model)$aic,
             NA)
    )
  )

  measures$estimate <- round(measures$estimate, 2)
  measures$estimate <- as.character(measures$estimate)

  return(measures)
}

#' Parse a model and return formatted results
#'
#' Main parsing function that combines coefficient extraction, formatting,
#' and measure calculation.
#'
#' @param model A statistical model object (lm or glm)
#' @param robust.se Logical indicating whether to use robust standard errors
#' @param margins Logical indicating whether to compute marginal effects
#'
#' @return A data frame with one column for terms and one for formatted estimates
#' @keywords internal
parse_model <- function(model, robust.se = FALSE, margins = FALSE) {

  # Extract coefficients
  coef_data <- parse_single_model(model, robust.se, margins)

  # Format coefficients with stars and SE
  mod.df <- format_coefficients(coef_data)

  # Extract model measures
  measures <- extract_model_measures(model)

  # Combine coefficients and measures
  result <- dplyr::bind_rows(mod.df, measures)

  return(result)
}

#' Parse multiple models into a combined table
#'
#' @param model_list A named list of statistical models
#' @param robust.se Logical indicating whether to use robust standard errors
#' @param margins Logical indicating whether to compute marginal effects
#'
#' @return A data frame with terms in rows and models in columns
#' @keywords internal
parse_models <- function(model_list, robust.se = FALSE, margins = FALSE) {

  model_names <- names(model_list)

  # Parse first model
  result_table <- parse_model(model_list[[1]], robust.se, margins)
  names(result_table)[2] <- model_names[1]

  # Parse remaining models if any
  if (length(model_list) > 1) {
    for (i in 2:length(model_list)) {
      model <- model_list[[i]]
      model_table <- parse_model(model, robust.se, margins)
      names(model_table)[2] <- model_names[i]

      result_table <- dplyr::full_join(result_table, model_table, by = "term")
    }
  }

  return(result_table)
}
