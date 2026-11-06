# Volume of each day against the days before it

Each day's volume divided by the median volume of the `days` days before
it: 2 is twice the usual volume of the time, 0.5 half of it. The median
keeps a single busy day from raising the bar, and the ratio follows the
coin's volume as it grows over the years. Days without volume (0 or
missing, as 'CoinMarketCap' has for the earliest days of some coins) are
left out, and a day needs volume on two thirds of the days before it.

## Usage

``` r
volume_ratio(volume, days = 30)
```

## Arguments

- volume:

  Numeric vector of daily volumes, sorted by date.

- days:

  Number of days before each day to compare with.

## Value

A numeric vector as long as `volume`, `NA` where there is no ratio.

## Examples

``` r
golemcrypto:::volume_ratio(c(rep(100, 30), 300, 50), days = 30)
#>  [1]  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA 3.0 0.5
```
