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
