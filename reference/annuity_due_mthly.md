# Life annuity-due paid m times a year

Pays 1/m at the start of every 1/m of a year while alive, for at most n
years.

## Usage

``` r
annuity_due_mthly(q, i, m, n = NULL, method = "udd", mu0 = NULL, mun = NULL)
```

## Arguments

- q:

  Annual death probabilities from
  [`q_path()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/q_path.md).

- i:

  Effective annual interest rate.

- m:

  Payments a year.

- n:

  Number of years (NULL for whole life).

- method:

  "exact_udd" or "exact_cf" (sum every payment using that fractional-age
  assumption), "udd" (alpha and beta formula), "woolhouse2" or
  "woolhouse3" (two or three terms of Woolhouse's formula).

- mu0, mun:

  Force of mortality at the start and at the end of the term, needed
  only for "woolhouse3".

## Value

The EPV of the m-thly annuity-due.
