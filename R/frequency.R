# Paying more often than once a year, and paying at the moment of death:
# exact sums under a fractional-age assumption, UDD formulas, Woolhouse and
# claims acceleration.

#' Nominal rates of interest and discount
#'
#' @param i Effective annual interest rate.
#' @param m Number of payments a year.
#' @return A list with `im` (nominal interest), `dm` (nominal discount),
#'   `alpha` and `beta` (the UDD m-thly annuity adjustment factors).
#' @export
nominal_rates <- function(i, m) {
  d <- i / (1 + i)
  im <- m * ((1 + i)^(1 / m) - 1)
  dm <- m * (1 - (1 - d)^(1 / m))
  list(im = im, dm = dm, alpha = i * d / (im * dm), beta = (i - im) / (im * dm))
}

#' Life annuity-due on the yearly grid
#'
#' @param q Annual death probabilities from [q_path()].
#' @param i Effective annual interest rate.
#' @param n Number of years of payments (NULL for whole life).
#' @return The EPV of 1 a year in advance while alive, for at most n years.
#' @export
annuity_due <- function(q, i, n = NULL) {
  N <- if (is.null(n)) length(q) else min(n, length(q))
  sum((1 + i)^(-(0:(N - 1))) * kpx_from_q(q)[1:N])
}

#' Life annuity-due paid m times a year
#'
#' Pays 1/m at the start of every 1/m of a year while alive, for at most n years.
#'
#' @param q Annual death probabilities from [q_path()].
#' @param i Effective annual interest rate.
#' @param m Payments a year.
#' @param n Number of years (NULL for whole life).
#' @param method "exact_udd" or "exact_cf" (sum every payment using that
#'   fractional-age assumption), "udd" (alpha and beta formula), "woolhouse2" or
#'   "woolhouse3" (two or three terms of Woolhouse's formula).
#' @param mu0,mun Force of mortality at the start and at the end of the term,
#'   needed only for "woolhouse3".
#' @return The EPV of the m-thly annuity-due.
#' @export
annuity_due_mthly <- function(q, i, m, n = NULL, method = "udd", mu0 = NULL, mun = NULL) {
  K <- length(q)
  N <- if (is.null(n)) K else min(n, K)
  a <- annuity_due(q, i, N)
  En <- if (N < K) nEx(q, i, N) else 0
  delta <- log(1 + i)
  switch(method,
    udd = { r <- nominal_rates(i, m); r$alpha * a - r$beta * (1 - En) },
    woolhouse2 = a - (m - 1) / (2 * m) * (1 - En),
    woolhouse3 = {
      if (is.null(mu0) || (N < K && is.null(mun))) stop("woolhouse3 needs mu0 (and mun for a term annuity)")
      t3 <- (delta + mu0) - if (N < K) En * (delta + mun) else 0
      a - (m - 1) / (2 * m) * (1 - En) - (m^2 - 1) / (12 * m^2) * t3
    },
    exact_udd = , exact_cf = {
      ass <- if (method == "exact_udd") "udd" else "cf"
      j <- 0:(N * m - 1)
      sum((1 + i)^(-j / m) * tpx_frac(q, j / m, ass)) / m
    },
    stop("unknown method: ", method))
}

#' Term or whole life insurance paid at the end of the 1/m-th of a year of death
#'
#' @param q Annual death probabilities from [q_path()].
#' @param i Effective annual interest rate.
#' @param m Periods a year.
#' @param n Term in years (NULL for whole life).
#' @param method "udd" (i / i(m) times the annual value) or "exact_udd" (sum over
#'   every period under UDD).
#' @return The EPV of a benefit of 1.
#' @export
insurance_mthly <- function(q, i, m, n = NULL, method = "udd") {
  K <- length(q)
  N <- if (is.null(n)) K else min(n, K)
  A1 <- sum((1 + i)^(-(1:N)) * curtate_pmf(q)[1:N])
  switch(method,
    udd = i / nominal_rates(i, m)$im * A1,
    exact_udd = {
      j <- 0:(N * m - 1)
      sum((1 + i)^(-(j + 1) / m) * (tpx_frac(q, j / m, "udd") - tpx_frac(q, (j + 1) / m, "udd")))
    },
    stop("unknown method: ", method))
}

#' Insurance paid at the moment of death
#'
#' @param q Annual death probabilities from [q_path()].
#' @param i Effective annual interest rate.
#' @param n Term in years (NULL for whole life).
#' @param method "udd" (i / delta times the annual value) or "claims" (claims
#'   acceleration, (1 + i)^(1/2) times the annual value).
#' @return The EPV of a benefit of 1 paid at the moment of death.
#' @export
insurance_continuous <- function(q, i, n = NULL, method = "udd") {
  K <- length(q)
  N <- if (is.null(n)) K else min(n, K)
  A1 <- sum((1 + i)^(-(1:N)) * curtate_pmf(q)[1:N])
  switch(method,
    udd = i / log(1 + i) * A1,
    claims = sqrt(1 + i) * A1,
    stop("unknown method: ", method))
}

#' Insurance paid at the moment of death, exact under a law of mortality
#'
#' Integrates v^t tpx mu(x + t) with Simpson's rule.
#'
#' @param m A mortality object from [mortality_law()].
#' @param x Age.
#' @param i Effective annual interest rate.
#' @param n Term in years (NULL for whole life to max_age).
#' @param max_age Upper limit of integration for whole life.
#' @param steps Integration steps per year (even total).
#' @return The EPV of a benefit of 1 paid at the moment of death.
#' @export
insurance_continuous_exact <- function(m, x, i, n = NULL, max_age = 120, steps = 200) {
  Tn <- if (is.null(n)) max_age - x else n
  N <- Tn * steps
  t <- seq(0, Tn, length.out = N + 1)
  f <- exp(-log(1 + i) * t) * tpx(m, x, t) * mu_x(m, x + t)
  w <- rep(c(2, 4), length.out = N + 1); w[1] <- 1; w[N + 1] <- 1
  # Simpson weights 1, 4, 2, 4, ..., 2, 4, 1
  w[seq(2, N, by = 2)] <- 4
  w[seq(3, N - 1, by = 2)] <- 2
  (Tn / N) / 3 * sum(w * f)
}
