# Falls of the price from its all-time high

Splits a price history into its falls, the drawdown episodes. A fall
starts on the last close at an all-time high, the peak, goes down to its
lowest close, the trough, and ends on the first close back at or above
the peak. The last fall is still going on when the price has not got
back to its high. The highs are those of the history given: for a coin
whose history starts after its real all-time high, the first fall starts
on the first day.

## Usage

``` r
drawdown_episodes(close, date, min_depth = 0)
```

## Arguments

- close:

  Numeric vector of close prices, sorted by date.

- date:

  Dates of the closes.

- min_depth:

  Smallest fall to keep, in percent below the peak: 20 keeps the falls
  that went at least 20% down. The default, 0, keeps them all.

## Value

A data frame with a row per fall, the deepest first: `peak_date` and
`peak_price`, `trough_date` and `trough_price`, `depth_pct` (from −100
to 0), `days_to_trough` (from the peak), `recovery_date` (`NA` while the
fall goes on), `days_to_recover` (from the trough), `days_total` (from
the peak to the recovery, or to the last date while the fall goes on)
and `ongoing`.

## Examples

``` r
drawdown_episodes(c(100, 120, 90, 130, 65, 70), as.Date("2026-01-01") + 0:5)
#>    peak_date peak_price trough_date trough_price depth_pct days_to_trough recovery_date days_to_recover days_total ongoing
#> 1 2026-01-04        130  2026-01-05           65       -50              1          <NA>              NA          2    TRUE
#> 2 2026-01-02        120  2026-01-03           90       -25              1    2026-01-04               1          2   FALSE
# only the falls of at least 40%
drawdown_episodes(c(100, 120, 90, 130, 65, 70), as.Date("2026-01-01") + 0:5, min_depth = 40)
#>    peak_date peak_price trough_date trough_price depth_pct days_to_trough recovery_date days_to_recover days_total ongoing
#> 1 2026-01-04        130  2026-01-05           65       -50              1          <NA>              NA          2    TRUE
```
