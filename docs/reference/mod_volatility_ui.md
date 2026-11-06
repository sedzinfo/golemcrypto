# Volatility module - UI

For the coin selected in the Timeseries tab: three cards that say in
words whether the volatility of the last month and the move of the last
days are normal, and what the next days may bring, a button that
downloads the daily data behind them as CSV, and the volatility chart.

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
