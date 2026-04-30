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

  Integer number of digits after the decimal point for coefficients and
  standard errors, including the mantissa in scientific notation.
  Allowed values are 0 to 4. Default 2. Does not affect p-value star
  thresholds.

## Value

A data frame with formatted coefficient strings
