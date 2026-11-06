[← Previous: Paying for Life](03-paying-for-life.md) · [Overview](../../README.md)

# Chapter 4: The Quote

*Premiums, the risk inside them, the rate book and the natural hedge.*

**Code:** [`R/premiums.R`](../../R/premiums.R), [`R/ratebook.R`](../../R/ratebook.R), [`R/hedge.R`](../../R/hedge.R) · **Tests:** `test-premiums.R` (22), `test-ratebook.R` (14), `test-hedge.R` (7) · **SQL:** [`sql/`](../../sql/) · **Excel:** [`excel/rate_calculator.xlsx`](../../excel/rate_calculator.xlsx) · **Memo:** [`report/pricing-memo.pdf`](../../report/pricing-memo.pdf)

## The loss at issue

With level annual premiums $P$ paid in advance while alive, for at most $t$ years:

$$L_0 = S \, Z - P \, Y, \qquad Y = \ddot a_{\overline{\min(K+1, t)}\vert}$$

The engine keeps $L_0$ for every curtate lifetime, so it can give the whole distribution, not just its mean.

## Four premium principles (whole life, age 40, $250,000, 4.5%)

| Principle | Rule | Premium |
|---|---|---|
| Equivalence | $E[L_0] = 0$ | $2,109.46 |
| Percentile, one policy | $P(L_0 > 0) \le 5\%$ | $6,589.87 |
| Portfolio percentile, 1,000 policies | $N E[L] + z_{0.95} \sqrt{N \text{Var}(L)} = 0$ | $2,200.39 |
| Premium refund on death (20-year term) | $P \ddot a = S A^1 + P (IA)^1$ | $453.38, against $443.66 without the refund |

At the net premium the policy loses money with probability 33.8%, and the loss variance equals $(S + P/d)^2 (^2A_x - A_x^2)$, as the textbook says. The portfolio premium is checked by simulating 2,000 portfolios; the share that lose money comes out close to 5%.

**The percentile trap.** For 20-year term at 40, death within 20 years has probability 4.2%. A zero premium already gives a loss with probability below 5%, so the 95% percentile premium is **$0**. A percentile rule on its own can give the cover away.

## The rate book

`rate_book()` prices 6 plans (whole life, 20-pay whole life, 10- and 20-year term, 20-year endowment, a deferred annuity from 65) for 9 issue ages, 4 underwriting classes and 2 payment frequencies: 424 rates per 1,000 of benefit. Standard annual rates at 40:

| WL | WL20 | T10 | T20 | E20 | DA65 |
|---|---|---|---|---|---|
| 8.42 | 12.16 | 1.06 | 1.75 | 31.31 | 273.70 |

Relative to Standard at 40, smokers pay 1.33 times as much for whole life but only 0.82 times as much for the deferred annuity, and the Rated class's flat extra multiplies 10-year term by 5.5.

The SQL database stores the rate book, the model's probability of loss for each rate cell, 50,000 simulated policies and a quote log, with views for the rate card, class loadings, the cost of paying monthly, and actual against expected losses. The Excel rate calculator rebuilds any quote in formulas and checks it against the R rate book.

## The natural hedge

Heavier mortality brings insurance claims forward and cuts annuity payments short. The engine measures both sensitivities by a central difference and solves for the mix that cancels them:

$$\text{ratio} = - \frac{S \, \partial A / \partial s}{B \, \partial \ddot a / \partial s}$$

For whole life at 40 ($250,000) against annuities at 65 ($20,000 a year), the ratio is **0.262**. A 10% mortality shock changes 1,000 insurance policies by $1,593,241; with 262 annuities alongside, the change is $15,855. What remains is second order, and it is positive whichever way mortality moves.

## Key functions

`net_premium()`, `net_premium_mthly()`, `loss_distribution()`, `prob_loss()`, `loss_moments()`, `percentile_premium()`, `portfolio_premium()`, `simulate_portfolio()`, `refund_premium()`, `risk_classes()`, `class_q_path()`, `plans()`, `plan_premium()`, `rate_book()`, `shock_q()`, `natural_hedge()`, `block_change()`
