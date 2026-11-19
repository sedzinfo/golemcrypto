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
```
