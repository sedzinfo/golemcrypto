# The group of each day in a calendar effect

Puts each day in or out of a calendar effect. Coins trade every day, so
the days are those of the calendar:

- turn:

  The turn of the month: the last day of a month and the first 3 of the
  next.

- santa:

  The Santa rally: the last 5 days of December, from the 27th, and the
  first 2 of January.

## Usage

``` r
effect_days(date, period = c("turn", "santa"))
```

## Arguments

- date:

  Dates.

- period:

  `"turn"` or `"santa"`.

## Value

A factor as long as `date`, the days in the effect first.

## Examples

``` r
days <- as.Date("2024-12-25") + 0:10
data.frame(days, group = golemcrypto:::effect_days(days, "santa"))
#>          days       group
#> 1  2024-12-25  Other days
#> 2  2024-12-26  Other days
#> 3  2024-12-27 Santa rally
#> 4  2024-12-28 Santa rally
#> 5  2024-12-29 Santa rally
#> 6  2024-12-30 Santa rally
#> 7  2024-12-31 Santa rally
#> 8  2025-01-01 Santa rally
#> 9  2025-01-02 Santa rally
#> 10 2025-01-03  Other days
#> 11 2025-01-04  Other days
```
