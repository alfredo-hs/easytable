# Parse multiple models into a combined table

Parse multiple models into a combined table

## Usage

``` r
parse_models(model_list, robust.se = FALSE, margins = FALSE, digits = 2)
```

## Arguments

- model_list:

  A named list of statistical models

- robust.se:

  Logical indicating whether to use robust standard errors

- margins:

  Logical indicating whether to compute marginal effects

- digits:

  Integer number of decimal places for coefficients and SEs

## Value

A data frame with terms in rows and models in columns
