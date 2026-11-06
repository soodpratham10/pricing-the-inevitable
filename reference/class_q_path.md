# Death probabilities for an underwriting class

Death probabilities for an underwriting class

## Usage

``` r
class_q_path(m, x, class = "Standard", select = TRUE)
```

## Arguments

- m:

  A mortality object from
  [`mortality_law()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/mortality_law.md).

- x:

  Issue age.

- class:

  One of the classes in
  [`risk_classes()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/risk_classes.md).

- select:

  TRUE to apply select mortality for a newly underwritten life.

## Value

Annual death probabilities from
[`q_path()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/q_path.md).
