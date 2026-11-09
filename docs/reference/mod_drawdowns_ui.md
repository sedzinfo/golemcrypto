# Drawdowns module - UI

For the coin selected in the Timeseries tab: a choice of the smallest
fall to list, a button that downloads the falls as CSV, the drawdown
chart, the table of the falls, and under it two cards that say in words
how far the coin is below its all-time high and how that compares with
its earlier falls.

## Usage

``` r
mod_drawdowns_ui(id)
```

## Arguments

- id:

  Character. Module namespace id.

## Value

A `tagList` of Shiny UI elements.

## Examples

``` r
if (FALSE) { # \dontrun{
shiny::fluidPage(golemcrypto:::mod_drawdowns_ui("drawdowns"))
} # }
```
