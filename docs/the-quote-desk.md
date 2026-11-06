[← Overview](../README.md)

# The Quote Desk

**[▶ Open it](https://soodpratham10.shinyapps.io/pricing-the-inevitable/)**

A pricing desk in the style of a 1950s insurance office, for the fictional Prairie Life. Every number comes from the `inevitable` package.

## The Quote Desk tab

Choose the applicant (name, issue age 20 to 75, underwriting class), the plan, the benefit, how often premiums are paid (annual, or monthly by UDD, two-term Woolhouse or the exact constant-force sum), the interest rate, the acceptable chance of a loss and the size of the portfolio. The desk types a quote letter with:

- the premium per payment and per year, and per $1,000 of benefit
- the chance the policy pays a death claim (for the deferred annuity: the chance of reaching 65)
- the chance the policy loses money at its net premium
- the premium needed to be, say, 95% sure on one policy, and across a portfolio

The stamp turns green when the chance of a loss is already below the target. **File this quote** adds it to the session's quote book; **Print the letter** prints just the letter. Two charts show when the policy would lose money (by age at death) and what each underwriting class would pay.

## Risk Lab

The four premium principles side by side, the "percentile trap" explained for the current policy, the probability of loss as the premium rises from half to four times the net premium, and 1,000 simulated portfolios at the portfolio premium, compared with the normal approximation's target.

## Mortality Lab

Survival curves under five laws from any age, with each law's force of mortality, q and life expectancy; and how UDD, constant force and Balducci spread a year's deaths.

## Product Shelf

All 19 products for any age, term, deferral and interest rate, with each one's EPV and standard deviation, and the full distribution of the present value of any one product.

## Natural Hedge

Choose the insured age and benefit and the annuitant age and income; the desk gives the hedge ratio and plots the change in liabilities for mortality shocks from −30% to +30%, with and without the annuities.

## Beat the Underwriter

A random applicant arrives. Guess the annual net premium; the desk stamps it APPROVED (within 10%), REFERRED (within 40%) or DECLINED, and keeps a ledger of points. **Show me the rate card** gives the Standard rate per $1,000 at the nearest rate-book age as a hint.

## Limitations

- Net premiums only: no expenses, commission or profit.
- One assumed law of mortality, not fitted to data.
- A flat interest rate.
- Independent lives in every portfolio result.
- Assumptions are illustrative and not calibrated. Nothing on the desk is a real offer of insurance.
