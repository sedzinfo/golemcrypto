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
```
