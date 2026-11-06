# Loss at issue for every curtate lifetime

L = S Z - P Y, where Z is the present value of the benefit and Y the
present value of the premiums actually paid.

## Usage

``` r
loss_distribution(product, q, i, S, P, n = 10, h = 5, t = NULL)
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

A data frame with the curtate lifetime k, its probability, the benefit
present value Z, the premium annuity Y and the loss.
