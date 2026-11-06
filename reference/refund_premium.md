# Premium for a policy that refunds the premiums on death

On death within n years the policy pays S plus every premium paid so
far, without interest. Equivalence: P a = S A + P (IA), so P = S A /
(a - (IA)).

## Usage

``` r
refund_premium(q, i, S, n, product = "term")
```

## Arguments

- q:

  Annual death probabilities from
  [`q_path()`](https://soodpratham10.github.io/pricing-the-inevitable/reference/q_path.md).

- i:

  Effective annual interest rate.

- S:

  Benefit amount.

- n:

  Term and premium term in years.

- product:

  "term" or "endowment".

## Value

The level annual premium.
