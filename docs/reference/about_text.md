# The text of the About tab

Reads `inst/app/about.md` and fills in how often the data are downloaded
again, so that the text follows `refresh_minutes`, `history_minutes` and
`coins_minutes`.

## Usage

``` r
about_text()
```

## Value

The Markdown text, as one string.

## Examples

``` r
cat(substr(golemcrypto:::about_text(), 1, 300))
#> Crypto Time Series Analyzer shows the prices of cryptocurrencies from <a href="https://coinmarketcap.com" target="_blank" rel="noopener">CoinMarketCap</a>, in US dollars. This page explains what each tab shows and how its numbers are calculated. The CSV button of each tab downloads the data behind i
```
