[← Previous: The Clock](01-the-clock.md) · [Overview](../../README.md) · [Next: Paying for Life →](03-paying-for-life.md)

# Chapter 2: Paying at Death

*Insurance, and the whole distribution behind its price.*

**Code:** [`R/products.R`](../../R/products.R) · **Tests:** [`tests/testthat/test-products.R`](../../tests/testthat/test-products.R) (30, shared with Chapter 3)

## One method for every product

For the curtate future lifetime $K$, with $P(K = k) = {}_kp_x \, q_{x+k}$, the engine writes down the present value of each benefit for every possible $k$ (`pv_by_k()`), then takes moments over that distribution:

$$E[Z] = \sum_k z_k \, P(K = k), \qquad \text{Var}(Z) = \sum_k z_k^2 \, P(K = k) - E[Z]^2$$

Because the whole distribution is kept, the same code gives percentiles and probabilities of loss in Chapter 4.

## The eight insurance benefits

| Product | Present value if $K = k$ |
|---|---|
| Whole life | $v^{k+1}$ |
| n-year term | $v^{k+1}$ if $k < n$ |
| n-year pure endowment | $v^n$ if $k \ge n$ |
| n-year endowment | $v^{\min(k+1, n)}$ |
| h-year deferred whole life | $v^{k+1}$ if $k \ge h$ |
| h-year deferred n-year term | $v^{k+1}$ if $h \le k < h + n$ |
| Increasing n-year term | $(k+1) v^{k+1}$ if $k < n$ |
| Decreasing n-year term | $(n - k) v^{k+1}$ if $k < n$ |

## At age 40, 4.5% interest (ultimate mortality)

| Quantity | Value |
|---|---|
| $A_{40}$ | 0.163842 |
| $\text{Var}(Z)$, whole life | 0.012710 |
| $A_{40:\overline{20}\vert}$, endowment | 0.421153 |
| $A^1_{40:\overline{20}\vert}$, term | 0.023855 |

## Checks

- A three-year life valued by hand at 10%: whole life, term, pure endowment, endowment and the second moment.
- Identities: $A_x = 1 - d \ddot a_x$; endowment = term + pure endowment; deferred whole life = whole life − term; deferred term = (h + n)-year term − h-year term; increasing + decreasing term = (n + 1) × term.

## Key functions

`products()`, `pv_by_k()`, `product_moments()`, `epv()`, `nEx()`, `value_all()`
