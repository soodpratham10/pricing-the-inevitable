# Chapter 4: The Quote
qh <- c(0.1, 0.2, 1)
v <- 1 / 1.1

test_that("premiums on the three-year life match the hand calculation", {
  A <- 0.1 * v + 0.18 * v^2 + 0.72 * v^3
  a <- 1 + 0.9 * v + 0.72 * v^2
  expect_equal(net_premium("whole_life", qh, 0.1, S = 1000), 1000 * A / a)
  # refund of premiums on death within 2 years: P = S A1 / (a - (IA)1)
  expect_equal(refund_premium(qh, 0.1, 1000, 2),
               1000 * (0.1 * v + 0.18 * v^2) / ((1 + 0.9 * v) - (0.1 * v + 2 * 0.18 * v^2)))
})

m <- mortality_law()
q <- q_path(m, 40)
i <- 0.045
d <- i / (1 + i)
S <- 250000
P <- net_premium("whole_life", q, i, S)

test_that("net premiums for the block", {
  expect_equal(P, 2109.463271800984, tolerance = 1e-10)
  expect_equal(net_premium("whole_life", q, i, S, t = 20), 3047.168511731767, tolerance = 1e-10)
  expect_equal(net_premium("term", q, i, S, n = 20, t = 20), 443.66442768596943, tolerance = 1e-10)
})

test_that("the loss at the net premium has mean zero and the textbook variance", {
  lm <- loss_moments("whole_life", q, i, S, P)
  expect_true(abs(lm$mean) < 1e-6)
  A <- epv("whole_life", q, i)
  A2 <- product_moments("whole_life", q, i)$second
  expect_equal(lm$var, (S + P / d)^2 * (A2 - A^2))
})

test_that("monthly premiums cost more in total than annual ones", {
  pm <- net_premium_mthly("whole_life", q, i, S, m = 12)
  expect_equal(pm$annual, 2160.9438667822847, tolerance = 1e-10)
  expect_equal(pm$instalment, pm$annual / 12)
  expect_true(pm$annual > P)
})

test_that("the probability of loss and the percentile premium", {
  expect_equal(prob_loss("whole_life", q, i, S, P), 0.3375663967961955, tolerance = 1e-10)
  pp <- percentile_premium("whole_life", q, i, S, alpha = 0.05)
  expect_equal(pp, 6589.867478932465, tolerance = 1e-10)
  expect_true(prob_loss("whole_life", q, i, S, pp) <= 0.05)
  expect_true(prob_loss("whole_life", q, i, S, pp * 0.999) > 0.05)
  # dying within 20 years is less likely than 5%, so the 95% percentile premium is zero
  expect_equal(percentile_premium("term", q, i, S, alpha = 0.05, n = 20, t = 20), 0)
})

test_that("the portfolio percentile premium", {
  pf <- portfolio_premium("whole_life", q, i, S, N = 1000, alpha = 0.05)
  expect_equal(pf, 2200.39435594495, tolerance = 1e-8)
  expect_true(pf > P && pf < percentile_premium("whole_life", q, i, S))
  sim <- simulate_portfolio("whole_life", q, i, S, pf, N = 1000, sims = 2000, seed = 2026)
  expect_true(abs(sim$prob_loss - 0.05) < 0.025)
})

test_that("refunding premiums on death raises the price, and the equivalence principle holds", {
  rf <- refund_premium(q, i, S, 20)
  expect_equal(rf, 453.38074122571777, tolerance = 1e-10)
  expect_true(rf > net_premium("term", q, i, S, n = 20, t = 20))
  # EPV of premiums = EPV of the death benefit plus the EPV of the refunds
  expect_equal(rf * annuity_due(q, i, 20), S * epv("term", q, i, n = 20) + rf * epv("increasing_term", q, i, n = 20))
  expect_error(refund_premium(q, i, S, 20, product = "whole_life"))
})
