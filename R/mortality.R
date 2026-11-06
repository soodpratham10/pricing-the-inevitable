# Chapter 1: The Clock
# Laws of mortality, survival probabilities, annual death probabilities from issue age,
# select mortality, extra risk and fractional-age assumptions.

#' Create a law of mortality
#'
#' Builds a mortality object used by every other function. The default is
#' Gompertz-Makeham with the project's own illustrative parameters
#' (not calibrated to real data): mu(x) = 0.0002 + 0.000008 * 1.112^x.
#'
#' @param law One of "makeham", "gompertz", "demoivre", "constant" or "weibull".
#' @param A Makeham constant (ignored for Gompertz, which sets it to 0).
#' @param B Gompertz level.
#' @param c Gompertz growth rate.
#' @param omega Limiting age for de Moivre's law.
#' @param mu Force of mortality for the constant-force law.
#' @param k Weibull scale, mu(x) = k * x^n.
#' @param n Weibull shape.
#' @return A list of class "mortality" with the law name and its parameters.
#' @examples
#' m <- mortality_law()
#' mu_x(m, 65)
#' @export
mortality_law <- function(law = "makeham", A = 0.0002, B = 0.000008, c = 1.112,
                          omega = 110, mu = 0.02, k = 2.5e-10, n = 4) {
  par <- switch(law,
    makeham  = list(A = A, B = B, c = c),
    gompertz = list(A = 0, B = B, c = c),
    demoivre = list(omega = omega),
    constant = list(mu = mu),
    weibull  = list(k = k, n = n),
    stop("unknown law: ", law))
  structure(list(law = if (law == "gompertz") "makeham" else law, name = law, par = par),
            class = "mortality")
}

#' Force of mortality
#'
#' @param m A mortality object from [mortality_law()].
#' @param x Age or vector of ages.
#' @return The force of mortality at each age.
#' @export
mu_x <- function(m, x) {
  p <- m$par
  switch(m$law,
    makeham  = p$A + p$B * p$c^x,
    demoivre = ifelse(x < p$omega, 1 / (p$omega - x), Inf),
    constant = p$mu + 0 * x,
    weibull  = p$k * x^p$n)
}

#' Survival probability under a law of mortality
#'
#' The probability that a life aged x survives t more years, exact under the law.
#'
#' @param m A mortality object from [mortality_law()].
#' @param x Age.
#' @param t Time or vector of times (years).
#' @return The survival probability for each t.
#' @export
tpx <- function(m, x, t) {
  p <- m$par
  switch(m$law,
    makeham  = exp(-p$A * t - p$B * p$c^x * (p$c^t - 1) / log(p$c)),
    demoivre = pmin(pmax((p$omega - x - t) / (p$omega - x), 0), 1),
    constant = exp(-p$mu * t),
    weibull  = exp(-p$k / (p$n + 1) * ((x + t)^(p$n + 1) - x^(p$n + 1))))
}

#' Annual death probabilities for a life aged x
#'
#' Returns q for durations 0, 1, 2, ... until the limiting age, where the last
#' probability is set to 1. Optional select mortality and extra risk are applied
#' in this order: age rating, select factors, then an addition to the force of
#' mortality or a multiple of q.
#'
#' @param m A mortality object from [mortality_law()].
#' @param x Issue age.
#' @param select NULL for ultimate mortality, or a list with `factors`, the
#'   multipliers applied to q in the first select years (for example
#'   `list(factors = c(0.7, 0.85))`).
#' @param extra NULL, or a list describing extra risk: `list(type = "age", years = 5)`,
#'   `list(type = "add_mu", delta = 0.005)` or `list(type = "mult_q", k = 1.5)`.
#' @param max_age Limiting age for laws without one.
#' @return A numeric vector of one-year death probabilities.
#' @export
q_path <- function(m, x, select = NULL, extra = NULL, max_age = 120) {
  xa <- x + if (!is.null(extra) && extra$type == "age") extra$years else 0
  K <- if (m$law == "demoivre") ceiling(m$par$omega - xa) else max_age - x
  if (K < 1) stop("no years left before the limiting age")
  k <- 0:(K - 1)
  q <- pmin(pmax(1 - tpx(m, xa + k, 1), 0), 1)
  if (!is.null(select)) {
    s <- min(length(select$factors), K)
    q[1:s] <- q[1:s] * select$factors[1:s]
  }
  if (!is.null(extra)) {
    if (extra$type == "add_mu") q <- 1 - (1 - q) * exp(-extra$delta)
    else if (extra$type == "mult_q") q <- pmin(1, extra$k * q)
    else if (extra$type != "age") stop("unknown extra risk type: ", extra$type)
  }
  q[K] <- 1
  q
}

#' Survival probabilities from annual death probabilities
#'
#' @param q Annual death probabilities from [q_path()].
#' @return kpx for k = 0, 1, ..., length(q).
#' @export
kpx_from_q <- function(q) c(1, cumprod(1 - q))

#' Probability function of the curtate future lifetime
#'
#' @param q Annual death probabilities from [q_path()].
#' @return P(K = k) for k = 0, 1, ..., length(q) - 1.
#' @export
curtate_pmf <- function(q) kpx_from_q(q)[seq_along(q)] * q

#' Curtate life expectancy
#'
#' @param q Annual death probabilities from [q_path()].
#' @return The expected number of complete future years lived.
#' @export
curtate_ex <- function(q) sum(kpx_from_q(q)[-1])

#' Fractional-age survival within one year
#'
#' @param qx One-year death probability.
#' @param s Fraction of the year, between 0 and 1.
#' @param assumption "udd" (uniform distribution of deaths), "cf" (constant force)
#'   or "balducci".
#' @return The probability of surviving the fraction s of the year.
#' @export
spx <- function(qx, s, assumption = "udd") {
  switch(assumption,
    udd = 1 - s * qx,
    cf = (1 - qx)^s,
    balducci = (1 - qx) / (1 - (1 - s) * qx),
    stop("unknown assumption: ", assumption))
}

#' Survival to a non-integer time
#'
#' @param q Annual death probabilities from [q_path()].
#' @param t Time or vector of times (years).
#' @param assumption Fractional-age assumption passed to [spx()].
#' @return The survival probability at each t.
#' @export
tpx_frac <- function(q, t, assumption = "udd") {
  kp <- kpx_from_q(q)
  sapply(t, function(tt) {
    k <- floor(tt + 1e-12); s <- tt - k
    if (k >= length(q)) 0 else kp[k + 1] * spx(q[k + 1], s, assumption)
  })
}

#' A life table built from a law of mortality
#'
#' @param m A mortality object from [mortality_law()].
#' @param x0 Starting age.
#' @param radix Number of lives at the starting age.
#' @param max_age Limiting age for laws without one.
#' @return A data frame with columns x, lx, dx, qx and ex (curtate).
#' @export
life_table <- function(m, x0 = 20, radix = 100000, max_age = 120) {
  q <- q_path(m, x0, max_age = max_age)
  lx <- radix * kpx_from_q(q)[seq_along(q)]
  ex <- sapply(seq_along(q), function(j) curtate_ex(q[j:length(q)]))
  data.frame(x = x0 + seq_along(q) - 1, lx = lx, dx = lx * q, qx = q, ex = ex)
}
