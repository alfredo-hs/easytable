# Extract tidy coefficients from a coeftest matrix

Extract tidy coefficients from a coeftest matrix

## Usage

``` r
tidy_coeftest(x)
```

## Arguments

- x:

  A coeftest object from lmtest::coeftest()

## Value

A data frame with columns: term, estimate, std.error, p.value
