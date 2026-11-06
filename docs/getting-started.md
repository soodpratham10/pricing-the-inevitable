[← Overview](../README.md)

# Getting started

If you just want to use it, **[The Quote Desk](https://soodpratham10.shinyapps.io/pricing-the-inevitable/)** needs no installation.

## 1. Install the package

```r
install.packages("devtools")
devtools::install_github("soodpratham10/pricing-the-inevitable")
library(inevitable)
```

Or, from a clone of the repository:

```r
devtools::install()
```

## 2. Run the tests

```r
devtools::test()     # 120 tests
devtools::check()    # the full R CMD check that GitHub Actions runs on every push
```

| File | Tests |
|---|---|
| `test-mortality.R` | 30 |
| `test-products.R` | 30 |
| `test-frequency.R` | 17 |
| `test-premiums.R` | 22 |
| `test-ratebook.R` | 14 |
| `test-hedge.R` | 7 |

## 3. Build the quoting database

```r
install.packages(c("DBI", "RSQLite"))
source("sql/build_database.R")    # writes sql/quote_desk.sqlite and prints every query
```

The database is not stored in the repository. Open it in DB Browser for SQLite to run the `.sql` files yourself.

## 4. The Excel rate calculator

Open `excel/rate_calculator.xlsx`. Fill in the yellow cells on **Quote**; the **Cross-check** sheet should say **ALL PASS**.

## 5. Render the pricing memo

Needs [Quarto](https://quarto.org) and the R packages `quarto`, `knitr` and `rmarkdown`. In a terminal:

```
quarto render report/pricing-memo.qmd
```

This writes `report/pricing-memo.html` and `report/pricing-memo.pdf` (the PDF through Typst, which comes with Quarto).

## 6. The Python cross-check

Needs Python 3 and numpy.

```r
source("python/export_r_values.R")    # in R
```
```
python3 python/crosscheck.py          # in a terminal: ALL PASS: 20 of 20
```

## 7. Open The Quote Desk

```r
install.packages(c("shiny", "bslib"))
shiny::runApp("app")
```

## Repository layout

```
R/             the package: mortality, products, frequency, premiums, rate book, hedge
tests/         120 testthat tests
man/           help pages generated from the code by roxygen2
sql/           schema, views, database builder and queries
excel/         the rate calculator
report/        the Quarto pricing memo and its PDF
python/        the independent Python port and cross-check
app/           The Quote Desk (Shiny)
docs/          chapter pages and guides
.github/       GitHub Actions: R CMD check and the pkgdown website
deploy.R       publishes The Quote Desk to shinyapps.io
```
