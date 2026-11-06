# The rate book
m <- mortality_law()

test_that("the plans and classes are all there", {
  expect_equal(nrow(plans()), 6)
  expect_equal(nrow(risk_classes()), 4)
  expect_equal(nrow(rate_book(m)), 424)   # 6 plans x 9 ages x 4 classes x 2 frequencies, less DA65 at 65
})

test_that("premiums match the independent calculation", {
  expect_equal(plan_premium(m, 40, "WL"), 8.420336161719579, tolerance = 1e-10)
  expect_equal(plan_premium(m, 40, "WL", frequency = "Monthly"), 8.625758965261983, tolerance = 1e-10)
  expect_equal(plan_premium(m, 40, "T20", "Smoker", S = 250000), 783.2338164960015, tolerance = 1e-10)
  expect_equal(plan_premium(m, 40, "DA65"), 273.6978926990454, tolerance = 1e-10)
})

test_that("underwriting moves premiums the right way", {
  expect_true(plan_premium(m, 40, "WL", "Smoker") > plan_premium(m, 40, "WL", "Standard"))
  expect_true(plan_premium(m, 40, "WL", "Preferred") < plan_premium(m, 40, "WL", "Standard"))
  # smokers are expected to collect an annuity for fewer years, so it costs them less
  expect_true(plan_premium(m, 40, "DA65", "Smoker") < plan_premium(m, 40, "DA65", "Standard"))
  # select mortality lowers the premium against ultimate mortality
  qu <- class_q_path(m, 40, "Standard", select = FALSE)
  expect_true(plan_premium(m, 40, "WL") < 1000 * epv("whole_life", qu, 0.045) / annuity_due(qu, 0.045))
})

test_that("monthly instalments and bad inputs", {
  rb <- rate_book(m, ages = 40)
  row <- rb[rb$plan == "WL" & rb$class == "Standard" & rb$frequency == "Monthly", ]
  expect_equal(row$instalment_per_1000, row$premium_per_1000 / 12)
  expect_error(plan_premium(m, 65, "DA65"))
  expect_error(class_q_path(m, 40, "Immortal"))
})
