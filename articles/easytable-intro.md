# easytable: Quick Start

`easytable` is built around one promise:

1.  Easy to use.
2.  Easy to read.

## Minimal Example

``` r
library(easytable)

m1 <- lm(mpg ~ wt, data = mtcars)
m2 <- lm(mpg ~ wt + hp, data = mtcars)

easytable(m1, m2)
```

[TABLE]

## Output Formats

### Word / HTML path (default)

``` r
easytable(m1, m2, output = "word")
```

[TABLE]

### LaTeX / PDF path

``` r
easytable(m1, m2, output = "latex")
```

## Common Options

``` r
easytable(
  m1, m2,
  model.names = c("Baseline", "With Controls"),
  highlight = TRUE
)
```

[TABLE]

``` r
easytable(
  m1, m2,
  robust.se = TRUE
)
```

[TABLE]

## Export Files

``` r
easytable(
  m1, m2,
  export.word = "table.docx",
  export.csv = "table.csv"
)
```

## Next Steps

- Full end-to-end walkthrough:
  [`vignette("penguins-tutorial", package = "easytable")`](https://alfredo-hs.github.io/easytable/articles/penguins-tutorial.md)
- Developer API and architecture plan:
  [`vignette("developer-roadmap", package = "easytable")`](https://alfredo-hs.github.io/easytable/articles/developer-roadmap.md)
