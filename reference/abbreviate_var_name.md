# Abbreviate variable name

Deterministic abbreviation rules:

- (Intercept) is preserved

- Single-token names truncate to 6 characters

- "\_" and "." are treated as separators

- Two-token names become `token1[1:4] . token2[1:4]`

- Three-plus-token names become `t1[1:2] . t2[1:2] . t3[1:2]`

## Usage

``` r
abbreviate_var_name(var_name)
```

## Arguments

- var_name:

  Character string

## Value

Character string
