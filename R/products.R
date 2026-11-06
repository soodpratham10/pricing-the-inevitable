# Chapters 2 and 3: Paying at Death and Paying for Life
# Nineteen products, the present value of each one for every possible curtate
# lifetime K, and from that the expected value, variance and full distribution.

#' The product shelf
#'
#' The 19 insurance and annuity products the engine can value. Insurance benefits
#' are paid at the end of the year of death; annuities pay 1 a year.
#'
#' @return A data frame with the product id, its label, its type and which of the
#'   term n and deferral h it uses.
#' @export
products <- function() {
  data.frame(
    id = c("whole_life", "term", "pure_endowment", "endowment", "deferred_whole",
           "deferred_term", "increasing_term", "decreasing_term",
           "whole_due", "whole_imm", "term_due", "term_imm",
           "deferred_whole_due", "deferred_whole_imm", "deferred_term_due", "deferred_term_imm",
           "guaranteed_due", "guaranteed_imm", "increasing_due"),
    label = c("Whole life insurance", "n-year term insurance", "n-year pure endowment",
              "n-year endowment insurance", "h-year deferred whole life insurance",
              "h-year deferred n-year term insurance", "Increasing n-year term insurance",
              "Decreasing n-year term insurance",
              "Whole life annuity-due", "Whole life annuity-immediate",
              "n-year term annuity-due", "n-year term annuity-immediate",
              "h-year deferred whole life annuity-due", "h-year deferred whole life annuity-immediate",
              "h-year deferred n-year annuity-due", "h-year deferred n-year annuity-immediate",
              "n-year guaranteed whole life annuity-due", "n-year guaranteed whole life annuity-immediate",
              "Increasing whole life annuity-due"),
    type = rep(c("insurance", "annuity"), c(8, 11)),
    uses_n = c(FALSE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE,
               FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, FALSE),
    uses_h = c(FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE,
               FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE),
    stringsAsFactors = FALSE)
}

#' Annuity-certain values
#'
#' @param n Number of payments (vector allowed).
#' @param i Effective annual interest rate.
#' @param due TRUE for payments at the start of each year, FALSE for the end.
#' @return The present value of n payments of 1.
#' @export
annuity_certain <- function(n, i, due = TRUE) {
  v <- 1 / (1 + i)
  if (due) (1 - v^n) / (1 - v) else (1 - v^n) / i
}

#' Present value of a product for each curtate lifetime
#'
#' @param product A product id from [products()].
#' @param K Number of possible curtate lifetimes (K = 0, ..., K - 1).
#' @param i Effective annual interest rate.
#' @param n Term in years, for products that use it.
#' @param h Deferral period in years, for products that use it.
#' @return The present value of the benefit if the curtate lifetime is k.
#' @export
pv_by_k <- function(product, K, i, n = 10, h = 5) {
  k <- 0:(K - 1)
  v <- 1 / (1 + i)
  ad <- function(m) annuity_certain(m, i, due = TRUE)
  ai <- function(m) annuity_certain(m, i, due = FALSE)
  switch(product,
    whole_life         = v^(k + 1),
    term               = ifelse(k < n, v^(k + 1), 0),
    pure_endowment     = ifelse(k >= n, v^n, 0),
    endowment          = v^pmin(k + 1, n),
    deferred_whole     = ifelse(k >= h, v^(k + 1), 0),
    deferred_term      = ifelse(k >= h & k < h + n, v^(k + 1), 0),
    increasing_term    = ifelse(k < n, (k + 1) * v^(k + 1), 0),
    decreasing_term    = ifelse(k < n, (n - k) * v^(k + 1), 0),
    whole_due          = ad(k + 1),
    whole_imm          = ai(k),
    term_due           = ad(pmin(k + 1, n)),
    term_imm           = ai(pmin(k, n)),
    deferred_whole_due = v^h * ad(pmax(k + 1 - h, 0)),
    deferred_whole_imm = v^h * ai(pmax(k - h, 0)),
    deferred_term_due  = v^h * ad(pmin(pmax(k + 1 - h, 0), n)),
    deferred_term_imm  = v^h * ai(pmin(pmax(k - h, 0), n)),
    guaranteed_due     = ad(pmax(k + 1, n)),
    guaranteed_imm     = ai(pmax(k, n)),
    increasing_due     = cumsum((k + 1) * v^k),
    stop("unknown product: ", product))
}

#' Expected value, variance and distribution of a product's present value
#'
#' @param product A product id from [products()].
#' @param q Annual death probabilities from [q_path()].
#' @param i Effective annual interest rate.
#' @param n Term in years, for products that use it.
#' @param h Deferral period in years, for products that use it.
#' @return A list with `epv`, `second` (second moment), `var`, `sd` and `dist`, a
#'   data frame of the present value for each curtate lifetime and its probability.
#' @examples
#' q <- q_path(mortality_law(), 40)
#' product_moments("whole_life", q, 0.045)$epv
#' @export
product_moments <- function(product, q, i, n = 10, h = 5) {
  pmf <- curtate_pmf(q)
  pv <- pv_by_k(product, length(q), i, n, h)
  e <- sum(pv * pmf)
  e2 <- sum(pv^2 * pmf)
  list(epv = e, second = e2, var = e2 - e^2, sd = sqrt(max(e2 - e^2, 0)),
       dist = data.frame(k = seq_along(q) - 1, pv = pv, prob = pmf))
}

#' Expected present value of a product
#'
#' @inheritParams product_moments
#' @return The expected present value per unit of benefit.
#' @export
epv <- function(product, q, i, n = 10, h = 5) product_moments(product, q, i, n, h)$epv

#' Pure endowment factor nEx
#'
#' @param q Annual death probabilities from [q_path()].
#' @param i Effective annual interest rate.
#' @param n Number of years.
#' @return v^n times the probability of surviving n years.
#' @export
nEx <- function(q, i, n) {
  kp <- kpx_from_q(q)
  (1 + i)^(-n) * if (n < length(kp)) kp[n + 1] else 0
}

#' Every product valued at once
#'
#' @param q Annual death probabilities from [q_path()].
#' @param i Effective annual interest rate.
#' @param n Term in years.
#' @param h Deferral period in years.
#' @return The product table from [products()] with the EPV, variance and standard
#'   deviation of each product.
#' @export
value_all <- function(q, i, n = 10, h = 5) {
  tab <- products()
  mom <- lapply(tab$id, product_moments, q = q, i = i, n = n, h = h)
  tab$epv <- sapply(mom, `[[`, "epv")
  tab$var <- sapply(mom, `[[`, "var")
  tab$sd <- sapply(mom, `[[`, "sd")
  tab
}
