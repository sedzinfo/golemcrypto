# The seasonality analysis in words

Sentences built from the numbers of
[`seasonality_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/seasonality_analysis.md),
for the Seasonality tab: the best and the worst group, and whether the
differences between the groups could be chance.

## Usage

``` r
seasonality_text(analysis)
```

## Arguments

- analysis:

  The result of
  [`seasonality_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/seasonality_analysis.md).

## Value

A list with `groups` and `chance`, each with a `headline` and `points`,
a character vector of sentences.

## Examples

``` r
btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
seasonality_text(seasonality_analysis(btc, "day"))
#> $groups
#> $groups$headline
#> [1] "Best day: Monday, mean +0.55%; worst: Thursday, −0.03%"
#> 
#> $groups$points
#> [1] "Monday: mean +0.55%, median +0.23%, up 379 of 705 times (54%)."           "Thursday: mean −0.03%, median −0.07%, up 346 of 706 times (49%)."        
#> [3] "All 4,940 days together: mean +0.20%, median +0.10%, up 52% of the time."
#> 
#> 
#> $chance
#> $chance$headline
#> [1] "The differences between the days of the week could well be chance (p = 0.23)"
#> 
#> $chance$points
#> [1] "A Kruskal-Wallis test asks whether the returns of the days of the week could all come from the same distribution: p = 0.23, so differences as large as these would turn up in about 23% of histories in which they did not matter."
#> [2] "The returns run from 30 Apr 2013 to 7 Nov 2026: 4,940 days, 705 to 706 per group."                                                                                                                                                 
#> [3] "With 7 days of the week to pick from, the best one looks good partly by luck, and a pattern of the past need not hold: the crypto market has changed a lot since 2013."                                                            
#> 
#> 
```
