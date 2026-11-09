# The best and the worst group in words

By the mean return, among the groups with at least half the returns of
the largest group: week 53, which only some years have, would otherwise
often come first or last by luck.

## Usage

``` r
seasonality_groups_text(analysis)
```

## Arguments

- analysis:

  The result of
  [`seasonality_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/seasonality_analysis.md).

## Value

A list with a `headline` and `points`.

## Examples

``` r
btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
golemcrypto:::seasonality_groups_text(seasonality_analysis(btc, "month"))
#> $headline
#> [1] "Best month: November, mean +41.8%; worst: September, −2.5%"
#> 
#> $points
#> [1] "November: mean +41.8%, median +8.8%, up 8 of 13 times (62%)."           "September: mean −2.5%, median −2.4%, up 6 of 14 times (43%)."          
#> [3] "All 162 months together: mean +7.7%, median +2.6%, up 54% of the time."
#> 
```
