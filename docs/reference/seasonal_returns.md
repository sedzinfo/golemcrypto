# The return of each complete period of a coin

A period's return is its last close relative to the last close of the
period before, in percent, as in
[`monthly_returns()`](https://sedzinfo.github.io/golemcrypto/reference/monthly_returns.md).
Only complete periods count: the period and the one before must both
have a close on their last day. The first period, which has none before
it, the current one, which has not ended, and the periods next to
missing days are left out.

Each return is put in a group: the day of the week for days, the ISO
8601 week of the year for weeks (Monday to Sunday), the month for
months, and the year of the 4-year cycle of Bitcoin's halvings for
years. The halvings came in 2012, 2016, 2020 and 2024, so a year
divisible by 4 is a halving year and 2025 is "Halving + 1".

## Usage

``` r
seasonal_returns(history, period = c("day", "week", "month", "year"))
```

## Arguments

- history:

  Price history of one coin from
  [`get_history()`](https://sedzinfo.github.io/golemcrypto/reference/get_history.md),
  with `timestamp` and `close` columns.

- period:

  `"day"`, `"week"`, `"month"` or `"year"`.

## Value

A data frame with a row per complete period, the oldest first: `start`
and `end`, the first and last day of the period, `group`, a factor with
the groups in their natural order, and `return_pct`.

## Examples

``` r
history <- data.frame(
  timestamp = as.Date("2024-01-01") + 0:120,
  close = 100 * cumprod(c(1, rep(1.002, 120)))
)
seasonal_returns(history, "month")
#>        start        end group return_pct
#> 1 2024-02-01 2024-02-29   Feb   5.965362
#> 2 2024-03-01 2024-03-31   Mar   6.389647
#> 3 2024-04-01 2024-04-30   Apr   6.177292
head(seasonal_returns(history, "day"))
#>        start        end     group return_pct
#> 1 2024-01-02 2024-01-02   Tuesday        0.2
#> 2 2024-01-03 2024-01-03 Wednesday        0.2
#> 3 2024-01-04 2024-01-04  Thursday        0.2
#> 4 2024-01-05 2024-01-05    Friday        0.2
#> 5 2024-01-06 2024-01-06  Saturday        0.2
#> 6 2024-01-07 2024-01-07    Sunday        0.2
```
