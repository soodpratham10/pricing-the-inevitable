# Simulate portfolios to check the probability of a portfolio loss

Simulate portfolios to check the probability of a portfolio loss

## Usage

``` r
simulate_portfolio(
  product,
  q,
  i,
  S,
  P,
  N,
  sims = 2000,
  seed = 2026,
  n = 10,
  h = 5,
  t = NULL
)
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

- N:

  Policies in each portfolio.

- sims:

  Number of simulated portfolios.

- seed:

  Random seed.

- n:

  Term in years, for products that use it.

- h:

  Deferral period in years, for products that use it.

- t:

  Premium paying term in years (NULL for life).

## Value

A list with the simulated `prob_loss` and the vector of portfolio
`totals`.
