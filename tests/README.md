# Testing Protocol

This directory contains committed, deterministic package tests.

## Scope

- Main test suite: `tests/testthat/`
- Goal: stable CI behavior and reproducible validation

## How to Run Tests

### Core package tests

```r
devtools::test()
```

### In constrained environments (for example, headless AI sessions)

Word rendering tests can be skipped:

```sh
EASYTABLE_SKIP_WORD_TESTS=true Rscript -e "devtools::test()"
```

### Optional helper script

```sh
Rscript tests/run-tests.R core
```

## What Must Stay Stable

- Coefficient cell format: two lines (estimate + stars, then `(SE)`).
- Zebra striping only in the coefficient block.
- One divider line between coefficient block and model-stat block.
- Control indicators (`control.var`) are model-stat rows, not coefficient rows.
