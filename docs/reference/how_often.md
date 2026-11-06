# How often something happens, in words

How often something happens, in words

## Usage

``` r
how_often(per_year)
```

## Arguments

- per_year:

  Times a year.

## Value

A character string such as "about 3 times a year" or "about once every 4
years".

## Examples

``` r
golemcrypto:::how_often(c(0, 0.25, 3))
#> [1] "never before in its history" "about once every 4.0 years"  "about 3.0 times a year"     
```
