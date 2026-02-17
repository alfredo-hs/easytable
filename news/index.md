# Changelog

## easytable 2.1.0

### Breaking Changes

- **Removed markdown output mode** from
  [`easytable()`](https://alfredo-hs.github.io/easytable/reference/easytable.md).
  Supported outputs are now `"word"` (default) and `"latex"`.

- **Renamed CSV export argument**:

  - Old: `csv`
  - New: `export.csv` (must end with `.csv`)

### New Features

- **Direct Word file export** with new `export.word` argument (must end
  with `.docx`).
  - Example: `easytable(m1, m2, export.word = "mytable.docx")`
- **Interaction term wrapping in term column**: interaction labels now
  wrap after `*` to reduce table width (e.g., `x1 *` on one line, `x2`
  on the next line).

### Formatting and Consistency

- **Word/HTML and LaTeX alignment improved**:
  - Shared measure-row detection for divider placement
  - Single divider between coefficient block and model-stat block
  - Zebra striping constrained to coefficient block only

### Documentation

- Rewrote `README.md` around a clearer user promise: easy to use, easy
  to read.
- Added a dedicated penguins tutorial vignette: `penguins-tutorial`.
- Added a developer roadmap vignette: `developer-roadmap`.
- Added architecture and maintenance guides:
  - `DESIGN_PHILOSOPHY.md`
  - `AI_NOTES.md`
- Reorganized `_pkgdown.yml` navigation and article structure.
- Added `LICENSE.md` so the MIT license text is human-readable in the
  repository.

### Testing Infrastructure

- Added `tests/README.md` with a deterministic, CI-safe testing
  protocol.
- Added `tests/run-tests.R` with a committed `core` profile.
- Added `tests/testthat/helper-testing-profiles.R` for environment-aware
  test skipping.
- Added `tests/testthat/test-design-invariants.R` to lock key table
  invariants.

### API and Validation UX

- Added
  [`validate_output_format()`](https://alfredo-hs.github.io/easytable/reference/validate_output_format.md)
  to provide friendly, explicit output-format validation.
- Reworded key validation errors to be more beginner-friendly and
  actionable.

------------------------------------------------------------------------

## easytable 2.0.1

### New Features

- **Direct model interface**: New
  [`easytable()`](https://alfredo-hs.github.io/easytable/reference/easytable.md)
  function accepts model objects directly through dots, like
  `easytable(m1, m2, m3)`. This provides a more intuitive API for
  multiple model input.

- **Default model naming**: Model columns are now automatically named
  “Model 1”, “Model 2”, etc. when using the new
  [`easytable()`](https://alfredo-hs.github.io/easytable/reference/easytable.md)
  interface.

- **Custom model names**: Added `model.names` parameter to specify
  custom column names for models. Example:
  `easytable(m1, m2, model.names = c("Baseline", "Full"))`

- **Enhanced term label formatting**: Term labels are now automatically
  formatted for improved readability:

  - Factor levels separated with colon (e.g., `digital_confidence:low`)
  - Interactions displayed with asterisk and spaces (e.g.,
    `var1 * var2`)
  - Polynomial contrasts shown as L indices (e.g., `var:L1` for `.Q`,
    `var:L2` for `.L`)
  - Common variable names abbreviated (e.g., `fin.prud` for
    `financial_prudence`)

### Bug Fixes

- **Fixed markdown output**: Resolved issue with stray vertical bars
  appearing inside table cells. Markdown tables now use `<br>` for line
  breaks within cells, ensuring proper rendering.

- **Improved markdown formatting**: Ensured coefficient formatting
  (stars, standard errors) is consistent across markdown and LaTeX
  output formats.

### Backward Compatibility

- The original `easy_table()` function with list-based interface remains
  fully functional for backward compatibility.

- All existing code using `easy_table(list(Model1 = m1, Model2 = m2))`
  continues to work without changes.

### Migration from 2.0.0

Most users can adopt the new interface immediately:

``` r
# Old way (still works)
models <- list(Model1 = m1, Model2 = m2)
easy_table(models)

# New way (recommended)
easytable(m1, m2)

# With custom names
easytable(m1, m2, model.names = c("Model1", "Model2"))
```

------------------------------------------------------------------------

## easytable 2.0.0

### Major Changes

This is a complete rewrite of easytable with breaking changes. Version
2.0.0 modernizes the package architecture and dramatically expands
functionality.

#### New Features

- **Multi-format output**: Now supports Word (via flextable), Markdown
  (for Quarto/RMarkdown), and LaTeX/PDF output
  - New `output` parameter: `"word"`, `"markdown"`, or `"latex"`
  - Default remains `"word"` for backward compatibility
- **Modular architecture**: Complete refactor into clean, maintainable
  modules
  - `parse_models.R`: Extract coefficients and statistics
  - `transform_table.R`: Handle control variables and organization
  - `format_word.R`, `format_markdown.R`, `format_latex.R`:
    Format-specific renderers
  - `validators.R`: Comprehensive input validation
- **Enhanced validation**: Informative error messages with clear
  guidance
  - Validates model types and structure
  - Checks for required packages and provides installation instructions
  - Warns about control variables not found in models
- **Better dependency management**:
  - Only core dependencies (broom, dplyr, magrittr) are always loaded
  - Format-specific packages loaded conditionally
  - Clear error messages when optional packages are missing

#### Breaking Changes

⚠️ **IMPORTANT**: The following changes may affect existing code:

1.  **Removed runtime installation** (CRITICAL SECURITY FIX)
    - OLD: Package automatically installed missing dependencies

    - NEW: Users must install dependencies themselves

    - If you get an error about missing packages, install them with:

      ``` r
      install.packages(c("flextable", "lmtest", "sandwich", "margins"))
      ```
2.  **Function parameter changes**
    - OLD: `F` and `T` were accepted
    - NEW: Must use `FALSE` and `TRUE` (best practice)
    - This shouldn’t affect most code, but if you passed variables named
      `F` or `T`, they won’t work
3.  **Improved join operations**
    - Fixed warnings from dplyr about unspecified join columns
    - No user-facing changes, but cleaner console output

#### Bug Fixes

- **Fixed control variable regex bug**: Previously, searching for
  control variable “hp” would also match “hpq”. Now uses word boundaries
  for exact matching.

- **Fixed deduplication issue**: Improved handling of duplicate control
  variable rows (previously noted as “slight problem” in code)

- **Explicit namespace calls**: All function calls use explicit
  namespaces (e.g.,
  [`dplyr::filter`](https://dplyr.tidyverse.org/reference/filter.html))
  to prevent masking issues

- **Better handling of GLM models**: Improved extraction of fit
  statistics for generalized linear models

#### Documentation

- **Comprehensive README**: Installation, quick start, and feature
  overview
- **Detailed vignette**:
  [`vignette("easytable-intro")`](https://alfredo-hs.github.io/easytable/articles/easytable-intro.md)
  with working examples
- **Function documentation**: Complete roxygen2 documentation with
  examples
- **Developer guide**: `AI_NOTES.md` with architecture and contributor
  guidelines

#### Testing

- **Full test coverage**:
  - Unit tests for all modules
  - Integration tests for full pipeline
  - Tests for all output formats and parameter combinations
  - Using testthat framework

#### Performance

- **Modular design** enables easier maintenance and future enhancements
- **Conditional loading** of packages reduces memory footprint
- **Cleaner code** with proper separation of concerns

### Migration Guide: 0.1.0 → 2.0.0

#### If You’re Using Basic Features

**Good news**: Most basic usage should work without changes!

``` r
# This still works exactly the same
easy_table(model_list)
```

#### If You Had Issues with Missing Packages

**Old behavior (0.1.0)**:

``` r
# Package would auto-install dependencies (security risk!)
easy_table(models)
# Installing package into '~/R/library'...
```

**New behavior (2.0.0)**:

``` r
# Get clear error with installation instructions
easy_table(models)
# Error: Package 'flextable' is required for Word output.
#   Install it with: install.packages('flextable')

# You install once:
install.packages("flextable")

# Then use normally:
easy_table(models)
```

#### If You Want Markdown or LaTeX Output

**New in 2.0.0**:

``` r
# Markdown for Quarto/RMarkdown
easy_table(models, output = "markdown")

# LaTeX for PDF
easy_table(models, output = "latex")
```

#### If You’re Using Advanced Features

All advanced features work the same way:

``` r
# Robust SE - still works
easy_table(models, robust.se = TRUE)

# Marginal effects - still works
easy_table(models, margins = TRUE)

# Control variables - still works (now with fixed regex bug!)
easy_table(models, control.var = c("species", "island"))

# Highlighting - still works
easy_table(models, highlight = TRUE)

# CSV export - still works
easy_table(models, csv = "results")
```

#### Package Dependencies

**Install what you need**:

``` r
# For basic usage (Word output)
install.packages(c("broom", "dplyr", "flextable"))

# For robust standard errors
install.packages(c("lmtest", "sandwich"))

# For marginal effects
install.packages("margins")

# For Markdown/LaTeX output
install.packages("knitr")
install.packages("kableExtra")  # optional, for enhanced formatting
```

#### What Stays the Same

✅ Function name: `easy_table()` ✅ Default behavior: Word output via
flextable ✅ Parameter names: `robust.se`, `margins`, `control.var`,
`highlight`, `csv` ✅ Model support: `lm`, `glm` ✅ Significance stars:
`***` p \< .01, `**` p \< .05, `*` p \< .1 ✅ Model fit statistics: N, R
sq., Adj. R sq., AIC

#### What’s Different

🔄 Must install dependencies manually (no more auto-install) 🆕 New
output formats: markdown and latex 🐛 Control variable matching now
works correctly 📚 Much better documentation and examples ✅
Comprehensive test coverage 🏗️ Cleaner, more maintainable code
architecture

### Detailed Changes by Component

#### Parse Models (`R/parse_models.R`)

- Extracted from monolithic function
- Added
  [`parse_single_model()`](https://alfredo-hs.github.io/easytable/reference/parse_single_model.md)
  for individual model parsing
- Added
  [`format_coefficients()`](https://alfredo-hs.github.io/easytable/reference/format_coefficients.md)
  for significance star formatting
- Added
  [`extract_model_measures()`](https://alfredo-hs.github.io/easytable/reference/extract_model_measures.md)
  for fit statistics
- Added
  [`parse_models()`](https://alfredo-hs.github.io/easytable/reference/parse_models.md)
  for multi-model parsing
- All functions properly documented with roxygen2

#### Transform Table (`R/transform_table.R`)

- Added
  [`collapse_control_vars()`](https://alfredo-hs.github.io/easytable/reference/collapse_control_vars.md)
  with fixed regex patterns
- Added
  [`mark_control_vars()`](https://alfredo-hs.github.io/easytable/reference/mark_control_vars.md)
  for Y indicators
- Added
  [`deduplicate_control_vars()`](https://alfredo-hs.github.io/easytable/reference/deduplicate_control_vars.md)
  for cleaning duplicates
- Added
  [`sort_table()`](https://alfredo-hs.github.io/easytable/reference/sort_table.md)
  for proper ordering
- Added
  [`separate_measures()`](https://alfredo-hs.github.io/easytable/reference/separate_measures.md)
  for bottom placement
- Added
  [`transform_table()`](https://alfredo-hs.github.io/easytable/reference/transform_table.md)
  as main orchestrator

#### Format Renderers

- **Word** (`R/format_word.R`): Extracted and cleaned flextable code
- **Markdown** (`R/format_markdown.R`): NEW - knitr/kableExtra support
- **LaTeX** (`R/format_latex.R`): NEW - LaTeX with booktabs

#### Validators (`R/validators.R`)

- Added
  [`validate_model_list()`](https://alfredo-hs.github.io/easytable/reference/validate_model_list.md)
  with clear error messages
- Added
  [`validate_model_types()`](https://alfredo-hs.github.io/easytable/reference/validate_model_types.md)
  for supported model checking
- Added
  [`validate_control_vars()`](https://alfredo-hs.github.io/easytable/reference/validate_control_vars.md)
  with warnings for missing vars
- Added
  [`validate_parameters()`](https://alfredo-hs.github.io/easytable/reference/validate_parameters.md)
  for type checking
- Added dependency checkers for all optional features

#### Main Function (`R/easytab.R`)

- Complete rewrite using modular components
- Added `output` parameter with validation
- Integrated validators → parser → transformer → formatter pipeline
- Comprehensive roxygen2 documentation with examples
- Maintains backward compatibility

### Future Roadmap

The modular architecture in 2.0.0 makes it easy to add:

- **New model types**: plm (panel data), fixest (fixed effects),
  survival models
- **New output formats**: HTML tables, gt tables, custom formats
- **Theme system**: Customizable table styling
- **More statistics**: Confidence intervals, standardized coefficients
- **Enhanced features**: Multi-equation models, nested model tests

### Credits

- Original package: Alfredo Hernandez Sanchez
- 2.0.0 rewrite: Comprehensive modernization and expansion
- Testing data: Palmer Penguins dataset (Horst et al.)

### Feedback

Found a bug? Have a feature request? Please open an issue on GitHub:
<https://github.com/alfredo-hs/easytable/issues>

------------------------------------------------------------------------

## easytable 0.1.0

Initial release (2024)

- Basic functionality for creating Word regression tables
- Support for lm and glm models
- Robust standard errors via lmtest/sandwich
- Marginal effects via margins package
- Control variable grouping
- Highlighting of significant results
- CSV export

**Note**: Version 0.1.0 had critical issues: - Runtime package
installation (security risk) - Monolithic code structure (hard to
maintain) - Control variable regex bug - Limited to Word output only -
No tests or comprehensive documentation

All issues resolved in 2.0.0.
