# Chapters 2 and 3: Paying at Death and Paying for Life
qh <- c(0.1, 0.2, 1)   # a life that dies within three years, valued at 10%
v <- 1 / 1.1

test_that("insurance on the three-year life matches the hand calculation", {
  # A = 0.1 v + 0.18 v^2 + 0.72 v^3
  expect_equal(epv("whole_life", qh, 0.1), 0.1 * v + 0.18 * v^2 + 0.72 * v^3)
  expect_equal(epv("term", qh, 0.1, n = 2), 0.1 * v + 0.18 * v^2)
  expect_equal(epv("pure_endowment", qh, 0.1, n = 2), 0.72 * v^2)
  expect_equal(epv("endowment", qh, 0.1, n = 2), 0.1 * v + 0.18 * v^2 + 0.72 * v^2)
  expect_equal(product_moments("whole_life", qh, 0.1)$second, 0.1 * v^2 + 0.18 * v^4 + 0.72 * v^6)
})

test_that("annuities on the three-year life match the hand calculation", {
  expect_equal(epv("whole_due", qh, 0.1), 1 + 0.9 * v + 0.72 * v^2)
  expect_equal(epv("whole_imm", qh, 0.1), 0.9 * v + 0.72 * v^2)
  expect_equal(annuity_certain(3, 0.1), 1 + v + v^2)
})

m <- mortality_law()
q <- q_path(m, 40)
i <- 0.045
d <- i / (1 + i)

test_that("the block's key values match the independent calculation", {
  expect_equal(epv("whole_life", q, i), 0.16384163558297818, tolerance = 1e-10)
  expect_equal(epv("whole_due", q, i), 19.417455351461992, tolerance = 1e-10)
  expect_equal(product_moments("whole_life", q, i)$var, 0.012709807669939416, tolerance = 1e-10)
  expect_equal(epv("endowment", q, i, n = 20), 0.42115266932039086, tolerance = 1e-10)
})

test_that("insurance identities hold", {
  expect_equal(epv("whole_life", q, i), 1 - d * epv("whole_due", q, i))
  expect_equal(epv("endowment", q, i, n = 20), epv("term", q, i, n = 20) + epv("pure_endowment", q, i, n = 20))
  expect_equal(epv("deferred_whole", q, i, h = 10), epv("whole_life", q, i) - epv("term", q, i, n = 10))
  expect_equal(epv("deferred_term", q, i, n = 20, h = 10), epv("term", q, i, n = 30) - epv("term", q, i, n = 10))
  # increasing plus decreasing term pays n + 1 in every year
  expect_equal(epv("increasing_term", q, i, n = 20) + epv("decreasing_term", q, i, n = 20), 21 * epv("term", q, i, n = 20))
})

test_that("annuity identities hold", {
  expect_equal(epv("whole_imm", q, i), epv("whole_due", q, i) - 1)
  expect_equal(epv("term_due", q, i, n = 20), (1 - epv("endowment", q, i, n = 20)) / d)
  expect_equal(epv("deferred_whole_due", q, i, h = 25), nEx(q, i, 25) * epv("whole_due", q_path(m, 65), i))
  expect_equal(epv("guaranteed_due", q, i, n = 10),
               annuity_certain(10, i) + nEx(q, i, 10) * epv("whole_due", q_path(m, 50), i))
  expect_equal(epv("term_imm", q, i, n = 20), epv("term_due", q, i, n = 20) - 1 + nEx(q, i, 20))
  # (I a-due) = sum of (k + 1) v^k kpx
  expect_equal(epv("increasing_due", q, i), sum((1:80) * (1 + i)^(-(0:79)) * kpx_from_q(q)[1:80]))
})

test_that("annuity variances follow from the insurance variances", {
  vZ <- product_moments("whole_life", q, i)$var
  expect_equal(product_moments("whole_due", q, i)$var, vZ / d^2)
  expect_equal(product_moments("whole_imm", q, i)$var, vZ / d^2)
  expect_equal(product_moments("term_due", q, i, n = 20)$var, product_moments("endowment", q, i, n = 20)$var / d^2)
})

test_that("the shelf has all nineteen products", {
  expect_equal(nrow(products()), 19)
  expect_equal(nrow(value_all(q, i)), 19)
  expect_true(all(value_all(q, i)$var >= 0))
  expect_error(pv_by_k("lottery_ticket", 10, i))
})
