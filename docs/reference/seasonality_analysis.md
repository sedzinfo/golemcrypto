# Seasonality analysis of a coin

Do some days of the week, weeks of the year, months or years of the
halving cycle bring better returns than others? The returns of the
complete periods (see
[`seasonal_returns()`](https://sedzinfo.github.io/golemcrypto/reference/seasonal_returns.md))
are summed up by group, and a Kruskal-Wallis test asks whether the
differences between the groups are larger than chance would give. The
test compares the ranks of the returns, so a few extreme months do not
decide it, but it takes the returns as independent, which crypto returns
are only roughly: calm and wild stretches come in runs.

## Usage

``` r
seasonality_analysis(history, period = c("day", "week", "month", "year"))
```

## Arguments

- history:

  Price history of one coin from
  [`get_history()`](https://sedzinfo.github.io/golemcrypto/reference/get_history.md),
  with all of it.

- period:

  `"day"`, `"week"`, `"month"` or `"year"`.

## Value

`NULL` when the history has no complete period with one before it, or a
list with:

- coin, period:

  What was analysed.

- returns:

  The returns of
  [`seasonal_returns()`](https://sedzinfo.github.io/golemcrypto/reference/seasonal_returns.md).

- groups:

  A row per group that has returns, in their natural order: `group`,
  `returns` (how many), `mean_pct`, `median_pct`, `up_pct` (the share of
  the returns above 0), `best_pct` and `worst_pct`.

- all:

  The same numbers for all the returns together, as a list.

- p_value:

  The p-value of the Kruskal-Wallis test, `NA` when fewer than two
  groups have returns, or no group has two.

## Examples

``` r
btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
analysis <- seasonality_analysis(btc, "month")
analysis$groups
#>    group returns   mean_pct median_pct   up_pct   best_pct worst_pct
#> 1    Jan      13 -0.2909088  0.6910592 53.84615  39.835567 -32.08346
#> 2    Feb      13  6.8058464 11.4810969 69.23077  43.716856 -33.81771
#> 3    Mar      13 -0.8480297 -2.1619465 46.15385  30.531110 -32.93329
#> 4    Apr      13  9.2210271  7.5802233 61.53846  34.477899 -17.18056
#> 5    May      14  9.2234063  3.3732947 50.00000  69.628819 -35.35456
#> 6    Jun      14 -1.5659196 -0.5140670 50.00000  26.713348 -37.76883
#> 7    Jul      14  7.7163080  8.1254476 71.42857  23.916334  -8.37172
#> 8    Aug      14  2.3174099 -7.1875290 35.71429  63.576829 -19.17934
#> 9    Sep      14 -2.4603540 -2.4092218 42.85714   7.392924 -19.00922
#> 10   Oct      14 17.5478457 12.9418542 71.42857  53.383459 -12.56590
#> 11   Nov      13 41.8265543  8.7832808 61.53846 453.642183 -36.41158
#> 12   Dec      13  4.0366002 -3.1921079 38.46154  47.773176 -33.23978
analysis$p_value
#> [1] 0.3450331
seasonality_text(analysis)
#> $groups
#> $groups$headline
#> [1] "Best month: November, mean +41.8%; worst: September, −2.5%"
#> 
#> $groups$points
#> [1] "November: mean +41.8%, median +8.8%, up 8 of 13 times (62%)."           "September: mean −2.5%, median −2.4%, up 6 of 14 times (43%)."          
#> [3] "All 162 months together: mean +7.7%, median +2.6%, up 54% of the time."
#> 
#> 
#> $chance
#> $chance$headline
#> [1] "The differences between the months could well be chance (p = 0.35)"
#> 
#> $chance$points
#> [1] "A Kruskal-Wallis test asks whether the returns of the months could all come from the same distribution: p = 0.35, so differences as large as these would turn up in about 35% of histories in which they did not matter."
#> [2] "The returns run from 1 May 2013 to 31 Oct 2026: 162 months, 13 to 14 per group."                                                                                                                                         
#> [3] "With 12 months to pick from, the best one looks good partly by luck, and a pattern of the past need not hold: the crypto market has changed a lot since 2013."                                                           
#> 
#> 
```
