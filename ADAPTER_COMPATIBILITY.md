# Adapter Compatibility Guide

This guide explains how `easytable` should adapt when renderer dependencies change (for example `flextable`, `knitr`, or `kableExtra`).

## 1) Keep a Stable Core Contract

Core transformation should output:

1. Display-ready strings for each cell.
2. Row semantics (`coefficient` vs `model_stat`).
3. Style intents (zebra eligibility, significance state, divider positions).

Renderers should consume this contract and avoid mutating row semantics.

## 2) Renderer Responsibilities

Each renderer adapter is responsible for:

1. Mapping style intents to backend syntax.
2. Preserving two-line coefficient cells.
3. Preserving single divider placement.
4. Preserving coefficient-only zebra policy.

Renderers should not infer business logic from text when semantic metadata exists.

## 3) Dependency Upgrade Checklist

When upgrading renderer dependencies:

1. Read release notes for breaking API changes.
2. Run `devtools::test()`.
3. Run constrained profile:
   - `EASYTABLE_SKIP_WORD_TESTS=true Rscript -e "devtools::test()"`
4. Run optional sandbox checks:
   - `EASYTABLE_RUN_XTEST=true Rscript tests/run-tests.R full`
5. Validate design invariants in produced tables.

## 4) Backward-Compatibility Policy

For internal adapters:

1. Keep wrapper functions small and isolated.
2. Avoid widespread direct calls to third-party APIs.
3. Change one adapter layer at a time.
4. Prefer additive transitions with feature flags when possible.

## 5) Failure Behavior

When a dependency is missing or incompatible:

1. Fail early.
2. Return a friendly, actionable error.
3. Include installation guidance in the message.

## 6) Testing Expectations

Add tests whenever adapter behavior changes:

1. Unit tests for mapping logic.
2. Invariant tests for final output semantics.
3. Regression tests for previously fixed formatting bugs.
