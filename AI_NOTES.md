# AI Notes for easytable

This file is the handoff brief for human contributors and AI coding agents.

## 1) Project Mission

`easytable` is a workhorse regression-table package with one promise:

1. Easy to use.
2. Easy to read.

The design reference is the LaTeX output style. Word/HTML should converge to the same visual language.

## 2) Stable User API (current)

Main function:

- `easytable(...)`

Supported model classes:

- `lm`
- `glm`

Supported outputs:

- `output = "word"` (default, `flextable`)
- `output = "latex"`

Optional exports:

- `export.word = "table.docx"`
- `export.csv = "table.csv"`

## 3) Non-Negotiable Design Invariants

1. Coefficients and standard errors share one cell with a real line break.
2. Coefficient row content is `estimate + stars` on line 1, `(SE)` on line 2.
3. Zebra striping is allowed only in the coefficient block.
4. Model-stat rows (`N`, `R-squared`, `AIC`, control indicators, FE indicators, etc.) must not be zebra-striped.
5. No horizontal rules between individual coefficient rows.
6. Exactly one divider line between the coefficient block and model-stat block.

Use `DESIGN_PHILOSOPHY.md` as the policy source for output decisions.

## 4) Architecture Map

Pipeline in `R/easytab.R`:

1. Validate inputs (`R/validators.R`)
2. Parse model results (`R/parse_models.R`)
3. Transform table structure (`R/transform_table.R`)
4. Render output (`R/format_word.R` or `R/format_latex.R`)
5. Optional side-effect exports (`export.word`, `export.csv`)

Current technical debt:

- Some renderer-level styling logic still infers row semantics from rendered strings.
- Long-run direction remains: backend-agnostic table spec + thin adapters.

## 5) Renderer Expectations

`R/format_word.R` and `R/format_latex.R` should:

1. Consume finalized display strings and row semantics.
2. Apply backend styling without redefining business logic.
3. Preserve the invariant set above.

## 6) Testing Protocol (important)

Committed tests live in `tests/testthat/`.

Protocol:

- Keep invariant assertions in committed tests.
- Keep tests deterministic and CI-safe.
- Keep private local experiments out of package documentation and release notes.

See `tests/README.md` for details.

## 7) Documentation and pkgdown

Source docs:

- `_pkgdown.yml`
- `pkgdown/index.md`
- `vignettes/*.Rmd`
- `README.md`

Deployment:

- Use GitHub Actions workflow at `.github/workflows/pkgdown.yaml`.
- Recommended GitHub Pages source: `gh-pages` branch root.
- Do not rely on manually committed `docs/` artifacts as authoritative.

## 8) Contributor Guardrails

1. Keep user-facing errors beginner-friendly and actionable.
2. Preserve API clarity over parameter proliferation.
3. Prefer small, auditable changes.
4. Update docs/tests when behavior changes.
5. If design tradeoffs are ambiguous, choose consistency with LaTeX reference style.
6. Do not create unnecessary workspace clutter (temporary logs, check folders, tarballs, scratch notes).
7. If temporary files are needed for debugging, remove them before finishing unless they are required for package functionality.

## 9) Quick Pre-PR Checklist

1. `devtools::test()` passes.
2. Invariants are still true in Word and LaTeX output.
3. README and vignette examples run with current API.
4. `_pkgdown.yml` links resolve to existing pages.
5. No IDE artifacts are staged (`.Rproj.user`, etc.).
6. No temporary artifacts remain (`*.Rcheck/`, `*.tar.gz`, stray scratch files).
