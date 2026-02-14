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
