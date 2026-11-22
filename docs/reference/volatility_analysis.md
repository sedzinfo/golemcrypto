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
#> 1 2026-11-20  -5.012517 -1.8067770   36.909810 60703101498     2.192394           23.23267
#> 2 2026-11-21   2.202607  0.6915258    6.074621 58412154472     2.109652           20.58333
analysis$forecast$days
#>         date    sigma      low   low_50   median  high_50     high
#> 1 2026-11-22 3.051407 56790.60 59287.42 60118.42 60961.08 63641.25
#> 2 2026-11-23 3.065145 55446.16 58872.21 60149.07 61440.97 65240.98
#> 3 2026-11-24 3.078693 54479.37 58547.04 60161.03 61822.96 66458.90
#> 4 2026-11-25 3.092053 53627.16 58313.16 60204.84 62172.71 67477.88
#> 5 2026-11-26 3.105229 52894.42 58064.16 60242.91 62470.33 68548.48
#> 6 2026-11-27 3.118226 52212.10 57877.77 60254.63 62732.29 69407.79
#> 7 2026-11-28 3.131046 51595.69 57707.20 60284.22 62964.09 70244.95
volatility_text(analysis)
#> $month
#> $month$headline
#> [1] "Volatility of the last 30 days: normal"
#> 
#> $month$points
#> [1] "46.4% a year, against 44.3% in the year before and a median of 55.7% for all 30-day periods since 2013: the 34th percentile."             
#> [2] "No significant difference from the year before (variance ratio 1.10, p = 0.34 and 0.48)."                                                 
#> [3] "The largest day, 14 Nov (−6.04%), was 2.7 standard deviations of the year before: common, as days that large come about 8.6 times a year."
#> [4] "The return of the 30 days, −26.1%, is in the 5th percentile of all 30-day periods: one of the most extreme months."                       
#> 
#> 
#> $recent
#> $recent$headline
#> [1] "Last 2 days: −2.9% together, a normal fall"
#> 
#> $recent$points
#> [1] "Day by day: 20 Nov −5.01%, 21 Nov +2.20%."                                                                                                                                                                     
#> [2] "Since 2013, 2-day moves this large came about 67 times a year (the 18th percentile)."                                                                                                                          
#> [3] "Against the volatility of the year before, the move is −0.9 standard deviations, which came about 41 times a year."                                                                                            
#> [4] "A GARCH model fitted to the 4 years before saw −1.8 and +0.7 standard deviations (−0.7 together), given the volatility it expected: about 1 in 6 days. The days went opposite ways, so they partly cancel out."
#> [5] "The most extreme single day, 20 Nov (−5.01%), was −1.8 standard deviations: an unusual fall, about 1 in 37 days (about 9.9 times a year)."                                                                     
#> [6] "Volume: 20 Nov $60.7bn and 21 Nov $58.4bn, 2.2 and 2.1 times the median of the 30 days before; 20 Nov is normal for the coin, as volume that far above its month came about 16 times a year."                  
#> 
#> 
#> $forecast
#> $forecast$headline
#> [1] "Expected move on 22 Nov (95% range): −5.5% to +5.9%"
#> 
#> $forecast$points
#> [1] "Over the next 7 days, to 28 Nov (95% range): −14.1% to +16.9%, a close between $51,596 and $70,245."                                               
#> [2] "The model expects the volatility on 22 Nov to be 28% below its long-run level of the last 4 years: it should rise towards it, half-way in 73 days."
#> [3] "Value at risk: on 1 day in 20, the loss on 22 Nov would exceed 4.1%, and average 6.5% on those days (the 95% VaR and expected shortfall)."         
#> [4] "In the last year, the worst 5% of days lost at least 3.5%, and 5.2% on average."                                                                   
#> [5] "Check: losses beyond the model's daily VaR came on 18 of the last 365 days (4.9%), in line with the 5% expected (Kupiec test p = 0.95)."           
#> 
#> 
# the volatility of the last week, and the move of the last day
volatility_text(volatility_analysis(btc, month_days = 7, recent_days = 1))$month$headline
#> [1] "Volatility of the last 7 days: normal"
```
