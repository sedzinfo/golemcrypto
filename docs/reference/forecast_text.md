# The forecast and the value at risk in words

The third card of the Volatility tab, see
[`volatility_text()`](https://sedzinfo.github.io/golemcrypto/reference/volatility_text.md).

## Usage

``` r
forecast_text(analysis, p_text)
```

## Arguments

- analysis:

  The result of
  [`volatility_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/volatility_analysis.md).

- p_text:

  Function that formats a p-value.

## Value

A list with a `headline` and `points`, a character vector of sentences.

## Examples

``` r
if (FALSE) { # \dontrun{
btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
golemcrypto:::forecast_text(volatility_analysis(btc), format)
} # }
```
