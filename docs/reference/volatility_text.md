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
```
