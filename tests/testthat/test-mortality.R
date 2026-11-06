# Chapter 1: The Clock
m <- mortality_law()
q <- q_path(m, 40)

test_that("the force of mortality follows each law", {
  expect_equal(mu_x(m, 65), 0.0002 + 0.000008 * 1.112^65)
  expect_equal(mu_x(mortality_law("gompertz"), 50), 0.000008 * 1.112^50)
  expect_equal(mu_x(mortality_law("demoivre", omega = 100), 60), 1 / 40)
})

test_that("survival probabilities match the closed forms", {
  expect_equal(tpx(m, 65, 0), 1)
  expect_equal(tpx(mortality_law("constant", mu = 0.02), 50, 10), exp(-0.2))
  expect_equal(tpx(mortality_law("demoivre", omega = 100), 60, 10), 0.75)
  # Weibull: exp(-k / (n + 1) * (60^5 - 50^5)) with k = 2.5e-10, n = 4
  expect_equal(tpx(mortality_law("weibull"), 50, 10), 0.9770133136104608, tolerance = 1e-12)
  expect_error(mortality_law("vampire"))
})

test_that("a three-year example works by hand", {
  qh <- c(0.1, 0.2, 1)
  expect_equal(kpx_from_q(qh), c(1, 0.9, 0.72, 0))
  expect_equal(curtate_pmf(qh), c(0.1, 0.18, 0.72))
  expect_equal(curtate_ex(qh), 1.62)
})

test_that("the block's death probabilities and life expectancies", {
  expect_equal(length(q), 80)
  expect_equal(q[80], 1)
  expect_equal(q[1], 0.0007892616434139743, tolerance = 1e-10)
  expect_equal(sum(curtate_pmf(q)), 1)
  expect_equal(curtate_ex(q), 43.56033140739581, tolerance = 1e-10)
  expect_equal(curtate_ex(q_path(m, 65)), 20.654568187969303, tolerance = 1e-10)
})

test_that("select mortality and the three kinds of extra risk", {
  qs <- q_path(m, 40, select = list(factors = c(0.7, 0.85)))
  expect_equal(qs[1:3], q[1:3] * c(0.7, 0.85, 1))
  expect_equal(q_path(m, 40, extra = list(type = "age", years = 5))[1], q_path(m, 45)[1])
  expect_equal(1 - q_path(m, 40, extra = list(type = "add_mu", delta = 0.005))[1], (1 - q[1]) * exp(-0.005))
  expect_equal(q_path(m, 40, extra = list(type = "mult_q", k = 1.5))[1], 1.5 * q[1])
  expect_error(q_path(m, 40, extra = list(type = "lucky")))
})

test_that("fractional-age assumptions", {
  expect_equal(spx(0.1, 0.25, "udd"), 0.975)
  expect_equal(spx(0.1, 0.25, "cf"), 0.9^0.25)
  expect_equal(spx(0.1, 0.25, "balducci"), 0.9 / 0.925)
  expect_equal(tpx_frac(q, 2.5), kpx_from_q(q)[3] * (1 - 0.5 * q[3]))
  expect_equal(tpx_frac(q, 3), kpx_from_q(q)[4])
})

test_that("the life table is built from the law", {
  lt <- life_table(m)
  expect_equal(nrow(lt), 100)
  expect_equal(lt$lx[1], 100000)
  expect_equal(lt$ex[lt$x == 65], curtate_ex(q_path(m, 65)))
})
