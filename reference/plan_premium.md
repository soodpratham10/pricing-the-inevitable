# Premium for one plan

Premium for one plan

## Usage

``` r
plan_premium(
  m,
  x,
  plan,
  class = "Standard",
  frequency = "Annual",
  i = 0.045,
  S = 1000
)
```

## Arguments

- m:

  A mortality object from
  [`mortality_law()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/mortality_law.md).

- x:

  Issue age.

- plan:

  A plan code from
  [`plans()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/plans.md).

- class:

  An underwriting class from
  [`risk_classes()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/risk_classes.md).

- frequency:

  "Annual" or "Monthly" (monthly premiums use the UDD m-thly annuity).

- i:

  Effective annual interest rate.

- S:

  Benefit: the sum assured, or the yearly income for the deferred
  annuity.

## Value

The total premium for a year (for Monthly, 12 times each instalment).

## Examples

``` r
plan_premium(mortality_law(), 40, "T20", "Smoker", S = 250000)
#> [1] 783.2338
```
