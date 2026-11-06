# The natural hedge: life insurance loses money when people die sooner, annuities
# lose money when people live longer. Find the mix that cancels a mortality shock.

#' Shock annual death probabilities
#'
#' Multiplies every q by (1 + s), capped at 1, keeping the last year at 1.
#'
#' @param q Annual death probabilities from [q_path()].
#' @param s Relative shock (0.1 means 10% heavier mortality).
#' @return The shocked death probabilities.
#' @export
shock_q <- function(q, s) {
  out <- pmin(1, q * (1 + s))
  out[length(out)] <- 1
  out
}

#' The natural hedge between life insurance and annuities
#'
#' Measures how much the value of one whole life insurance policy and one whole
#' life annuity-due change when mortality is shocked, and finds the number of
#' annuities per insurance policy that makes the total insensitive to the shock.
#'
#' @param m A mortality object from [mortality_law()].
#' @param x_ins Age of the insured lives.
#' @param x_ann Age of the annuitants.
#' @param S Insurance benefit.
#' @param B Annual annuity payment.
#' @param i Effective annual interest rate.
#' @param shock Size of the shock used for the central difference.
#' @return A list with the sensitivities `dA` and `da` (change per unit of relative
#'   shock), the per-policy changes `ins_change` and `ann_change` for the given
#'   shock, and `ratio`, the annuities per insurance policy that hedge the block.
#' @examples
#' natural_hedge(mortality_law())$ratio
#' @export
natural_hedge <- function(m, x_ins = 40, x_ann = 65, S = 250000, B = 20000, i = 0.045, shock = 0.10) {
  qi <- q_path(m, x_ins); qa <- q_path(m, x_ann)
  A_up <- epv("whole_life", shock_q(qi, shock), i); A_dn <- epv("whole_life", shock_q(qi, -shock), i)
  a_up <- epv("whole_due", shock_q(qa, shock), i);  a_dn <- epv("whole_due", shock_q(qa, -shock), i)
  dA <- (A_up - A_dn) / (2 * shock)
  da <- (a_up - a_dn) / (2 * shock)
  list(dA = dA, da = da,
       ins_change = S * (A_up - epv("whole_life", qi, i)),
       ann_change = B * (a_up - epv("whole_due", qa, i)),
       ratio = -(S * dA) / (B * da))
}

#' Change in the value of a hedged block after a mortality shock
#'
#' @param m A mortality object from [mortality_law()].
#' @param n_ins Number of insurance policies.
#' @param n_ann Number of annuities.
#' @param s Relative mortality shock.
#' @inheritParams natural_hedge
#' @return The change in the total value of the promises (positive means the
#'   insurer owes more).
#' @export
block_change <- function(m, n_ins, n_ann, s, x_ins = 40, x_ann = 65, S = 250000, B = 20000, i = 0.045) {
  qi <- q_path(m, x_ins); qa <- q_path(m, x_ann)
  n_ins * S * (epv("whole_life", shock_q(qi, s), i) - epv("whole_life", qi, i)) +
    n_ann * B * (epv("whole_due", shock_q(qa, s), i) - epv("whole_due", qa, i))
}
