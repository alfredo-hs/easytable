# Extract tidy coefficients from a model using base R

Includes aliased (perfectly collinear) terms as NA rows, matching the
behaviour of broom::tidy().

## Usage

``` r
tidy_model(model)
```

## Arguments

- model:

  A statistical model object (lm or glm)

## Value

A data frame with columns: term, estimate, std.error, p.value
