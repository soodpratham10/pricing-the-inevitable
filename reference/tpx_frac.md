# Survival to a non-integer time

Survival to a non-integer time

## Usage

``` r
tpx_frac(q, t, assumption = "udd")
```

## Arguments

- q:

  Annual death probabilities from
  [`q_path()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/q_path.md).

- t:

  Time or vector of times (years).

- assumption:

  Fractional-age assumption passed to
  [`spx()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/spx.md).

## Value

The survival probability at each t.
