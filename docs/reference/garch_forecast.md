# Forecast of a GARCH model for the next days

The variance the model expects for each of the next days, and the range
of the return from the last close to the end of each day. The variance
of the next day is known from the last day,
`omega + alpha * e^2 + beta * variance`, and later days fall back to the
long-run variance `omega / (1 - alpha - beta)` at the rate
`alpha + beta` a day. The range of the next day is exact, from the
Student-t distribution of the model; the ranges of the later days come
from `paths` simulated paths of the model, with a fixed seed so that
they do not change from one run to the next.

## Usage

``` r
garch_forecast(garch, e_last, variance_last, days, level, paths = 50000)
```

## Arguments

- garch:

  A model from
  [`garch_fit()`](https://sedzinfo.github.io/golemcrypto/reference/garch_fit.md).

- e_last:

  The last day's return minus `mu`, in percent.

- variance_last:

  The variance the model expected for the last day.

- days:

  Number of days to forecast.

- level:

  Probability of the range, such as 0.95.

- paths:

  Number of simulated paths.

## Value

A data frame with a row per day and the columns `day`, `sigma` (the
daily standard deviation the model expects, in percent) and the
quantiles of the log return from the last close, in percent: `low` and
`high` for the range of probability `level`, `low_50` and `high_50` for
the middle half, and `median`.

## Examples

``` r
garch <- list(mu = 0.05, omega = 0.4, alpha = 0.1, beta = 0.85, nu = 4)
golemcrypto:::garch_forecast(garch, e_last = -5, variance_last = 6, days = 7, level = 0.95)
#>   day    sigma        low    low_50     median  high_50      high
#> 1   1 2.828427  -5.502890 -1.431394 0.05000000 1.531394  5.602890
#> 2   2 2.828427  -7.774688 -2.097403 0.08561467 2.272838  7.924958
#> 3   3 2.828427  -9.519619 -2.609086 0.12640947 2.876574  9.759043
#> 4   4 2.828427 -10.899962 -3.002712 0.19307256 3.400057 11.381648
#> 5   5 2.828427 -12.130463 -3.350509 0.26002110 3.844832 12.667964
#> 6   6 2.828427 -13.212424 -3.681198 0.32123444 4.250505 13.923125
#> 7   7 2.828427 -14.333559 -3.958686 0.32850063 4.661422 14.862589
```
