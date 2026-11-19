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
#>         date  return_pct      garch_z one_in_days      volume volume_ratio volume_one_in_days
#> 1 2026-11-17  0.05875191  0.005872495    2.014649 34516876177     1.269612           3.905079
#> 2 2026-11-18 -2.93814808 -1.042695633   11.415478 30351320839     1.106065           2.542005
analysis$forecast$days
#>         date    sigma      low   low_50   median  high_50     high
#> 1 2026-11-19 2.924955 59674.95 62183.07 63013.23 63854.48 66538.26
#> 2 2026-11-20 2.941630 58401.23 61774.04 63032.07 64341.63 68078.73
#> 3 2026-11-21 2.958069 57375.96 61446.64 63051.09 64713.21 69442.10
#> 4 2026-11-22 2.974278 56560.84 61198.75 63114.77 65070.85 70473.61
#> 5 2026-11-23 2.990261 55823.03 60965.57 63142.59 65363.38 71400.16
#> 6 2026-11-24 3.006024 55075.36 60748.83 63168.15 65637.13 72273.95
#> 7 2026-11-25 3.021572 54529.33 60583.75 63201.90 65902.26 73072.94
volatility_text(analysis)
#> $month
#> $month$headline
#> [1] "Volatility of the last 30 days: normal"
#> 
#> $month$points
#> [1] "44.7% a year, against 44.2% in the year before and a median of 55.7% for all 30-day periods since 2013: the 31st percentile."             
#> [2] "No significant difference from the year before (variance ratio 1.02, p = 0.44 and 0.62)."                                                 
#> [3] "The largest day, 14 Nov (−6.04%), was 2.7 standard deviations of the year before: common, as days that large come about 8.6 times a year."
#> [4] "The return of the 30 days, −23.0%, is in the 6th percentile of all 30-day periods: a weak month."                                         
#> 
#> 
#> $recent
#> $recent$headline
#> [1] "Last 2 days: −2.9% together, a normal fall"
#> 
#> $recent$points
#> [1] "Day by day: 17 Nov +0.06%, 18 Nov −2.94%."                                                                                                                                                                    
#> [2] "Since 2013, 2-day moves this large came about 68 times a year (the 19th percentile)."                                                                                                                         
#> [3] "Against the volatility of the year before, the move is −0.9 standard deviations, which came about 42 times a year."                                                                                           
#> [4] "A GARCH model fitted to the 4 years before saw 0.0 and −1.0 standard deviations (−0.7 together), given the volatility it expected: about 1 in 6 days. The days went opposite ways, so they partly cancel out."
#> [5] "The most extreme single day, 18 Nov (−2.94%), was −1.0 standard deviations: a normal fall, about 1 in 11 days (about 32 times a year)."                                                                       
#> [6] "Volume: 17 Nov $34.5bn and 18 Nov $30.4bn, 1.3 and 1.1 times the median of the 30 days before; 17 Nov is normal for the coin, as volume that far above its month came about 93 times a year."                 
#> 
#> 
#> $forecast
#> $forecast$headline
#> [1] "Expected move on 19 Nov (95% range): −5.3% to +5.6%"
#> 
#> $forecast$points
#> [1] "Over the next 7 days, to 25 Nov (95% range): −13.4% to +16.0%, a close between $54,529 and $73,073."                                               
#> [2] "The model expects the volatility on 19 Nov to be 35% below its long-run level of the last 4 years: it should rise towards it, half-way in 81 days."
#> [3] "Value at risk: on 1 day in 20, the loss on 19 Nov would exceed 3.9%, and average 6.3% on those days (the 95% VaR and expected shortfall)."         
#> [4] "In the last year, the worst 5% of days lost at least 3.5%, and 5.2% on average."                                                                   
#> [5] "Check: losses beyond the model's daily VaR came on 18 of the last 365 days (4.9%), in line with the 5% expected (Kupiec test p = 0.95)."           
#> 
#> 
# the volatility of the last week, and the move of the last day
volatility_text(volatility_analysis(btc, month_days = 7, recent_days = 1))$month$headline
#> [1] "Volatility of the last 7 days: normal"
```
