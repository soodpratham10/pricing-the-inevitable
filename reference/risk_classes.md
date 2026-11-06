# The underwriting classes

Every newly underwritten life gets select mortality (q multiplied by 0.7
in the first year and 0.85 in the second). The class then adjusts
mortality: Preferred multiplies q by 0.75, Smoker multiplies q by 1.8,
and Rated adds a flat 0.005 to the force of mortality.

## Usage

``` r
risk_classes()
```

## Value

A data frame with each class, its extra-risk method and its value.
