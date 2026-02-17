# easytable API Rework Plan

Goal: keep the package beginner-friendly while removing mixed behavior from one function.

## Problem

`easytable()` currently:

1. builds table data,
2. renders output,
3. exports files.

This is convenient, but mixes responsibilities and makes maintenance harder.

## Proposed End State

Keep `easytable()` as the simple entry point, but implement explicit staged helpers:

1. `easytable_build(...)` -> returns backend-agnostic table spec.
2. `easytable_render(spec, output = "word" | "latex")` -> returns renderer object.
3. `easytable_export(spec_or_rendered, export.word = NULL, export.csv = NULL)` -> writes files.

`easytable()` becomes a wrapper around those three functions.

## Migration Plan

### Phase 1 (now)

1. Keep current behavior.
2. Improve validation messages and documentation.
3. Document side effects clearly.

### Phase 2

1. Add staged helper functions behind current API.
2. Add tests around staged interfaces.
3. Keep output parity with existing behavior.

### Phase 3

1. Promote staged helpers in documentation.
2. Keep `easytable()` for beginners and quick workflows.
3. Introduce soft deprecations only if needed.

## Beginner-Centered UX Rules

1. Default examples should show one function call.
2. Error messages should explain what to do next.
3. Optional complexity should be additive, not required.

## Success Criteria

1. No behavior regressions in current workflows.
2. Cleaner internals for renderer maintenance.
3. Clear migration path for future model classes and output adapters.
