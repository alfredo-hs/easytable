# Testing Protocol

This directory has two different test tracks:

1. `tests/testthat/` (committed, deterministic, CI-safe)
2. `tests/xtest/` (user sandbox, exploratory, intentionally not part of CI)

## Non-Negotiable Separation

- Do not move sandbox files from `tests/xtest/` into `tests/testthat/`.
- Do not assume `tests/xtest/` exists in forks or CI.
- Keep `tests/xtest/` available for manual rendering checks (`.qmd`, `.pdf`, `.docx`, large models).

## How To Run Tests

### Core package tests

```r
devtools::test()
```

### In constrained environments (for example, headless AI sandboxes)

Word rendering tests can be skipped:

```sh
EASYTABLE_SKIP_WORD_TESTS=true Rscript -e "devtools::test()"
```

### Optional sandbox checks

Sandbox checks are opt-in and are not required for CI:

```sh
EASYTABLE_RUN_XTEST=true Rscript tests/run-tests.R full
```

## Test Layers

- `core`: `tests/testthat/` only.
- `full`: `tests/testthat/` + optional `tests/xtest/test-api-and-layout.R` when explicitly enabled.

## What Must Stay Stable

- Coefficient cell format: two lines (estimate + stars, then `(SE)`).
- Zebra striping only in coefficient block.
- One divider line between coefficient block and model-stat block.
- Control indicators (`control.var`) are model-stat rows, not coefficient rows.
