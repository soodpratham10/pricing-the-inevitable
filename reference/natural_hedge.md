# The natural hedge between life insurance and annuities

Measures how much the value of one whole life insurance policy and one
whole life annuity-due change when mortality is shocked, and finds the
number of annuities per insurance policy that makes the total
insensitive to the shock.

## Usage

``` r
natural_hedge(
  m,
  x_ins = 40,
  x_ann = 65,
  S = 250000,
  B = 20000,
  i = 0.045,
  shock = 0.1
)
```

## Arguments

- m:

  A mortality object from
  [`mortality_law()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/mortality_law.md).

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

- shock:

  Size of the shock used for the central difference.

## Value

A list with the sensitivities `dA` and `da` (change per unit of relative
shock), the per-policy changes `ins_change` and `ann_change` for the
given shock, and `ratio`, the annuities per insurance policy that hedge
the block.

## Examples

``` r
natural_hedge(mortality_law())$ratio
#> [1] 0.2618415
```
