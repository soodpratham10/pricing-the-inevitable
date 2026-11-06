# Survival probability under a law of mortality

The probability that a life aged x survives t more years, exact under
the law.

## Usage

``` r
tpx(m, x, t)
```

## Arguments

- m:

  A mortality object from
  [`mortality_law()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/mortality_law.md).

- x:

  Age.

- t:

  Time or vector of times (years).

## Value

The survival probability for each t.
