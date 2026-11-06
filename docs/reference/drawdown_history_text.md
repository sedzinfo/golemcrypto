# The falls of the history in words

The falls of the history in words

## Usage

``` r
drawdown_history_text(analysis)
```

## Arguments

- analysis:

  The result of
  [`drawdown_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_analysis.md).

## Value

A list with a `headline` and `points`.

## Examples

``` r
btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
golemcrypto:::drawdown_history_text(drawdown_analysis(btc))
#> $headline
#> [1] "Since 29 Apr 2013: 15 falls of 20% or more"
#> 
#> $points
#> [1] "The deepest: −84.5%, from $1,151 on 4 Dec 2013 to $178.10 on 14 Jan 2015; the price was back at the high on 4 Jan 2017, 1,127 days after the peak."
#> [2] "The median fall: −34.8%, with the trough 67 days after the peak; the falls that ended got back to the high a median of 86 days after it."          
#> [3] "Of its 4,939 days, 75% closed 20% or more below the high so far, and 179 days set a new all-time high."                                            
#> 
```
