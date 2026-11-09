# First and last day of the period of each date

Weeks run from Monday to Sunday, as in ISO 8601. Weekdays are worked out
from the date itself, not from the names of the locale.

## Usage

``` r
period_bounds(date, period)
```

## Arguments

- date:

  Dates.

- period:

  `"day"`, `"week"`, `"month"` or `"year"`.

## Value

A list with the `start` and the `end` of the period of each date.

## Examples

``` r
golemcrypto:::period_bounds(as.Date(c("2024-02-14", "2024-12-31")), "week")
#> $start
#> [1] "2024-02-12" "2024-12-30"
#> 
#> $end
#> [1] "2024-02-18" "2025-01-05"
#> 
```
