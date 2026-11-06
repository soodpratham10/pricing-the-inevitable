[← Overview](../../README.md) · [Next: Paying at Death →](02-paying-at-death.md)

# Chapter 1: The Clock

*How long will they live?*

**Code:** [`R/mortality.R`](../../R/mortality.R) · **Tests:** [`tests/testthat/test-mortality.R`](../../tests/testthat/test-mortality.R) (30)

## The law

Mortality follows Gompertz-Makeham with the project's own illustrative parameters:

$$\mu_x = A + B c^x, \qquad A = 0.0002, \quad B = 0.000008, \quad c = 1.112$$

$${}_tp_x = \exp\left( -A t - \frac{B c^x (c^t - 1)}{\ln c} \right)$$

A 40-year-old has q = 0.000789 and can expect 43.56 more complete years; a 65-year-old, 20.65. Everything else in the engine works from the annual death probabilities $q_{x+k}$ that `q_path()` builds from the issue age to age 120, where q is set to 1.

The package also has four other laws for comparison (`mortality_law()`):

| Law | Force of mortality |
|---|---|
| Gompertz | $B c^x$ |
| de Moivre | $1 / (\omega - x)$, with $\omega = 110$ |
| Constant force | $\mu$, by default 0.02 |
| Weibull | $k x^n$, with $k = 2.5 \times 10^{-10}$ and $n = 4$ |

## Select mortality and extra risk

Someone who has just passed underwriting is healthier than average for a few years. The rate book multiplies q by 0.7 in the first policy year and 0.85 in the second. Extra risk is then added in one of the three textbook ways:

| Method | What it does | Used for |
|---|---|---|
| Age rating | treat the life as $r$ years older | available in `q_path()` |
| Constant addition to the force | $p' = p \, e^{-\delta}$ | the Rated class, $\delta = 0.005$ |
| Multiple of q | $q' = \min(1, k q)$ | Preferred ($k = 0.75$) and Smoker ($k = 1.8$) |

## Fractional ages

Between integer ages the engine needs an assumption about how the year's deaths are spread:

| Assumption | ${}_sp_x$ for $0 \le s \le 1$ |
|---|---|
| Uniform distribution of deaths (UDD) | $1 - s q_x$ |
| Constant force | $(1 - q_x)^s$ |
| Balducci | $(1 - q_x) / (1 - (1 - s) q_x)$ |

Chapter 3 uses them for monthly annuities.

## Checks

- A three-year life with q = (0.1, 0.2, 1): kpx = (1, 0.9, 0.72, 0), P(K = k) = (0.1, 0.18, 0.72), curtate expectation 1.62.
- Closed forms for every law; select factors and each extra-risk method applied exactly as stated; fractional assumptions at s = 0.25.
- The life table's expectation at 65 equals the expectation computed directly from age 65.

## Key functions

`mortality_law()`, `mu_x()`, `tpx()`, `q_path()`, `kpx_from_q()`, `curtate_pmf()`, `curtate_ex()`, `spx()`, `tpx_frac()`, `life_table()`
