# Volatility module - UI

For the coin selected in the Timeseries tab: a choice of the days of the
volatility window and of the recent move, a button that downloads the
daily data behind them as CSV, the volatility chart, and under it three
cards that say in words whether the volatility of the window and the
recent move are normal, and what the next days may bring.

## Usage

``` r
mod_volatility_ui(id)
```

## Arguments

- id:

  Character. Module namespace id.

## Value

A `tagList` of Shiny UI elements.

## Examples

``` r
if (FALSE) { # \dontrun{
shiny::fluidPage(golemcrypto:::mod_volatility_ui("volatility"))
} # }
```
