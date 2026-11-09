# The groups of a seasonality analysis, as one table

The table behind the CSV button of the Seasonality tab.

## Usage

``` r
seasonality_csv(analysis)
```

## Arguments

- analysis:

  The result of
  [`seasonality_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/seasonality_analysis.md).

## Value

The `groups` of the analysis, with the period in front and the group
column named after the period, such as `month`.

## Examples

``` r
btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
golemcrypto:::seasonality_csv(seasonality_analysis(btc, "month"))
#>    month returns   mean_pct median_pct   up_pct   best_pct worst_pct
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
```
