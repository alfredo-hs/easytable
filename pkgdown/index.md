# easytable

`easytable` helps you create publication-ready tables with clear defaults and minimal code. Its [Design Philosophy](https://github.com/alfredo-hs/easytable/blob/main/DESIGN_PHILOSOPHY.md) is very simple, it should be:

1. Easy to use.
2. Easy to read.

## Basic Function and Installation

To install `easytable` you need to have `devtools` installed. 

```r
# install.packages("devtools")
devtools::install_github("alfredo-hs/easytable")
```

After this, everything is **easy**! 

```r
library(easytable)

model <- lm(mpg ~ wt, data = mtcars)

easytable(model)
```

For more information about the functions in the package consult the [Penguins Tutorial](articles/penguins-tutorial.html). 

## What You Get

- One function for routine workflows: `easytable()`
- Word/HTML and LaTeX output paths
- Control-variable indicators (STATA-like)
- Optional export to `.docx` and `.csv`

## On what can I use it?

Since `easytable` is a workhorse package, it currently supports the bread and butter of Rstats:

- `lm`
- `glm`

Other model classes (including `plm`) will be integrated in later releases. 

## For Contributors

Please feel free to contribute to this project by forking the GitHub repo and trying out the package! 
- [Design Philosophy](https://github.com/alfredo-hs/easytable/blob/main/DESIGN_PHILOSOPHY.md)
- [Developer Roadmap](articles/developer-roadmap.html)
- [Testing Protocol](https://github.com/alfredo-hs/easytable/blob/main/tests/README.md)
