# Percentile premium

The smallest premium for which the probability of a loss is at most
alpha.

## Usage

``` r
percentile_premium(product, q, i, S, alpha = 0.05, n = 10, h = 5, t = NULL)
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

- alpha:

  Largest acceptable probability of loss.

- n:

  Term in years, for products that use it.

- h:

  Deferral period in years, for products that use it.

- t:

  Premium paying term in years (NULL for life).

## Value

The percentile premium.
