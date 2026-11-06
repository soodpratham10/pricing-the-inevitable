# Portfolio percentile premium

The premium for which a portfolio of N independent policies makes a loss
with probability alpha, using the normal approximation: N E(L) + z(1 -
alpha) sqrt(N Var(L)) = 0.

## Usage

``` r
portfolio_premium(product, q, i, S, N, alpha = 0.05, n = 10, h = 5, t = NULL)
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

- N:

  Number of policies.

- alpha:

  Probability of a portfolio loss.

- n:

  Term in years, for products that use it.

- h:

  Deferral period in years, for products that use it.

- t:

  Premium paying term in years (NULL for life).

## Value

The portfolio percentile premium.
