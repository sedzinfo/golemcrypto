# Relative strength index of prices

J. Welles Wilder's RSI, from 0 to 100: the share of the average daily
rise in the average daily move,
`100 - 100 / (1 + average rise / average fall)`. The first averages are
the means of the rises and the falls of the first `days` days; after
that each day counts for `1 / days` of the average and the day before
for the rest, as Wilder smoothed them. Traders read above 70 as
overbought, a run up that may pause, and below 30 as oversold.

## Usage

``` r
rsi(close, days = 14)
```

## Arguments

- close:

  Numeric vector of close prices, sorted by date.

- days:

  Number of days of the averages, 14 by default.

## Value

A numeric vector as long as `close`, `NA` for the first `days` days, 100
when the coin only rose and 50 when it did not move.

## Examples

``` r
rsi(c(100, 101, 102, 101, 103, 104, 103, 105), days = 3)
#> [1]       NA       NA       NA 66.66667 83.33333 87.87879 62.36559 79.88506
```
