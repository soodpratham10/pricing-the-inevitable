# Expected value, variance and distribution of a product's present value

Expected value, variance and distribution of a product's present value

## Usage

``` r
product_moments(product, q, i, n = 10, h = 5)
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

A list with `epv`, `second` (second moment), `var`, `sd` and `dist`, a
data frame of the present value for each curtate lifetime and its
probability.

## Examples

``` r
q <- q_path(mortality_law(), 40)
product_moments("whole_life", q, 0.045)$epv
#> [1] 0.1638416
```
