# A life table built from a law of mortality

A life table built from a law of mortality

## Usage

``` r
life_table(m, x0 = 20, radix = 1e+05, max_age = 120)
```

## Arguments

- m:

  A mortality object from
  [`mortality_law()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/mortality_law.md).

- x0:

  Starting age.

- radix:

  Number of lives at the starting age.

- max_age:

  Limiting age for laws without one.

## Value

A data frame with columns x, lx, dx, qx and ex (curtate).
