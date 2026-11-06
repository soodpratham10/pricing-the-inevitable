# Probability the policy makes a loss

Probability the policy makes a loss

## Usage

``` r
prob_loss(product, q, i, S, P, n = 10, h = 5, t = NULL)
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

- P:

  Annual premium.

- n:

  Term in years, for products that use it.

- h:

  Deferral period in years, for products that use it.

- t:

  Premium paying term in years (NULL for life).

## Value

P(L \> 0).
