# Developer Documentation: easytable

**For: Future maintainers, contributors, and Claude Code sessions**

---

## Project Overview

**easytable** is an R package for creating publication-ready regression tables in multiple formats (Word, Markdown, LaTeX). It was completely rewritten in version 2.0.0 to address critical issues and expand functionality.

### Quick Facts

- **Current version**: 2.0.0
- **Language**: R
- **License**: MIT
- **Author**: Alfredo Hernandez Sanchez
- **Repository**: https://github.com/alhdzsz/easytable

---

## History

### Version 0.1.0 (2024)

Initial release with basic functionality:
- Single 185-line monolithic function
- Word-only output via flextable
- Runtime package installation (security risk)
- No tests or comprehensive documentation
- Control variable regex bug

### Version 2.0.0 (2026)

Complete rewrite addressing all issues:
- Modular architecture with separation of concerns
- Multi-format output (Word, Markdown, LaTeX)
- Proper dependency management
- Comprehensive testing (testthat)
- Full documentation (README, vignette, roxygen2)
- Fixed regex bug in control variable matching
- Better error handling and validation

---

## Architecture

### Design Philosophy

**Parse → Transform → Format → Render**

The package follows a clean pipeline:

1. **Parse**: Extract coefficients, SEs, p-values from models
2. **Transform**: Organize data (control vars, sorting, measures)
3. **Format**: Apply format-specific rendering (Word/Markdown/LaTeX)
4. **Render**: Return formatted output to user

### Module Structure

```
R/
├── easytable-package.R    # Package documentation, imports
├── easytab.R              # Main user interface
├── validators.R           # Input validation
├── parse_models.R         # Coefficient extraction
├── transform_table.R      # Data transformation
├── format_word.R          # Word (flextable) renderer
├── format_markdown.R      # Markdown renderer
├── format_latex.R         # LaTeX renderer
└── utils.R                # Helper functions
```

### Data Flow

```
User Input (model_list)
    ↓
Validators (check inputs, dependencies)
    ↓
Parser (parse_models)
    → parse_single_model() for each model
    → format_coefficients() (add stars, format)
    → extract_model_measures() (N, R², AIC)
    ↓
Transformer (transform_table)
    → collapse_control_vars() (handle factor levels)
    → mark_control_vars() (replace with "Y")
    → deduplicate_control_vars() (clean up duplicates)
    → sort_table() (controls last)
    → separate_measures() (measures at bottom)
    ↓
Format Router (switch on output type)
    ↓
    ├─→ format_word() → flextable object
    ├─→ format_markdown() → character (markdown)
    └─→ format_latex() → character (LaTeX)
    ↓
Return to User
```

---

## Module Responsibilities

### `easytab.R` - Main Interface

**Purpose**: User-facing API and orchestration

**Key function**: `easy_table()`

**Responsibilities**:
- Validate `output` parameter
- Call validators
- Call parser
- Call transformer
- Route to appropriate formatter
- Handle CSV export
- Return formatted result

**DO**: Keep this thin - just orchestration
**DON'T**: Add business logic here

### `validators.R` - Input Validation

**Purpose**: Comprehensive input checking with helpful errors

**Key functions**:
- `validate_model_list()`: Check list structure
- `validate_model_types()`: Check model classes
- `validate_control_vars()`: Warn about missing vars
- `validate_parameters()`: Check parameter types
- `check_*_dependencies()`: Verify packages available

**DO**: Provide actionable error messages
**DON'T**: Silently fail or return TRUE/FALSE

### `parse_models.R` - Coefficient Extraction

**Purpose**: Extract statistics from models (format-agnostic)

**Key functions**:
- `parse_single_model()`: Extract from one model
- `format_coefficients()`: Add significance stars
- `extract_model_measures()`: Get fit statistics
- `parse_models()`: Handle multiple models

**DO**: Return standardized data frames
**DON'T**: Make formatting decisions

**Note**: This module handles robust.se and margins options

### `transform_table.R` - Data Organization

**Purpose**: Process parsed data into table structure

**Key functions**:
- `collapse_control_vars()`: Handle factor levels
- `mark_control_vars()`: Replace with "Y"
- `deduplicate_control_vars()`: Remove duplicates
- `sort_table()`: Order rows
- `separate_measures()`: Move measures to bottom
- `transform_table()`: Main orchestrator

**Critical fix**: Uses word boundaries in regex to avoid greedy matching
(e.g., "hp" no longer matches "hpq")

**DO**: Keep format-agnostic
**DON'T**: Generate format-specific output

### `format_*.R` - Renderers

**Purpose**: Convert transformed data to format-specific output

**`format_word.R`**:
- Uses flextable package
- Adds horizontal line before measures
- Supports highlighting (green/red backgrounds)
- Returns flextable object

**`format_markdown.R`**:
- Uses knitr::kable() (always available)
- Uses kableExtra (optional, for highlighting)
- Returns character string
- Adds footnotes

**`format_latex.R`**:
- Uses knitr + kableExtra
- Booktabs styling
- Threeparttable for footnotes
- Returns LaTeX code string

**DO**: Check package availability first
**DON'T**: Assume packages are installed

---

## Extension Points

### Adding New Output Formats

**Example: Adding HTML format**

1. Create `R/format_html.R`:

```r
#' @export
format_html <- function(table, robust.se, margins, highlight) {
  if (!requireNamespace("knitr", quietly = TRUE)) {
    stop("Package 'knitr' required for HTML output")
  }

  # Create HTML table
  result <- knitr::kable(table, format = "html")

  # Add footnotes
  # ...

  return(result)
}
```

2. Update `R/validators.R`:

```r
check_format_dependencies <- function(output) {
  if (output == "html") {
    if (!requireNamespace("knitr", quietly = TRUE)) {
      stop("Package 'knitr' required for HTML output")
    }
  }
  # ...
}
```

3. Update `R/easytab.R`:

```r
easy_table <- function(..., output = "word", ...) {
  output <- match.arg(output, c("word", "markdown", "latex", "html"))

  # ...

  result <- switch(
    output,
    word = format_word(...),
    markdown = format_markdown(...),
    latex = format_latex(...),
    html = format_html(...)
  )
}
```

4. Add tests in `tests/testthat/test-formats.R`

5. Update documentation in `R/easytab.R` roxygen

### Adding New Model Types

**Example: Adding plm (panel data) support**

1. Update `R/validators.R`:

```r
is_supported_model <- function(model) {
  inherits(model, c("lm", "glm", "plm"))
}
```

2. Update `R/parse_models.R`:

```r
parse_single_model <- function(model, robust.se, margins) {
  if (inherits(model, "plm")) {
    # Special handling for plm
    m <- broom::tidy(model)
    # Handle plm-specific features
  } else {
    # Existing lm/glm code
  }
}

extract_model_measures <- function(model) {
  if (inherits(model, "plm")) {
    # Extract plm-specific measures
    # e.g., within R², between R²
  }
  # ...
}
```

3. Add tests with plm models

4. Update documentation

### Adding Marginal Effects for GLM

Currently margins are supported, but GLM-specific marginal effects could be enhanced:

```r
# In parse_single_model()
if (inherits(model, "glm") && margins) {
  # Use margins::margins() with specific type
  m <- margins::margins(model, type = "response")
  # For logit: average marginal effects on probability scale
}
```

---

## Future Feature Placeholders

### Priority 1: Additional Model Types

**fixest** (fixed effects models):
- Location: `R/parse_models.R`
- Add case in `parse_single_model()`
- Handle multiple fixed effects
- Extract clustered SE (already supported by fixest)

**plm** (panel data):
- See extension point example above
- Handle within/between/random effects
- Panel-specific diagnostics

### Priority 2: Enhanced Statistics

**Confidence intervals**:
- Add to `format_coefficients()` in `parse_models.R`
- Optional parameter `conf.int = FALSE`
- Format as `[lower, upper]` below estimate

**Standardized coefficients**:
- Add to `parse_single_model()`
- Option `standardize = FALSE`
- Use `lm.beta` package or manual calculation

**Multiple comparison adjustments**:
- Add to `format_coefficients()`
- Option `p.adjust = c("none", "holm", "bonferroni")`

### Priority 3: Theme System

Create `R/themes.R`:

```r
# Define theme objects
theme_apa <- function() {
  list(
    font.family = "Times New Roman",
    font.size = 12,
    header.style = "bold",
    significance.stars = c("***", "**", "*"),
    decimal.places = 2
  )
}

theme_minimal <- function() { ... }

# Apply in format functions
format_word(..., theme = theme_apa())
```

### Priority 4: More Output Formats

**gt tables**:
- Modern alternative to flextable
- Better HTML rendering
- Create `R/format_gt.R`

**huxtable**:
- Multi-format support
- Create `R/format_huxtable.R`

**Custom formatters**:
- Allow user-defined formatting functions
- `format_custom(table, formatter = my_formatter)`

### Priority 5: Advanced Features

**Multi-equation models**:
- SUR (seemingly unrelated regression)
- Simultaneous equations
- Separate panels in output

**Model comparison tests**:
- Add rows for F-test, LR test, Wald test
- Compare nested models automatically

**Group/panel structure**:
- Separate sections for different model types
- E.g., "Linear Models" and "Logit Models" sections

**Stargazer compatibility**:
- Add `style = "stargazer"` option
- Mimic stargazer output exactly

---

## Testing Strategy

### Test Organization

```
tests/testthat/
├── helper-data.R           # Shared test data (penguins models)
├── test-validators.R       # Input validation tests
├── test-parsing.R          # Coefficient extraction tests
├── test-transform.R        # Data transformation tests
├── test-formats.R          # Format-specific tests
└── test-integration.R      # Full pipeline tests
```

### Test Coverage Goals

- **Unit tests**: Each function tested independently
- **Integration tests**: Full pipeline with various parameter combinations
- **Edge cases**: Empty models, perfect fit, missing data
- **Error handling**: Invalid inputs, missing packages

### Running Tests

```r
# Run all tests
devtools::test()

# Run specific test file
testthat::test_file("tests/testthat/test-validators.R")

# Check test coverage
covr::package_coverage()

# Check package
devtools::check()
```

### Key Test Cases

**Validators**:
- Invalid model lists (unnamed, empty, wrong type)
- Unsupported model types
- Missing control variables
- Invalid parameter types

**Parsing**:
- Basic lm/glm models
- Robust standard errors
- Marginal effects
- Robust SE + margins together
- Edge cases (intercept-only, perfect fit)

**Transform**:
- Control variable collapsing (especially regex fix)
- Control variable marking
- Deduplication
- Sorting
- Measure separation

**Formats**:
- Word output (flextable object)
- Markdown output (string with pipes)
- LaTeX output (string with LaTeX code)
- Highlighting (green/red backgrounds)
- Method notes (robust SE, margins)

**Integration**:
- All output formats
- All parameter combinations
- Multi-model tables
- CSV export
- Full pipeline with penguins data

---

## Critical Bugs Fixed in 2.0.0

### 1. Control Variable Regex (CRITICAL)

**Issue**: Original regex `^%s.*$` was too greedy

```r
# OLD (BAD):
mtable$term <- gsub(sprintf("^%s.*$", var), var, mtable$term)

# Problem: var="hp" matches both "hp" and "hpq"
```

**Fix**: Use word boundaries

```r
# NEW (GOOD):
pattern_exact <- sprintf("^%s($|[^[:alnum:]_].*$)", var)
mtable$term <- gsub(pattern_exact, var, mtable$term, perl = TRUE)

# Now: var="hp" only matches "hp", not "hpq"
```

**Location**: `R/transform_table.R`, `collapse_control_vars()`

### 2. Runtime Package Installation (SECURITY)

**Issue**: Package installed dependencies at runtime without user consent

```r
# OLD (DANGEROUS):
if (!requireNamespace("margins", quietly = TRUE)) {
  install.packages("margins")  # BAD!
}
```

**Fix**: Check and error with clear instructions

```r
# NEW (SAFE):
check_margins_dependencies <- function(margins) {
  if (margins && !requireNamespace("margins", quietly = TRUE)) {
    stop(
      "Package 'margins' is required for marginal effects.\n",
      "  Install it with: install.packages('margins')",
      call. = FALSE
    )
  }
}
```

**Location**: `R/validators.R`

### 3. Unspecified Join Columns

**Issue**: dplyr joins without `by` parameter generated warnings

```r
# OLD:
m <- left_join(m1, m2)  # Warning: Joining by "term"

# NEW:
m <- dplyr::left_join(m1, m2, by = "term")  # Explicit
```

**Location**: Fixed in multiple places during refactor

### 4. F/T Instead of FALSE/TRUE

**Issue**: Using `F` and `T` can be overwritten by user variables

```r
# OLD (BAD):
if (robust.se == T & margins == F)

# NEW (GOOD):
if (robust.se == TRUE & margins == FALSE)
```

**Location**: Fixed throughout package

---

## Contribution Guidelines

### Before You Start

1. Read this file (CLAUDE.md) completely
2. Review the architecture section
3. Look at existing code in relevant modules
4. Check if there's a related issue on GitHub

### Making Changes

1. **Create a branch**: `git checkout -b feature-name`
2. **Write tests first**: Test-driven development
3. **Make changes**: Follow existing patterns
4. **Document**: Add roxygen2 comments
5. **Test**: `devtools::test()` should pass
6. **Check**: `devtools::check()` should have 0 errors/warnings
7. **Commit**: Clear commit messages
8. **Push**: `git push origin feature-name`
9. **Pull request**: Describe changes, link to issue

### Code Style

- **Naming**: snake_case for functions and variables
- **Line length**: Max 80 characters (flexible to 100)
- **Indentation**: 2 spaces (R standard)
- **Documentation**: roxygen2 for all exported functions
- **Tests**: testthat for all new functionality

### Adding Features

1. **Validators**: Add to `R/validators.R` if new parameters
2. **Parsing**: Modify `R/parse_models.R` if new model types
3. **Transform**: Modify `R/transform_table.R` if new table operations
4. **Format**: Add new file `R/format_*.R` if new output type
5. **Main**: Update `R/easytab.R` to integrate new feature
6. **Tests**: Add tests in appropriate `test-*.R` file
7. **Docs**: Update roxygen in `R/easytab.R` and vignette

### Submitting Issues

**Bug reports**:
- Minimal reproducible example
- Expected vs actual behavior
- Session info (`sessionInfo()`)

**Feature requests**:
- Use case description
- Proposed API (if applicable)
- Examples from other packages

---

## Package Maintenance

### Release Checklist

1. **Update version**: DESCRIPTION, NEWS.md
2. **Run tests**: `devtools::test()`
3. **Check package**: `devtools::check()`
4. **Build vignettes**: `devtools::build_vignettes()`
5. **Update documentation**: `devtools::document()`
6. **Check spelling**: `spelling::spell_check_package()`
7. **Review NEWS.md**: Document all changes
8. **Build package**: `devtools::build()`
9. **Test installation**: `install.packages("easytable_2.0.0.tar.gz")`
10. **Tag release**: `git tag v2.0.0`
11. **Push**: `git push origin main --tags`
12. **GitHub release**: Create release on GitHub

### Dependency Updates

When updating dependencies:

1. Check backward compatibility
2. Update DESCRIPTION
3. Test with new versions
4. Document breaking changes in NEWS.md

### Documentation Updates

- **README.md**: User-facing, installation, quick start
- **Vignettes**: Detailed examples, best practices
- **Roxygen**: Function-level documentation
- **NEWS.md**: Version history, migration guides
- **CLAUDE.md**: Developer documentation (this file)

---

## Common Tasks

### Add Support for New Model Type

1. Update `is_supported_model()` in `validators.R`
2. Add case in `parse_single_model()` in `parse_models.R`
3. Handle model-specific measures in `extract_model_measures()`
4. Add tests with new model type
5. Update documentation in `easy_table()`

### Add New Output Format

1. Create `R/format_newformat.R`
2. Implement `format_newformat()` function
3. Add dependency check in `validators.R`
4. Add case in switch statement in `easytab.R`
5. Add tests in `test-formats.R`
6. Update documentation and vignette

### Fix a Bug

1. Write a test that demonstrates the bug
2. Fix the bug
3. Verify test passes
4. Add regression test if needed
5. Document fix in NEWS.md

---

## Resources

### R Package Development

- [R Packages (2nd ed)](https://r-pkgs.org/) by Wickham & Bryan
- [Writing R Extensions](https://cran.r-project.org/doc/manuals/r-release/R-exts.html) (CRAN manual)
- [testthat documentation](https://testthat.r-lib.org/)
- [roxygen2 documentation](https://roxygen2.r-lib.org/)

### Related Packages

- **stargazer**: LaTeX/HTML tables (reference implementation)
- **modelsummary**: Modern alternative with many features
- **huxtable**: Multi-format tables
- **gt**: Grammar of tables
- **flextable**: Word tables (used in easytable)
- **kableExtra**: Enhanced markdown/LaTeX (used in easytable)

### Statistical Computing

- [lmtest](https://cran.r-project.org/package=lmtest): Diagnostic testing
- [sandwich](https://cran.r-project.org/package=sandwich): Robust covariance
- [margins](https://cran.r-project.org/package=margins): Marginal effects
- [broom](https://cran.r-project.org/package=broom): Tidy model output

---

## Contact

- **Maintainer**: Alfredo Hernandez Sanchez <alhdzsz@gmail.com>
- **Issues**: https://github.com/alhdzsz/easytable/issues
- **Discussions**: https://github.com/alhdzsz/easytable/discussions

---

## Notes for Claude Code

When working on this package:

1. **Read this file first** before making changes
2. **Respect the modular architecture** - don't mix concerns
3. **Write tests** for any new functionality
4. **Document thoroughly** with roxygen2
5. **Check the plan**: See planning transcripts for context on major decisions
6. **Ask before breaking changes**: Maintain backward compatibility when possible

### Key Design Decisions

- **Default output = "word"**: Maintains backward compatibility
- **Conditional dependencies**: Keep package lightweight
- **Informative errors**: Always provide installation instructions
- **Modular architecture**: Easy to extend and maintain
- **Comprehensive testing**: Prevent regressions

Last updated: 2026-02-14
