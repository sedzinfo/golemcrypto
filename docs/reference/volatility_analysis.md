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
#>         date    return_pct     garch_z one_in_days      volume volume_ratio volume_one_in_days
#> 1 2026-11-06 -0.2570329594 -0.09763982    2.270570 29286736588    1.1469851           2.849574
#> 2 2026-11-07  0.0008610965 -0.01557586    2.038979  9362321961    0.3666658         161.344828
analysis$forecast$days
#>         date    sigma      low   low_50   median  high_50     high
#> 1 2026-11-08 2.787915 71937.30 74823.29 75782.94 76754.91 79834.17
#> 2 2026-11-09 2.812751 70453.50 74376.58 75821.06 77300.01 81565.01
#> 3 2026-11-10 2.836043 69332.25 74012.67 75872.96 77726.78 83026.01
#> 4 2026-11-11 2.857898 68318.83 73734.67 75914.94 78138.77 84290.15
#> 5 2026-11-12 2.878419 67400.20 73481.18 75935.42 78470.57 85475.64
#> 6 2026-11-13 2.897694 66715.98 73276.22 75977.13 78774.51 86566.40
#> 7 2026-11-14 2.915809 66037.63 73067.24 75998.34 79070.80 87550.73
volatility_text(analysis)
#> $month
#> $month$headline
#> [1] "Volatility of the last 30 days: normal"
#> 
#> $month$points
#> [1] "36.1% a year, against 45.1% in the year before and a median of 55.8% for all 30-day periods since 2013: the 18th percentile."           
#> [2] "No significant difference from the year before (variance ratio 0.64, p = 0.93 and 0.21)."                                               
#> [3] "The largest day, 5 Nov (−5.55%), was 2.4 standard deviations of the year before: common, as days that large come about 11 times a year."
#> [4] "The return of the 30 days, −7.3%, is in the 27th percentile of all 30-day periods: an ordinary month."                                  
#> 
#> 
#> $recent
#> $recent$headline
#> [1] "Last 2 days: −0.3% together, a normal fall"
#> 
#> $recent$points
#> [1] "Day by day: 6 Nov −0.26%, 7 Nov 0.00%."                                                                                                                                                    
#> [2] "Since 2013, 2-day moves this large came about 155 times a year (the 43rd percentile)."                                                                                                     
#> [3] "Against the volatility of the year before, the move is −0.1 standard deviations, which came about 149 times a year."                                                                       
#> [4] "A GARCH model fitted to the 4 years before saw −0.1 and 0.0 standard deviations (−0.1 together), given the volatility it expected: about 1 in 2 days."                                     
#> [5] "The most extreme single day, 6 Nov (−0.26%), was −0.1 standard deviations: a normal fall, about 1 in 2 days (about 161 times a year)."                                                     
#> [6] "Volume: 6 Nov $29.3bn and 7 Nov $9.4bn, 1.1 and 0.4 times the median of the 30 days before; 7 Nov is unusual for the coin, as volume that far below its month came about 2.3 times a year."
#> 
#> 
#> $forecast
#> $forecast$headline
#> [1] "Expected move on 8 Nov (95% range): −5.0% to +5.4%"
#> 
#> $forecast$points
#> [1] "Over the next 7 days, to 14 Nov (95% range): −12.8% to +15.6%, a close between $66,038 and $87,551."                                              
#> [2] "The model expects the volatility on 8 Nov to be 13% below its long-run level of the last 4 years: it should rise towards it, half-way in 12 days."
#> [3] "Value at risk: on 1 day in 20, the loss on 8 Nov would exceed 3.8%, and average 6.0% on those days (the 95% VaR and expected shortfall)."         
#> [4] "In the last year, the worst 5% of days lost at least 3.4%, and 5.1% on average."                                                                  
#> [5] "Check: losses beyond the model's daily VaR came on 18 of the last 365 days (4.9%), in line with the 5% expected (Kupiec test p = 0.95)."          
#> 
#> 
# the volatility of the last week, and the move of the last day
volatility_text(volatility_analysis(btc, month_days = 7, recent_days = 1))$month$headline
#> [1] "Volatility of the last 7 days: elevated"
```
