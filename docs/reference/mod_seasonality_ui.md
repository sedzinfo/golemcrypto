# Seasonality module - UI

For the coin selected in the Timeseries tab: a choice of the returns to
compare (days by day of the week, weeks by week of the year, months by
month or years by year of the halving cycle), a button that downloads
the numbers as CSV, two cards that name the best and the worst group and
say whether the differences could be chance, the seasonality chart and
the table of the groups.

## Usage

``` r
mod_seasonality_ui(id)
```

## Arguments

- id:

  Character. Module namespace id.

## Value

A `tagList` of Shiny UI elements.

## Examples

``` r
if (FALSE) { # \dontrun{
shiny::fluidPage(golemcrypto:::mod_seasonality_ui("seasonality"))
} # }
```
