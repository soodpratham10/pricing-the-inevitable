# The rate book

Premium per 1,000 of benefit for every plan, issue age, class and
frequency.

## Usage

``` r
rate_book(m, ages = seq(25, 65, by = 5), i = 0.045)
```

## Arguments

- m:

  A mortality object from
  [`mortality_law()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/mortality_law.md).

- ages:

  Issue ages in the book.

- i:

  Effective annual interest rate.

## Value

A data frame with plan, issue_age, class, frequency, annual premium per
1,000 and the instalment per 1,000 (the annual premium, or a twelfth of
it).
