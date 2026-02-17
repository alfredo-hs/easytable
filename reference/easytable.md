# Create publication-ready regression tables

Takes model objects as arguments and creates formatted tables for Word
or LaTeX/PDF output. Supports robust standard errors, marginal effects,
and control variable grouping.

## Usage

``` r
easytable(
  ...,
  model.names = NULL,
  output = "word",
  export.word = NULL,
  export.csv = NULL,
  robust.se = FALSE,
  control.var = NULL,
  margins = FALSE,
  highlight = FALSE,
  abbreviate = FALSE,
  table_size = "normalsize"
)
```

## Arguments

- ...:

  Statistical model objects (lm or glm). Pass models directly like
  `easytable(m1, m2, m3)`.

- model.names:

  Character vector of custom names for model columns. If NULL (default),
  columns are named "Model 1", "Model 2", etc. Length must match number
  of models.

- output:

  Character string specifying output format. One of:

  - `"word"` - Microsoft Word via flextable (default)

  - `"latex"` - LaTeX for PDF output

- export.word:

  Character string ending in `.docx` for Word file export. Only
  supported when `output = "word"`. If NULL (default), no file is
  written.

- export.csv:

  Character string ending in `.csv` for CSV export. If NULL (default),
  no CSV file is written.

- robust.se:

  Logical. Use robust standard errors (HC type)? Default FALSE. Requires
  packages: lmtest, sandwich

- control.var:

  Character vector of variable names to group as "control variables".
  These will be collapsed into single rows showing "Y" for presence
  instead of individual coefficients. Default NULL.

- margins:

  Logical. Compute average marginal effects (AME)? Default FALSE.
  Requires package: margins

- highlight:

  Logical. Highlight significant coefficients (positive in green,
  negative in red)? Default FALSE. Works best with Word output.

- abbreviate:

  Logical. Abbreviate variable names for readability? Default FALSE.
  When TRUE, long variable names are shortened using deterministic
  rules.

- table_size:

  Character string specifying LaTeX table size. Only works with
  `output = "latex"`. Options: "tiny", "small", "normalsize",
  "scriptsize". Default "normalsize". Error if used with Word output.

## Value

Depends on `output`:

- `"word"` - A flextable object

- `"latex"` - Character string with LaTeX table code

## Details

The function extracts coefficients, standard errors, and p-values from
each model, adds significance stars (\*\*\* p\<.01, \*\* p\<.05, \*
p\<.1), and includes model fit statistics (N, R-squared, Adjusted
R-squared, AIC).

Control variables can be grouped to show presence/absence rather than
individual coefficients for each factor level or transformation.

Term labels are automatically formatted for readability:

- Factor levels separated with colon (e.g., `advisor_confidence:low`)

- Interactions shown with asterisk (e.g., `var1 * var2`)

- Polynomial contrasts as L indices (e.g., `var:L1`, `var:L2`)

- Long variable names abbreviated for clarity

## Dependencies

- Always required: broom, dplyr

- Word output: flextable

- LaTeX output: knitr, optionally kableExtra for enhanced formatting

- Robust SE: lmtest, sandwich

- Marginal effects: margins

## Examples

``` r
if (FALSE) { # \dontrun{
# Load example data
library(palmerpenguins)
data(penguins)

# Fit models
m1 <- lm(body_mass_g ~ flipper_length_mm, data = penguins)
m2 <- lm(body_mass_g ~ flipper_length_mm + species, data = penguins)
m3 <- lm(body_mass_g ~ flipper_length_mm + species + island, data = penguins)

# Create table with default names (Model 1, Model 2, Model 3)
easytable(m1, m2, m3)

# Custom model names
easytable(m1, m2, m3, model.names = c("Baseline", "With Species", "Full"))

# LaTeX output
easytable(m1, m2, output = "latex")

# With robust standard errors
easytable(m1, m2, robust.se = TRUE)

# Group species and island as control variables
easytable(m1, m2, m3, control.var = c("species", "island"))

# Export to Word and CSV
easytable(m1, m2, export.word = "mytable.docx", export.csv = "mytable.csv")
} # }
```
