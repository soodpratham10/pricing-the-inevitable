library(shiny)

# The engine: the installed package (deploy.R swaps this block for the bundled R/ files)
# ENGINE-START
library(inevitable)
# ENGINE-END

m <- mortality_law()
BOOK_AGES <- seq(25, 65, by = 5)
PLANS <- plans()
CLASSES <- risk_classes()$class

plan_spec <- function(plan, x) switch(plan,
  WL   = list(product = "whole_life", n = 10, h = 5, t = NULL),
  WL20 = list(product = "whole_life", n = 10, h = 5, t = 20),
  T10  = list(product = "term", n = 10, h = 5, t = 10),
  T20  = list(product = "term", n = 20, h = 5, t = 20),
  E20  = list(product = "endowment", n = 20, h = 5, t = 20),
  DA65 = list(product = "deferred_whole_due", n = 10, h = 65 - x, t = 65 - x))

dollars <- function(x, d = 2) ifelse(is.na(x), "-", paste0(ifelse(x < 0, "-", ""), "$",
                                     formatC(abs(x), format = "f", digits = d, big.mark = ",")))
pct <- function(x, d = 1) paste0(formatC(100 * x, format = "f", digits = d), "%")
note <- p(class = "fineprint", "Net premiums on illustrative assumptions: not calibrated, not a real offer, not financial advice.")

# ---------- The look: a 1950s insurance office ----------
INK <- "#2b2520"; PAPER <- "#f5efe2"; CARD <- "#fffdf7"; RULE <- "#d9cfba"
OXBLOOD <- "#8c2f39"; FOREST <- "#2f5d50"; OCHRE <- "#c08a2e"; SLATE <- "#5b6b7a"
CLASS_COL <- c(Preferred = FOREST, Standard = SLATE, Smoker = OCHRE, Rated = OXBLOOD)

office_par <- function(mar = c(4, 4.6, 2.2, 1)) {
  par(bg = CARD, fg = INK, col.axis = INK, col.lab = INK, col.main = INK, mar = mar,
      family = "serif", font.main = 1, cex.main = 1.05, las = 1)
}

css <- "
  body { background: #f5efe2; color: #2b2520; font-family: 'Source Serif 4', Georgia, serif; }
  h1, h2, h3, h4, .navbar-brand { font-family: 'Special Elite', 'Courier New', monospace; letter-spacing: 0.5px; }
  .navbar { background: #2b2520 !important; }
  .navbar-brand { color: #f5efe2 !important; font-size: 1.35em; }
  .navbar .nav-link { color: #d9cfba !important; }
  .navbar .nav-link.active { color: #ffffff !important; border-bottom: 2px solid #c08a2e; }
  .masthead { border-top: 6px double #2b2520; border-bottom: 2px solid #2b2520; padding: 18px 4px 12px 4px; margin-bottom: 18px; }
  .masthead h1 { font-size: 2.6em; margin: 0; }
  .masthead .tag { font-style: italic; color: #5b6b7a; font-size: 1.1em; }
  .masthead .dept { font-family: 'Courier Prime', monospace; text-transform: uppercase; letter-spacing: 3px;
                    font-size: 0.78em; color: #8c2f39; }
  .ix { background: #fffdf7; border: 1px solid #d9cfba; border-top: 4px solid #8c2f39; border-radius: 3px;
        box-shadow: 3px 3px 0 #e6dcc6; padding: 14px 18px; margin-bottom: 18px; }
  .ix.green { border-top-color: #2f5d50; } .ix.ochre { border-top-color: #c08a2e; }
  .ix .label { font-family: 'Courier Prime', monospace; text-transform: uppercase; letter-spacing: 2px;
               font-size: 0.75em; color: #8c2f39; margin-bottom: 6px; }
  .mono { font-family: 'Courier Prime', monospace; }
  .letter { position: relative; background: #fffef9; border: 1px solid #d9cfba; padding: 26px 30px 22px 30px;
            font-family: 'Courier Prime', 'Courier New', monospace; box-shadow: 0 6px 18px #00000022; margin-bottom: 18px;
            background-image: repeating-linear-gradient(#fffef9 0 29px, #f0e9da 29px 30px); }
  .letter .head { font-family: 'Special Elite', monospace; font-size: 1.4em; border-bottom: 2px solid #2b2520; padding-bottom: 4px; }
  .letter .sub { font-size: 0.85em; color: #5b6b7a; margin-bottom: 14px; }
  .letter .big { font-size: 2.1em; font-weight: 700; color: #2b2520; }
  .letter table td { padding: 2px 14px 2px 0; }
  .stamp { position: absolute; right: 26px; top: 64px; transform: rotate(-14deg); border: 4px solid #8c2f39; color: #8c2f39;
           font-family: 'Special Elite', monospace; font-size: 1.6em; padding: 2px 14px; opacity: 0.78; letter-spacing: 3px; }
  .stamp.green { border-color: #2f5d50; color: #2f5d50; }
  .btn-desk { background: #8c2f39; color: #fffdf7; border: none; font-family: 'Courier Prime', monospace;
              text-transform: uppercase; letter-spacing: 1.5px; border-radius: 3px; padding: 8px 16px; }
  .btn-desk:hover { background: #6f222b; color: #fffdf7; }
  .btn-ghost { background: transparent; color: #2b2520; border: 1px solid #2b2520; font-family: 'Courier Prime', monospace;
               text-transform: uppercase; letter-spacing: 1.5px; border-radius: 3px; padding: 7px 14px; }
  .score { font-family: 'Special Elite', monospace; font-size: 3em; color: #2f5d50; }
  .fineprint { font-size: 0.82em; font-style: italic; color: #5b6b7a; margin-top: 8px; }
  .table { font-family: 'Courier Prime', monospace; font-size: 0.92em; }
  .irs--shiny .irs-bar { background: #8c2f39; border-color: #8c2f39; }
  .irs--shiny .irs-single { background: #8c2f39; }
  @media print {
    .navbar, .no-print, .col-sm-4 { display: none !important; }
    .letter { box-shadow: none; border: none; }
  }
"

head_tags <- tags$head(
  tags$link(rel = "stylesheet",
            href = "https://fonts.googleapis.com/css2?family=Special+Elite&family=Courier+Prime:wght@400;700&family=Source+Serif+4:wght@400;600&display=swap"),
  tags$style(HTML(css)))

ix <- function(label, ..., tone = "") div(class = paste("ix", tone), div(class = "label", label), ...)

masthead <- function(title, tag) div(class = "masthead",
  div(class = "dept", "Prairie Life (fictional) \u00B7 pricing department \u00B7 est. 1952"),
  h1(title), div(class = "tag", tag))

# ---------- The Quote Desk ----------
tab_desk <- tabPanel("The Quote Desk",
  masthead("The Quote Desk", "Everyone dies. The premium is about when."),
  fluidRow(
    column(4, class = "no-print",
      ix("The applicant",
        textInput("name", "Name on the quote", "A. N. Applicant"),
        sliderInput("age", "Issue age", min = 20, max = 75, value = 40, step = 1),
        radioButtons("class", "Underwriting class", CLASSES, selected = "Standard", inline = TRUE)),
      ix("The policy", tone = "green",
        selectInput("plan", "Plan", setNames(PLANS$plan, paste0(PLANS$plan, ": ", PLANS$label)), selected = "WL"),
        numericInput("benefit", "Benefit ($; for DA65 the yearly income from 65)", 250000, min = 1000, step = 10000),
        radioButtons("freq", "Premiums paid", c("Annual", "Monthly"), selected = "Annual", inline = TRUE),
        conditionalPanel("input.freq == 'Monthly'",
          selectInput("method", "Monthly method", c("UDD" = "udd", "Woolhouse, 2 terms" = "woolhouse2",
                                                    "Exact, constant force" = "exact_cf"))),
        sliderInput("rate", "Interest rate (%)", min = 1, max = 8, value = 4.5, step = 0.25)),
      ix("The risk appetite", tone = "ochre",
        sliderInput("alpha", "Acceptable chance of a loss", min = 0.01, max = 0.25, value = 0.05, step = 0.01),
        selectInput("N", "Policies in the portfolio", c("100", "1,000" = "1000", "10,000" = "10000", "100,000" = "100000"),
                    selected = "1000"))
    ),
    column(8,
      uiOutput("letter"),
      div(class = "no-print",
        actionButton("log", "File this quote", class = "btn-desk"),
        tags$button("Print the letter", class = "btn btn-ghost", onclick = "window.print()"),
        br(), br(),
        fluidRow(
          column(7, ix("When would this policy lose money?", plotOutput("death_plot", height = "260px"))),
          column(5, ix("The same policy, every class", plotOutput("class_plot", height = "260px"), tone = "green"))),
        ix("The quote book (this session)", tableOutput("quote_log"), tone = "ochre"),
        note)
    )
  )
)

# ---------- Risk Lab ----------
tab_risk <- tabPanel("Risk Lab",
  masthead("The Risk Lab", "A premium is a bet. How sure do you want to be?"),
  fluidRow(
    column(5,
      ix("Four ways to set the price", p("For the applicant and policy on the Quote Desk."), tableOutput("principles")),
      ix("The percentile trap", tone = "ochre", uiOutput("trap"))),
    column(7,
      ix("Probability of a loss as the premium rises (one policy)", plotOutput("loss_curve", height = "280px")),
      ix("1,000 simulated portfolios at the portfolio premium", tone = "green",
        selectInput("simN", "Policies per portfolio", c("100", "1,000" = "1000", "10,000" = "10000"), selected = "1000"),
        plotOutput("sim_plot", height = "260px"), uiOutput("sim_note")),
      note)
  )
)

# ---------- Mortality Lab ----------
tab_mort <- tabPanel("Mortality Lab",
  masthead("The Mortality Lab", "Five ways to write down the clock."),
  fluidRow(
    column(4,
      ix("Compare laws of mortality",
        sliderInput("lab_age", "From age", 20, 90, 40),
        checkboxGroupInput("laws", NULL, c("Makeham (the project's law)" = "makeham", "Gompertz (no Makeham constant)" = "gompertz",
                                           "de Moivre, omega 110" = "demoivre", "Constant force 0.02" = "constant",
                                           "Weibull" = "weibull"), selected = c("makeham", "demoivre", "weibull"))),
      ix("Inside one year", tone = "ochre",
        sliderInput("frac_q", "A one-year death probability q", 0.01, 0.6, 0.3, step = 0.01),
        p("How the year's deaths are spread: uniformly (UDD), at a constant force, or by Balducci's hyperbolic assumption."))),
    column(8,
      ix("Survival from the chosen age", plotOutput("surv_plot", height = "300px"), tableOutput("law_table")),
      ix("Surviving part of a year", tone = "ochre", plotOutput("frac_plot", height = "250px")),
      note)
  )
)

# ---------- The Shelf ----------
tab_shelf <- tabPanel("Product Shelf",
  masthead("The Product Shelf", "Nineteen promises, one life."),
  fluidRow(
    column(4,
      ix("The life and the terms",
        sliderInput("sh_age", "Age", 20, 80, 40),
        sliderInput("sh_n", "Term n (years)", 1, 40, 20),
        sliderInput("sh_h", "Deferral h (years)", 0, 40, 25),
        sliderInput("sh_i", "Interest (%)", 1, 8, 4.5, step = 0.25)),
      ix("Look inside one product", tone = "green",
        selectInput("sh_prod", NULL, setNames(products()$id, products()$label), selected = "deferred_whole_due"))),
    column(8,
      ix("Expected present value and spread, per 1 of benefit", tableOutput("shelf")),
      ix("The distribution of the present value", tone = "green", plotOutput("pv_plot", height = "260px")),
      note)
  )
)

# ---------- The natural hedge ----------
tab_hedge <- tabPanel("Natural Hedge",
  masthead("The Natural Hedge", "Insurance loses when people die young. Annuities lose when they live long."),
  fluidRow(
    column(4,
      ix("The two books",
        sliderInput("h_xins", "Age of the insured", 25, 60, 40),
        numericInput("h_S", "Insurance benefit ($)", 250000, min = 10000, step = 10000),
        sliderInput("h_xann", "Age of the annuitants", 55, 80, 65),
        numericInput("h_B", "Annuity income ($ a year)", 20000, min = 1000, step = 1000)),
      ix("The answer", tone = "green", uiOutput("hedge_answer"))),
    column(8,
      ix("Change in what the company owes after a mortality shock (1,000 insurance policies)",
        plotOutput("hedge_plot", height = "340px")),
      note)
  )
)

# ---------- Beat the Underwriter ----------
tab_game <- tabPanel("Beat the Underwriter",
  masthead("Beat the Underwriter", "Guess the annual net premium. The desk will check your arithmetic."),
  fluidRow(
    column(5,
      ix("Today's applicant", uiOutput("case_card")),
      ix("Your guess", tone = "green",
        numericInput("guess", "Annual premium ($)", value = NA, min = 0, step = 10),
        actionButton("submit", "Stamp my guess", class = "btn-desk"),
        actionButton("hint", "Show me the rate card", class = "btn btn-ghost"),
        actionButton("next_case", "Next applicant", class = "btn btn-ghost"),
        uiOutput("hint_box"))),
    column(7,
      ix("The verdict", uiOutput("verdict"), tone = "ochre"),
      ix("Your ledger", div(class = "score", textOutput("total", inline = TRUE)), tableOutput("ledger")),
      note)
  )
)

tab_about <- tabPanel("About",
  fluidRow(column(8, offset = 2,
    masthead("Pricing the Inevitable", "A life contingencies pricing engine and the desk built on it."),
    ix("About the desk",
      p("Every number on these pages comes from ", strong("inevitable"), ", an R package built from first principles with 120 automated tests
         that run on GitHub after every change. The same results are rebuilt in SQL, in an Excel rate calculator,
         in a Quarto pricing memo and in an independent Python port."),
      p("Mortality: Gompertz-Makeham, mu(x) = 0.0002 + 0.000008 x 1.112^x, with select factors 0.7 and 0.85 for newly
         underwritten lives. Interest 4.5% unless you change it. Net premiums: no expenses or profit."),
      p(a("Source code on GitHub", href = "https://github.com/soodpratham10/pricing-the-inevitable", target = "_blank"),
        " \u00B7 ", a("Function reference", href = "https://soodpratham10.github.io/pricing-the-inevitable/", target = "_blank")),
      p("Built by Pratham Sood, Actuarial Mathematics and Statistics, University of Manitoba."),
      p(em("Also by the author: "), a("The Odds of a Lifetime", href = "https://soodpratham10.shinyapps.io/odds-of-a-lifetime/", target = "_blank"),
        " and ", a("Matching the Promise", href = "https://soodpratham10.shinyapps.io/matching-the-promise/", target = "_blank"), "."),
      note)
  ))
)

ui <- navbarPage(
  title = "Pricing the Inevitable",
  header = head_tags,
  theme = bslib::bs_theme(version = 5, bg = PAPER, fg = INK, primary = OXBLOOD, secondary = FOREST,
                          base_font = "Source Serif 4, Georgia, serif", heading_font = "Special Elite, monospace"),
  tab_desk, tab_risk, tab_mort, tab_shelf, tab_hedge, tab_game, tab_about
)

server <- function(input, output, session) {

  # ---------- The Quote Desk ----------
  desk <- reactive({
    req(input$benefit > 0)
    x <- input$age; plan <- input$plan; cl <- input$class
    validate(need(!(plan == "DA65" && x >= 65), "The deferred annuity (DA65) needs an issue age below 65."))
    i <- input$rate / 100; S <- input$benefit
    s <- plan_spec(plan, x)
    q <- class_q_path(m, x, cl)
    benefit <- S * epv(s$product, q, i, s$n, s$h)
    a_ann <- annuity_due(q, i, s$t)
    P_ann <- benefit / a_ann
    a_pay <- if (input$freq == "Annual") a_ann else annuity_due_mthly(q, i, 12, s$t, method = input$method)
    P_year <- benefit / a_pay
    alpha <- input$alpha; N <- as.numeric(input$N)
    kp <- kpx_from_q(q)
    claim <- switch(plan, WL = 1, WL20 = 1, T10 = 1 - kp[11], T20 = 1 - kp[21], E20 = 1 - kp[21], DA65 = kp[s$h + 1])
    list(x = x, plan = plan, cl = cl, i = i, S = S, s = s, q = q, benefit = benefit, P_ann = P_ann, P_year = P_year,
         instalment = if (input$freq == "Annual") P_year else P_year / 12, claim = claim,
         prob_loss = prob_loss(s$product, q, i, S, P_ann, s$n, s$h, s$t),
         pct = percentile_premium(s$product, q, i, S, alpha, s$n, s$h, s$t),
         port = tryCatch(portfolio_premium(s$product, q, i, S, N, alpha, s$n, s$h, s$t), error = function(e) NA),
         alpha = alpha, N = N)
  })

  ref_no <- reactive({ input$log; paste0("PL-", format(Sys.Date(), "%Y%m%d"), "-", sample(1000:9999, 1)) })

  output$letter <- renderUI({
    d <- desk()
    lab <- PLANS$label[PLANS$plan == d$plan]
    claim_lab <- if (d$plan == "DA65") "Chance of reaching 65 and collecting" else "Chance the policy pays a death claim"
    benefit_lab <- if (d$plan == "DA65") paste(dollars(d$S, 0), "a year from age 65") else dollars(d$S, 0)
    div(class = "letter",
      div(class = "head", "PRAIRIE LIFE \u00B7 QUOTE DESK"),
      div(class = "sub", sprintf("Ref. %s \u00B7 %s \u00B7 a fictional insurer", ref_no(), format(Sys.Date(), "%d %B %Y"))),
      div(class = if (d$prob_loss < d$alpha) "stamp green" else "stamp", "QUOTED"),
      p(sprintf("Dear %s,", if (nzchar(input$name)) input$name else "Applicant")),
      p(sprintf("Thank you for your enquiry. For a %s (issue age %d, %s class), the net premium is:", tolower(lab), d$x, d$cl)),
      div(class = "big", sprintf("%s %s", dollars(d$instalment), if (input$freq == "Annual") "a year" else "a month")),
      tags$table(
        tags$tr(tags$td("Benefit"), tags$td(benefit_lab)),
        tags$tr(tags$td("Total premium a year"), tags$td(dollars(d$P_year))),
        tags$tr(tags$td("Premium per $1,000"), tags$td(dollars(1000 * d$P_year / d$S))),
        tags$tr(tags$td(claim_lab), tags$td(pct(d$claim, 2))),
        tags$tr(tags$td("Chance this policy loses us money"), tags$td(pct(d$prob_loss))),
        tags$tr(tags$td(sprintf("Premium to be %s sure on this one policy", pct(1 - d$alpha, 0))), tags$td(dollars(d$pct))),
        tags$tr(tags$td(sprintf("... and across %s such policies", formatC(as.integer(d$N), format = "d", big.mark = ","))), tags$td(dollars(d$port)))),
      p(style = "margin-top: 12px;", "Yours faithfully,"),
      p("The Pricing Actuary"),
      p(class = "fineprint", "Net premium: no expenses, commission or profit. The risk lines use annual premiums."))
  })

  quotes <- reactiveVal(data.frame())
  observeEvent(input$log, {
    d <- desk()
    quotes(rbind(quotes(), data.frame(Ref = ref_no(), Name = input$name, Plan = d$plan, Age = d$x, Class = d$cl,
                                      Benefit = dollars(d$S, 0), Paid = input$freq, Premium = dollars(d$instalment),
                                      stringsAsFactors = FALSE)))
  })
  output$quote_log <- renderTable({
    if (nrow(quotes()) == 0) data.frame(Note = "No quotes filed yet. Press 'File this quote'.") else quotes()
  })

  output$death_plot <- renderPlot({
    d <- desk()
    ld <- loss_distribution(d$s$product, d$q, d$i, d$S, d$P_ann, d$s$n, d$s$h, d$s$t)
    keep <- ld$prob > 1e-6
    office_par()
    plot(d$x + ld$k[keep], ld$prob[keep], type = "h", lwd = 3,
         col = ifelse(ld$loss[keep] > 0, OXBLOOD, FOREST),
         xlab = "Age at death", ylab = "Probability", main = sprintf("Loss in red: %s of outcomes", pct(d$prob_loss)))
    legend("topleft", c("Company loses", "Company gains"), col = c(OXBLOOD, FOREST), lwd = 3, bty = "n")
  }, bg = CARD)

  output$class_plot <- renderPlot({
    d <- desk()
    v <- sapply(CLASSES, function(cl) plan_premium(m, d$x, d$plan, cl, "Annual", d$i, d$S))
    office_par(c(4, 5.5, 2.2, 1))
    b <- barplot(v, col = CLASS_COL[CLASSES], border = NA, ylab = "", main = "Annual premium",
                 ylim = c(0, max(v) * 1.18), yaxt = "n")
    axis(2, at = pretty(c(0, max(v))), labels = dollars(pretty(c(0, max(v))), 0))
    text(b, v, dollars(v, 0), pos = 3, family = "mono", cex = 0.85)
  }, bg = CARD)

  # ---------- Risk Lab ----------
  output$principles <- renderTable({
    d <- desk()
    ports <- sapply(c(100, 1000, 10000), function(N)
      tryCatch(portfolio_premium(d$s$product, d$q, d$i, d$S, N, d$alpha, d$s$n, d$s$h, d$s$t), error = function(e) NA))
    data.frame(Principle = c("Equivalence (break even on average)",
                             sprintf("Percentile: one policy, %s sure", pct(1 - d$alpha, 0)),
                             "Portfolio of 100", "Portfolio of 1,000", "Portfolio of 10,000"),
               `Annual premium` = dollars(c(d$P_ann, d$pct, ports)),
               `Above net` = c("-", pct(c(d$pct, ports) / d$P_ann - 1)), check.names = FALSE)
  })

  output$trap <- renderUI({
    d <- desk()
    if (d$pct < d$P_ann) {
      p(strong("This policy falls into the trap. "), sprintf(
        "Its %s percentile premium (%s) is below the net premium (%s): the chance of a loss is already under %s at a zero or tiny premium, so a percentile rule alone would give the cover away.",
        pct(1 - d$alpha, 0), dollars(d$pct), dollars(d$P_ann), pct(d$alpha, 0)))
    } else {
      p(sprintf("Here the percentile premium is %s times the net premium. Try 20-year term (T20) at age 40: dying within 20 years is less likely than 5%%, so its 95%% percentile premium is $0.",
                formatC(d$pct / d$P_ann, format = "f", digits = 2)))
    }
  })

  output$loss_curve <- renderPlot({
    d <- desk()
    mult <- seq(0.5, 4, by = 0.01)
    pl <- sapply(mult, function(k) prob_loss(d$s$product, d$q, d$i, d$S, k * d$P_ann, d$s$n, d$s$h, d$s$t))
    office_par()
    plot(mult, pl, type = "s", lwd = 3, col = INK, xlab = "Premium as a multiple of the net premium",
         ylab = "Probability of a loss", ylim = c(0, 1))
    abline(h = d$alpha, col = OXBLOOD, lty = 2); abline(v = 1, col = SLATE, lty = 3)
    if (d$pct > 0) abline(v = d$pct / d$P_ann, col = OXBLOOD, lty = 2)
    legend("topright", c("Chance of a loss", sprintf("Target %s", pct(d$alpha, 0))), col = c(INK, OXBLOOD),
           lty = c(1, 2), lwd = c(3, 1), bty = "n")
  }, bg = CARD)

  sim <- reactive({
    d <- desk(); N <- as.numeric(input$simN)
    P <- tryCatch(portfolio_premium(d$s$product, d$q, d$i, d$S, N, d$alpha, d$s$n, d$s$h, d$s$t), error = function(e) NA)
    validate(need(!is.na(P), "No portfolio premium for this case."))
    list(P = P, N = N, s = simulate_portfolio(d$s$product, d$q, d$i, d$S, P, N, sims = 1000, seed = 2026,
                                              n = d$s$n, h = d$s$h, t = d$s$t))
  })
  output$sim_plot <- renderPlot({
    r <- sim()
    office_par()
    tot <- r$s$totals / 1e6
    h <- hist(tot, breaks = 40, plot = FALSE)
    plot(h, col = ifelse(h$mids > 0, OXBLOOD, FOREST), border = CARD, main = "", xlab = "Portfolio loss ($ millions)", ylab = "Portfolios")
    abline(v = 0, lwd = 2)
  }, bg = CARD)
  output$sim_note <- renderUI({
    r <- sim(); d <- desk()
    p(sprintf("At %s a year each, %s of 1,000 simulated portfolios lost money. The normal approximation aimed for %s.",
              dollars(r$P), pct(r$s$prob_loss), pct(d$alpha)))
  })

  # ---------- Mortality Lab ----------
  lab_laws <- reactive({
    req(length(input$laws) > 0)
    lapply(input$laws, function(l) mortality_law(l))
  })
  LAW_COL <- c(makeham = OXBLOOD, gompertz = OCHRE, demoivre = SLATE, constant = "#8a7f72", weibull = FOREST)
  output$surv_plot <- renderPlot({
    x <- input$lab_age; t <- seq(0, 120 - x, by = 0.25)
    office_par()
    plot(NA, xlim = c(x, 120), ylim = c(0, 1), xlab = "Age", ylab = "Probability of being alive")
    for (lw in lab_laws()) lines(x + t, tpx(lw, x, t), lwd = 3, col = LAW_COL[lw$name])
    legend("topright", input$laws, col = LAW_COL[input$laws], lwd = 3, bty = "n")
  }, bg = CARD)
  output$law_table <- renderTable({
    x <- input$lab_age
    do.call(rbind, lapply(lab_laws(), function(lw) {
      q <- q_path(lw, x)
      data.frame(Law = lw$name, `mu at this age` = formatC(mu_x(lw, x), format = "f", digits = 5),
                 `q at this age` = formatC(q[1], format = "f", digits = 5),
                 `Life expectancy (complete years)` = formatC(curtate_ex(q), format = "f", digits = 2), check.names = FALSE)
    }))
  })
  output$frac_plot <- renderPlot({
    s <- seq(0, 1, by = 0.01); qv <- input$frac_q
    office_par()
    plot(s, spx(qv, s, "udd"), type = "l", lwd = 3, col = INK, ylim = c(1 - qv, 1),
         xlab = "Fraction of the year", ylab = "Probability of surviving that far")
    lines(s, spx(qv, s, "cf"), lwd = 3, col = OXBLOOD)
    lines(s, spx(qv, s, "balducci"), lwd = 3, col = FOREST)
    legend("topright", c("UDD", "Constant force", "Balducci"), col = c(INK, OXBLOOD, FOREST), lwd = 3, bty = "n")
  }, bg = CARD)

  # ---------- The Shelf ----------
  shelf_q <- reactive(q_path(m, input$sh_age))
  output$shelf <- renderTable({
    tab <- value_all(shelf_q(), input$sh_i / 100, input$sh_n, input$sh_h)
    data.frame(Product = tab$label, Type = tab$type, EPV = formatC(tab$epv, format = "f", digits = 5),
               `Standard deviation` = formatC(tab$sd, format = "f", digits = 5), check.names = FALSE)
  })
  output$pv_plot <- renderPlot({
    mo <- product_moments(input$sh_prod, shelf_q(), input$sh_i / 100, input$sh_n, input$sh_h)
    dd <- aggregate(prob ~ pv, data = transform(mo$dist, pv = round(pv, 4)), FUN = sum)
    office_par()
    plot(dd$pv, dd$prob, type = "h", lwd = 3, col = FOREST, xlab = "Present value of the benefit", ylab = "Probability",
         main = sprintf("EPV %s, standard deviation %s", formatC(mo$epv, format = "f", digits = 4),
                        formatC(mo$sd, format = "f", digits = 4)))
    abline(v = mo$epv, col = OXBLOOD, lty = 2, lwd = 2)
  }, bg = CARD)

  # ---------- The natural hedge ----------
  hedge <- reactive(natural_hedge(m, input$h_xins, input$h_xann, input$h_S, input$h_B, 0.045))
  output$hedge_answer <- renderUI({
    h <- hedge()
    tagList(
      div(class = "score", formatC(h$ratio, format = "f", digits = 3)),
      p(sprintf("annuities of %s a year for every insurance policy of %s make the company's promises insensitive to a small mortality shock.",
                dollars(input$h_B, 0), dollars(input$h_S, 0))),
      p(sprintf("A 10%% heavier mortality adds %s to one insurance policy and saves %s on one annuity.",
                dollars(h$ins_change, 0), dollars(-h$ann_change, 0))))
  })
  output$hedge_plot <- renderPlot({
    h <- hedge(); s <- seq(-0.3, 0.3, by = 0.01)
    f <- function(na) sapply(s, function(z) block_change(m, 1000, na, z, input$h_xins, input$h_xann, input$h_S, input$h_B, 0.045)) / 1e6
    un <- f(0); hed <- f(1000 * h$ratio)
    office_par()
    plot(100 * s, un, type = "l", lwd = 3, col = OXBLOOD, ylim = range(c(un, hed)),
         xlab = "Mortality shock (% change in every q)", ylab = "Change in liabilities ($ millions)")
    lines(100 * s, hed, lwd = 3, col = FOREST); abline(h = 0, v = 0, col = SLATE, lty = 3)
    legend("topleft", c("Insurance only", sprintf("Hedged with %s annuities", round(1000 * h$ratio))),
           col = c(OXBLOOD, FOREST), lwd = 3, bty = "n")
  }, bg = CARD)

  # ---------- Beat the Underwriter ----------
  new_case <- function() {
    plan <- sample(PLANS$plan, 1)
    x <- if (plan == "DA65") sample(25:60, 1) else sample(25:65, 1)
    list(plan = plan, x = x, cl = sample(CLASSES, 1, prob = c(0.25, 0.4, 0.2, 0.15)),
         S = if (plan == "DA65") sample(c(10000, 20000, 30000), 1) else sample(c(100000, 250000, 500000), 1))
  }
  game <- reactiveValues(case = new_case(), done = FALSE, hint = FALSE, ledger = data.frame())
  observeEvent(input$next_case, { game$case <- new_case(); game$done <- FALSE; game$hint <- FALSE
    updateNumericInput(session, "guess", value = NA) })
  observeEvent(input$hint, game$hint <- TRUE)
  truth <- reactive({ cs <- game$case; plan_premium(m, cs$x, cs$plan, cs$cl, "Annual", 0.045, cs$S) })

  output$case_card <- renderUI({
    cs <- game$case
    lab <- PLANS$label[PLANS$plan == cs$plan]
    div(class = "letter", style = "padding: 16px 20px;",
      div(class = "head", "APPLICATION"),
      tags$table(
        tags$tr(tags$td("Age"), tags$td(cs$x)),
        tags$tr(tags$td("Class"), tags$td(cs$cl)),
        tags$tr(tags$td("Plan"), tags$td(paste0(cs$plan, ": ", lab))),
        tags$tr(tags$td(if (cs$plan == "DA65") "Income from 65" else "Benefit"), tags$td(dollars(cs$S, 0))),
        tags$tr(tags$td("Premiums"), tags$td("Annual, net, 4.5% interest"))))
  })
  output$hint_box <- renderUI({
    req(game$hint)
    cs <- game$case
    near <- BOOK_AGES[which.min(abs(BOOK_AGES - cs$x))]
    if (cs$plan == "DA65" && near >= 65) near <- 60
    r <- plan_premium(m, near, cs$plan, "Standard", "Annual", 0.045, 1000)
    p(class = "fineprint", sprintf("Rate card: %s for a Standard life aged %d is %s per $1,000 a year. Adjust for age and class.",
                                   cs$plan, near, dollars(r)))
  })
  observeEvent(input$submit, {
    req(!game$done, !is.na(input$guess))
    err <- input$guess / truth() - 1
    pts <- max(0, round(100 * (1 - abs(err))))
    cs <- game$case
    game$ledger <- rbind(game$ledger, data.frame(Applicant = sprintf("%s, %d, %s", cs$plan, cs$x, cs$cl),
                                                 Guess = dollars(input$guess), Answer = dollars(truth()),
                                                 Off = pct(err), Points = pts, stringsAsFactors = FALSE))
    game$done <- TRUE
  })
  output$verdict <- renderUI({
    if (!game$done) return(p("Make a guess and press 'Stamp my guess'."))
    last <- game$ledger[nrow(game$ledger), ]
    stamp <- if (last$Points >= 90) "APPROVED" else if (last$Points >= 60) "REFERRED" else "DECLINED"
    div(style = "position: relative; min-height: 120px;",
      div(class = if (last$Points >= 90) "stamp green" else "stamp", style = "top: 10px;", stamp),
      p(sprintf("The net premium is %s a year. You were %s off: %d points.", last$Answer, last$Off, last$Points)),
      p(class = "fineprint", "Press 'Next applicant' for another."))
  })
  output$total <- renderText({
    if (nrow(game$ledger) == 0) "0 points" else sprintf("%d points in %d", sum(game$ledger$Points), nrow(game$ledger))
  })
  output$ledger <- renderTable({ if (nrow(game$ledger) == 0) NULL else game$ledger })
}

shinyApp(ui, server)
