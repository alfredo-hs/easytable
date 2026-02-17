# Format table for Word output

Creates a flextable object formatted for Microsoft Word documents.
Includes significance footnotes, optional highlighting, and notes about
robust standard errors or marginal effects.

## Usage

``` r
format_word(table, robust.se = FALSE, margins = FALSE, highlight = FALSE)
```

## Arguments

- table:

  A transformed data frame from transform_table()

- robust.se:

  Logical indicating if robust standard errors were used

- margins:

  Logical indicating if marginal effects were computed

- highlight:

  Logical indicating whether to highlight significant results

## Value

A flextable object ready for export to Word
