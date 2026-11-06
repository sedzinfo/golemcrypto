# Quantile of the Student-t distribution scaled to a variance of 1

Quantile of the Student-t distribution scaled to a variance of 1

## Usage

``` r
t_quantile(p, nu)
```

## Arguments

- p:

  Numeric vector of probabilities.

- nu:

  Degrees of freedom, above 2.

## Value

The quantiles, in standard deviations.

## Examples

``` r
golemcrypto:::t_quantile(c(0.025, 0.975), nu = 4)
#> [1] -1.963243  1.963243
```
