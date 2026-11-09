# Whether the differences could be chance, in words

Whether the differences could be chance, in words

## Usage

``` r
seasonality_chance_text(analysis)
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
golemcrypto:::seasonality_chance_text(seasonality_analysis(btc, "month"))
#> $headline
#> [1] "The differences between the months could well be chance (p = 0.35)"
#> 
#> $points
#> [1] "A Kruskal-Wallis test asks whether the returns of the months could all come from the same distribution: p = 0.35, so differences as large as these would turn up in about 35% of histories in which they did not matter."
#> [2] "The returns run from 1 May 2013 to 31 Oct 2026: 162 months, 13 to 14 per group."                                                                                                                                         
#> [3] "With 12 months to pick from, the best one looks good partly by luck, and a pattern of the past need not hold: the crypto market has changed a lot since 2013."                                                           
#> 
```
