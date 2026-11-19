# The top 100 coins

The Top 100 and Treemap tabs of the [golemcrypto
app](https://sedzinfo-golemcrypto.share.connect.posit.cloud/) show the
coins with the largest market cap. In R,
[`get_listings()`](https://sedzinfo.github.io/golemcrypto/reference/get_listings.md)
downloads them,
[`plot_treemap()`](https://sedzinfo.github.io/golemcrypto/reference/plot_treemap.md)
draws the treemap and
[`listings_table()`](https://sedzinfo.github.io/golemcrypto/reference/listings_table.md)
shows the table.

## Set up an API key

The listings come from the CoinMarketCap API, which needs a free API
key. The price charts of [Price charts in
R](https://sedzinfo.github.io/golemcrypto/articles/golemcrypto.md) and
[Volatility, drawdowns and
seasonality](https://sedzinfo.github.io/golemcrypto/articles/analyses.md)
do not need one.

1.  Sign up at [coinmarketcap.com/api](https://coinmarketcap.com/api/)
    and copy your API key.
2.  Open your `.Renviron` file with
    [`usethis::edit_r_environ()`](https://usethis.r-lib.org/reference/edit.html).
3.  Add this line with your own key, save the file and restart R:

&nbsp;

    COINMARKETCAP_APIKEY=your-api-key

To use a key for the current R session only, set it with
[`Sys.setenv()`](https://rdrr.io/r/base/Sys.setenv.html):

``` r

Sys.setenv(COINMARKETCAP_APIKEY = "your-api-key")
```

Keep the key out of your scripts and out of Git: anyone who has it can
use your API credits.

## Download the listings

``` r

library(golemcrypto)
listings <- get_listings()
listings$time
#> [1] "2026-11-19 12:56:07 EET"
head(listings$data$name_symbol, 10)
#>  [1] "Bitcoin (BTC)"      "Ethereum (ETH)"     "Tether USDt (USDT)" "BNB (BNB)"          "USDC (USDC)"        "XRP (XRP)"          "Solana (SOL)"       "TRON (TRX)"         "Hyperliquid (HYPE)"
#> [10] "Zcash (ZEC)"
names(listings$data)
#>  [1] "name_symbol"                  "USD_price"                    "USD_volume_24h"               "USD_volume_change_24h"        "USD_percent_change_24h"       "USD_percent_change_7d"       
#>  [7] "USD_percent_change_30d"       "USD_percent_change_60d"       "USD_percent_change_90d"       "USD_market_cap"               "USD_market_cap_dominance"     "USD_fully_diluted_market_cap"
#> [13] "USD_last_updated"
```

`listings$data` has a row per coin, sorted by market cap, with the
price, the volume, the price changes from 24 hours to 90 days, the
market cap and the dominance, all in US dollars. `listings$time` is when
it was downloaded.

Each download uses one credit of your key.
[`get_listings()`](https://sedzinfo.github.io/golemcrypto/reference/get_listings.md)
downloads the listings at most once every 10 minutes, and in between it
returns the last download. When a download fails, `listings$problem`
says why, for example when the key has used up its credits.

## Treemap

[`plot_treemap()`](https://sedzinfo.github.io/golemcrypto/reference/plot_treemap.md)
draws a box per coin, sized by its market cap and colored from red to
green by its price change over 24 hours:

``` r

plot_treemap(listings$data)
```

## Table

[`listings_table()`](https://sedzinfo.github.io/golemcrypto/reference/listings_table.md)
shows the listings as a sortable table. Losses are shaded red and gains
green, more strongly the larger the change:

``` r

listings_table(listings$data)
```

Like the other charts,
[`plot_treemap()`](https://sedzinfo.github.io/golemcrypto/reference/plot_treemap.md)
takes `mode = "dark"` for a dark page, and
[`htmlwidgets::saveWidget()`](https://rdrr.io/pkg/htmlwidgets/man/saveWidget.html)
saves the treemap or the table as a web page.
