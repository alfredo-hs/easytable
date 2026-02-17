# Separate model statistics from coefficients

Splits the table into coefficient rows and model-stat rows (control
indicators, N, R sq., etc.), removes empty stat rows, then recombines
with stats at the bottom.

## Usage

``` r
separate_measures(table, control.var = NULL)
```

## Arguments

- table:

  A data frame with regression results

- control.var:

  Character vector of control variable names

## Value

A data frame with measures at the bottom
