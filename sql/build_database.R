# Build the quoting database: sql/quote_desk.sqlite
#
# Run from the project root, after installing the package with devtools::install():
#   source("sql/build_database.R")
# Needs the packages DBI and RSQLite.

library(inevitable)

# Split a .sql file into single statements (SQLite runs one at a time from R)
read_sql_statements <- function(file) {
  txt <- paste(readLines(file, warn = FALSE), collapse = "\n")
  parts <- trimws(strsplit(txt, ";", fixed = TRUE)[[1]])
  keep <- sapply(parts, function(p) {
    lines <- trimws(strsplit(p, "\n", fixed = TRUE)[[1]])
    any(nchar(lines) > 0 & !startsWith(lines, "--"))
  })
  parts[keep]
}

# Run a query file and return the result of its last statement
run_sql_file <- function(con, file) {
  st <- read_sql_statements(file)
  for (s in st[-length(st)]) DBI::dbExecute(con, s)
  DBI::dbGetQuery(con, st[length(st)])
}

build_quote_database <- function(path = "sql/quote_desk.sqlite", n_policies = 50000, seed = 2026, i = 0.045) {
  if (file.exists(path)) file.remove(path)
  con <- DBI::dbConnect(RSQLite::SQLite(), path)
  for (s in read_sql_statements("sql/schema.sql")) DBI::dbExecute(con, s)
  m <- mortality_law()

  DBI::dbAppendTable(con, "assumption", data.frame(
    name = c("makeham_A", "makeham_B", "makeham_c", "interest", "select_year1", "select_year2"),
    value = c(m$par$A, m$par$B, m$par$c, i, 0.7, 0.85),
    note = c("Makeham constant", "Gompertz level", "Gompertz growth", "effective annual rate",
             "select factor on q in the first policy year", "select factor on q in the second policy year")))
  DBI::dbAppendTable(con, "plan", plans())
  DBI::dbAppendTable(con, "risk_class", risk_classes())

  rb <- rate_book(m, i = i)
  DBI::dbAppendTable(con, "rate", rb)

  # Product details for each plan, used to follow every simulated policy
  spec <- function(plan, x) switch(plan,
    WL = list(product = "whole_life", n = 10, h = 5, t = NULL),
    WL20 = list(product = "whole_life", n = 10, h = 5, t = 20),
    T10 = list(product = "term", n = 10, h = 5, t = 10),
    T20 = list(product = "term", n = 20, h = 5, t = 20),
    E20 = list(product = "endowment", n = 20, h = 5, t = 20),
    DA65 = list(product = "deferred_whole_due", n = 10, h = 65 - x, t = 65 - x))

  cells <- unique(rb[rb$frequency == "Annual", c("plan", "issue_age", "class")])
  risk <- cells
  risk$prob_loss <- mapply(function(p, x, cl) {
    s <- spec(p, x)
    prob_loss(s$product, class_q_path(m, x, cl), i, 1000, plan_premium(m, x, p, cl, "Annual", i, 1000), s$n, s$h, s$t)
  }, cells$plan, cells$issue_age, cells$class, USE.NAMES = FALSE)
  DBI::dbAppendTable(con, "model_risk", risk)

  # Sell 50,000 policies: plan, age and class at random, sum assured from a short list
  set.seed(seed)
  cls_w <- c(Preferred = 0.25, Standard = 0.50, Smoker = 0.15, Rated = 0.10)
  pick <- data.frame(plan = sample(plans()$plan, n_policies, replace = TRUE),
                     issue_age = sample(seq(25, 65, by = 5), n_policies, replace = TRUE),
                     class = sample(names(cls_w), n_policies, replace = TRUE, prob = cls_w),
                     stringsAsFactors = FALSE)
  pick$issue_age[pick$plan == "DA65" & pick$issue_age >= 65] <- 60   # the annuity is sold below 65
  pick$sum_assured <- ifelse(pick$plan == "DA65", sample(c(10000, 20000, 30000), nrow(pick), replace = TRUE),
                             sample(c(100000, 250000, 500000), nrow(pick), replace = TRUE))
  key <- paste(pick$plan, pick$issue_age, pick$class)
  out <- vector("list", length(unique(key)))
  for (j in seq_along(unique(key))) {
    rows <- which(key == unique(key)[j])
    p <- pick$plan[rows[1]]; x <- pick$issue_age[rows[1]]; cl <- pick$class[rows[1]]
    s <- spec(p, x)
    rate1 <- plan_premium(m, x, p, cl, "Annual", i, 1)
    ld <- loss_distribution(s$product, class_q_path(m, x, cl), i, 1, rate1, s$n, s$h, s$t)
    k <- sample(ld$k, length(rows), replace = TRUE, prob = ld$prob)
    S <- pick$sum_assured[rows]
    out[[j]] <- data.frame(plan = p, issue_age = x, class = cl, sum_assured = S,
                           annual_premium = S * rate1, curtate_lifetime = k,
                           pv_benefit = S * ld$Z[k + 1], pv_premium = S * rate1 * ld$Y[k + 1],
                           loss = S * ld$loss[k + 1])
  }
  pol <- do.call(rbind, out)
  pol <- cbind(policy_id = seq_len(nrow(pol)), pol)
  DBI::dbAppendTable(con, "policy", pol)
  con
}

# Run every query and print the results
run_all_queries <- function(con) {
  for (q in c("rate_card", "class_loadings", "monthly_cost", "actual_vs_expected", "quote_lookup")) {
    cat("\n==", q, "==\n")
    print(run_sql_file(con, file.path("sql", paste0(q, ".sql"))))
  }
  invisible(NULL)
}

con <- build_quote_database()
run_all_queries(con)
DBI::dbDisconnect(con)
