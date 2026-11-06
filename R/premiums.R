# Chapter 4: The Quote
# Net premiums by the equivalence principle, the loss random variable and its
# distribution, percentile and portfolio percentile premiums, a Monte Carlo check,
# and premiums for policies that refund the premiums on death.

#' Net annual premium by the equivalence principle
#'
#' Premiums are paid annually in advance for t years (or for life), while alive.
#'
#' @param product A product id from [products()].
#' @param q Annual death probabilities from [q_path()].
#' @param i Effective annual interest rate.
#' @param S Benefit amount.
#' @param n Term in years, for products that use it.
#' @param h Deferral period in years, for products that use it.
#' @param t Premium paying term in years (NULL for life).
#' @return The level annual net premium.
#' @examples
#' q <- q_path(mortality_law(), 40)
#' net_premium("whole_life", q, 0.045, S = 250000)
#' @export
net_premium <- function(product, q, i, S = 1, n = 10, h = 5, t = NULL) {
  S * epv(product, q, i, n, h) / annuity_due(q, i, t)
}

#' Net premium paid m times a year
#'
#' @inheritParams net_premium
#' @param m Premium instalments a year.
#' @param method Method for the m-thly premium annuity, passed to [annuity_due_mthly()].
#' @param mu0,mun Force of mortality at the start and end of the premium term,
#'   needed only for "woolhouse3".
#' @return A list with the total `annual` premium and each `instalment`.
#' @export
net_premium_mthly <- function(product, q, i, S = 1, n = 10, h = 5, t = NULL, m = 12,
                              method = "udd", mu0 = NULL, mun = NULL) {
  ann <- S * epv(product, q, i, n, h) / annuity_due_mthly(q, i, m, t, method, mu0, mun)
  list(annual = ann, instalment = ann / m)
}

#' Loss at issue for every curtate lifetime
#'
#' L = S Z - P Y, where Z is the present value of the benefit and Y the present
#' value of the premiums actually paid.
#'
#' @inheritParams net_premium
#' @param P Annual premium.
#' @return A data frame with the curtate lifetime k, its probability, the benefit
#'   present value Z, the premium annuity Y and the loss.
#' @export
loss_distribution <- function(product, q, i, S, P, n = 10, h = 5, t = NULL) {
  K <- length(q)
  k <- 0:(K - 1)
  tt <- if (is.null(t)) K else t
  Z <- pv_by_k(product, K, i, n, h)
  Y <- annuity_certain(pmin(k + 1, tt), i, due = TRUE)
  data.frame(k = k, prob = curtate_pmf(q), Z = Z, Y = Y, loss = S * Z - P * Y)
}

#' Probability the policy makes a loss
#'
#' @inheritParams loss_distribution
#' @return P(L > 0).
#' @export
prob_loss <- function(product, q, i, S, P, n = 10, h = 5, t = NULL) {
  ld <- loss_distribution(product, q, i, S, P, n, h, t)
  sum(ld$prob[ld$loss > 1e-9])
}

#' Mean and variance of the loss at issue
#'
#' @inheritParams loss_distribution
#' @return A list with `mean` and `var` of L.
#' @export
loss_moments <- function(product, q, i, S, P, n = 10, h = 5, t = NULL) {
  ld <- loss_distribution(product, q, i, S, P, n, h, t)
  e <- sum(ld$loss * ld$prob)
  list(mean = e, var = sum(ld$loss^2 * ld$prob) - e^2)
}

#' Percentile premium
#'
#' The smallest premium for which the probability of a loss is at most alpha.
#'
#' @inheritParams net_premium
#' @param alpha Largest acceptable probability of loss.
#' @return The percentile premium.
#' @export
percentile_premium <- function(product, q, i, S, alpha = 0.05, n = 10, h = 5, t = NULL) {
  ld <- loss_distribution(product, q, i, S, 0, n, h, t)
  thr <- S * ld$Z / ld$Y               # the premium at which each lifetime breaks even
  o <- order(-thr)
  cum <- cumsum(ld$prob[o])
  thr[o][which(cum > alpha + 1e-12)[1]]
}

#' Portfolio percentile premium
#'
#' The premium for which a portfolio of N independent policies makes a loss with
#' probability alpha, using the normal approximation:
#' N E(L) + z(1 - alpha) sqrt(N Var(L)) = 0.
#'
#' @inheritParams net_premium
#' @param N Number of policies.
#' @param alpha Probability of a portfolio loss.
#' @return The portfolio percentile premium.
#' @export
portfolio_premium <- function(product, q, i, S, N, alpha = 0.05, n = 10, h = 5, t = NULL) {
  z <- stats::qnorm(1 - alpha)
  f <- function(P) {
    lm <- loss_moments(product, q, i, S, P, n, h, t)
    N * lm$mean + z * sqrt(N * lm$var)
  }
  P0 <- net_premium(product, q, i, S, n, h, t)
  stats::uniroot(f, c(0.5 * P0, 20 * P0), tol = 1e-12)$root
}

#' Simulate portfolios to check the probability of a portfolio loss
#'
#' @inheritParams loss_distribution
#' @param N Policies in each portfolio.
#' @param sims Number of simulated portfolios.
#' @param seed Random seed.
#' @return A list with the simulated `prob_loss` and the vector of portfolio `totals`.
#' @export
simulate_portfolio <- function(product, q, i, S, P, N, sims = 2000, seed = 2026,
                               n = 10, h = 5, t = NULL) {
  ld <- loss_distribution(product, q, i, S, P, n, h, t)
  set.seed(seed)
  totals <- replicate(sims, sum(sample(ld$loss, N, replace = TRUE, prob = ld$prob)))
  list(prob_loss = mean(totals > 0), totals = totals)
}

#' Premium for a policy that refunds the premiums on death
#'
#' On death within n years the policy pays S plus every premium paid so far,
#' without interest. Equivalence: P a = S A + P (IA), so P = S A / (a - (IA)).
#'
#' @param q Annual death probabilities from [q_path()].
#' @param i Effective annual interest rate.
#' @param S Benefit amount.
#' @param n Term and premium term in years.
#' @param product "term" or "endowment".
#' @return The level annual premium.
#' @export
refund_premium <- function(q, i, S, n, product = "term") {
  if (!product %in% c("term", "endowment")) stop("product must be term or endowment")
  IA <- epv("increasing_term", q, i, n)
  S * epv(product, q, i, n) / (annuity_due(q, i, n) - IA)
}
