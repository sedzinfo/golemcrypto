# The current fall in words

The current fall in words

## Usage

``` r
drawdown_now_text(analysis)
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
golemcrypto:::drawdown_now_text(drawdown_analysis(btc))
#> $headline
#> [1] "Now: −39.3% from the all-time high, in its 5th deepest fall"
#> 
#> $points
#> [1] "The all-time high: $124,753 on 6 Oct 2025, 396 days ago. The lowest close since: $58,559 on 30 Jun 2026, −53.1%."                                                                                                
#> [2] "Back to the high takes a rise of +64.7% from the last close of $75,747."                                                                                                                                         
#> [3] "Earlier falls as deep as −53.1% or deeper: 4. They got back to their high 189 to 1,127 days (median 964) after the peak, and 91 to 721 days (median 592) after the trough. This fall has lasted 396 days so far."
#> 
```
