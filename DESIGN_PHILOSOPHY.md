# easytable Design Philosophy

This document is the contributor guide for humans and AI agents working
on `easytable`.

## Core Aim

`easytable` should be easy to use and easy to read.

- Easy to use: one clear path from model objects to a publication-ready
  table.
- Easy to read: strong visual defaults and predictable output across
  formats.

## Source of Truth

The LaTeX table style is the visual reference.  
Word and HTML should converge toward the same design language.

## Non-Negotiable Table Invariants

1.  Coefficients and standard errors share one cell.
2.  Coefficient cell has two lines:
    - line 1: estimate with stars
    - line 2: standard error in parentheses
3.  Zebra striping is only for coefficient rows.
4.  No zebra striping on model statistics (`N`, `R sq.`, `Adj. R sq.`,
    `AIC`) or control indicators.
5.  No horizontal rules between individual coefficient rows.
6.  Exactly one divider line between coefficient block and model-stat
    block.
7.  Control indicators from `control.var` belong to the model-stat
    block.

## Architecture Direction

Target architecture:

1.  Core produces a backend-agnostic table spec:
    - finalized display strings
    - row/column semantic roles
    - style map tokens
2.  Renderers are thin adapters (`word`, `latex`, future renderers).
3.  Renderer code should avoid data transformation logic.

## Contribution Guardrails

Before merging:

1.  Validate invariants in `tests/testthat`.
2.  Prefer adding tests before or with behavior changes.
3.  Avoid renderer-only fixes that silently diverge from other formats.

## AI Agent Protocol

If you are an AI coding agent:

1.  Read `tests/README.md` before changing tests.
2.  Keep changes deterministic in `tests/testthat`.
3.  Document any design decision in `AI_NOTES.md` with timestamp + next
    step.

## Release Quality Standard

A release is acceptable when:

1.  design invariants pass in core tests,
2.  output behavior is predictable for `lm`/`glm`,
3.  documentation explains both the user path and architecture limits
    clearly.
