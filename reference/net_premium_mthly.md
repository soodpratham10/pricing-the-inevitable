# Net premium paid m times a year

Net premium paid m times a year

## Usage

``` r
net_premium_mthly(
  product,
  q,
  i,
  S = 1,
  n = 10,
  h = 5,
  t = NULL,
  m = 12,
  method = "udd",
  mu0 = NULL,
  mun = NULL
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

- n:

  Term in years, for products that use it.

- h:

  Deferral period in years, for products that use it.

- t:

  Premium paying term in years (NULL for life).

- m:

  Premium instalments a year.

- method:

  Method for the m-thly premium annuity, passed to
  [`annuity_due_mthly()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/annuity_due_mthly.md).

- mu0, mun:

  Force of mortality at the start and end of the premium term, needed
  only for "woolhouse3".

## Value

A list with the total `annual` premium and each `instalment`.
