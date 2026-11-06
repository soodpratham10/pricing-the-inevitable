# The rate book: the plans an agent can sell, the four underwriting classes, and
# the premium per 1,000 of benefit for every plan, age, class and frequency.

#' The underwriting classes
#'
#' Every newly underwritten life gets select mortality (q multiplied by 0.7 in the
#' first year and 0.85 in the second). The class then adjusts mortality:
#' Preferred multiplies q by 0.75, Smoker multiplies q by 1.8, and Rated adds a
#' flat 0.005 to the force of mortality.
#'
#' @return A data frame with each class, its extra-risk method and its value.
#' @export
risk_classes <- function() {
  data.frame(class = c("Preferred", "Standard", "Smoker", "Rated"),
             method = c("mult_q", "none", "mult_q", "add_mu"),
             value = c(0.75, NA, 1.8, 0.005),
             stringsAsFactors = FALSE)
}

#' Death probabilities for an underwriting class
#'
#' @param m A mortality object from [mortality_law()].
#' @param x Issue age.
#' @param class One of the classes in [risk_classes()].
#' @param select TRUE to apply select mortality for a newly underwritten life.
#' @return Annual death probabilities from [q_path()].
#' @export
class_q_path <- function(m, x, class = "Standard", select = TRUE) {
  extra <- switch(class,
    Preferred = list(type = "mult_q", k = 0.75),
    Standard = NULL,
    Smoker = list(type = "mult_q", k = 1.8),
    Rated = list(type = "add_mu", delta = 0.005),
    stop("unknown class: ", class))
  q_path(m, x, select = if (select) list(factors = c(0.7, 0.85)) else NULL, extra = extra)
}

#' The plans in the rate book
#'
#' @return A data frame with the plan code, its label, the product it uses, and
#'   its term and premium paying rules.
#' @export
plans <- function() {
  data.frame(plan = c("WL", "WL20", "T10", "T20", "E20", "DA65"),
             label = c("Whole life, premiums for life", "Whole life, 20 years of premiums",
                       "10-year term", "20-year term", "20-year endowment",
                       "Deferred annuity from 65, premiums until 65"),
             product = c("whole_life", "whole_life", "term", "term", "endowment", "deferred_whole_due"),
             stringsAsFactors = FALSE)
}

#' Premium for one plan
#'
#' @param m A mortality object from [mortality_law()].
#' @param x Issue age.
#' @param plan A plan code from [plans()].
#' @param class An underwriting class from [risk_classes()].
#' @param frequency "Annual" or "Monthly" (monthly premiums use the UDD m-thly annuity).
#' @param i Effective annual interest rate.
#' @param S Benefit: the sum assured, or the yearly income for the deferred annuity.
#' @return The total premium for a year (for Monthly, 12 times each instalment).
#' @examples
#' plan_premium(mortality_law(), 40, "T20", "Smoker", S = 250000)
#' @export
plan_premium <- function(m, x, plan, class = "Standard", frequency = "Annual", i = 0.045, S = 1000) {
  q <- class_q_path(m, x, class)
  spec <- switch(plan,
    WL   = list(product = "whole_life", n = 10, h = 5, t = NULL),
    WL20 = list(product = "whole_life", n = 10, h = 5, t = 20),
    T10  = list(product = "term", n = 10, h = 5, t = 10),
    T20  = list(product = "term", n = 20, h = 5, t = 20),
    E20  = list(product = "endowment", n = 20, h = 5, t = 20),
    DA65 = {
      if (x >= 65) stop("the deferred annuity needs an issue age below 65")
      list(product = "deferred_whole_due", n = 10, h = 65 - x, t = 65 - x)
    },
    stop("unknown plan: ", plan))
  benefit <- S * epv(spec$product, q, i, spec$n, spec$h)
  ann <- switch(frequency,
    Annual = annuity_due(q, i, spec$t),
    Monthly = annuity_due_mthly(q, i, 12, spec$t, method = "udd"),
    stop("unknown frequency: ", frequency))
  benefit / ann
}

#' The rate book
#'
#' Premium per 1,000 of benefit for every plan, issue age, class and frequency.
#'
#' @param m A mortality object from [mortality_law()].
#' @param ages Issue ages in the book.
#' @param i Effective annual interest rate.
#' @return A data frame with plan, issue_age, class, frequency, annual premium per
#'   1,000 and the instalment per 1,000 (the annual premium, or a twelfth of it).
#' @export
rate_book <- function(m, ages = seq(25, 65, by = 5), i = 0.045) {
  grid <- expand.grid(frequency = c("Annual", "Monthly"), class = risk_classes()$class,
                      issue_age = ages, plan = plans()$plan, stringsAsFactors = FALSE)
  grid <- grid[!(grid$plan == "DA65" & grid$issue_age >= 65), c("plan", "issue_age", "class", "frequency")]
  grid$premium_per_1000 <- mapply(function(p, x, cl, f) plan_premium(m, x, p, cl, f, i, 1000),
                                  grid$plan, grid$issue_age, grid$class, grid$frequency, USE.NAMES = FALSE)
  grid$instalment_per_1000 <- ifelse(grid$frequency == "Monthly", grid$premium_per_1000 / 12, grid$premium_per_1000)
  rownames(grid) <- NULL
  grid
}
