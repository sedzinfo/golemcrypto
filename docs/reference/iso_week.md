# ISO 8601 week number of dates

Week 1 is the week, Monday to Sunday, with the first Thursday of the
year, so the last days of December can be in week 1 and the first days
of January in week 52 or 53 of the year before.

## Usage

``` r
iso_week(date)
```

## Arguments

- date:

  Dates.

## Value

Integers from 1 to 53.

## Examples

``` r
golemcrypto:::iso_week(as.Date(c("2021-01-03", "2024-01-01", "2024-12-30")))
#> [1] 53  1  1
```
