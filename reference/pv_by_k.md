# Present value of a product for each curtate lifetime

Present value of a product for each curtate lifetime

## Usage

``` r
pv_by_k(product, K, i, n = 10, h = 5)
```

## Arguments

- product:

  A product id from
  [`products()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/products.md).

- K:

  Number of possible curtate lifetimes (K = 0, ..., K - 1).

- i:

  Effective annual interest rate.

- n:

  Term in years, for products that use it.

- h:

  Deferral period in years, for products that use it.

## Value

The present value of the benefit if the curtate lifetime is k.
