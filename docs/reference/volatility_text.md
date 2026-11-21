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
```
