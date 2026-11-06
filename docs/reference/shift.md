# Shift a vector later by some days

Shift a vector later by some days

## Usage

``` r
shift(x, days)
```

## Arguments

- x:

  A vector.

- days:

  Number of days.

## Value

`x` without its last `days` values, after `days` `NA`s, so that day t
holds the value of day t - days.

## Examples

``` r
golemcrypto:::shift(1:5, 2)
#> [1] NA NA  1  2  3
```
