#' Extract tidy coefficients from a model using base R
#'
#' Includes aliased (perfectly collinear) terms as NA rows, matching the
#' behaviour of broom::tidy().
#'
#' @param model A statistical model object (lm or glm)
#' @return A data frame with columns: term, estimate, std.error, p.value
#' @keywords internal
tidy_model <- function(model) {
  mat   <- summary(model)$coefficients
  p_col <- grep("Pr\\(", colnames(mat), value = TRUE)

  base_df <- data.frame(
    term      = rownames(mat),
    estimate  = mat[, "Estimate"],
    std.error = mat[, "Std. Error"],
    p.value   = mat[, p_col],
    row.names = NULL,
    stringsAsFactors = FALSE
  )

  # summary() drops aliased terms; add them back as NA rows (broom parity)
  all_terms <- names(stats::coef(model))
  aliased   <- setdiff(all_terms, base_df$term)
  if (length(aliased) > 0) {
    na_df <- data.frame(
      term      = aliased,
      estimate  = NA_real_,
      std.error = NA_real_,
      p.value   = NA_real_,
      stringsAsFactors = FALSE
    )
    base_df <- rbind(base_df, na_df)
    base_df <- base_df[match(all_terms, base_df$term), ]
    rownames(base_df) <- NULL
  }

  base_df
}

#' Extract tidy coefficients from a coeftest matrix
#'
#' @param x A coeftest object from lmtest::coeftest()
#' @return A data frame with columns: term, estimate, std.error, p.value
#' @keywords internal
tidy_coeftest <- function(x) {
  mat <- as.matrix(x)
  p_col <- grep("Pr\\(", colnames(mat), value = TRUE)
  data.frame(
    term      = rownames(mat),
    estimate  = mat[, "Estimate"],
    std.error = mat[, "Std. Error"],
    p.value   = mat[, p_col],
    row.names = NULL,
    stringsAsFactors = FALSE
  )
}

#' Extract tidy marginal effects from a margins object
#'
#' @param model A statistical model object (lm or glm)
#' @return A data frame with columns: term, estimate, std.error, p.value
#' @keywords internal
tidy_margins <- function(model) {
  s <- summary(margins::margins(model))
  data.frame(
    term      = s[["factor"]],
    estimate  = s[["AME"]],
    std.error = s[["SE"]],
    p.value   = s[["p"]],
    row.names = NULL,
    stringsAsFactors = FALSE
  )
}

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

  if (isTRUE(robust.se) && !isTRUE(margins)) {
    m <- tidy_coeftest(
      lmtest::coeftest(model, vcov = sandwich::vcovHC(model, type = "HC"))
    )
  } else if (!isTRUE(robust.se) && isTRUE(margins)) {
    m <- tidy_margins(model)
  } else if (isTRUE(robust.se) && isTRUE(margins)) {
    m1 <- tidy_coeftest(
      lmtest::coeftest(model, vcov = sandwich::vcovHC(model, type = "HC"))
    ) %>%
      dplyr::filter(term != "(Intercept)") %>%
      dplyr::select(-estimate)

    m2 <- tidy_margins(model) %>%
      dplyr::select(term, estimate)

    m <- dplyr::left_join(m1, m2, by = "term")
  } else {
    m <- tidy_model(model)
  }

  m
}

#' Format coefficients with significance stars and standard errors
#'
#' @param coef_data A data frame with columns: term, estimate, std.error, p.value
#' @param digits Integer number of decimal places for coefficients and standard
#'   errors. Default 2. Does not affect p-value star thresholds.
#'
#' @return A data frame with formatted coefficient strings
#' @keywords internal
format_coefficients <- function(coef_data, digits = 2) {
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
    dplyr::mutate(
      estimate  = round(estimate,  digits),
      std.error = round(std.error, digits)
    ) %>%
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
#' Rounding is fixed per statistic and independent of the user-facing \code{digits}
#' option: N = 0, R sq. = 2, Adj. R sq. = 2, AIC = 0.
#'
#' @param model A statistical model object (lm or glm)
#'
#' @return A data frame with model fit statistics
#' @keywords internal
extract_model_measures <- function(model) {
  s <- summary(model)

  fmt <- function(x, d) as.character(round(x, d))

  data.frame(
    term = c("N", "R sq.", "Adj. R sq.", "AIC"),
    estimate = c(
      fmt(stats::nobs(model),                                   0L),
      fmt(if (!is.null(s$r.squared))     s$r.squared     else NA, 2L),
      fmt(if (!is.null(s$adj.r.squared)) s$adj.r.squared else NA, 2L),
      fmt(if (!is.null(s$aic))           s$aic           else NA, 0L)
    ),
    stringsAsFactors = FALSE
  )
}

#' Parse a model and return formatted results
#'
#' Main parsing function that combines coefficient extraction, formatting,
#' and measure calculation.
#'
#' @param model A statistical model object (lm or glm)
#' @param robust.se Logical indicating whether to use robust standard errors
#' @param margins Logical indicating whether to compute marginal effects
#' @param digits Integer number of decimal places for coefficients and SEs
#'
#' @return A data frame with one column for terms and one for formatted estimates
#' @keywords internal
parse_model <- function(model, robust.se = FALSE, margins = FALSE, digits = 2) {

  coef_data <- parse_single_model(model, robust.se, margins)
  mod.df <- format_coefficients(coef_data, digits)
  measures <- extract_model_measures(model)

  dplyr::bind_rows(mod.df, measures)
}

#' Parse multiple models into a combined table
#'
#' @param model_list A named list of statistical models
#' @param robust.se Logical indicating whether to use robust standard errors
#' @param margins Logical indicating whether to compute marginal effects
#' @param digits Integer number of decimal places for coefficients and SEs
#'
#' @return A data frame with terms in rows and models in columns
#' @keywords internal
parse_models <- function(model_list, robust.se = FALSE, margins = FALSE, digits = 2) {

  model_names <- names(model_list)

  if (is.null(model_names) || any(!nzchar(model_names))) {
    stop("model_list must be a named list of models.", call. = FALSE)
  }

  # Build factor-level map from model metadata for later label splitting
  levels_map <- build_levels_map(model_list)

  # Parse first model
  result_table <- parse_model(model_list[[1]], robust.se, margins, digits)
  names(result_table)[2] <- model_names[1]

  # Parse remaining models
  if (length(model_list) > 1) {
    for (i in 2:length(model_list)) {
      model_table <- parse_model(model_list[[i]], robust.se, margins, digits)
      names(model_table)[2] <- model_names[i]

      result_table <- dplyr::full_join(result_table, model_table, by = "term")
    }
  }

  # Carry levels_map forward without changing return type
  attr(result_table, "levels_map") <- levels_map

  result_table
}
