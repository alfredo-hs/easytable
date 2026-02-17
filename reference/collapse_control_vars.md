# Collapse control variable rows

Collapses multiple rows for control variables (including factor levels
and transformations) into a single row per control variable.

## Usage

``` r
collapse_control_vars(table, control.var)
```

## Arguments

- table:

  A data frame with regression results

- control.var:

  Character vector of control variable names to collapse

## Value

A data frame with collapsed control variables
