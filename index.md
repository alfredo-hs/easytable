# easytable

`easytable` helps you create publication-ready tables with clear
defaults and minimal code. Its [Design
Philosophy](https://github.com/alfredo-hs/easytable/blob/main/DESIGN_PHILOSOPHY.md)
is simple:

1.  Easy to use.
2.  Easy to read.

## Basic Function and Installation

To install `easytable`, you need `devtools` installed.

``` r
# install.packages("devtools")
devtools::install_github("alfredo-hs/easytable")
```

After installation, everything is **easy**.

``` r
library(easytable)

model <- lm(mpg ~ wt, data = mtcars)

easytable(model)
```

For more information about package functions, see the [Penguins
Tutorial](https://alfredo-hs.github.io/easytable/articles/penguins-tutorial.md).

## What You Get

- One function for routine workflows:
  [`easytable()`](https://alfredo-hs.github.io/easytable/reference/easytable.md)
- Word/HTML and LaTeX output paths
- Control-variable indicators (STATA-like)
- Optional export to `.docx` and `.csv`

## On what can I use it?

As a workhorse package, `easytable` currently supports the
bread-and-butter classes in R:

- `lm`
- `glm`

Other model classes (including `plm`) will be added in later releases.

## For Contributors

Please feel free to contribute by forking the GitHub repository and
trying the package.

- [Design
  Philosophy](https://github.com/alfredo-hs/easytable/blob/main/DESIGN_PHILOSOPHY.md)
- [Developer
  Roadmap](https://alfredo-hs.github.io/easytable/articles/developer-roadmap.md)
- [Testing
  Protocol](https://github.com/alfredo-hs/easytable/blob/main/tests/README.md)
