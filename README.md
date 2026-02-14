# easytable <img src="man/figures/logo.png" align="right" width="190"/>

**Create publication-ready regression tables in multiple formats**

**Authors:** [Alfredo Hernandez Sanchez](https://alfredohs.com),  Claude Code ✨ <br>
**License:** [MIT](https://opensource.org/licenses/MIT)

[![R-CMD-check](https://img.shields.io/badge/R--CMD--check-passing-brightgreen)]()
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)

---
## Overview

**easytable** creates beautiful, publication-ready regression tables from R statistical models. Export your results to:

- **Microsoft Word** (via flextable)
- **Markdown** (for Quarto/RMarkdown documents)
- **LaTeX/PDF** (for academic papers)

All from a single, simple function call.

## Features

- 📊 **Multi-format output**: Word, Markdown, or LaTeX
- ⭐ **Automatic significance stars**: \*\*\*p < .01, \*\*p < .05, \*p < .1
- 🔒 **Robust standard errors**: HC robust SEs with lmtest/sandwich
- 📈 **Marginal effects**: Average marginal effects (AME) with margins package
- 🎯 **Control variables**: Group control variables for cleaner tables
- 🎨 **Highlighting**: Color-code significant results (green positive, red negative)
- 📁 **CSV export**: Save raw data alongside formatted tables
- ✅ **Model support**: Linear models (lm) and generalized linear models (glm)

## Installation

Install the development version from GitHub:

```r
# install.packages("devtools")
devtools::install_github("alfredo-hs/easytable")
```

## Quick Start

```r
library(easytable)
library(palmerpenguins)

# Fit models
m1 <- lm(body_mass_g ~ flipper_length_mm, data = penguins)
m2 <- lm(body_mass_g ~ flipper_length_mm + species, data = penguins)
m3 <- lm(body_mass_g ~ flipper_length_mm + species + island, data = penguins)

models <- list(Model1 = m1, Model2 = m2, Model3 = m3)

# Create table (defaults to Word format)
easy_table(models)
```

## Output Formats

### Word (Default)

Perfect for Microsoft Word documents:

```r
easy_table(models, output = "word")
```

Returns a `flextable` object that can be:
- Viewed in RStudio Viewer
- Saved with `flextable::save_as_docx()`
- Inserted into R Markdown Word documents

### Markdown

For Quarto and RMarkdown documents:

```r
easy_table(models, output = "markdown")
```

Returns a markdown table that renders beautifully in `.qmd` and `.Rmd` files:

```r
---
title: "My Analysis"
format: html
---

```{r}
#| echo: false
library(easytable)
easy_table(models, output = "markdown")
```
```

### LaTeX

For academic papers and PDF output:

```r
easy_table(models, output = "latex")
```

Returns LaTeX table code with booktabs styling, perfect for academic journals.

## Advanced Features

### Robust Standard Errors

Use heteroskedasticity-consistent (HC) standard errors:

```r
easy_table(models, output = "word", robust.se = TRUE)
```

*Requires: `lmtest`, `sandwich` packages*

### Marginal Effects

Compute average marginal effects instead of raw coefficients:

```r
easy_table(models, output = "markdown", margins = TRUE)
```

*Requires: `margins` package*

### Both Together

Combine robust SEs with marginal effects:

```r
easy_table(models, output = "latex",
           robust.se = TRUE,
           margins = TRUE)
```

### Control Variables

Group control variables to show presence/absence rather than individual coefficients:

```r
easy_table(models, output = "word",
           control.var = c("species", "island"))
```

Instead of showing separate rows for `speciesChinstrap`, `speciesGentoo`, etc., the table shows a single "species" row marked with "Y" for models that include it.

### Highlighting

Color-code significant results (positive = green, negative = red):

```r
easy_table(models, output = "word", highlight = TRUE)
```

*Works best with Word output*

### CSV Export

Export the underlying data table alongside your formatted output:

```r
easy_table(models, output = "latex", csv = "results")
# Creates results.csv
```

## Full Example

Combine all features:

```r
library(easytable)
library(palmerpenguins)

# Fit models with controls
m1 <- lm(body_mass_g ~ flipper_length_mm, data = penguins)
m2 <- lm(body_mass_g ~ flipper_length_mm + species + island + sex,
         data = na.omit(penguins))

models <- list(
  "Baseline" = m1,
  "Full Model" = m2
)

# Create publication-ready table
easy_table(
  models,
  output = "word",
  robust.se = TRUE,
  control.var = c("species", "island", "sex"),
  highlight = TRUE,
  csv = "regression_results"
)
```

## Model Support

Currently supports:
- `lm()` - Linear regression
- `glm()` - Generalized linear models

Coming soon:
- `plm` - Panel data models
- `fixest` - Fixed effects models
- Additional model types (survival, mixed effects, etc.)

## Dependencies

**Always required:**
- broom
- dplyr

**Output format specific:**
- Word: flextable
- Markdown/LaTeX: knitr, kableExtra (optional, for enhanced formatting)

**Feature specific:**
- Robust SE: lmtest, sandwich
- Marginal effects: margins

Missing packages will trigger informative error messages with installation instructions.

## Comparison to Other Packages

| Feature | easytable | stargazer | modelsummary | huxtable |
|---------|-----------|-----------|--------------|----------|
| Word output | ✅ | ❌ | ✅ | ✅ |
| Markdown | ✅ | ❌ | ✅ | ✅ |
| LaTeX | ✅ | ✅ | ✅ | ✅ |
| Robust SE | ✅ | ✅ | ✅ | ✅ |
| Marginal effects | ✅ | ❌ | ⚠️ | ⚠️ |
| Control var grouping | ✅ | ❌ | ⚠️ | ❌ |
| Single function | ✅ | ✅ | ✅ | ❌ |

## Documentation

- **Quick start**: You're reading it!
- **Vignette**: `vignette("easytable-intro")`
- **Function reference**: `?easy_table`
- **Developer docs**: See `CLAUDE.md` for architecture details

## Getting Help

- **Bug reports**: [GitHub Issues](https://github.com/alfredo-hs/easytable/issues)
- **Questions**: [GitHub Discussions](https://github.com/alfredo-hs/easytable/discussions)

## Citation

If you use easytable in your research, please cite:

```
Hernandez Sanchez, A. (2026). easytable: Create Multi-Format Regression Tables.
R package version 2.0.0. https://github.com/alfredo-hs/easytable
```

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Changelog

See [NEWS.md](NEWS.md) for version history and migration guide from 0.1.0 to 2.0.0.
