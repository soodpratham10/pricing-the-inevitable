# Net annual premium by the equivalence principle

Premiums are paid annually in advance for t years (or for life), while
alive.

## Usage

``` r
net_premium(product, q, i, S = 1, n = 10, h = 5, t = NULL)
```

## Arguments

- product:

  A product id from
  [`products()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/products.md).

- q:

  Annual death probabilities from
  [`q_path()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/q_path.md).

- i:

  Effective annual interest rate.

- S:

  Benefit amount.

- n:

  Term in years, for products that use it.

- h:

  Deferral period in years, for products that use it.

- t:

  Premium paying term in years (NULL for life).

## Value

The level annual net premium.

## Examples

``` r
q <- q_path(mortality_law(), 40)
net_premium("whole_life", q, 0.045, S = 250000)
#> [1] 2109.463
```
