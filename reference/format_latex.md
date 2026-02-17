# Format table for LaTeX/PDF output

Creates a LaTeX table suitable for PDF documents. Uses booktabs styling
and includes significance footnotes via threeparttable package.

## Usage

``` r
format_latex(
  table,
  robust.se = FALSE,
  margins = FALSE,
  highlight = FALSE,
  table_size = "normalsize"
)
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

- table_size:

  LaTeX size command: "tiny", "small", "normalsize", "scriptsize"

## Value

A character string containing the LaTeX table code
