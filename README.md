# Pricing the Inevitable

*Everyone dies. The premium is about when.*

[![R-CMD-check](https://github.com/soodpratham10/pricing-the-inevitable/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/soodpratham10/pricing-the-inevitable/actions/workflows/R-CMD-check.yaml) ![R package](https://img.shields.io/badge/R-package-276DC3?logo=r&logoColor=white) ![License](https://img.shields.io/badge/license-MIT-lightgrey)

A life contingencies pricing engine, built from first principles as an R package called **`inevitable`**. Every push to GitHub runs the full test suite automatically: the badge above is live.

> 🚧 **Under construction.** Stage 1 (the engine and its tests) is in. Still to come: the SQL rate book, the Excel rate calculator, the Quarto pricing memo, the Python cross-check, and **The Quote Desk**, a Shiny pricing calculator.

## What the engine does

| Chapter | What it covers | Code |
|---|---|---|
| 1. The Clock | Makeham, Gompertz, de Moivre, constant-force and Weibull laws; select mortality; age rating, added force and multiplied q; UDD, constant-force and Balducci fractional ages | `R/mortality.R` |
| 2. Paying at Death | Whole life, term, pure endowment, endowment, deferred, increasing and decreasing insurance: expected value, variance and full distribution | `R/products.R` |
| 3. Paying for Life | Eleven life annuities, paid annually or m times a year, by exact sums, UDD and Woolhouse; insurance paid at the moment of death | `R/products.R`, `R/frequency.R` |
| 4. The Quote | Equivalence, percentile and portfolio percentile premiums, the loss distribution, a Monte Carlo check, and premium refunds | `R/premiums.R` |
| The natural hedge | The mix of life insurance and annuities that cancels a mortality shock | `R/hedge.R` |

## Try it

```r
# install.packages("devtools")
devtools::install_github("soodpratham10/pricing-the-inevitable")
library(inevitable)

m <- mortality_law()                    # our own illustrative Gompertz-Makeham law
q <- q_path(m, 40)                      # a 40-year-old's death probabilities
net_premium("whole_life", q, i = 0.045, S = 250000)
percentile_premium("whole_life", q, i = 0.045, S = 250000, alpha = 0.05)
natural_hedge(m)$ratio                  # annuities per insurance policy that hedge a mortality shock
```

*All assumptions are illustrative and not calibrated to real data.*
