# Drawdowns module - server

Analyses the falls of the coin selected in the Timeseries tab from its
all-time high with
[`drawdown_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_analysis.md),
and shows them in words, as a chart and as a table. The CSV file, named
like `bitcoin-btc-drawdowns-2026-11-06.csv`, holds
[`drawdown_csv()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_csv.md):
a row per fall of the chosen size.

## Usage

``` r
mod_drawdowns_server(id, history, dark_mode)
```

## Arguments

- id:

  Character. Module namespace id, must match the id used in
  [`mod_drawdowns_ui()`](https://sedzinfo.github.io/golemcrypto/reference/mod_drawdowns_ui.md).

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
  mod_drawdowns_server("drawdowns", history, dark_mode)
}
} # }
```
