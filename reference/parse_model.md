# Parse a model and return formatted results

Main parsing function that combines coefficient extraction, formatting,
and measure calculation.

## Usage

``` r
parse_model(model, robust.se = FALSE, margins = FALSE)
```

## Arguments

- model:

  A statistical model object (lm or glm)

- robust.se:

  Logical indicating whether to use robust standard errors

- margins:

  Logical indicating whether to compute marginal effects

## Value

A data frame with one column for terms and one for formatted estimates
