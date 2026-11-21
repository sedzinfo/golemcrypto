# Volatility analysis of a coin

Is the coin's recent volatility normal? The analysis looks at the daily
log returns, `log(close(t) / close(t-1))`, in two ways.

**The last month** (`month_days` days, 30 by default): its volatility,
the standard deviation of the daily returns times `sqrt(365)`, against
the year before it and against every past period of the same length; an
F test and the Fligner-Killeen test, which is robust to a few extreme
days, of whether its variance is larger than the year before; its
largest daily move, in standard deviations of the year before; and its
return against every past period of the same length.

**The last days** (`recent_days` days): their return against every past
period of as many days; the same, in standard deviations of the year
before; a GARCH(1,1) model with Student-t errors (see
[`garch_fit()`](https://sedzinfo.github.io/golemcrypto/reference/garch_fit.md)),
fitted to the `garch_years` years before them, which judges each day
against the volatility the model expected for it given the days before;
and each day's volume against the `volume_days` days before it (see
[`volume_ratio()`](https://sedzinfo.github.io/golemcrypto/reference/volume_ratio.md)),
judged by how often the coin's volume was as far from usual.

**The next days** (`forecast_days` days): the same model, with its
variance brought up to the last day, forecasts the volatility and the
range of the price (see
[`garch_forecast()`](https://sedzinfo.github.io/golemcrypto/reference/garch_forecast.md)),
and gives the value at risk and the expected shortfall of the next day
(see
[`garch_risk()`](https://sedzinfo.github.io/golemcrypto/reference/garch_risk.md)).
A Kupiec test (see
[`kupiec_test()`](https://sedzinfo.github.io/golemcrypto/reference/kupiec_test.md))
checks how often the model's value at risk was exceeded over the last
year. The value at risk and expected shortfall of the last year's daily
returns are given without the model too.

## Usage

``` r
volatility_analysis(
  history,
  month_days = 30,
  recent_days = 2,
  garch_years = 4,
  forecast_days = 7,
  level = 0.95,
  volume_days = 30
)
```

## Arguments

- history:

  Price history of one coin from
  [`get_history()`](https://sedzinfo.github.io/golemcrypto/reference/get_history.md),
  sorted by date. The comparisons use the whole history, so pass all of
  it.

- month_days:

  Days of the volatility window, the "month": 30, or for example 7 for
  the last week or 90 for the last quarter.

- recent_days:

  Days in the recent move, such as 1 for the last day alone.

- garch_years:

  Years of history to fit the GARCH model to.

- forecast_days:

  Days to forecast.

- level:

  Probability of the forecast ranges, and of the value at risk: 0.95 is
  the 95% range and the worst 5% of days.

- volume_days:

  Days before each day whose median volume the day's volume is compared
  with.

## Value

`NULL` when the history is not longer than a year and the longer of
`month_days` and `recent_days`, or the price did not move at all in the
year before the month or the last days, otherwise a list with

- `coin`, `first_date` and `last_date`;

- `month`: a list of the month's measures, see the code;

- `recent`: a list of the measures of the last days, with a `days` data
  frame of each day's return, GARCH measures, `volume`, `volume_ratio`
  and `volume_one_in_days` (`NA` without volume);

- `garch`: the fitted model, or `NULL` when it could not be fitted or
  there are fewer than 500 days before the last days;

- `forecast`: `NULL` without a model, otherwise a list with `days`, a
  data frame with a row per day ahead: its `date`, `sigma` (the daily
  standard deviation the model expects, in percent) and the closes
  `low`, `low_50`, `median`, `high_50` and `high` of the ranges (see
  [`garch_forecast()`](https://sedzinfo.github.io/golemcrypto/reference/garch_forecast.md));
  `sigma` and `sigma_long_run`, the daily standard deviation expected
  for the next day and in the long run; `half_life`, the days for the
  volatility to get half-way back to the long run; `var` and `es`, the
  value at risk and expected shortfall of the next day; and `backtest`,
  the `days`, `exceedances` and `p_value` of the Kupiec test;

- `history_risk`: `var` and `es` of the daily returns of the last
  `days` (365) days, in percent;

- `series`: a data frame with a row per day and the columns `date`,
  `close`, `volume`, `return_pct`, `volume_ratio` (see
  [`volume_ratio()`](https://sedzinfo.github.io/golemcrypto/reference/volume_ratio.md)),
  `volatility_month` (of the `month_days` days up to the day,
  annualized, in percent), `garch_sigma` (the daily standard deviation
  the model expected, in percent), `garch_z` (the day's move in those
  standard deviations) and `garch_var` (the model's value at risk for
  the day, in percent);

- `settings`: `month_days`, `recent_days`, `garch_years`,
  `forecast_days`, `level` and `volume_days`.

## Examples

``` r
btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
analysis <- volatility_analysis(btc)
analysis$month$level
#> [1] "normal"
analysis$recent$days
#>         date return_pct    garch_z one_in_days      volume volume_ratio volume_one_in_days
#> 1 2026-11-19  -1.723279 -0.6126392    5.242241 33464018146     1.215544           3.414847
#> 2 2026-11-20  -5.012517 -1.8137774   37.017821 60703101498     2.192394          23.227723
analysis$forecast$days
#>         date    sigma      low   low_50   median  high_50     high
#> 1 2026-11-21 3.080894 55527.79 57997.16 58822.62 59659.83 62312.95
#> 2 2026-11-22 3.093037 54289.48 57586.96 58848.90 60122.08 63872.91
#> 3 2026-11-23 3.105008 53220.72 57264.95 58862.67 60515.02 65132.14
#> 4 2026-11-24 3.116808 52494.62 57028.68 58921.16 60837.40 66190.52
#> 5 2026-11-25 3.128442 51699.20 56786.55 58930.25 61139.49 67158.83
#> 6 2026-11-26 3.139912 51087.44 56610.04 58966.90 61404.17 68118.12
#> 7 2026-11-27 3.151222 50561.84 56423.79 58969.44 61641.13 68843.47
volatility_text(analysis)
#> $month
#> $month$headline
#> [1] "Volatility of the last 30 days: normal"
#> 
#> $month$points
#> [1] "45.6% a year, against 44.2% in the year before and a median of 55.7% for all 30-day periods since 2013: the 32nd percentile."             
#> [2] "No significant difference from the year before (variance ratio 1.06, p = 0.38 and 0.37)."                                                 
#> [3] "The largest day, 14 Nov (−6.04%), was 2.7 standard deviations of the year before: common, as days that large come about 8.6 times a year."
#> [4] "The return of the 30 days, −30.0%, is in the 3rd percentile of all 30-day periods: one of the most extreme months."                       
#> 
#> 
#> $recent
#> $recent$headline
#> [1] "Last 2 days: −6.6% together, an unusual fall"
#> 
#> $recent$points
#> [1] "Day by day: 19 Nov −1.72%, 20 Nov −5.01%."                                                                                                                                                   
#> [2] "Since 2013, 2-day moves this large came about 24 times a year (the 7th percentile)."                                                                                                         
#> [3] "Against the volatility of the year before, the move is −2.1 standard deviations, which came about 8.1 times a year."                                                                         
#> [4] "A GARCH model fitted to the 4 years before saw −0.6 and −1.8 standard deviations (−1.7 together), given the volatility it expected: about 1 in 32 days."                                     
#> [5] "The most extreme single day, 20 Nov (−5.01%), was −1.8 standard deviations: an unusual fall, about 1 in 37 days (about 9.9 times a year)."                                                   
#> [6] "Volume: 19 Nov $33.5bn and 20 Nov $60.7bn, 1.2 and 2.2 times the median of the 30 days before; 20 Nov is normal for the coin, as volume that far above its month came about 16 times a year."
#> 
#> 
#> $forecast
#> $forecast$headline
#> [1] "Expected move on 21 Nov (95% range): −5.6% to +6.0%"
#> 
#> $forecast$points
#> [1] "Over the next 7 days, to 27 Nov (95% range): −14.0% to +17.1%, a close between $50,562 and $68,843."                                               
#> [2] "The model expects the volatility on 21 Nov to be 25% below its long-run level of the last 4 years: it should rise towards it, half-way in 66 days."
#> [3] "Value at risk: on 1 day in 20, the loss on 21 Nov would exceed 4.2%, and average 6.6% on those days (the 95% VaR and expected shortfall)."         
#> [4] "In the last year, the worst 5% of days lost at least 3.5%, and 5.2% on average."                                                                   
#> [5] "Check: losses beyond the model's daily VaR came on 18 of the last 365 days (4.9%), in line with the 5% expected (Kupiec test p = 0.95)."           
#> 
#> 
# the volatility of the last week, and the move of the last day
volatility_text(volatility_analysis(btc, month_days = 7, recent_days = 1))$month$headline
#> [1] "Volatility of the last 7 days: normal"
```
