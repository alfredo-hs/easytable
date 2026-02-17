# Format term labels for display

Transformations:

- Preserve polynomial suffixes (.L, .Q, .C, etc.)

- Split factor levels using levels_map

- Abbreviate only variable portion (if abbreviate = TRUE)

- Ensure uniqueness after abbreviation

## Usage

``` r
format_term_labels(terms, levels_map = NULL, abbreviate = FALSE)
```

## Arguments

- abbreviate:

  Logical. Apply abbreviation? Default FALSE
