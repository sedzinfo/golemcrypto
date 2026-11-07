# The drawdown analysis in words

Sentences built from the numbers of
[`drawdown_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_analysis.md),
for the Drawdowns tab.

## Usage

``` r
drawdown_text(analysis)
```

## Arguments

- analysis:

  The result of
  [`drawdown_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_analysis.md).

## Value

A list with `now` and `history`, each with a `headline` and `points`, a
character vector of sentences.

## Examples

``` r
btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
drawdown_text(drawdown_analysis(btc))
#> $now
#> $now$headline
#> [1] "Now: −39.3% from the all-time high, in its 5th deepest fall"
#> 
#> $now$points
#> [1] "The all-time high: $124,753 on 6 Oct 2025, 396 days ago. The lowest close since: $58,559 on 30 Jun 2026, −53.1%."                                                                                                
#> [2] "Back to the high takes a rise of +64.7% from the last close of $75,747."                                                                                                                                         
#> [3] "Earlier falls as deep as −53.1% or deeper: 4. They got back to their high 189 to 1,127 days (median 964) after the peak, and 91 to 721 days (median 592) after the trough. This fall has lasted 396 days so far."
#> 
#> 
#> $history
#> $history$headline
#> [1] "Since 29 Apr 2013: 15 falls of 20% or more"
#> 
#> $history$points
#> [1] "The deepest: −84.5%, from $1,151 on 4 Dec 2013 to $178.10 on 14 Jan 2015; the price was back at the high on 4 Jan 2017, 1,127 days after the peak."
#> [2] "The median fall: −34.8%, with the trough 67 days after the peak; the falls that ended got back to the high a median of 86 days after it."          
#> [3] "Of its 4,940 days, 75% closed 20% or more below the high so far, and 179 days set a new all-time high."                                            
#> 
#> 
```
