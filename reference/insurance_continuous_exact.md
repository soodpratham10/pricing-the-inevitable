# Insurance paid at the moment of death, exact under a law of mortality

Integrates v^t tpx mu(x + t) with Simpson's rule.

## Usage

``` r
insurance_continuous_exact(m, x, i, n = NULL, max_age = 120, steps = 200)
```

## Arguments

- m:

  A mortality object from
  [`mortality_law()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/mortality_law.md).

- x:

  Age.

- i:

  Effective annual interest rate.

- n:

  Term in years (NULL for whole life to max_age).

- max_age:

  Upper limit of integration for whole life.

- steps:

  Integration steps per year (even total).

## Value

The EPV of a benefit of 1 paid at the moment of death.
