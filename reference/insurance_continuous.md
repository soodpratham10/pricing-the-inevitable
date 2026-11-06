# Insurance paid at the moment of death

Insurance paid at the moment of death

## Usage

``` r
insurance_continuous(q, i, n = NULL, method = "udd")
```

## Arguments

- q:

  Annual death probabilities from
  [`q_path()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/q_path.md).

- i:

  Effective annual interest rate.

- n:

  Term in years (NULL for whole life).

- method:

  "udd" (i / delta times the annual value) or "claims" (claims
  acceleration, (1 + i)^(1/2) times the annual value).

## Value

The EPV of a benefit of 1 paid at the moment of death.
