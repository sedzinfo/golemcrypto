# Volatility analysis of a coin

Is the coin's recent volatility normal? The analysis looks at the daily
log returns, `log(close(t) / close(t-1))`, in two ways.

**The last month** (`month_days` days): its volatility, the standard
deviation of the daily returns times `sqrt(365)`, against the year
before it and against every past period of the same length; an F test
and the Fligner-Killeen test, which is robust to a few extreme days, of
whether its variance is larger than the year before; its largest daily
move, in standard deviations of the year before; and its return against
every past period of the same length.

**The last days** (`recent_days` days): their return against every past
period of as many days; the same, in standard deviations of the year
before; a GARCH(1,1) model with Student-t errors (see
[`garch_fit()`](https://sedzinfo.github.io/golemcrypto/reference/garch_fit.md)),
fitted to the `garch_years` years before them, which judges each day
against the volatility the model expected for it given the days before;
and each day's volume against the `month_days` days before it (see
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
  level = 0.95
)
```

## Arguments

- history:

  Price history of one coin from
  [`get_history()`](https://sedzinfo.github.io/golemcrypto/reference/get_history.md),
  sorted by date. The comparisons use the whole history, so pass all of
  it.

- month_days:

  Days in the month.

- recent_days:

  Days in the recent move.

- garch_years:

  Years of history to fit the GARCH model to.

- forecast_days:

  Days to forecast.

- level:

  Probability of the forecast ranges, and of the value at risk: 0.95 is
  the 95% range and the worst 5% of days.

## Value

`NULL` when the history is shorter than a year and a month, or the price
did not move at all in the year before the month or the last days,
otherwise a list with

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
  `volatility_month` (annualized, in percent), `garch_sigma` (the daily
  standard deviation the model expected, in percent), `garch_z` (the
  day's move in those standard deviations) and `garch_var` (the model's
  value at risk for the day, in percent);

- `settings`: `month_days`, `recent_days`, `garch_years`,
  `forecast_days` and `level`.

## Examples

``` r
btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
analysis <- volatility_analysis(btc)
analysis$month$level
#> [1] "normal"
analysis$recent$days
#>         date return_pct     garch_z one_in_days      volume volume_ratio volume_one_in_days
#> 1 2026-11-05  -5.550836 -2.28819054   67.726837 48407763452     1.945375          15.237785
#> 2 2026-11-06  -0.257033 -0.09944261    2.276274 29286736588     1.146985           2.848965
analysis$forecast$days
#>         date    sigma      low   low_50   median  high_50     high
#> 1 2026-11-07 2.904263 71781.08 74783.24 75782.42 76794.94 80006.80
#> 2 2026-11-08 2.921028 70202.28 74319.64 75808.18 77362.61 81937.23
#> 3 2026-11-09 2.936918 69095.59 73951.74 75829.09 77802.22 83359.83
#> 4 2026-11-10 2.951984 68123.88 73678.62 75889.19 78202.65 84608.42
#> 5 2026-11-11 2.966272 67340.91 73403.37 75926.57 78561.40 85897.56
#> 6 2026-11-12 2.979826 66473.72 73186.09 75930.28 78862.33 87037.65
#> 7 2026-11-13 2.992688 65856.21 72949.92 75983.90 79140.42 88051.90
volatility_text(analysis)
#> $month
#> $month$headline
#> [1] "Volatility of the last 30 days: normal"
#> 
#> $month$points
#> [1] "36.6% a year, against 45.1% in the year before and a median of 55.8% for all 30-day periods since 2013: the 18th percentile."           
#> [2] "No significant difference from the year before (variance ratio 0.66, p = 0.91 and 0.35)."                                               
#> [3] "The largest day, 5 Nov (−5.55%), was 2.4 standard deviations of the year before: common, as days that large come about 11 times a year."
#> [4] "The return of the 30 days, −9.0%, is in the 24th percentile of all 30-day periods: an ordinary month."                                  
#> 
#> 
#> $recent
#> $recent$headline
#> [1] "Last 2 days: −5.8% together, a normal fall"
#> 
#> $recent$points
#> [1] "Day by day: 5 Nov −5.55%, 6 Nov −0.26%."                                                                                                                                                  
#> [2] "Since 2013, 2-day moves this large came about 29 times a year (the 8th percentile)."                                                                                                      
#> [3] "Against the volatility of the year before, the move is −1.8 standard deviations, which came about 11 times a year."                                                                       
#> [4] "A GARCH model fitted to the 4 years before saw −2.3 and −0.1 standard deviations (−1.5 together), given the volatility it expected: about 1 in 25 days."                                  
#> [5] "The most extreme single day, 5 Nov (−5.55%), was −2.3 standard deviations: an unusual fall, about 1 in 68 days (about 5.4 times a year)."                                                 
#> [6] "Volume: 5 Nov $48.4bn and 6 Nov $29.3bn, 1.9 and 1.1 times the median of the 30 days before; 5 Nov is normal for the coin, as volume that far above its month came about 24 times a year."
#> 
#> 
#> $forecast
#> $forecast$headline
#> [1] "Expected move on 7 Nov (95% range): −5.2% to +5.6%"
#> 
#> $forecast$points
#> [1] "Over the next 7 days, to 13 Nov (95% range): −13.1% to +16.2%, a close between $65,856 and $88,052."                                              
#> [2] "The model expects the volatility on 7 Nov to be 10% below its long-run level of the last 4 years: it should rise towards it, half-way in 14 days."
#> [3] "Value at risk: on 1 day in 20, the loss on 7 Nov would exceed 3.9%, and average 6.2% on those days (the 95% VaR and expected shortfall)."         
#> [4] "In the last year, the worst 5% of days lost at least 3.4%, and 5.1% on average."                                                                  
#> [5] "Check: losses beyond the model's daily VaR came on 18 of the last 365 days (4.9%), in line with the 5% expected (Kupiec test p = 0.95)."          
#> 
#> 
```
