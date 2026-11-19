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
#> [1] "2026-11-19 12:33:47 EET"
head(listings$data[, c("name_symbol", "USD_price", "USD_percent_change_24h", "USD_market_cap")])
#>           name_symbol    USD_price USD_percent_change_24h USD_market_cap
#>                <char>        <num>                  <num>          <num>
#> 1:      Bitcoin (BTC) 6.376272e+04           -0.662035372   1.282497e+12
#> 2:     Ethereum (ETH) 1.803233e+03            0.205440606   2.204151e+11
#> 3: Tether USDt (USDT) 9.989683e-01            0.008377362   1.750653e+11
#> 4:          BNB (BNB) 5.898914e+02            0.154294349   7.757683e+10
#> 5:        USDC (USDC) 9.998201e-01            0.001723867   6.823068e+10
#> 6:          XRP (XRP) 9.802060e-01           -1.614150719   6.225936e+10
```

`listings$data` has a row per coin, sorted by market cap, with the
price, the volume, the price changes from 24 hours to 90 days, the
market cap and the dominance. `listings$time` is when it was downloaded.

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
