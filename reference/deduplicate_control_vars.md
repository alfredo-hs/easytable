# Remove duplicate control variable rows

After collapsing control variables, removes duplicate rows but keeps one
representative row per control variable for each model.

## Usage

``` r
deduplicate_control_vars(table)
```

## Arguments

- table:

  A data frame with regression results

## Value

A data frame with duplicates removed
