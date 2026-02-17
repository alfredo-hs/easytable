# easytable

`easytable` helps you move from fitted models to publication-ready tables with clear defaults and minimal code.

Main promise:

1. Easy to use.
2. Easy to read.

## Start Here

- [Penguins Tutorial](articles/penguins-tutorial.html)
- [Function Reference](reference/index.html)

## What You Get

- One function for routine workflows: `easytable()`
- Word/HTML and LaTeX output paths
- Two-line coefficient cells (`estimate + stars`, then `(SE)`)
- Control-variable indicators for compact model specifications
- Optional export to `.docx` and `.csv`

## Stable Scope

Current stable classes:

- `lm`
- `glm`

Other model classes (including `plm`) are intentionally deferred until core API and renderer contracts are finalized.

## For Contributors

- [Design Philosophy](https://github.com/alfredo-hs/easytable/blob/main/DESIGN_PHILOSOPHY.md)
- [Developer Roadmap](articles/developer-roadmap.html)
- [Testing Protocol](https://github.com/alfredo-hs/easytable/blob/main/tests/README.md)
