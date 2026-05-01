# Extract goodness-of-fit measures from a model

Rounding is fixed per statistic and independent of the user-facing
`digits` option: N = 0, R sq. = 2, Adj. R sq. = 2, AIC = 0. AIC is only
reported for `glm` models.

## Usage

``` r
extract_model_measures(model)
```

## Arguments

- model:

  A statistical model object (lm or glm)

## Value

A data frame with model fit statistics
