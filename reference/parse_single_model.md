# Parse a single statistical model

Extracts coefficients, standard errors, and p-values from a statistical
model. Supports options for robust standard errors and marginal effects.

## Usage

``` r
parse_single_model(model, robust.se = FALSE, margins = FALSE)
```

## Arguments

- model:

  A statistical model object (lm or glm)

- robust.se:

  Logical indicating whether to use robust standard errors

- margins:

  Logical indicating whether to compute marginal effects

## Value

A data frame with columns: term, estimate, std.error, p.value
