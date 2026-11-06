# How rare a volume is, in words

How rare a volume is, in words

## Usage

``` r
volume_verdict(one_in_days)
```

## Arguments

- one_in_days:

  A volume this far from usual comes about once in so many days.

## Value

"normal", "unusual", "rare" or "very rare", with the thresholds of
[`move_verdict()`](https://sedzinfo.github.io/golemcrypto/reference/move_verdict.md),
or `NA`.

## Examples

``` r
golemcrypto:::volume_verdict(c(10, 100, 1000, 5000))
#> [1] "normal"    "unusual"   "rare"      "very rare"
```
