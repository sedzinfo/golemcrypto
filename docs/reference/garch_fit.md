# Fit a GARCH(1,1) model with Student-t errors

The model of daily volatility most used in finance: a day's return is
`mu + sigma(t) * z(t)`, where `z` follows a Student-t distribution
scaled to a variance of 1 and `sigma(t)^2` follows
[`garch_variance()`](https://sedzinfo.github.io/golemcrypto/reference/garch_variance.md).
The parameters are fitted by maximum likelihood with
[`stats::optim()`](https://rdrr.io/r/stats/optim.html), in a form that
keeps `omega` positive, `alpha` and `beta` positive with `alpha + beta`
below 1, and `nu` above 2.

## Usage

``` r
garch_fit(r)
```

## Arguments

- r:

  Numeric vector of daily returns, in percent.

## Value

A list with `mu`, `omega`, `alpha`, `beta`, `nu` and `start`, the
variance of the first day, or `NULL` when the fit fails.

## Examples

``` r
set.seed(1)
golemcrypto:::garch_fit(rnorm(1000, sd = 3))[c("alpha", "beta", "nu")]
#> $alpha
#> [1] 3.165167e-05
#> 
#> $beta
#> [1] 0.4641205
#> 
#> $nu
#> [1] 4557.462
#> 
```
