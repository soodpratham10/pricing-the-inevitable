# Package index

## Chapter 1: The Clock

Laws of mortality, select mortality, extra risk and fractional ages.

- [`mortality_law()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/mortality_law.md)
  : Create a law of mortality
- [`mu_x()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/mu_x.md)
  : Force of mortality
- [`tpx()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/tpx.md)
  : Survival probability under a law of mortality
- [`q_path()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/q_path.md)
  : Annual death probabilities for a life aged x
- [`kpx_from_q()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/kpx_from_q.md)
  : Survival probabilities from annual death probabilities
- [`curtate_pmf()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/curtate_pmf.md)
  : Probability function of the curtate future lifetime
- [`curtate_ex()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/curtate_ex.md)
  : Curtate life expectancy
- [`spx()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/spx.md)
  : Fractional-age survival within one year
- [`tpx_frac()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/tpx_frac.md)
  : Survival to a non-integer time
- [`life_table()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/life_table.md)
  : A life table built from a law of mortality

## Chapters 2 and 3: Paying at Death and Paying for Life

Nineteen insurance and annuity products, with their full distributions.

- [`products()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/products.md)
  : The product shelf
- [`annuity_certain()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/annuity_certain.md)
  : Annuity-certain values
- [`pv_by_k()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/pv_by_k.md)
  : Present value of a product for each curtate lifetime
- [`product_moments()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/product_moments.md)
  : Expected value, variance and distribution of a product's present
  value
- [`epv()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/epv.md)
  : Expected present value of a product
- [`nEx()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/nEx.md)
  : Pure endowment factor nEx
- [`value_all()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/value_all.md)
  : Every product valued at once

## Paying more often than once a year

m-thly and continuous benefits by exact sums, UDD, Woolhouse and claims
acceleration.

- [`nominal_rates()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/nominal_rates.md)
  : Nominal rates of interest and discount
- [`annuity_due()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/annuity_due.md)
  : Life annuity-due on the yearly grid
- [`annuity_due_mthly()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/annuity_due_mthly.md)
  : Life annuity-due paid m times a year
- [`insurance_mthly()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/insurance_mthly.md)
  : Term or whole life insurance paid at the end of the 1/m-th of a year
  of death
- [`insurance_continuous()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/insurance_continuous.md)
  : Insurance paid at the moment of death
- [`insurance_continuous_exact()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/insurance_continuous_exact.md)
  : Insurance paid at the moment of death, exact under a law of
  mortality

## Chapter 4: The Quote

Premium principles and the loss at issue.

- [`net_premium()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/net_premium.md)
  : Net annual premium by the equivalence principle
- [`net_premium_mthly()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/net_premium_mthly.md)
  : Net premium paid m times a year
- [`loss_distribution()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/loss_distribution.md)
  : Loss at issue for every curtate lifetime
- [`prob_loss()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/prob_loss.md)
  : Probability the policy makes a loss
- [`loss_moments()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/loss_moments.md)
  : Mean and variance of the loss at issue
- [`percentile_premium()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/percentile_premium.md)
  : Percentile premium
- [`portfolio_premium()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/portfolio_premium.md)
  : Portfolio percentile premium
- [`simulate_portfolio()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/simulate_portfolio.md)
  : Simulate portfolios to check the probability of a portfolio loss
- [`refund_premium()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/refund_premium.md)
  : Premium for a policy that refunds the premiums on death

## The rate book

Plans, underwriting classes and premiums per 1,000.

- [`risk_classes()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/risk_classes.md)
  : The underwriting classes
- [`class_q_path()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/class_q_path.md)
  : Death probabilities for an underwriting class
- [`plans()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/plans.md)
  : The plans in the rate book
- [`plan_premium()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/plan_premium.md)
  : Premium for one plan
- [`rate_book()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/rate_book.md)
  : The rate book

## The natural hedge

Life insurance and annuities offsetting each other.

- [`shock_q()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/shock_q.md)
  : Shock annual death probabilities
- [`natural_hedge()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/natural_hedge.md)
  : The natural hedge between life insurance and annuities
- [`block_change()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/block_change.md)
  : Change in the value of a hedged block after a mortality shock
