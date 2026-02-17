# Mark control variables with 'Y' indicator

Replaces coefficient values with "Y" for control variables to indicate
their presence in the model without showing individual coefficients.

## Usage

``` r
mark_control_vars(table, control.var)
```

## Arguments

- table:

  A data frame with regression results

- control.var:

  Character vector of control variable names

## Value

A data frame with control variables marked as "Y"
