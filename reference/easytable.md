# Create Multi-Format Regression Tables

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
  table_size = "normalsize",
  digits = 2,
  custom.row = NULL
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

- digits:

  Number of digits after the decimal point for coefficients and standard
  errors, including the mantissa in scientific notation. Allowed values
  are 0 to 4. Default 2.

- custom.row:

  Optional character vector for an additional row placed at the bottom
  of the statistics block. The first element is the row label and each
  subsequent element is the value for the corresponding model column.
  The vector must have exactly one more element than the number of
  models. Default NULL (no extra row).

## Value

Depends on `output`:

- `"word"` - A flextable object

- `"latex"` - Character string with LaTeX table code

## Details

The function extracts coefficients, standard errors, and p-values from
each model, adds significance stars (\*\*\* p\<.01, \*\* p\<.05, \*
p\<.1), and includes model fit statistics such as N, R-squared, Adjusted
R-squared, and AIC (for `glm` models).

Control variables can be grouped to show presence/absence rather than
individual coefficients for each factor level or transformation.

Term labels are automatically formatted for readability:

- Factor levels separated with colon (e.g., `advisor_confidence:low`)

- Interactions shown with a multiplication sign (e.g., `var1 × var2`)

- Polynomial contrasts as L indices (e.g., `var:L1`, `var:L2`)

- Long variable names abbreviated for clarity

## Dependencies

- Always required: dplyr

- Word output: flextable

- LaTeX output: knitr, optionally kableExtra for enhanced formatting

- Robust SE: lmtest, sandwich

- Marginal effects: margins
