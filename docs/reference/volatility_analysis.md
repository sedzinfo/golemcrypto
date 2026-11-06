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
#>         date return_pct   garch_z one_in_days      volume volume_ratio volume_one_in_days
#> 1 2026-11-04   3.956612  1.707661    32.41037 40881988659     1.642935           8.925573
#> 2 2026-11-05  -5.550836 -2.299618    69.06806 48407763452     1.945375          15.234528
analysis$forecast$days
#>         date    sigma      low   low_50   median  high_50     high
#> 1 2026-11-06 3.028457 71812.70 74940.07 75976.19 77026.63 80381.05
#> 2 2026-11-07 3.041512 70249.07 74447.70 76000.15 77617.44 82308.00
#> 3 2026-11-08 3.053994 68992.06 74056.90 76027.99 78066.46 83944.18
#> 4 2026-11-09 3.065930 68030.44 73771.04 76103.36 78490.85 85229.47
#> 5 2026-11-10 3.077346 67114.49 73501.29 76140.12 78840.72 86388.32
#> 6 2026-11-11 3.088267 66228.78 73250.13 76174.89 79172.76 87387.87
#> 7 2026-11-12 3.098717 65546.97 73067.49 76215.12 79476.53 88413.71
volatility_text(analysis)
#> $month
#> $month$headline
#> [1] "Volatility of the last 30 days: normal"
#> 
#> $month$points
#> [1] "37.5% a year, against 45.1% in the year before and a median of 55.8% for all 30-day periods since 2013: the 19th percentile."           
#> [2] "No significant difference from the year before (variance ratio 0.69, p = 0.88 and 0.57)."                                               
#> [3] "The largest day, 5 Nov (−5.55%), was 2.4 standard deviations of the year before: common, as days that large come about 11 times a year."
#> [4] "The return of the 30 days, −11.2%, is in the 21st percentile of all 30-day periods: an ordinary month."                                 
#> 
#> 
#> $recent
#> $recent$headline
#> [1] "Last 2 days: −1.8% together, a normal fall"
#> 
#> $recent$points
#> [1] "Day by day: 4 Nov +3.96%, 5 Nov −5.55%."                                                                                                                                                                       
#> [2] "Since 2013, 2-day moves this large came about 94 times a year (the 26th percentile)."                                                                                                                          
#> [3] "Against the volatility of the year before, the move is −0.6 standard deviations, which came about 70 times a year."                                                                                            
#> [4] "A GARCH model fitted to the 4 years before saw +1.7 and −2.3 standard deviations (−0.6 together), given the volatility it expected: about 1 in 5 days. The days went opposite ways, so they partly cancel out."
#> [5] "The most extreme single day, 5 Nov (−5.55%), was −2.3 standard deviations: an unusual fall, about 1 in 69 days (about 5.3 times a year)."                                                                      
#> [6] "Volume: 4 Nov $40.9bn and 5 Nov $48.4bn, 1.6 and 1.9 times the median of the 30 days before; 5 Nov is normal for the coin, as volume that far above its month came about 24 times a year."                     
#> 
#> 
#> $forecast
#> $forecast$headline
#> [1] "Expected move on 6 Nov (95% range): −5.4% to +5.8%"
#> 
#> $forecast$points
#> [1] "Over the next 7 days, to 12 Nov (95% range): −13.7% to +16.4%, a close between $65,547 and $88,414."                                             
#> [2] "The model expects the volatility on 6 Nov to be 9% below its long-run level of the last 4 years: it should rise towards it, half-way in 17 days."
#> [3] "Value at risk: on 1 day in 20, the loss on 6 Nov would exceed 4.1%, and average 6.5% on those days (the 95% VaR and expected shortfall)."        
#> [4] "In the last year, the worst 5% of days lost at least 3.4%, and 5.1% on average."                                                                 
#> [5] "Check: losses beyond the model's daily VaR came on 17 of the last 365 days (4.7%), in line with the 5% expected (Kupiec test p = 0.76)."         
#> 
#> 
```
