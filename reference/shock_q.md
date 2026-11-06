# Shock annual death probabilities

Multiplies every q by (1 + s), capped at 1, keeping the last year at 1.

## Usage

``` r
shock_q(q, s)
```

## Arguments

- q:

  Annual death probabilities from
  [`q_path()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/q_path.md).

- s:

  Relative shock (0.1 means 10% heavier mortality).

## Value

The shocked death probabilities.
