# Rolling sum and standard deviation

Right-aligned windows: the value of day t covers days t - width + 1 to
t, and the first `width - 1` days are `NA`. Computed from cumulative
sums, so a long history takes no time.

## Usage

``` r
rolling_sum(x, width)

rolling_sd(x, width)
```

## Arguments

- x:

  Numeric vector without `NA`.

- width:

  Number of days in each window.

## Value

A numeric vector as long as `x`.

## Examples

``` r
golemcrypto:::rolling_sum(1:5, 2)
#> [1] NA  3  5  7  9
golemcrypto:::rolling_sd(c(1, 3, 2, 5, 4), 3)
#> [1]       NA       NA 1.000000 1.527525 1.527525
```
