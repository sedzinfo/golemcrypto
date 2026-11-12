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
#> [1] "35.8% a year, against 44.4% in the year before and a median of 55.8% for all 30-day periods since 2013: the 17th percentile."           
#> [2] "No significant difference from the year before (variance ratio 0.65, p = 0.92 and 0.24)."                                               
#> [3] "The largest day, 5 Nov (−5.55%), was 2.5 standard deviations of the year before: common, as days that large come about 11 times a year."
#> [4] "The return of the 30 days, −9.5%, is in the 24th percentile of all 30-day periods: an ordinary month."                                  
#> 
#> 
#> $recent
#> $recent$headline
#> [1] "Last 2 days: −1.7% together, a normal fall"
#> 
#> $recent$points
#> [1] "Day by day: 10 Nov −2.00%, 11 Nov +0.33%."                                                                                                                                                                     
#> [2] "Since 2013, 2-day moves this large came about 98 times a year (the 27th percentile)."                                                                                                                          
#> [3] "Against the volatility of the year before, the move is −0.5 standard deviations, which came about 76 times a year."                                                                                            
#> [4] "A GARCH model fitted to the 4 years before saw −0.8 and +0.1 standard deviations (−0.5 together), given the volatility it expected: about 1 in 4 days. The days went opposite ways, so they partly cancel out."
#> [5] "The most extreme single day, 10 Nov (−2.00%), was −0.8 standard deviations: a normal fall, about 1 in 8 days (about 46 times a year)."                                                                         
#> [6] "Volume: 10 Nov $27.8bn and 11 Nov $23.5bn, 1.1 and 0.9 times the median of the 30 days before; 11 Nov is normal for the coin, as volume that far below its month came about 124 times a year."                 
#> 
#> 
#> $forecast
#> $forecast$headline
#> [1] "Expected move on 12 Nov (95% range): −4.3% to +4.6%"
#> 
#> $forecast$points
#> [1] "Over the next 7 days, to 18 Nov (95% range): −11.2% to +13.3%, a close between $65,715 and $83,821."                                               
#> [2] "The model expects the volatility on 12 Nov to be 41% below its long-run level of the last 4 years: it should rise towards it, half-way in 75 days."
#> [3] "Value at risk: on 1 day in 20, the loss on 12 Nov would exceed 3.2%, and average 5.1% on those days (the 95% VaR and expected shortfall)."         
#> [4] "In the last year, the worst 5% of days lost at least 3.4%, and 5.1% on average."                                                                   
#> [5] "Check: losses beyond the model's daily VaR came on 16 of the last 365 days (4.4%), in line with the 5% expected (Kupiec test p = 0.58)."           
#> 
#> 
```
