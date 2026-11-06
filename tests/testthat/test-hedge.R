# The natural hedge between life insurance and annuities
m <- mortality_law()
q <- q_path(m, 40)

test_that("shocks scale q and keep the limiting age", {
  qs <- shock_q(q, 0.1)
  expect_equal(qs[1], 1.1 * q[1])
  expect_equal(qs[80], 1)
})

test_that("insurance and annuities move in opposite directions", {
  h <- natural_hedge(m)
  expect_true(h$dA > 0)       # heavier mortality: death benefits come sooner
  expect_true(h$da < 0)       # heavier mortality: fewer annuity payments
  expect_equal(h$ratio, 0.26184153783135455, tolerance = 1e-8)
})

test_that("the hedged block barely moves when mortality is shocked", {
  h <- natural_hedge(m)
  unhedged <- block_change(m, 1000, 0, 0.1)
  hedged <- block_change(m, 1000, 1000 * h$ratio, 0.1)
  expect_equal(unhedged, 1000 * h$ins_change)
  expect_true(abs(hedged) < 0.05 * abs(unhedged))
})
