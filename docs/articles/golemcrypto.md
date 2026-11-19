# Price charts in R

The charts of the [golemcrypto
app](https://sedzinfo-golemcrypto.share.connect.posit.cloud/) are also R
functions. Each one takes the prices you download with
[`get_history()`](https://sedzinfo.github.io/golemcrypto/reference/get_history.md)
and returns an interactive [plotly](https://plotly.com/r/) chart. Run it
in the console and the chart opens in the RStudio Viewer or your
browser. In an R Markdown or Quarto document it appears in the page.

This article shows the price charts. [Volatility, drawdowns and
seasonality](https://sedzinfo.github.io/golemcrypto/articles/analyses.md)
shows the charts of the analyses, and [The top 100
coins](https://sedzinfo.github.io/golemcrypto/articles/market.md) shows
the market treemap and table.

## Install and load the package

``` r

install.packages("golemcrypto", repos = c("https://sedzinfo.r-universe.dev", "https://cloud.r-project.org"))
```

``` r

library(golemcrypto)
```

The prices need no API key. They come from CoinMarketCap through the
crypto2 package.

## Find a coin

Coins are picked by their label, such as `"Bitcoin (BTC)"`.
[`get_coins()`](https://sedzinfo.github.io/golemcrypto/reference/get_coins.md)
lists all active coins, and its `name_symbol` column holds the labels:

``` r

coins <- get_coins()
head(coins$name_symbol)
#> [1] "Bitcoin (BTC)"   "Litecoin (LTC)"  "Namecoin (NMC)"  "Terracoin (TRC)" "Peercoin (PPC)"  "Novacoin (NVC)"
grep("^Ethereum", coins$name_symbol, value = TRUE)
#> [1] "Ethereum (ETH)"              "Ethereum Classic (ETC)"      "Ethereum Name Service (ENS)" "EthereumPoW (ETHW)"          "EthereumFair (ETHF)"
```

## Download the prices

[`get_history()`](https://sedzinfo.github.io/golemcrypto/reference/get_history.md)
downloads the daily prices of one or more coins from a start date on, a
year ago by default. CoinMarketCap’s data starts on 29 April 2013:

``` r

btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
tail(btc[, c("timestamp", "open", "high", "low", "close", "volume")])
#>       timestamp     open     high      low    close      volume
#> 4947 2026-11-13 71342.97 71428.53 67653.07 68249.27 42985296506
#> 4948 2026-11-14 68249.27 68377.54 63329.43 64128.05 44019244180
#> 4949 2026-11-15 64128.05 66055.10 62017.88 65305.06 39757267458
#> 4950 2026-11-16 65305.06 65604.60 63834.67 64855.84 31812410118
#> 4951 2026-11-17 64855.84 65365.13 63284.46 64893.95 34516876177
#> 4952 2026-11-18 64893.95 64928.80 62017.38 62987.27 30351320839
```

Each coin’s prices are kept on disk between R sessions. Later calls
download only the days since the last one, so they are fast.

## Candlestick chart

[`plot_timeseries()`](https://sedzinfo.github.io/golemcrypto/reference/plot_timeseries.md)
draws the daily open, high, low and close prices of one coin as candles,
with a line through the close and its 50- and 200-day moving averages.
The smaller charts underneath show the trading volume and the drawdown:
how far the price is below its all-time high so far.

``` r

plot_timeseries(btc)
```

Zoom with the range buttons (1 year, 6 months, 7 days, …) or the slider
under the chart. The Linear and Log buttons switch the axis of the
prices, and a click on a legend entry hides or shows that line.

The averages and the drawdown are calculated over the history you pass.
Pass all of it and zoom on the chart, rather than downloading a shorter
history.

Choose other moving averages with `averages`, or none with
`averages = NULL`. Leave out the drawdown chart with
`show_drawdown = FALSE`. A chart of the whole history is large, so this
one is not drawn here, to keep the page light:

``` r

plot_timeseries(btc, averages = c(20, 100), show_drawdown = FALSE)
```

## Compare coins

To compare several coins, download them together and pass them through
[`normalize_prices()`](https://sedzinfo.github.io/golemcrypto/reference/normalize_prices.md).
It starts every coin at 100 on the first date on which all of them have
data, so 150 means the price rose by half since that date:

``` r

history <- get_history(c("Bitcoin (BTC)", "Ethereum (ETH)", "Solana (SOL)"))
prices <- normalize_prices(history)
tail(prices[, c("name_symbol", "timestamp", "close", "index")])
#>       name_symbol  timestamp    close    index
#> 1090 Solana (SOL) 2026-11-13 78.09609 57.10157
#> 1091 Solana (SOL) 2026-11-14 70.17686 51.31126
#> 1092 Solana (SOL) 2026-11-15 72.67892 53.14070
#> 1093 Solana (SOL) 2026-11-16 71.50532 52.28260
#> 1094 Solana (SOL) 2026-11-17 75.10517 54.91470
#> 1095 Solana (SOL) 2026-11-18 73.62283 53.83086
plot_compare(prices)
```

## Monthly returns

[`monthly_returns()`](https://sedzinfo.github.io/golemcrypto/reference/monthly_returns.md)
turns a coin’s prices into a matrix of returns in percent, with a row
per year and a column per month.
[`plot_returns_calendar()`](https://sedzinfo.github.io/golemcrypto/reference/plot_returns_calendar.md)
draws it as a heatmap, from red for falls to green for rises:

``` r

returns <- monthly_returns(btc)
tail(returns, 3)
#>         Jan    Feb   Mar    Apr   May    Jun  Jul   Aug  Sep   Oct    Nov   Dec
#> 2024   0.75  43.72 16.56 -15.00 11.30  -7.13 3.10 -8.74 7.39 10.87  37.36 -3.13
#> 2025   9.61 -17.61 -2.16  14.12 11.07   2.39 8.05 -6.50 5.38 -3.95 -17.49 -3.19
#> 2026 -10.16 -14.79  1.85  11.83 -3.57 -20.41 7.27 25.05 6.37 -7.32 -18.66    NA
plot_returns_calendar(returns, "Bitcoin (BTC)")
```

## Dark mode

Every chart function has a `mode` argument. `mode = "dark"` uses light
text and grid lines on a transparent background, for a page with a dark
background. On this page, which is light, its text would not show, so
the code is not run here:

``` r

plot_timeseries(btc, mode = "dark")
```

## Save or change a chart

The charts are plotly objects, so the functions of the plotly and
htmlwidgets packages work on them. To save a chart as a web page that
opens in any browser:

``` r

chart <- plot_compare(prices)
htmlwidgets::saveWidget(chart, "compare.html")
```

To change the layout, for example to add a title:

``` r

plotly::layout(chart, title = "Bitcoin, Ethereum and Solana over the last year")
```
