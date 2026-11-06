# Conditional variance of a GARCH(1,1) model

`variance(t) = omega + alpha * e(t-1)^2 + beta * variance(t-1)`, started
at `start`. Each day's variance depends only on the days before it, so
it is the variance the model expects for that day.

## Usage

``` r
garch_variance(e, omega, alpha, beta, start)
```

## Arguments

- e:

  Numeric vector of the returns minus their mean.

- omega, alpha, beta:

  The parameters of the model.

- start:

  The variance of the first day.

## Value

A numeric vector of variances, as long as `e`.

## Examples

``` r
golemcrypto:::garch_variance(c(1, -2, 0.5, 3), omega = 0.1, alpha = 0.1, beta = 0.8, start = 2)
#> [1] 2.000 1.800 1.940 1.677
```
