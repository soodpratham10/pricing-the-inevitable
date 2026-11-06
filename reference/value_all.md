# Every product valued at once

Every product valued at once

## Usage

``` r
value_all(q, i, n = 10, h = 5)
```

## Arguments

- q:

  Annual death probabilities from
  [`q_path()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/q_path.md).

- i:

  Effective annual interest rate.

- n:

  Term in years.

- h:

  Deferral period in years.

## Value

The product table from
[`products()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/products.md)
with the EPV, variance and standard deviation of each product.
