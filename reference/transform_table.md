# Transform parsed model table

Main transformation function that handles control variables, sorting,
deduplication, organization, and term label formatting.

## Usage

``` r
transform_table(parsed_table, control.var = NULL, abbreviate = FALSE)
```

## Arguments

- parsed_table:

  A data frame from parse_models()

- control.var:

  Character vector of control variable names

- abbreviate:

  Logical. Abbreviate variable names? Default FALSE

## Value

A transformed data frame ready for formatting
