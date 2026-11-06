# Annual death probabilities for a life aged x

Returns q for durations 0, 1, 2, ... until the limiting age, where the
last probability is set to 1. Optional select mortality and extra risk
are applied in this order: age rating, select factors, then an addition
to the force of mortality or a multiple of q.

## Usage

``` r
q_path(m, x, select = NULL, extra = NULL, max_age = 120)
```

## Arguments

- m:

  A mortality object from
  [`mortality_law()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/mortality_law.md).

- x:

  Issue age.

- select:

  NULL for ultimate mortality, or a list with `factors`, the multipliers
  applied to q in the first select years (for example
  `list(factors = c(0.7, 0.85))`).

- extra:

  NULL, or a list describing extra risk:
  `list(type = "age", years = 5)`,
  `list(type = "add_mu", delta = 0.005)` or
  `list(type = "mult_q", k = 1.5)`.

- max_age:

  Limiting age for laws without one.

## Value

A numeric vector of one-year death probabilities.
