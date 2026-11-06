# Term or whole life insurance paid at the end of the 1/m-th of a year of death

Term or whole life insurance paid at the end of the 1/m-th of a year of
death

## Usage

``` r
insurance_mthly(q, i, m, n = NULL, method = "udd")
```

## Arguments

- q:

  Annual death probabilities from
  [`q_path()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/q_path.md).

- i:

  Effective annual interest rate.

- m:

  Periods a year.

- n:

  Term in years (NULL for whole life).

- method:

  "udd" (i / i(m) times the annual value) or "exact_udd" (sum over every
  period under UDD).

## Value

The EPV of a benefit of 1.
