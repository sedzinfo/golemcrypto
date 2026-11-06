# Volatility module - server

Analyses the price history of the coin selected in the Timeseries tab
with
[`volatility_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/volatility_analysis.md),
once per coin, and shows it in words and as a chart. The CSV file, named
like `bitcoin-btc-volatility-2026-11-06.csv`, holds
[`volatility_csv()`](https://sedzinfo.github.io/golemcrypto/reference/volatility_csv.md):
a row per day, the days of the forecast included.

## Usage

``` r
mod_volatility_server(id, history, dark_mode)
```

## Arguments

- id:

  Character. Module namespace id, must match the id used in
  [`mod_volatility_ui()`](https://sedzinfo.github.io/golemcrypto/reference/mod_volatility_ui.md).

- history:

  Reactive returning the price history of the selected coin, from
  [`mod_timeseries_server()`](https://sedzinfo.github.io/golemcrypto/reference/mod_timeseries_server.md).

- dark_mode:

  Reactive returning `"light"` or `"dark"`, the mode of the app.

## Value

None. Called for its side effect of registering the module server.

## Examples

``` r
if (FALSE) { # \dontrun{
# inside app_server():
function(input, output, session) {
  dark_mode <- reactive(input$dark_mode)
  history <- mod_timeseries_server("timeseries", coins, dark_mode)
  mod_volatility_server("volatility", history, dark_mode)
}
} # }
```
