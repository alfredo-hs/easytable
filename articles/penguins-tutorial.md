# Penguins Tutorial: Easy to Use, Easy to Read

This tutorial shows the full `easytable` workflow using
`palmerpenguins`.

## 1) Fit a sequence of models

``` r
library(easytable)
library(palmerpenguins)
#> 
#> Attaching package: 'palmerpenguins'
#> The following objects are masked from 'package:datasets':
#> 
#>     penguins, penguins_raw

m1 <- lm(body_mass_g ~ flipper_length_mm, data = penguins)
m2 <- lm(body_mass_g ~ flipper_length_mm + species, data = penguins)
m3 <- lm(body_mass_g ~ flipper_length_mm + species + island, data = penguins)
```

## 2) Create a readable baseline table

``` r
easytable(
  m1, m2, m3,
  model.names = c("Baseline", "With Species", "Full Model")
)
```

[TABLE]

By default, each coefficient cell is two lines:

1.  Estimate + significance stars
2.  Standard error in parentheses

## 3) Highlight significant coefficients

``` r
easytable(
  m1, m2, m3,
  model.names = c("Baseline", "With Species", "Full Model"),
  highlight = TRUE
)
```

[TABLE]

## 4) Collapse controls into indicator rows

``` r
easytable(
  m1, m2, m3,
  model.names = c("Baseline", "With Species", "Full Model"),
  control.var = "island",
  highlight = TRUE
)
```

[TABLE]

`control.var` is useful when models include many factor levels or fixed
effects.

## 5) LaTeX output for PDF workflows

``` r
easytable(
  m1, m2, m3,
  model.names = c("Baseline", "With Species", "Full Model"),
  output = "latex",
  control.var = "island",
  highlight = TRUE
)
```

## 6) Robust standard errors (optional dependency path)

``` r
if (requireNamespace("lmtest", quietly = TRUE) &&
    requireNamespace("sandwich", quietly = TRUE)) {
  easytable(
    m1, m2, m3,
    model.names = c("Baseline", "With Species", "Full Model"),
    robust.se = TRUE
  )
}
```

[TABLE]

## 7) Marginal effects (optional dependency path)

``` r
if (requireNamespace("margins", quietly = TRUE)) {
  easytable(
    m2, m3,
    model.names = c("With Species", "Full Model"),
    margins = TRUE
  )
}
```

[TABLE]

## 8) Export outputs

``` r
easytable(
  m1, m2, m3,
  model.names = c("Baseline", "With Species", "Full Model"),
  highlight = TRUE,
  export.word = "penguins_table.docx",
  export.csv = "penguins_table.csv"
)
```

## Design Notes

`easytable` keeps these display invariants:

1.  Two-line coefficient cells.
2.  Zebra only in coefficient rows.
3.  One divider between coefficient rows and model-stat rows.
4.  Control indicators in the model-stat block.

These defaults are intentional so tables remain legible in long
workflows.
