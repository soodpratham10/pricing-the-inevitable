# Create a law of mortality

Builds a mortality object used by every other function. The default is
Gompertz-Makeham with the project's own illustrative parameters (not
calibrated to real data): mu(x) = 0.0002 + 0.000008 \* 1.112^x.

## Usage

``` r
mortality_law(
  law = "makeham",
  A = 2e-04,
  B = 8e-06,
  c = 1.112,
  omega = 110,
  mu = 0.02,
  k = 2.5e-10,
  n = 4
)
```

## Arguments

- law:

  One of "makeham", "gompertz", "demoivre", "constant" or "weibull".

- A:

  Makeham constant (ignored for Gompertz, which sets it to 0).

- B:

  Gompertz level.

- c:

  Gompertz growth rate.

- omega:

  Limiting age for de Moivre's law.

- mu:

  Force of mortality for the constant-force law.

- k:

  Weibull scale, mu(x) = k \* x^n.

- n:

  Weibull shape.

## Value

A list of class "mortality" with the law name and its parameters.

## Examples

``` r
m <- mortality_law()
mu_x(m, 65)
#> [1] 0.008141475
```
