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
#> 1 2026-11-18  -2.938148 -1.0479431   11.459243 30351320839     1.106065           2.541170
#> 2 2026-11-19  -1.723279 -0.6114166    5.274728 33464018146     1.215544           3.416606
analysis$forecast$days
#>         date    sigma      low   low_50   median  high_50     high
#> 1 2026-11-20 2.866157 58705.37 61124.76 61927.21 62740.20 65325.88
#> 2 2026-11-21 2.882526 57475.46 60720.04 61945.41 63212.15 66902.36
#> 3 2026-11-22 2.898657 56447.15 60402.76 61980.29 63568.43 68075.92
#> 4 2026-11-23 2.914553 55652.16 60167.63 62011.43 63909.53 69184.45
#> 5 2026-11-24 2.930221 54903.28 59927.30 62024.50 64196.13 70204.25
#> 6 2026-11-25 2.945666 54309.21 59733.46 62057.64 64462.89 71008.48
#> 7 2026-11-26 2.960892 53774.38 59563.72 62087.80 64700.58 71950.83
volatility_text(analysis)
#> $month
#> $month$headline
#> [1] "Volatility of the last 30 days: normal"
#> 
#> $month$points
#> [1] "44.1% a year, against 44.2% in the year before and a median of 55.7% for all 30-day periods since 2013: the 30th percentile."             
#> [2] "No significant difference from the year before (variance ratio 0.99, p = 0.48 and 0.65)."                                                 
#> [3] "The largest day, 14 Nov (−6.04%), was 2.7 standard deviations of the year before: common, as days that large come about 8.6 times a year."
#> [4] "The return of the 30 days, −25.4%, is in the 5th percentile of all 30-day periods: one of the most extreme months."                       
#> 
#> 
#> $recent
#> $recent$headline
#> [1] "Last 2 days: −4.6% together, a normal fall"
#> 
#> $recent$points
#> [1] "Day by day: 18 Nov −2.94%, 19 Nov −1.72%."                                                                                                                                                    
#> [2] "Since 2013, 2-day moves this large came about 40 times a year (the 11th percentile)."                                                                                                         
#> [3] "Against the volatility of the year before, the move is −1.4 standard deviations, which came about 19 times a year."                                                                           
#> [4] "A GARCH model fitted to the 4 years before saw −1.0 and −0.6 standard deviations (−1.2 together), given the volatility it expected: about 1 in 14 days."                                      
#> [5] "The most extreme single day, 18 Nov (−2.94%), was −1.0 standard deviations: a normal fall, about 1 in 11 days (about 32 times a year)."                                                       
#> [6] "Volume: 18 Nov $30.4bn and 19 Nov $33.5bn, 1.1 and 1.2 times the median of the 30 days before; 19 Nov is normal for the coin, as volume that far above its month came about 107 times a year."
#> 
#> 
#> $forecast
#> $forecast$headline
#> [1] "Expected move on 20 Nov (95% range): −5.2% to +5.5%"
#> 
#> $forecast$points
#> [1] "Over the next 7 days, to 26 Nov (95% range): −13.1% to +16.2%, a close between $53,774 and $71,951."                                               
#> [2] "The model expects the volatility on 20 Nov to be 34% below its long-run level of the last 4 years: it should rise towards it, half-way in 76 days."
#> [3] "Value at risk: on 1 day in 20, the loss on 20 Nov would exceed 3.9%, and average 6.1% on those days (the 95% VaR and expected shortfall)."         
#> [4] "In the last year, the worst 5% of days lost at least 3.5%, and 5.2% on average."                                                                   
#> [5] "Check: losses beyond the model's daily VaR came on 18 of the last 365 days (4.9%), in line with the 5% expected (Kupiec test p = 0.95)."           
#> 
#> 
# the volatility of the last week, and the move of the last day
volatility_text(volatility_analysis(btc, month_days = 7, recent_days = 1))$month$headline
#> [1] "Volatility of the last 7 days: normal"
```
