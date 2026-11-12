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
#> 1 2026-11-10 -1.9980882 -0.8447558    7.901172 27823310776    1.0906779           2.451832
#> 2 2026-11-11  0.3314509  0.1185734    2.334501 23451242490    0.8826546           2.934211
analysis$forecast$days
#>         date    sigma      low   low_50   median  high_50     high
#> 1 2026-11-12 2.382629 70764.44 73188.42 73995.48 74811.44 77374.05
#> 2 2026-11-13 2.403201 69494.20 72784.79 74031.60 75277.34 78888.80
#> 3 2026-11-14 2.423413 68515.65 72471.23 74048.99 75678.72 80033.30
#> 4 2026-11-15 2.443274 67717.56 72234.13 74101.73 76031.77 81194.31
#> 5 2026-11-16 2.462794 66945.39 72002.80 74131.72 76346.25 82147.79
#> 6 2026-11-17 2.481983 66324.46 71800.91 74172.05 76595.98 83071.94
#> 7 2026-11-18 2.500852 65714.61 71624.67 74192.27 76834.12 83820.93
volatility_text(analysis)
#> $month
#> $month$headline
#> [1] "Volatility of the last 30 days: normal"
#> 
#> $month$points
#> [1] "35.8% a year, against 44.4% in the year before and a median of 55.8% for all 30-day periods since 2013: the 17th percentile."           
#> [2] "No significant difference from the year before (variance ratio 0.65, p = 0.92 and 0.24)."                                               
#> [3] "The largest day, 5 Nov (−5.55%), was 2.5 standard deviations of the year before: common, as days that large come about 11 times a year."
#> [4] "The return of the 30 days, −9.5%, is in the 24th percentile of all 30-day periods: an ordinary month."                                  
#> 
#> 
#> $recent
#> $recent$headline
#> [1] "Last 2 days: −1.7% together, a normal fall"
#> 
#> $recent$points
#> [1] "Day by day: 10 Nov −2.00%, 11 Nov +0.33%."                                                                                                                                                                     
#> [2] "Since 2013, 2-day moves this large came about 98 times a year (the 27th percentile)."                                                                                                                          
#> [3] "Against the volatility of the year before, the move is −0.5 standard deviations, which came about 76 times a year."                                                                                            
#> [4] "A GARCH model fitted to the 4 years before saw −0.8 and +0.1 standard deviations (−0.5 together), given the volatility it expected: about 1 in 4 days. The days went opposite ways, so they partly cancel out."
#> [5] "The most extreme single day, 10 Nov (−2.00%), was −0.8 standard deviations: a normal fall, about 1 in 8 days (about 46 times a year)."                                                                         
#> [6] "Volume: 10 Nov $27.8bn and 11 Nov $23.5bn, 1.1 and 0.9 times the median of the 30 days before; 11 Nov is normal for the coin, as volume that far below its month came about 124 times a year."                 
#> 
#> 
#> $forecast
#> $forecast$headline
#> [1] "Expected move on 12 Nov (95% range): −4.3% to +4.6%"
#> 
#> $forecast$points
#> [1] "Over the next 7 days, to 18 Nov (95% range): −11.2% to +13.3%, a close between $65,715 and $83,821."                                               
#> [2] "The model expects the volatility on 12 Nov to be 41% below its long-run level of the last 4 years: it should rise towards it, half-way in 75 days."
#> [3] "Value at risk: on 1 day in 20, the loss on 12 Nov would exceed 3.2%, and average 5.1% on those days (the 95% VaR and expected shortfall)."         
#> [4] "In the last year, the worst 5% of days lost at least 3.4%, and 5.1% on average."                                                                   
#> [5] "Check: losses beyond the model's daily VaR came on 16 of the last 365 days (4.4%), in line with the 5% expected (Kupiec test p = 0.58)."           
#> 
#> 
# the volatility of the last week, and the move of the last day
volatility_text(volatility_analysis(btc, month_days = 7, recent_days = 1))$month$headline
#> [1] "Volatility of the last 7 days: normal"
```
