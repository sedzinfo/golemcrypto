# The top 100 coins

> This page was built without a CoinMarketCap API key, so the code is
> shown without its results.

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

[`Sys.setenv`](https://rdrr.io/r/base/Sys.setenv.html)`(``COINMARKETCAP_APIKEY ``=`` ``"your-api-key"``)`

Keep the key out of your scripts and out of Git: anyone who has it can
use your API credits.

## Download the listings

[`library`](https://rdrr.io/r/base/library.html)`(`[`golemcrypto`](https://sedzinfo.github.io/golemcrypto/)`)`` ``listings`` ``<-`` `[`get_listings`](https://sedzinfo.github.io/golemcrypto/reference/get_listings.md)`(``)`` ``listings``$``time`` `[`head`](https://rdrr.io/r/utils/head.html)`(``listings``$``data``$``name_symbol``, ``10``)`` `[`names`](https://rdrr.io/r/base/names.html)`(``listings``$``data``)`

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

[`plot_treemap`](https://sedzinfo.github.io/golemcrypto/reference/plot_treemap.md)`(``listings``$``data``)`

## Table

[`listings_table()`](https://sedzinfo.github.io/golemcrypto/reference/listings_table.md)
shows the listings as a sortable table. Losses are shaded red and gains
green, more strongly the larger the change:

[`listings_table`](https://sedzinfo.github.io/golemcrypto/reference/listings_table.md)`(``listings``$``data``)`

Like the other charts,
[`plot_treemap()`](https://sedzinfo.github.io/golemcrypto/reference/plot_treemap.md)
takes `mode = "dark"` for a dark page, and
[`htmlwidgets::saveWidget()`](https://rdrr.io/pkg/htmlwidgets/man/saveWidget.html)
saves the treemap or the table as a web page.
