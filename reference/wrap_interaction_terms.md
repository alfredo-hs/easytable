# Wrap interaction terms to reduce term-column width

For Word output, `"x1 * x2"` becomes `"x1\\n× x2"`.

## Usage

``` r
wrap_interaction_terms(terms, output = c("word", "latex"))
```

## Arguments

- terms:

  Character vector of displayed term labels.

- output:

  Output backend used for display formatting. `"word"` uses a literal
  multiplication sign, while `"latex"` uses a LaTeX-safe multiplication
  symbol.

## Value

Character vector with interaction terms wrapped for display.
