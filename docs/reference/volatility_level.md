# Volatility level from its percentile

Volatility level from its percentile

## Usage

``` r
volatility_level(percentile)
```

## Arguments

- percentile:

  Where the volatility falls among all the coin's past periods of the
  same length, from 0 to 100.

## Value

"normal" below the 60th percentile, "elevated" to the 85th, "high" to
the 95th and "extreme" above it.

## Examples

``` r
golemcrypto:::volatility_level(c(40, 70, 90, 99))
#> [1] "normal"   "elevated" "high"     "extreme" 
```
