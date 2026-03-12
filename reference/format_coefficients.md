# Format coefficients with significance stars and standard errors

Format coefficients with significance stars and standard errors

## Usage

``` r
format_coefficients(coef_data, digits = 2)
```

## Arguments

- coef_data:

  A data frame with columns: term, estimate, std.error, p.value

- digits:

  Integer number of decimal places for coefficients and standard errors.
  Default 2. Does not affect p-value star thresholds.

## Value

A data frame with formatted coefficient strings
