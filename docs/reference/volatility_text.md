# The volatility analysis in words

Sentences built from the numbers of
[`volatility_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/volatility_analysis.md),
for the Volatility tab.

## Usage

``` r
volatility_text(analysis)
```

## Arguments

- analysis:

  The result of
  [`volatility_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/volatility_analysis.md).

## Value

A list with `month`, `recent` and `forecast`, each with a `headline` and
`points`, a character vector of sentences.

## Examples

``` r
btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
volatility_text(volatility_analysis(btc))
#> $month
#> $month$headline
#> [1] "Volatility of the last 30 days: normal"
#> 
#> $month$points
#> [1] "44.3% a year, against 44.3% in the year before and a median of 55.7% for all 30-day periods since 2013: the 30th percentile."             
#> [2] "No significant difference from the year before (variance ratio 1.00, p = 0.47 and 0.87)."                                                 
#> [3] "The largest day, 14 Nov (−6.04%), was 2.7 standard deviations of the year before: common, as days that large come about 8.6 times a year."
#> [4] "The return of the 30 days, −20.3%, is in the 9th percentile of all 30-day periods: a weak month."                                         
#> 
#> 
#> $recent
#> $recent$headline
#> [1] "Last 2 days: +1.1% together, a normal rise"
#> 
#> $recent$points
#> [1] "Day by day: 15 Nov +1.84%, 16 Nov −0.69%."                                                                                                                                                                     
#> [2] "Since 2013, 2-day moves this large came about 139 times a year (the 62nd percentile)."                                                                                                                         
#> [3] "Against the volatility of the year before, the move is +0.3 standard deviations, which came about 113 times a year."                                                                                           
#> [4] "A GARCH model fitted to the 4 years before saw +0.6 and −0.2 standard deviations (+0.2 together), given the volatility it expected: about 1 in 3 days. The days went opposite ways, so they partly cancel out."
#> [5] "The most extreme single day, 15 Nov (+1.84%), was +0.6 standard deviations: a normal rise, about 1 in 5 days (about 74 times a year)."                                                                         
#> [6] "Volume: 15 Nov $39.8bn and 16 Nov $31.8bn, 1.6 and 1.2 times the median of the 30 days before; 15 Nov is normal for the coin, as volume that far above its month came about 49 times a year."                  
#> 
#> 
#> $forecast
#> $forecast$headline
#> [1] "Expected move on 17 Nov (95% range): −5.4% to +5.8%"
#> 
#> $forecast$points
#> [1] "Over the next 7 days, to 23 Nov (95% range): −13.8% to +16.5%, a close between $55,931 and $75,564."                                               
#> [2] "The model expects the volatility on 17 Nov to be 36% below its long-run level of the last 4 years: it should rise towards it, half-way in 87 days."
#> [3] "Value at risk: on 1 day in 20, the loss on 17 Nov would exceed 4.0%, and average 6.4% on those days (the 95% VaR and expected shortfall)."         
#> [4] "In the last year, the worst 5% of days lost at least 3.5%, and 5.2% on average."                                                                   
#> [5] "Check: losses beyond the model's daily VaR came on 18 of the last 365 days (4.9%), in line with the 5% expected (Kupiec test p = 0.95)."           
#> 
#> 
```
