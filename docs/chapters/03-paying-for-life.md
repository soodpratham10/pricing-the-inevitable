[← Previous: Paying at Death](02-paying-at-death.md) · [Overview](../../README.md) · [Next: The Quote →](04-the-quote.md)

# Chapter 3: Paying for Life

*Annuities, and what changes when payments come monthly.*

**Code:** [`R/products.R`](../../R/products.R), [`R/frequency.R`](../../R/frequency.R) · **Tests:** [`tests/testthat/test-products.R`](../../tests/testthat/test-products.R), [`tests/testthat/test-frequency.R`](../../tests/testthat/test-frequency.R) (17)

## The eleven annuities

Annuity-due and annuity-immediate versions of whole life, n-year term, h-year deferred whole life and h-year deferred n-year term; n-year guaranteed (certain-and-life) annuities in both timings; and an increasing whole life annuity-due. Each is valued from its present value for every curtate lifetime, exactly as in Chapter 2. For example, the guaranteed annuity-due pays $\ddot a_{\overline{\max(k+1, n)}\vert}$.

At age 40 and 4.5%: $\ddot a_{40} = 19.417455$, and an annuity-due deferred to 65 is worth 4.172405.

Variances follow from the insurance results: $\text{Var}(Y) = \text{Var}(Z) / d^2$, for the whole life annuity (with whole life insurance) and the term annuity (with endowment insurance). The tests check both.

## Paying monthly

| Method | Formula | $\ddot a^{(12)}_{40}$ |
|---|---|---|
| Exact sum, UDD | $\frac{1}{12} \sum_j v^{j/12} \, {}_{j/12}p_x$ | 18.954869 |
| UDD formula | $\alpha(m) \ddot a_x - \beta(m)$ | 18.954869 |
| Exact sum, constant force | as above, constant force within each year | 18.953979 |
| Woolhouse, 2 terms | $\ddot a_x - \frac{m-1}{2m}$ | 18.959122 |
| Woolhouse, 3 terms | also $- \frac{m^2-1}{12 m^2} (\delta + \mu_x)$ | 18.955417 |

Under UDD the alpha-beta formula is not an approximation: it equals the exact UDD sum, and the tests check that to 1e-10. Against the constant-force exact value, the third Woolhouse term cuts the error from 0.0051 to 0.0014.

## Paying at the moment of death

| Method | $\bar A_{40}$ |
|---|---|
| Exact, integrating $v^t \, {}_tp_x \, \mu_{x+t}$ (Simpson's rule) | 0.167477 |
| UDD: $\frac{i}{\delta} A_x$ | 0.167501 |
| Claims acceleration: $(1+i)^{1/2} A_x$ | 0.167488 |

## Key functions

`annuity_certain()`, `annuity_due()`, `annuity_due_mthly()`, `nominal_rates()`, `insurance_mthly()`, `insurance_continuous()`, `insurance_continuous_exact()`
