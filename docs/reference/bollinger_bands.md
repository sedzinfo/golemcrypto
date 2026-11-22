# Bollinger bands of prices

John Bollinger's bands: the moving average of the last `days` closes
(see
[`moving_average()`](https://sedzinfo.github.io/golemcrypto/reference/moving_average.md)),
and `width` standard deviations of those closes above and below it. The
bands widen when the coin swings and narrow when it is calm; a close
outside them is far from its recent level. The standard deviation is
that of the closes in the window, divided by `days` and not `days - 1`,
as Bollinger defined it.

## Usage

``` r
bollinger_bands(close, days = 20, width = 2)
```

## Arguments

- close:

  Numeric vector of close prices, sorted by date.

- days:

  Number of days of the average, 20 by default.

- width:

  Number of standard deviations from the average to the bands, 2 by
  default.

## Value

A data frame as long as `close` with `middle`, `upper` and `lower`, `NA`
for the first `days - 1` days.

## Examples

``` r
bollinger_bands(c(10, 11, 12, 11, 10, 12, 14), days = 3)
#>     middle    upper     lower
#> 1       NA       NA        NA
#> 2       NA       NA        NA
#> 3 11.00000 12.63299  9.367007
#> 4 11.33333 12.27614 10.390524
#> 5 11.00000 12.63299  9.367007
#> 6 11.00000 12.63299  9.367007
#> 7 12.00000 15.26599  8.734014
```
