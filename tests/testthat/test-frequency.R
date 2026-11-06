# Paying more often than once a year, and paying at the moment of death
m <- mortality_law()
q <- q_path(m, 40)
i <- 0.045

test_that("nominal rates reduce to the annual rate when m = 1", {
  r1 <- nominal_rates(i, 1)
  expect_equal(r1$im, i)
  expect_equal(r1$alpha, 1)
  expect_equal(r1$beta, 0)
})

test_that("under UDD the alpha-beta formula is exact", {
  expect_equal(annuity_due_mthly(q, i, 12, method = "exact_udd"), annuity_due_mthly(q, i, 12, method = "udd"),
               tolerance = 1e-10)
  expect_equal(annuity_due_mthly(q, i, 12, n = 20, method = "exact_udd"),
               annuity_due_mthly(q, i, 12, n = 20, method = "udd"), tolerance = 1e-10)
  expect_equal(annuity_due_mthly(q, i, 12, method = "udd"), 18.954869455603173, tolerance = 1e-10)
  expect_equal(insurance_mthly(q, i, 12, method = "exact_udd"), insurance_mthly(q, i, 12, method = "udd"),
               tolerance = 1e-10)
})

test_that("paying once a year needs no adjustment", {
  expect_equal(annuity_due_mthly(q, i, 1, method = "udd"), annuity_due(q, i))
  expect_equal(annuity_due_mthly(q, i, 1, method = "woolhouse2"), annuity_due(q, i))
})

test_that("three Woolhouse terms beat two against the constant-force exact value", {
  exact <- annuity_due_mthly(q, i, 12, method = "exact_cf")
  w2 <- annuity_due_mthly(q, i, 12, method = "woolhouse2")
  w3 <- annuity_due_mthly(q, i, 12, method = "woolhouse3", mu0 = mu_x(m, 40))
  expect_true(abs(w3 - exact) < abs(w2 - exact))
  expect_true(abs(w2 - exact) < 0.01)
  expect_error(annuity_due_mthly(q, i, 12, method = "woolhouse3"))
})

test_that("insurance paid at the moment of death", {
  A <- epv("whole_life", q, i)
  expect_equal(insurance_continuous(q, i, method = "udd"), i / log(1 + i) * A)
  expect_equal(insurance_continuous(q, i, method = "claims"), sqrt(1 + i) * A)
  exact <- insurance_continuous_exact(m, 40, i)
  expect_equal(exact, 0.16747677066818834, tolerance = 1e-8)
  expect_true(abs(insurance_continuous(q, i) / exact - 1) < 0.001)
  expect_error(insurance_continuous(q, i, method = "telepathy"))
})
