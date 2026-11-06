# Change in the value of a hedged block after a mortality shock

Change in the value of a hedged block after a mortality shock

## Usage

``` r
block_change(
  m,
  n_ins,
  n_ann,
  s,
  x_ins = 40,
  x_ann = 65,
  S = 250000,
  B = 20000,
  i = 0.045
)
```

## Arguments

- m:

  A mortality object from
  [`mortality_law()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/mortality_law.md).

- n_ins:

  Number of insurance policies.

- n_ann:

  Number of annuities.

- s:

  Relative mortality shock.

- x_ins:

  Age of the insured lives.

- x_ann:

  Age of the annuitants.

- S:

  Insurance benefit.

- B:

  Annual annuity payment.

- i:

  Effective annual interest rate.

## Value

The change in the total value of the promises (positive means the
insurer owes more).
