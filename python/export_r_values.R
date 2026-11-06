# Export the R engine's key results for the Python cross-check.
# Run from the project root:  source("python/export_r_values.R")

library(inevitable)

m <- mortality_law()
q <- q_path(m, 40)
i <- 0.045
S <- 250000
P <- net_premium("whole_life", q, i, S)

vals <- c(
  q40                  = q[1],
  e40                  = curtate_ex(q),
  e65                  = curtate_ex(q_path(m, 65)),
  A40                  = epv("whole_life", q, i),
  a40                  = epv("whole_due", q, i),
  var_A40              = product_moments("whole_life", q, i)$var,
  endowment_40_20      = epv("endowment", q, i, n = 20),
  deferred_annuity_40  = epv("deferred_whole_due", q, i, h = 25),
  a12_udd_40           = annuity_due_mthly(q, i, 12, method = "udd"),
  premium_whole_life   = P,
  premium_wl_20_pay    = net_premium("whole_life", q, i, S, t = 20),
  premium_term_20      = net_premium("term", q, i, S, n = 20, t = 20),
  prob_loss_whole_life = prob_loss("whole_life", q, i, S, P),
  percentile_premium   = percentile_premium("whole_life", q, i, S, alpha = 0.05),
  portfolio_premium    = portfolio_premium("whole_life", q, i, S, N = 1000, alpha = 0.05),
  refund_premium_20    = refund_premium(q, i, S, 20),
  hedge_ratio          = natural_hedge(m)$ratio,
  rate_WL_40_standard  = plan_premium(m, 40, "WL"),
  rate_T20_40_smoker   = plan_premium(m, 40, "T20", "Smoker", "Monthly"),
  rate_DA65_40         = plan_premium(m, 40, "DA65")
)

write.csv(data.frame(name = names(vals), r_value = format(unname(vals), digits = 17)),
          "python/r_values.csv", row.names = FALSE)
cat("Wrote", length(vals), "values to python/r_values.csv\n")
