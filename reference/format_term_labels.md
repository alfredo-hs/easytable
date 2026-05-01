# Format term labels for display

Transformations:

- Preserve polynomial suffixes (.L, .Q, .C, etc.)

- Split factor levels using levels_map

- Abbreviate only variable portion (if abbreviate = TRUE)

- Ensure uniqueness after abbreviation

## Usage

``` r
format_term_labels(
  terms,
  row_types = NULL,
  levels_map = NULL,
  abbreviate = FALSE
)
```

## Arguments

- terms:

  Character vector of displayed term labels.

- row_types:

  Optional character vector of row types

- levels_map:

  List mapping factor names to their levels

- abbreviate:

  Logical. Apply abbreviation? Default FALSE
