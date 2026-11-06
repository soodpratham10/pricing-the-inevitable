# Expected present value of a product

Expected present value of a product

## Usage

``` r
epv(product, q, i, n = 10, h = 5)
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

- n:

  Term in years, for products that use it.

- h:

  Deferral period in years, for products that use it.

## Value

The expected present value per unit of benefit.
