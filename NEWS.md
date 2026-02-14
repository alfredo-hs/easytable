# easytable 2.0.0

## Major Changes

This is a complete rewrite of easytable with breaking changes. Version 2.0.0 modernizes the package architecture and dramatically expands functionality.

### New Features

* **Multi-format output**: Now supports Word (via flextable), Markdown (for Quarto/RMarkdown), and LaTeX/PDF output
  * New `output` parameter: `"word"`, `"markdown"`, or `"latex"`
  * Default remains `"word"` for backward compatibility

* **Modular architecture**: Complete refactor into clean, maintainable modules
  * `parse_models.R`: Extract coefficients and statistics
  * `transform_table.R`: Handle control variables and organization
  * `format_word.R`, `format_markdown.R`, `format_latex.R`: Format-specific renderers
  * `validators.R`: Comprehensive input validation

* **Enhanced validation**: Informative error messages with clear guidance
  * Validates model types and structure
  * Checks for required packages and provides installation instructions
  * Warns about control variables not found in models

* **Better dependency management**:
  * Only core dependencies (broom, dplyr, magrittr) are always loaded
  * Format-specific packages loaded conditionally
  * Clear error messages when optional packages are missing

### Breaking Changes

⚠️ **IMPORTANT**: The following changes may affect existing code:

1. **Removed runtime installation** (CRITICAL SECURITY FIX)
   * OLD: Package automatically installed missing dependencies
   * NEW: Users must install dependencies themselves
   * If you get an error about missing packages, install them with:
     ```r
     install.packages(c("flextable", "lmtest", "sandwich", "margins"))
     ```

2. **Function parameter changes**
   * OLD: `F` and `T` were accepted
   * NEW: Must use `FALSE` and `TRUE` (best practice)
   * This shouldn't affect most code, but if you passed variables named `F` or `T`, they won't work

3. **Improved join operations**
   * Fixed warnings from dplyr about unspecified join columns
   * No user-facing changes, but cleaner console output

### Bug Fixes

* **Fixed control variable regex bug**: Previously, searching for control variable "hp" would also match "hpq". Now uses word boundaries for exact matching.

* **Fixed deduplication issue**: Improved handling of duplicate control variable rows (previously noted as "slight problem" in code)

* **Explicit namespace calls**: All function calls use explicit namespaces (e.g., `dplyr::filter`) to prevent masking issues

* **Better handling of GLM models**: Improved extraction of fit statistics for generalized linear models

### Documentation

* **Comprehensive README**: Installation, quick start, and feature overview
* **Detailed vignette**: `vignette("easytable-intro")` with working examples
* **Function documentation**: Complete roxygen2 documentation with examples
* **Developer guide**: `CLAUDE.md` with architecture and contribution guidelines

### Testing

* **Full test coverage**:
  * Unit tests for all modules
  * Integration tests for full pipeline
  * Tests for all output formats and parameter combinations
  * Using testthat framework

### Performance

* **Modular design** enables easier maintenance and future enhancements
* **Conditional loading** of packages reduces memory footprint
* **Cleaner code** with proper separation of concerns

## Migration Guide: 0.1.0 → 2.0.0

### If You're Using Basic Features

**Good news**: Most basic usage should work without changes!

```r
# This still works exactly the same
easy_table(model_list)
```

### If You Had Issues with Missing Packages

**Old behavior (0.1.0)**:
```r
# Package would auto-install dependencies (security risk!)
easy_table(models)
# Installing package into '~/R/library'...
```

**New behavior (2.0.0)**:
```r
# Get clear error with installation instructions
easy_table(models)
# Error: Package 'flextable' is required for Word output.
#   Install it with: install.packages('flextable')

# You install once:
install.packages("flextable")

# Then use normally:
easy_table(models)
```

### If You Want Markdown or LaTeX Output

**New in 2.0.0**:
```r
# Markdown for Quarto/RMarkdown
easy_table(models, output = "markdown")

# LaTeX for PDF
easy_table(models, output = "latex")
```

### If You're Using Advanced Features

All advanced features work the same way:

```r
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

### Package Dependencies

**Install what you need**:

```r
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

### What Stays the Same

✅ Function name: `easy_table()`
✅ Default behavior: Word output via flextable
✅ Parameter names: `robust.se`, `margins`, `control.var`, `highlight`, `csv`
✅ Model support: `lm`, `glm`
✅ Significance stars: `***` p < .01, `**` p < .05, `*` p < .1
✅ Model fit statistics: N, R sq., Adj. R sq., AIC

### What's Different

🔄 Must install dependencies manually (no more auto-install)
🆕 New output formats: markdown and latex
🐛 Control variable matching now works correctly
📚 Much better documentation and examples
✅ Comprehensive test coverage
🏗️ Cleaner, more maintainable code architecture

## Detailed Changes by Component

### Parse Models (`R/parse_models.R`)

* Extracted from monolithic function
* Added `parse_single_model()` for individual model parsing
* Added `format_coefficients()` for significance star formatting
* Added `extract_model_measures()` for fit statistics
* Added `parse_models()` for multi-model parsing
* All functions properly documented with roxygen2

### Transform Table (`R/transform_table.R`)

* Added `collapse_control_vars()` with fixed regex patterns
* Added `mark_control_vars()` for Y indicators
* Added `deduplicate_control_vars()` for cleaning duplicates
* Added `sort_table()` for proper ordering
* Added `separate_measures()` for bottom placement
* Added `transform_table()` as main orchestrator

### Format Renderers

* **Word** (`R/format_word.R`): Extracted and cleaned flextable code
* **Markdown** (`R/format_markdown.R`): NEW - knitr/kableExtra support
* **LaTeX** (`R/format_latex.R`): NEW - LaTeX with booktabs

### Validators (`R/validators.R`)

* Added `validate_model_list()` with clear error messages
* Added `validate_model_types()` for supported model checking
* Added `validate_control_vars()` with warnings for missing vars
* Added `validate_parameters()` for type checking
* Added dependency checkers for all optional features

### Main Function (`R/easytab.R`)

* Complete rewrite using modular components
* Added `output` parameter with validation
* Integrated validators → parser → transformer → formatter pipeline
* Comprehensive roxygen2 documentation with examples
* Maintains backward compatibility

## Future Roadmap

The modular architecture in 2.0.0 makes it easy to add:

* **New model types**: plm (panel data), fixest (fixed effects), survival models
* **New output formats**: HTML tables, gt tables, custom formats
* **Theme system**: Customizable table styling
* **More statistics**: Confidence intervals, standardized coefficients
* **Enhanced features**: Multi-equation models, nested model tests

## Credits

* Original package: Alfredo Hernandez Sanchez
* 2.0.0 rewrite: Comprehensive modernization and expansion
* Testing data: Palmer Penguins dataset (Horst et al.)

## Feedback

Found a bug? Have a feature request? Please open an issue on GitHub:
https://github.com/alfredo-hs/easytable/issues

---

# easytable 0.1.0

Initial release (2024)

* Basic functionality for creating Word regression tables
* Support for lm and glm models
* Robust standard errors via lmtest/sandwich
* Marginal effects via margins package
* Control variable grouping
* Highlighting of significant results
* CSV export

**Note**: Version 0.1.0 had critical issues:
- Runtime package installation (security risk)
- Monolithic code structure (hard to maintain)
- Control variable regex bug
- Limited to Word output only
- No tests or comprehensive documentation

All issues resolved in 2.0.0.
