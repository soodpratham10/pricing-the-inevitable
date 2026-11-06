# Life annuity-due on the yearly grid

Life annuity-due on the yearly grid

## Usage

``` r
annuity_due(q, i, n = NULL)
```

## Arguments

- q:

  Annual death probabilities from
  [`q_path()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/q_path.md).

- i:

  Effective annual interest rate.

- n:

  Number of years of payments (NULL for whole life).

## Value

The EPV of 1 a year in advance while alive, for at most n years.
