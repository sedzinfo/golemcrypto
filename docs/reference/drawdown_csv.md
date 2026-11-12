# The falls of a drawdown analysis, as one table

The table behind the CSV button of the Drawdowns tab.

## Usage

``` r
drawdown_csv(analysis)
```

## Arguments

- analysis:

  The result of
  [`drawdown_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_analysis.md).

## Value

The `episodes` of the analysis, with the depth renamed `fall_pct`.

## Examples

``` r
btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
head(golemcrypto:::drawdown_csv(drawdown_analysis(btc)))
#>   rank  peak_date peak_price trough_date trough_price  fall_pct days_to_trough recovery_date days_to_recover days_total ongoing
#> 1    1 2013-12-04    1151.17  2015-01-14      178.103 -84.52852            406    2017-01-04             721       1127   FALSE
#> 2    2 2017-12-16   19497.40  2018-12-15     3236.762 -83.39901            364    2020-11-30             716       1080   FALSE
#> 3    3 2021-11-08   67566.83  2022-11-21    15787.284 -76.63456            378    2024-03-04             469        847   FALSE
#> 4    4 2021-04-13   63503.46  2021-07-20    29807.348 -53.06185             98    2021-10-19              91        189   FALSE
#> 5    5 2025-10-06  124752.53  2026-06-30    58558.858 -53.05998            267          <NA>              NA        401    TRUE
#> 6    6 2013-04-29     144.54  2013-07-05       68.431 -52.65601             67    2013-10-15             102        169   FALSE
```
